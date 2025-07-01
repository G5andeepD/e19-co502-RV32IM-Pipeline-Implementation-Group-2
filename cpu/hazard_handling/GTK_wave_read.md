To view your hazard handling test results in GTKWave, here's what you should display and check:

## �� **Opening the Waveform File**

1. **Open GTKWave**: `gtkwave hazard_test_with_print.vcd`
2. **Or drag and drop** the `.vcd` file into GTKWave

## 📊 **Key Signals to Display**

### **1. Top-Level Module (`hazard_test_with_print`)**
- **`clk`** - Clock signal (for timing reference)
- **`reset`** - Reset signal
- **`instr_if`** - Current instruction being fetched

### **2. CPU Instance (`cpu_inst`)**
- **`pc_out`** - Program counter value
- **`alu_result_ma`** - ALU result from MA stage
- **`mem_write_ma`, `mem_read_ma`** - Memory control signals

### **3. Hazard Handling Signals (Most Important!)**
- **`rs1_id`, `rs2_id`** - Source register addresses from ID stage
- **`forward_rs1`, `forward_rs2`** - Forwarding control signals
- **`stall_pipeline`** - Pipeline stall signal
- **`if_id_enable`, `id_ex_enable`, `pc_enable`** - Pipeline enable signals
- **`flush_if_id`, `flush_id_ex`** - Pipeline flush signals

### **4. Pipeline Stage Data**
- **`rs_data_forwarded_id`, `rt_data_forwarded_id`** - Forwarded register data
- **`dmem_data_in`** - Data going to memory
- **`dmem_data_out`** - Data from memory

## �� **What to Check in GTKWave**

### **1. Data Hazard Detection**
- **Look for**: `forward_rs1` or `forward_rs2` changing from `00` to `01`, `10`, or `11`
- **Expected**: When an instruction uses a register that was written by a previous instruction
- **Check**: The forwarding signals should activate immediately after the dependency is detected

### **2. Load-Use Hazard (Stalling)**
- **Look for**: `stall_pipeline` going high (`1`)
- **Expected**: After a load instruction (`lw`) followed by an instruction using the loaded register
- **Check**: When `stall_pipeline = 1`, you should see:
  - `if_id_enable = 0`
  - `id_ex_enable = 0` 
  - `pc_enable = 0`

### **3. Control Hazard (Flushing)**
- **Look for**: `flush_if_id` or `flush_id_ex` going high (`1`)
- **Expected**: After branch/jump instructions when the branch is taken
- **Check**: Pipeline registers should be cleared when flush signals are active

### **4. Pipeline Flow**
- **Look for**: Normal progression of instructions through pipeline stages
- **Expected**: Instructions should flow smoothly unless hazards occur
- **Check**: `pc_out` should increment normally (except during stalls)

## 📈 **How to Analyze the Waveform**

### **Step 1: Set Time Scale**
- Use the zoom controls to set an appropriate time scale
- Look for patterns over multiple clock cycles

### **Step 2: Identify Test Phases**
- **Test 1 (No Hazard)**: Look for normal pipeline operation
- **Test 2 (Data Hazard)**: Look for forwarding activation
- **Test 3 (Load-Use)**: Look for pipeline stalling
- **Test 4-5 (Multiple Forwarding)**: Look for complex forwarding patterns
- **Test 6 (Control Hazard)**: Look for pipeline flushing

### **Step 3: Verify Hazard Resolution**
- **Data Hazards**: Should be resolved in 1 cycle via forwarding
- **Load-Use Hazards**: Should stall for 1 cycle, then forward
- **Control Hazards**: Should flush pipeline when branch taken

## 🎨 **GTKWave Display Tips**

### **1. Color Coding**
- Use different colors for different signal types
- Hazard signals: Red/Orange
- Pipeline control: Blue/Green
- Data signals: Yellow/Purple

### **2. Signal Grouping**
- Group related signals together:
  - Hazard detection signals
  - Pipeline control signals
  - Data flow signals

### **3. Cursor Usage**
- Place cursors at key events (hazard detection, forwarding activation)
- Measure timing between events
- Verify signal relationships

## �� **Key Verification Points**

### **✅ Data Hazard Working**
- `forward_rs1` or `forward_rs2` ≠ `00` when dependency exists
- Pipeline continues normally (no stalls)

### **✅ Load-Use Hazard Working**
- `stall_pipeline = 1` after load instruction
- Pipeline enables go to `0` during stall
- Stall lasts exactly 1 cycle

### **✅ Control Hazard Working**
- `flush_if_id` or `flush_id_ex = 1` after branch
- Pipeline registers clear when flush active

### **✅ No False Positives**
- No unnecessary stalls or flushes
- Forwarding only when needed

## 📋 **Quick Checklist**

- [ ] Data hazards detected and forwarded
- [ ] Load-use hazards cause pipeline stalls
- [ ] Control hazards cause pipeline flushes
- [ ] Pipeline runs normally when no hazards
- [ ] Forwarding sources are correct (EX/MA/WB)
- [ ] Timing is correct (1 cycle for most hazards)

By following this guide, you'll be able to clearly see how your hazard handling implementation is working and verify that all types of hazards are being detected and resolved correctly!