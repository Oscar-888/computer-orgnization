lui x31,0xFFFF0
main:
  lw    x6,0x004(x31)
  srli   x6,x6,10
  andi x6,x6,0x01F
  add x8,x6,x0
  add x7,x0,x0
  jal x5,n2
  sw x7,0x00C(x31)
  jal x0,main

n2: bge x0,x6,ret
      add x7,x7,x8
      addi x6,x6,-1
      jal x0,n2

ret: jalr x0,x5,0
      
