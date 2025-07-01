"""
RISC-V Assembler Script
------------------------

Usage:
    python assembler.py -i <input_file.asm> [-o <output_file.bin>] [-d <output_directory>] [--hex]

Arguments:
    -i <input_file.asm>     Required. Path to the assembly source file.
    -o <output_file.bin>    Optional. Custom name for the output binary file. Default is based on input filename.
    -d <output_directory>   Optional. Directory to save the output file. Default is './output'.
    --hex                   Optional. Outputs instructions in hexadecimal format (1 line per instruction).
                            If omitted, outputs 4 lines of 8-bit binary strings per instruction (little-endian).

Description:
    - Reads a RISC-V assembly file and translates each instruction into its corresponding 32-bit machine code.
    - Handles labels, instruction formatting based on RV32IM CSV encoding (opcode, funct3, funct7, type).
    - Supports instruction types: R-Type, I-Type, S-Type, B-Type, U-Type, J-Type, NOP-type.
    - If --hex is provided, writes one hex line per instruction.
    - If --hex is not provided, writes 4 lines of 8-bit binary strings per instruction.
    - Pads the output file to 1024 bytes (if not using hex) with 'xxxxxxxx'.

Examples:
    python assembler.py -i program.asm
    python assembler.py -i program.asm --hex
    python assembler.py -i program.asm -o out.bin -d ./bin
    python assembler.py -i src.asm -d ../cpu/build --hex

Notes:
    - Ensure RV32IM.csv is in the same directory.
    - Labels in the assembly are resolved to byte offsets.
    - The output directory will be created if it does not exist.
"""



import sys
import csv
import os
import shutil

# instruction sets grouped by the type
inst_data = {}

argList = {'inp_file': '', 'out_file': '', 'out_dir': './output', 'hex': False}
argKeys = {'-i': 'inp_file', '-o': 'out_file', '-d': 'out_dir', '--hex': 'hex'}


# array to load the instructions
Instructions = []
# this dictionary is used to remember the position of the label
labelPosition = {}

# the instuction count the written to the file
inst_count = 0

FILE_SIZE = 1024

def format(numOfDigits, num):
    return str(num).zfill(numOfDigits)[:numOfDigits]

# instruction formatting structure
# loop through the instructions and do the nessary stuff
def formatInstructions(Instructions):
    index = 0
    for ins in Instructions:
        formatInstruction(ins, index)
        index += 1

# format the different types of instructions
def formatInstruction(ins, index):
    # final instruction
    finalIns = []
    # Remove comments first (anything after ';' or '#')
    if ';' in ins:
        ins = ins.split(';')[0]
    if '#' in ins:
        ins = ins.split('#')[0]
    tmp_split = ins.split()
    if len(tmp_split) == 0:  # Skip if instruction becomes empty after comment removal
        return
    instruction_name = tmp_split.pop(0)
    finalIns.append(instruction_name.upper())
    # spliting by the ','
    for tmp in tmp_split:
        # splitting by comma
        tmp_split_2 = tmp.split(',')
        tmp_split_2 = list(filter(lambda a: a != '', tmp_split_2))

        # segmented list before putting together
        segmented_list = []

        for item in tmp_split_2:
            tmpItem = item
            # removing letter x from registers
            if item.startswith('x') and item[1:].isdigit():
                item = item.replace('x', '')
            # identifyng the sections with brackets
            if '(' and ')' in item:
                # removing ) from the string
                item = item.replace(')', '')
                tmp_split_3 = item.split('(')
                tmp_split_3.reverse()
                # Remove 'x' from register names in bracket expressions
                for i, part in enumerate(tmp_split_3):
                    if part.startswith('x') and part[1:].isdigit():
                        tmp_split_3[i] = part.replace('x', '')
                segmented_list.extend(tmp_split_3)            
            # resolwing the labels into offsets
            elif tmpItem in labelPosition:
                # Calculate branch offset: (target_position - current_position - 1) * 4
                offset = (labelPosition[tmpItem] - index - 1) * 4
                segmented_list.append(offset)
            elif item.isdigit() or (item.startswith('-') and item[1:].isdigit()):
                # Handle immediate values (positive or negative integers)
                segmented_list.append(item)
            else:
                # If it's not a known label and not a number, it might be an unknown label
                print(f"Warning: Unknown label or invalid operand '{tmpItem}' at instruction {index}, skipping...")
                # Don't append anything to segmented_list for unknown labels

        finalIns.extend(segmented_list)

    #print(instruction_name, finalIns)
    
    # Handle J pseudoinstruction by converting to JAL x0, label
    if finalIns[0] == 'J' and len(finalIns) == 2:
        # Convert j label to jal x0, label
        finalIns = ['JAL', '0', finalIns[1]]
    
    handleInstruction(finalIns)

# read the csv and create the instruction data dictionary
def read_csv():
    # reading the csv file
    with open('RV32IM.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')

        for row in csv_reader:
            opcode = format(7, row[0])
            funct3 = format(3, row[1])
            funct7 = format(7, row[2])
            inst = row[3]
            _type = row[4]
            inst_data[inst] = {'opcode': opcode,
                               'funct3': funct3, 'funct7': funct7, 'type': _type}

