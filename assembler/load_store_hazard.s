# load_store_hazard.s
addi x1, x0, 40     # x1 = 40 (byte address for memory[10])
addi x4, x1, 16     # x4 = 56 (byte address for memory[14])
sw   x2, 0(x1)      # Store x2 to MEM[40] (memory[10])
lw   x3, 0(x1)      # Load MEM[40] into x3 (memory[10])
sw   x3, 0(x4)      # Store x3 to MEM[56] (memory[14])