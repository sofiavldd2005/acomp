.data

#data section

    X1: .word 1
    Y1: .word 2
    X2: .word 3
    Y2: .word 4

.text
      #inputs and outputs are passed via registers
        la a0, X1    #store adress of x1 in a0
        lw a0, 0(a0) #store value of x1 in a0
    
        la a1, Y1
        lw a1, 0(a1)
    
        la a2, X2 
        lw a2, 0(a2)
    
        la a3, Y2
        lw a3, 0(a3)
    jal ra, dist_reg
    
    
    #print the result
    li a7, 1     
    ecall
    
    # Print a newline 
    li a0, 10
    li a7, 11
    ecall
    #now with dist stack
    addi sp, sp, -16
   
    la a0, X1
    lw t0, 0(a0)        # (Using t0 here in main is fine)
    sw t0, 0(sp)        # Push X1
    lw t0, 0(a0)
    sw t0, 4(sp)        # Push Y1
    
    la a0, X2
    lw t0, 0(a0)
    sw t0, 8(sp)        # Push X2
    
    la a0, Y2
    lw t0, 0(a0)
    sw t0, 12(sp)       # Push Y2
    jal ra, dist_stack
    
    lw a0, 0(sp)
    addi sp, sp, 16
    #print the result
    li a7, 1     
    ecall
    
    
    
    # Exit the program
    li a7, 10       # Service code 10 = Exit
    ecall
    
    dist_reg:   
        sub a0, a0, a2      # a0 = x1 - x2  (dx)
        sub a1, a1, a3      # a1 = y1 - y2  (dy)

        mul a0, a0, a0      # a0 = dx * dx
        mul a1, a1, a1      # a1 = dy * dy

        add a0, a0, a1      # a0 = result (dx^2 + dy^2)
        jr ra
    
   
    dist_stack:
        lw s1, 8(sp)        # X1
        lw s2, 16(sp)       # X2
        sub s1, s1, s2      # dx
        mul s1, s1, s1      # dx^2
    
        lw s2, 12(sp)       # Y1
        lw a0, 20(sp)       # Y2 (Use a0 as temp)
        sub s2, s2, a0      # dy
        mul s2, s2, s2      # dy^2   
        add s1, s1, s2      # Result
        # The prompt says output via stack. 
        # We overwrite the first argument (X1) with the result.
       
        sw s1, 8(sp)

        # Restore S registers
        lw s1, 0(sp)
        lw s2, 4(sp)
        addi sp, sp, 8
        jr ra
        