#!/usr/bin/python
f=open("/dev/ipb_0","r+b",0)
import struct
import mmap
import time
regs=mmap.mmap(f.fileno(),0x10,mmap.MAP_SHARED,mmap.ACCESS_WRITE,offset=0x000)

def set_val(mm,pos,val):
  s=struct.pack("<L",val)
  mm[(pos*4):((pos+1)*4)]=s

def fset_val(mm,pos,val):
  s=struct.pack("<L",val)
  mm.seek(pos*4,0)
  mm.write(s)

def get_val(mm,pos):
  s=mm[(pos*4):((pos+1)*4)]
  v=struct.unpack("<L",s)[0]
  return v

for i in range(0,4):
   print i, hex(get_val(regs,i))
#fset_val(regs,0xc,0x123456)
i=0
while 1:
   set_val(regs,1,i)
   i=(i+1)%8
   time.sleep(0.5)

