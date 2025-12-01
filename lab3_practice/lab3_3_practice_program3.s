.data

str1: .string "ola mundo"
str2: .string "hello world"
str:  .string "\nThe string length is: "
.text
    la a0, str1

   
    jal ra, strlen
    
    #store a0 in stack so we can print a string first
    addi sp, sp, -8
    sw a0, 0(sp)
    la, a0, str
    li a7, 4
    ecall
    lw a0, 0(sp)
    li a7, 1
    ecall
    addi sp, sp, 8
    
    la a0, str2 
    
    jal ra, strlen
    addi sp, sp, -8
    sw a0, 0(sp)
    la, a0, str
    li a7, 4
    ecall
    lw a0, 0(sp)
    li a7, 1
    ecall
    addi sp, sp, 8
    li a7, 10
    ecall
strlen:    #uses a0 for the base address, a1 for str[i] and a2 for i
    li a2, 1
    loop:    
    lb a1, 0(a0)
    
    beqz a1, end_loop
    addi a0,a0,1
    addi a2, a2, 1
    j loop
    
    jr ra
    
end_loop:
    mv a0, a2
    jr ra

    