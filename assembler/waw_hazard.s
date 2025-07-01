# Write-After-Write (WAW) Hazard
addi x1, x0, 5      # x1 = 5
addi x1, x1, 10     # x1 = x1 + 10 = 15 (should not get old value) 