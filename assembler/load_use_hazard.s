# Load-Use Hazard (Stall Required)
addi x1, x0, 0      # x1 = 0 (base address)
lw   x2, 0(x1)      # x2 = MEM[x1]
add  x3, x2, x2     # x3 = x2 + x2 (needs value just loaded, should stall) 