"""Create HDL for a Cheby description.

   Handling of names:
   Ideally we'd like to generate an HDL design that is error free.  But in
   practice, there could be some errors due to name conflict.  We try to do
   our best...
   A user name (one that comes from the Cheby description) get always a suffix,
   so that there is no conflict with reserved words.  The suffixes are:
   _i/_o for ports
   _reg for register
   However, it is supposed that the user name is valid and unique according to
   the HDL.  So for VHDL generation, it must be unique using case insensitive
   comparaison.
   The _i/_o suffixes are also used for ports, so the ports of the bus can
   also have conflicts with user names.
"""
import functools
from cheby.hdltree import (HDLModule, HDLPackage,
                           HDLInterface, HDLInterfaceSelect, HDLInstance,
                           HDLPort, HDLSignal,
                           HDLAssign, HDLSync, HDLComb, HDLComment,
                           HDLSwitch, HDLChoiceExpr, HDLChoiceDefault,
                           HDLIfElse,
                           bit_1, bit_0, bit_x,
                           HDLAnd, HDLOr, HDLNot, HDLEq, HDLConcat,
                           HDLIndex, HDLSlice, HDLReplicate, Slice_or_Index,
                           HDLConst, HDLBinConst, HDLNumber, HDLBool, HDLParen)
import cheby.tree as tree
from cheby.layout import ilog2
from cheby.hdl.wbbus import WBBus
from cheby.hdl.ibus import Ibus, add_bus
from cheby.hdl.genreg import GenReg
from cheby.hdl.geninterface import GenInterface
from cheby.hdl.genmemory import GenMemory
from cheby.hdl.gensubmap import GenSubmap
from cheby.hdl.buses import name_to_busgen

def add_ports(root, module, node):
    """Create ports for a composite node."""
    for n in node.children:
        if isinstance(n, tree.Block):
            if n.children:
                # Recurse
                add_ports(root, module, n)
        elif isinstance(n, tree.Submap):
            if n.include is True:
                # Inline
                add_ports(root, module, n.c_submap)
            else:
                n.h_gen.gen_ports()
        elif isinstance(n, tree.Memory):
            n.h_gen.gen_ports()
        elif isinstance(n, tree.Reg):
            n.h_gen.gen_ports()
        else:
            raise AssertionError


def add_processes(root, module, ibus, node):
    """Create assignment from register to outputs."""
    for n in node.children:
        if isinstance(n, tree.Block):
            add_processes(root, module, ibus, n)
        elif isinstance(n, tree.Submap):
            if n.include is True:
                add_processes(root, module, ibus, n.c_submap)
            else:
                n.h_gen.gen_processes(ibus)
        elif isinstance(n, tree.Memory):
            n.h_gen.gen_processes(ibus)
        elif isinstance(n, tree.Reg):
            n.h_gen.gen_processes(ibus)
        else:
            raise AssertionError


