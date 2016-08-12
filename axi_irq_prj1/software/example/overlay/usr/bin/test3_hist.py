#!/usr/bin/python
f=open("/dev/my_bm0","r+b",0)
import struct
import mmap
import time
fr=open("results.txt","w")
n=0
while n<10000:
  t1=time.time()
  f.write(struct.pack("<q",100e6*0.01))
  r=f.read(8)
  t2=time.time()
  res=struct.unpack("<q",r)[0]/100e6
  print(t2-t1, res)
  fr.write(str(res)+"\n")
  n+=1
f.close()
fr.close()
