target remote localhost:1234
#break *0x7e00
continue
info registers
#x/63xb 0x7e00
#continue
#x/63xb 0x0600
