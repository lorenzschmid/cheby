from cheby.hdl.elgen import ElGen
from cheby.hdltree import (HDLComment)
from cheby.hdl.buses import name_to_busgen


class GenInterface(ElGen):
    def __init__(self, root, module, n):
        self.root = root
        self.module = module
        self.n = n

    def gen_ports(self):
        # Generic submap.
        n = self.n
        busgroup = n.get_extension('x_hdl', 'busgroup')
        n.h_busgen = name_to_busgen(n.interface)
        n.h_busgen.gen_bus_slave(self.root, self.module, n.c_name + '_', n, busgroup)

    def gen_processes(self, ibus):
        n = self.n
        self.module.stmts.append(HDLComment('Interface {}'.format(n.c_name)))
        n.h_busgen.wire_bus_slave(self.root, self.module, n, ibus)

    def gen_read(self, s, off, ibus, rdproc):
        n = self.n
        n.h_busgen.read_bus_slave(self.root, s, n, rdproc, ibus, ibus.rd_dat)

    def gen_write(self, s, off, ibus, wrproc):
        n = self.n
        n.h_busgen.write_bus_slave(self.root, s, n, wrproc, ibus)
