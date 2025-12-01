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
    
    jal ra, strlen_recursive
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
    li a2, 0
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

strlen_recursive:
    #first we need to check case str[0]= "\0"
    lb a1, 0(a0)
    beqz a1, base_case
    
    # move sp to use stack
    addi sp, sp, -16
    sw ra, 0(sp)          # SAVE the Return Address
    addi a0, a0, 1        # Move address to next char
    jal ra, strlen_recursive
    # We add 1 to count the character at OUR current level.
    addi a0, a0, 1        
    
    # 5. Restore Stack and Return
    lw ra, 0(sp)          # Get our old return address back
    addi sp, sp, 16       # Clean up stack
    jr ra                 # Go back up one level

base_case:
    li a0, 0              # Length of empty string is 0
    jr ra                 # Return to the previous caller