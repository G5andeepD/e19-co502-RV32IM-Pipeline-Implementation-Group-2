# Load-Use Hazard (Stall Required)
addi x1, x0, 40     # x1 = 40 (byte address for memory[40])
lw   x2, 0(x1)      # Load MEM[40] into x2 (memory[40])
add  x3, x2, x2     # x3 = x2 + x2 (needs value just loaded, should stall) 