# handling the separated instructions
def handleInstruction(separatedIns):
    Instruction = None
    space = '' # used to visualize the space in instruction in debug mode

    # handle R-Type instructions
    if(inst_data[separatedIns[0]]['type'] == "R-Type"):
        Instruction = inst_data[separatedIns[0]]['funct7'] + toBin(5, separatedIns[3]) + toBin(
            5, separatedIns[2]) + inst_data[separatedIns[0]]['funct3'] + toBin(5, separatedIns[1]) + inst_data[separatedIns[0]]['opcode']
        
    elif(inst_data[separatedIns[0]]['type'] == "I - Type "):
        Instruction = toBin(12, separatedIns[3]) + space + toBin(5, separatedIns[2]) + space + inst_data[separatedIns[0]]['funct3'] + space + toBin(5, separatedIns[1]) + space + inst_data[separatedIns[0]]['opcode']
        
        
    elif(inst_data[separatedIns[0]]['type'] == "S-Type"):
        # sw rs2:value, rs1:base,  immediate
        immediate = toBin(12, separatedIns[3])
        Instruction = immediate[:7] + space + toBin(5, separatedIns[1]) + space + toBin(5, separatedIns[2])+ space + inst_data[separatedIns[0]]['funct3']+ space + immediate[7:] + space + inst_data[separatedIns[0]]['opcode']
    
    elif(inst_data[separatedIns[0]]['type'] == "B-Type"):
        # beq rs1, rs2, label
        immediate = toBin(13, separatedIns[3])
        Instruction = immediate[0]+ space + immediate[2:8] + space + toBin(5, separatedIns[2])+ space + toBin(5, separatedIns[1]) + space + inst_data[separatedIns[0]]['funct3'] + space + immediate[8:12] + space + immediate[1] + space + inst_data[separatedIns[0]]['opcode'] 
    
    elif(inst_data[separatedIns[0]]['type'] == "U -Type"):
        # lui rd, immediate
        immediate = toBin(32, separatedIns[2])
        Instruction = immediate[0:20] + space + toBin(5, separatedIns[1]) + space + inst_data[separatedIns[0]]['opcode']

    elif(inst_data[separatedIns[0]]['type'] == "J-Type"):
        #jal rd, immediate
        immediate = toBin(21, separatedIns[2])
        Instruction = immediate[0] + space + immediate[10:20]+ space +immediate[9] + space + immediate[1:9] + space + toBin(5, separatedIns[1]) + space + inst_data[separatedIns[0]]['opcode']
        print(immediate, Instruction)

    elif(inst_data[separatedIns[0]]['type'] == "NOP-type"):
        Instruction = "0"*32

    print(separatedIns[0],separatedIns, Instruction, hex(int(Instruction, 2)))
    saveToFile(Instruction)

# taking the file name if passed as an argument
def handleArgs():
    n = len(sys.argv)
    for i in range(1, n):
        if sys.argv[i].strip() in argKeys:
            key = argKeys[sys.argv[i]]
            if key == 'hex':
                argList['hex'] = True
            else:
                argList[key] = sys.argv[i+1]



# opening the assemblyfile and reading through the file
def handleInpFile():
    global labelPosition

    if argList['inp_file'] == '':
        print('Input file not found')
        sys.exit(1)

    # opening the assembly file
    f = open(argList['inp_file'], "r")
    # line count for the instructions
    lineCount = 0
    # loop through the file and handle the instrctions separately
    for ins in f:
        # skipping enpty lines
        if ins.strip() == '':
            continue
        # skiping the comments (both ; and # style comments)
        elif ins.strip()[0] == ';' or ins.strip()[0] == '#':
            continue
        elif ins.strip()[-1] == ':':
            labelPosition[ins.strip()[:(len(ins.strip())-1)]] = lineCount
        else:
            Instructions.append(ins)
            lineCount += 1
        # handleInstruction(ins)

    # start the instruction formatting
    formatInstructions(Instructions)

# convert a given number to binary according to a given format
def toBin(numOfDigits, num):
    num = int(num)
    s = bin(num & int("1"*numOfDigits, 2))[2:]
    return ("{0:0>%s}" % (numOfDigits)).format(s)

# saving data to a .bin file
def saveToFile(line):
    global inst_count

    filename = argList['inp_file'].split('.')[0] + '.bin'
    if argList['out_file']:
        filename = argList['out_file']

    os.makedirs(argList['out_dir'], exist_ok=True)
    file = os.path.join(argList['out_dir'], filename)

    with open(file, "a") as f:
        if argList['hex']:
            # Convert binary string to hex string (8 hex chars = 32 bits)
            hex_line = f"{int(line, 2):08x}"
            f.write(hex_line + '\n')
        else:
            # Default: 4 lines of 8 bits each (little-endian)
            for i in range(3, -1, -1):
                f.write(line[(i*8):(i*8+8)] + "\n")

    inst_count += 1


# fillig the rest of the file 
def fillTheFile():
    global FILE_SIZE
    file = "../cpu/build/" + argList['inp_file'].split('.')[0] + '.bin'
    if not (argList['out_file'] == ''):
        file = "../cpu/build/" + argList['out_file']

    f = open(file, "a")
    for i in range(FILE_SIZE - (4*inst_count)):
        f.write('x'*8 + '\n')

    # # copy the bin file to the verilog folder
    # shutil.copy2(file, )


if __name__ == "__main__":
    # remove all .bin file in the directory
    for i in os.listdir("../cpu/build"):
        if i.endswith(".bin"):
            os.remove("../cpu/build/" + i)

    #create the instruction disctionary
    read_csv()
    # handdle the argments
    handleArgs()
    # input file reding sequence
    handleInpFile()
    print(labelPosition)
    # fill the rest of the bin file
    fillTheFile()

    