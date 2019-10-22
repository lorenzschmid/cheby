from cheby.hdl.buses import name_to_busgen
from cheby.hdl.geninterface import GenInterface


class GenSubmap(GenInterface):
    def gen_ports(self):
        n = self.n
        busgroup = n.c_submap.get_extension('x_hdl', 'busgroup')
        n.h_busgen = name_to_busgen(n.c_submap.bus)
        n.h_busgen.gen_bus_slave(self.root, self.module, n.c_name + '_', n, busgroup)
