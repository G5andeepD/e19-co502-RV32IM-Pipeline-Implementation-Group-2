addi x1, x0, 5
addi x2, x0, 10
add x3, x1, x2
sub x4, x2, x1
mul x5, x1, x2
div x6, x2, x1
rem x7, x2, x1
addi x8, x0, 0
addi x9, x0, 10
loopone:
beq x8, x9, endone
add x10, x10, x8
addi x8, x8, 1
jal x0, loopone
endone:
addi x11, x0, 1
sll x12, x11, x1
srl x13, x12, x1
sra x14, x13, x1
and x15, x1, x2
or x16, x1, x2
xor x17, x1, x2
slti x18, x1, 20
sltiu x19, x1, 20
slt x20, x1, x2
sltu x21, x1, x2
addi x22, x0, -1
lui x23, 0x12345
auipc x24, 0x10
addi x25, x0, 0
addi x26, x0, 10
looptwo:
beq x25, x26, endtwo
mul x27, x25, x25
add x28, x28, x27
addi x25, x25, 1
jal x0, looptwo
endtwo:
addi x29, x0, 0
addi x30, x0, 1
addi x31, x0, 10
fibloop:
beq x31, x29, done
add x5, x30, x29
addi x31, x31, -1
jal x0, fibloop
done:
