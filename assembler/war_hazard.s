# Write-After-Read (WAR) Hazard
addi x1, x0, 5      # x1 = 5
add  x2, x1, x1     # x2 = x1 + x1 = 10
addi x1, x0, 20     # x1 = 20 (should not affect previous add) 