def add_block_decoder(root, stmts, addr, children, hi, func, off):
    # :param hi: is the highest address bit to be decoded.
    debug = False
    if debug:
        print("add_block_decoder: hi={}, off={:08x}".format(hi, off))
        for i in children:
            print("{}: {:08x}, sz={:x}, al={:x}".format(
                i.name, i.c_abs_addr, i.c_size, i.c_align))
        print("----")
    if len(children) == 1:
        # If there is only one child, no need to decode anymore.
        el = children[0]
        if isinstance(el, tree.Reg):
            if hi == root.c_addr_word_bits:
                foff = off & (el.c_size - 1)
                if root.c_word_endian == 'big':
                    # Big endian
                    foff = el.c_size - root.c_word_size - foff
                else:
                    # Little endian
                    foff = foff
                func(stmts, el, foff * tree.BYTE_SIZE)
                return
            else:
                # Multi-word register - to be split, so decode more.
                maxsz = 1 << root.c_addr_word_bits
        else:
            func(stmts, el, 0)
            return
    else:
        # Will add a decoder for the maximum aligned child.
        maxsz = max([e.c_align for e in children])

    maxszl2 = ilog2(maxsz)
    assert maxsz == 1 << maxszl2
    mask = ~(maxsz - 1)
    assert maxszl2 < hi

    # Add a decoder.
    # Note: addr has a word granularity.
    sw = HDLSwitch(HDLSlice(addr, maxszl2, hi - maxszl2))
    stmts.append(sw)

    next_base = off
    while len(children) > 0:
        # Extract the first child.
        first = children.pop(0)
        l = [first]
        # Skip holes in address to be decoded.
        base = max(next_base, first.c_abs_addr & mask)
        next_base = base + maxsz
        if debug:
            print("hi={} szl2={} first: {:08x}, base: {:08x}, mask: {:08x}".
                  format(hi, maxszl2, first.c_abs_addr, base, mask))

        # Create a branch.
        ch = HDLChoiceExpr(HDLConst(base >> maxszl2, hi - maxszl2))
        sw.choices.append(ch)

        # Gather other children that are decoded in the same branch (same
        # base address)
        last = first
        while len(children) > 0:
            el = children[0]
            if (el.c_abs_addr & mask) != base:
                break
            if debug:
                print(" {} @ {:08x}".format(el.name, el.c_abs_addr))
            last = el
            l.append(el)
            children.pop(0)

        # If the block is larger than its alignment, re-decode it again.
        if ((last.c_abs_addr + last.c_size - 1) & mask) != base:
            children.insert(0, last)

        # Sub-decode gathered children.
        add_block_decoder(root, ch.stmts, addr, l, maxszl2, func, base)

    ch = HDLChoiceDefault()
    sw.choices.append(ch)
    func(ch.stmts, None, 0)


def gather_leaves(n):
    # Gather all elements that need to be decoded.
    if isinstance(n, tree.Reg):
        return [n]
    elif isinstance(n, tree.Submap):
        if n.include is True:
            return gather_leaves(n.c_submap)
        else:
            return [n]
    elif isinstance(n, tree.Memory):
        return [n]
    elif isinstance(n, (tree.Root, tree.Block)):
        r = []
        for e in n.children:
            r.extend(gather_leaves(e))
        return r
    else:
        raise AssertionError


def add_decoder(root, stmts, addr, n, func):
    """Call :param func: for each element of :param n:.  :param func: can also
       be called with None when a decoder is generated and could handle an
       address that has no corresponding children."""
    children = gather_leaves(root)
    children = sorted(children, key=lambda x: x.c_abs_addr)

    add_block_decoder(root, stmts, addr, children, ilog2(root.c_size), func, 0)


def add_read_mux_process(root, module, ibus):
    # Generate the read decoder.  This is a large combinational process
    # that mux the data and ack.
    # It can be combinational because the read address is stable until the
    # end of the access.
    module.stmts.append(HDLComment('Process for read requests.'))
    rd_adr = ibus.rd_adr
    rdproc = HDLComb()
    if rd_adr is not None:
        rdproc.sensitivity.append(rd_adr)
    rdproc.sensitivity.extend([ibus.rd_req])
    module.stmts.append(rdproc)

    # All the read are ack'ed (including the read to unassigned addresses).
    rdproc.stmts.append(HDLComment("By default ack read requests"))
    rdproc.stmts.append(HDLAssign(ibus.rd_dat,
                                  HDLReplicate(bit_x, root.c_word_bits)))

    def add_read(s, n, off):
        if n is not None:
            if isinstance(n, tree.Reg):
                s.append(HDLComment(n.c_name))
                n.h_gen.gen_read(s, off, ibus, rdproc)
            elif isinstance(n, tree.Submap):
                s.append(HDLComment("Submap {}".format(n.c_name)))
                n.h_gen.gen_read(s, off, ibus, rdproc)
            elif isinstance(n, tree.Memory):
                s.append(HDLComment("RAM {}".format(n.c_name)))
                n.h_gen.gen_read(s, off, ibus, rdproc)
            else:
                # Blocks have been handled.
                raise AssertionError
        else:
            s.append(HDLAssign(ibus.rd_ack, ibus.rd_req))

    stmts = []
    add_decoder(root, stmts, rd_adr, root, add_read)
    rdproc.stmts.extend(stmts)


