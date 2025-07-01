# Expected Output for Hazard Handling Test

When you run the hazard handling test, you should see detailed output in the terminal showing how hazards are detected and resolved. Here's what to look for:

## Test Scenarios and Expected Output

### 1. No Hazard Test

```
=== Test 1: No Hazard ===
=== Clock Cycle 4 ===
Instruction: 003100b3 (ADD R-type)
  rs1: x2, rs2: x3, rd: x1
Hazard Detection:
  rs1_id: x2, rs2_id: x3
  Forward rs1: None
  Forward rs2: None
Pipeline Control:
  Stall: 0, IF/ID Enable: 1, ID/EX Enable: 1, PC Enable: 1
  Flush IF/ID: 0, Flush ID/EX: 0
```

**Expected Behavior**: No hazards detected, pipeline runs normally.

### 2. Data Hazard Test (Forwarding)

```
=== Test 2: Data Hazard (Forwarding) ===
=== Clock Cycle 6 ===
Instruction: 00520033 (ADD R-type)
  rs1: x1, rs2: x5, rd: x4
Hazard Detection:
  rs1_id: x1, rs2_id: x5
  Forward rs1: EX Stage
  Forward rs2: None
  *** DATA HAZARD DETECTED - FORWARDING ACTIVATED ***
Pipeline Control:
  Stall: 0, IF/ID Enable: 1, ID/EX Enable: 1, PC Enable: 1
  Flush IF/ID: 0, Flush ID/EX: 0
```

**Expected Behavior**: Data hazard detected, forwarding from EX stage activated.

### 3. Load-Use Hazard Test (Stalling)

```
=== Test 3: Load-Use Hazard (Stalling) ===
=== Clock Cycle 8 ===
Instruction: 00930433 (ADD R-type)
  rs1: x6, rs2: x9, rd: x8
Hazard Detection:
  rs1_id: x6, rs2_id: x9
  Forward rs1: None
  Forward rs2: None
Pipeline Control:
  Stall: 1, IF/ID Enable: 0, ID/EX Enable: 0, PC Enable: 0
  Flush IF/ID: 0, Flush ID/EX: 0
  *** PIPELINE STALLED - Load-Use Hazard ***
```

**Expected Behavior**: Load-use hazard detected, pipeline stalled for one cycle.

### 4. Multiple Forwarding Test

```
=== Test 4: Multiple Forwarding ===
=== Clock Cycle 12 ===
Instruction: 010687b3 (ADD R-type)
  rs1: x13, rs2: x16, rd: x15
Hazard Detection:
  rs1_id: x13, rs2_id: x16
  Forward rs1: EX Stage
  Forward rs2: None
  *** DATA HAZARD DETECTED - FORWARDING ACTIVATED ***
Pipeline Control:
  Stall: 0, IF/ID Enable: 1, ID/EX Enable: 1, PC Enable: 1
  Flush IF/ID: 0, Flush ID/EX: 0
```

**Expected Behavior**: Multiple forwarding scenarios, data forwarded from different stages.

### 5. Complex Forwarding Chain Test

```
=== Test 5: Complex Forwarding Chain ===
=== Clock Cycle 16 ===
Instruction: 00940033 (ADD R-type)
  rs1: x6, rs2: x9, rd: x8
Hazard Detection:
  rs1_id: x6, rs2_id: x9
  Forward rs1: EX Stage
  Forward rs2: None
  *** DATA HAZARD DETECTED - FORWARDING ACTIVATED ***
Pipeline Control:
  Stall: 0, IF/ID Enable: 1, ID/EX Enable: 1, PC Enable: 1
  Flush IF/ID: 0, Flush ID/EX: 0
```

**Expected Behavior**: Complex forwarding chain with data from multiple stages.

### 6. Control Hazard Test (Branch)

```
=== Test 6: Control Hazard (Branch) ===
=== Clock Cycle 20 ===
Instruction: 015a09b3 (ADD R-type)
  rs1: x20, rs2: x21, rd: x19
Hazard Detection:
  rs1_id: x20, rs2_id: x21
  Forward rs1: None
  Forward rs2: None
Pipeline Control:
  Stall: 0, IF/ID Enable: 1, ID/EX Enable: 1, PC Enable: 1
  Flush IF/ID: 1, Flush ID/EX: 1
  *** PIPELINE FLUSHED - Control Hazard ***
```

**Expected Behavior**: Control hazard detected, pipeline flushed when branch is taken.

## Key Indicators of Proper Hazard Handling

### ✅ **Data Hazards Working Correctly**

- Look for "**_ DATA HAZARD DETECTED - FORWARDING ACTIVATED _**"
- Forward signals should show "EX Stage", "MA Stage", or "WB Stage"
- Pipeline should NOT stall (Stall: 0)

### ✅ **Load-Use Hazards Working Correctly**

- Look for "**_ PIPELINE STALLED - Load-Use Hazard _**"
- Pipeline control should show: Stall: 1, IF/ID Enable: 0, ID/EX Enable: 0, PC Enable: 0
- This should happen after a load instruction followed by an instruction using the loaded value

### ✅ **Control Hazards Working Correctly**

- Look for "**_ PIPELINE FLUSHED - Control Hazard _**"
- Pipeline control should show: Flush IF/ID: 1, Flush ID/EX: 1
- This should happen after branch/jump instructions

### ✅ **No False Positives**

- Instructions without dependencies should show "Forward rs1: None, Forward rs2: None"
- Pipeline should run normally (all enables = 1, no stalls or flushes)

## What Each Signal Means

### Hazard Detection Signals:

- **rs1_id, rs2_id**: Source register addresses being read
- **Forward rs1, Forward rs2**: Where to forward data from (None/EX/MA/WB)

### Pipeline Control Signals:

- **Stall**: 1 = pipeline stalled, 0 = normal operation
- **IF/ID Enable**: 1 = register updates, 0 = register holds value
- **ID/EX Enable**: 1 = register updates, 0 = register holds value
- **PC Enable**: 1 = PC updates, 0 = PC holds value
- **Flush IF/ID**: 1 = flush IF/ID register, 0 = normal operation
- **Flush ID/EX**: 1 = flush ID/EX register, 0 = normal operation

## Running the Test

### Windows:

```bash
cd cpu/hazard_handling
run_hazard_test.bat
```

### Linux/Mac:

```bash
cd cpu/hazard_handling
chmod +x run_hazard_test.sh
./run_hazard_test.sh
```

### Manual Compilation:

```bash
cd cpu/hazard_handling
iverilog -o hazard_test_with_print hazard_test_with_print.v ../cpu.v
vvp hazard_test_with_print
```

## Troubleshooting

### If you see compilation errors:

1. Make sure all Verilog files are in the correct locations
2. Check that Icarus Verilog is installed
3. Verify all include paths are correct

### If you don't see hazard detection:

1. Check that the CPU module has the monitoring outputs connected
2. Verify that the hazard detection unit is properly instantiated
3. Ensure the testbench is connecting to the correct signals

### If forwarding isn't working:

1. Check that the forwarding unit is properly connected
2. Verify that register addresses are being compared correctly
3. Ensure the hazard detection logic is working properly

The test should provide clear, detailed output showing exactly how each type of hazard is detected and resolved!
