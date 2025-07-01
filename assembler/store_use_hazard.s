# Store-Use Hazard (Store followed by load from same address)
addi x1, x0, 0      # x1 = 0 (base address)
addi x2, x0, 55     # x2 = 55
sw   x2, 0(x1)      # MEM[x1] = x2
lw   x3, 0(x1)      # x3 = MEM[x1] (should get 55 if forwarding works) 