def add_write_mux_process(root, module, ibus):
    # Generate the write decoder.  This is a large combinational process
    # that mux the acks and regenerate the requests.
    # It can be combinational because the read address is stable until the
    # end of the access.
    module.stmts.append(HDLComment('Process for write requests.'))
    wr_adr = ibus.wr_adr
    wrproc = HDLComb()
    if wr_adr is not None:
        wrproc.sensitivity.append(wr_adr)
    wrproc.sensitivity.extend([ibus.wr_req])
    module.stmts.append(wrproc)

    def add_write(s, n, off):
        if n is not None:
            if isinstance(n, tree.Reg):
                s.append(HDLComment(n.c_name))
                n.h_gen.gen_write(s, off, ibus, wrproc)
            elif isinstance(n, tree.Submap):
                s.append(HDLComment("Submap {}".format(n.c_name)))
                n.h_gen.gen_write(s, off, ibus, wrproc)
            elif isinstance(n, tree.Memory):
                s.append(HDLComment("RAM {}".format(n.c_name)))
                n.h_gen.gen_write(s, off, ibus, wrproc)
            else:
                # Blocks have been handled.
                raise AssertionError
        else:
            # By default, ack unknown requests.
            s.append(HDLAssign(ibus.wr_ack, ibus.wr_req))

    stmts = []
    add_decoder(root, stmts, wr_adr, root, add_write)
    wrproc.stmts.extend(stmts)


def set_gen(root, module, node):
    """Add the object to generate hdl"""
    for n in node.children:
        if isinstance(n, tree.Block):
            if n.children:
                # Recurse
                set_gen(root, module, n)
        elif isinstance(n, tree.Submap):
            if n.include is True:
                # Inline
                set_gen(root, module, n.c_submap)
            elif n.filename is None:
                n.h_gen = GenInterface(root, module, n)
            else:
                n.h_gen = GenSubmap(root, module, n)
        elif isinstance(n, tree.Memory):
            if n.interface is not None:
                n.c_addr_bits = ilog2(n.c_depth)
                n.c_width = n.c_elsize * tree.BYTE_SIZE
                n.h_gen = GenInterface(root, module, n)
            else:
                n.h_gen = GenMemory(root, module, n)
        elif isinstance(n, tree.Reg):
            n.h_gen = GenReg(root, module, n)
            pass
        else:
            raise AssertionError

def gen_hdl_header(root, ibus=None):
    # Note: also called from gen_gena_regctrl but without ibus.
    module = HDLModule()
    module.name = root.name

    # Create the bus
    root.h_busgen = name_to_busgen(root.bus)
    root.h_busgen.expand_bus(root, module, ibus)

    return module


def generate_hdl(root):
    ibus = Ibus()

    # Force the regeneration of wb package (useful only when testing).
    WBBus.wb_pkg = None

    module = gen_hdl_header(root, ibus)

    set_gen(root, module, root)

    # Add ports
    iogroup = root.get_extension('x_hdl', 'iogroup')
    if iogroup is not None:
        root.h_itf = HDLInterface('t_' + iogroup)
        module.global_decls.append(root.h_itf)
        grp = module.add_port_group(iogroup, root.h_itf, True)
        grp.comment = 'Wires and registers'
        root.h_ports = grp
    else:
        root.h_itf = None
        root.h_ports = module
    add_ports(root, module, root)

    if root.hdl_pipeline:
        ibus = ibus.pipeline(root, module, root.hdl_pipeline, '_d0')

    # Add internal processes + wires
    root.h_ram = None
    add_processes(root, module, ibus, root)

    # Address decoders and muxes.
    add_write_mux_process(root, module, ibus)
    add_read_mux_process(root, module, ibus)

    return module
