#!/usr/bin/python
f=open("/dev/my_bm0","r+b",0)
import struct
import mmap
import time
t1=time.time()
f.write(struct.pack("<q",100e6*2))
r=f.read(8)
t2=time.time()
print(t2-t1, struct.unpack("<q",r)[0]/100e6)
f.close()

