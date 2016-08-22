#!/usr/bin/python

import cbus
nodes=cbus.cbus_read_nodes('ipbus_test.xml')
ctrl=nodes['CTRLREG']
idreg=nodes['IDREG']
stat=nodes['STATREG']
l1set=nodes['LFSR1_SET']
l1shift=nodes['LFSR1_SHIFT']
l1read=nodes['LFSR1_READ']
l2set=nodes['LFSR2_SET']
l2shift=nodes['LFSR2_SHIFT']
l2read=nodes['LFSR2_READ']
cbus.bus_delay(250)
print hex(idreg.read())
print "Simulating the shift register"
l1set.write(1)
for i in range(0,10):
   print hex(l1read.read())
   l1shift.write(0)

