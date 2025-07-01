# Data Hazard (Register-Register Forwarding)
addi x1, x0, 5      # x1 = 5
addi x2, x0, 10     # x2 = 10
add  x3, x1, x2     # x3 = x1 + x2 = 15
add  x4, x3, x2     # x4 = x3 + x2 = 25 (x3 just written, needs forwarding) 