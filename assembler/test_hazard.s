# Test program for hazard handling demonstration
# This program includes various hazard scenarios to test the pipeline


addi x1, x0, 10      # x1 = 10
addi x2, x0, 20      # x2 = 20
addi x3, x0, 30      # x3 = 30
addi x4, x0, 40      # x4 = 40
addi x5, x0, 50      # x5 = 50

# Phase 2: Test data hazards (RAW - Read After Write)
# Test 2.1: Simple data hazard - ADD x6, x1, x2 (x6 = 10 + 20 = 30)
add x6, x1, x2

# Test 2.2: Immediate data hazard - ADD x7, x6, x3 (x7 = 30 + 30 = 60)
add x7, x6, x3

# Test 2.3: Multiple data hazards - ADD x8, x7, x4 (x8 = 60 + 40 = 100)
add x8, x7, x4

# Test 2.4: Complex forwarding chain - ADD x9, x8, x5 (x9 = 100 + 50 = 150)
add x9, x8, x5

# Phase 3: Test load-use hazard
# Test 3.1: Load word from memory - LW x10, 0(x1) (load from address 10)
lw x10, 0(x1)

# Test 3.2: Use loaded value immediately - ADD x11, x10, x2 (should stall)
add x11, x10, x2

# Phase 4: Test arithmetic with immediate values
# Test 4.1: ADDI with data hazard - ADDI x12, x6, 100 (x12 = 30 + 100 = 130)
addi x12, x6, 100

# Test 4.2: ADDI with immediate hazard - ADDI x13, x12, 200 (x13 = 130 + 200 = 330)
addi x13, x12, 200

# Phase 5: Test complex forwarding scenarios
# Test 5.1: Multiple dependent operations
add x14, x9, x13     # x14 = 150 + 330 = 480
add x15, x14, x8     # x15 = 480 + 100 = 580
add x16, x15, x7     # x16 = 580 + 60 = 640

# Test 5.2: Self-referencing operations (complex forwarding)
add x17, x16, x16    # x17 = 640 + 640 = 1280
add x18, x17, x17    # x18 = 1280 + 1280 = 2560

# Phase 6: Test control hazards
# Test 6.1: Set up registers for branch comparison
addi x19, x0, 100    # x19 = 100
addi x20, x0, 100    # x20 = 100

# Test 6.2: Branch if equal - BEQ x19, x20, 8 (should branch)
beq x19, x20, branch_target

# Test 6.3: This instruction may be flushed if branch is taken
addi x21, x0, 999    # x21 = 999 (may be flushed)
    
branch_target:
    # Test 6.4: Target of branch
    addi x22, x0, 200    # x22 = 200
    
    # Phase 7: Test more complex scenarios
    # Test 7.1: Load and use in arithmetic
    lw x23, 4(x1)        # Load from address 14
    add x24, x23, x22    # x24 = loaded_value + 200
    
    # Test 7.2: Store operation
    sw x24, 8(x1)        # Store x24 to address 18
    
    # Test 7.3: Load from stored location
    lw x25, 8(x1)        # Load what we just stored
    add x26, x25, x1     # x26 = loaded_value + 10
    
    # Phase 8: Final calculations
    # Test 8.1: Use all accumulated values
    add x27, x26, x18    # x27 = x26 + 2560
    add x28, x27, x16    # x28 = x27 + 640
    add x29, x28, x9     # x29 = x28 + 150
    
    # Test 8.2: Final result
    add x30, x29, x5     # x30 = x29 + 50
    
    # End program
    j end_program
    
end_program:
    # Program ends here
    nop

# Expected behavior and register values:
# Phase 1: x1=10, x2=20, x3=30, x4=40, x5=50
# Phase 2: x6=30, x7=60, x8=100, x9=150 (data hazards resolved by forwarding)
# Phase 3: x10=loaded_value, x11=loaded_value+20 (load-use hazard, pipeline stalls)
# Phase 4: x12=130, x13=330 (immediate hazards resolved by forwarding)
# Phase 5: x14=480, x15=580, x16=640, x17=1280, x18=2560 (complex forwarding)
# Phase 6: x19=100, x20=100, x22=200 (control hazard, pipeline flushes)
# Phase 7: x23=loaded_value, x24=loaded_value+200, x25=loaded_value+200, x26=loaded_value+210
# Phase 8: x27=x26+2560, x28=x27+640, x29=x28+150, x30=x29+50 