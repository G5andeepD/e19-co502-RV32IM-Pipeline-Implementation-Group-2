# Control Hazard (Branch Taken)
addi x1, x0, 1      # x1 = 1
addi x2, x0, 1      # x2 = 1
beq  x1, x2, label  # branch taken
addi x3, x0, 99     # should be flushed if branch taken
addi x5, x0, 88     # should be flushed if branch taken
addi x6, x0, 77     # should be flushed if branch taken
label:
addi x4, x0, 42     # x4 = 42 (should execute after branch) 