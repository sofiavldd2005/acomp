.data
    X1: .word 1
    Y1: .word 2
    X2: .word 3
    Y2: .word 4
    
    # Vectors
    d1: .word -1, 3, 7, -2, 4, 1, 5, 9, 1, 4
    d2: .word 1, -3, 2, -2, -3, 2, 1, 0, 4, 4
    N: .word 10

.text
.globl main

main:
    # --- TEST 1: dist_reg ---
    la a0, X1    
    lw a0, 0(a0) 
    la a1, Y1
    lw a1, 0(a1)
    la a2, X2 
    lw a2, 0(a2)
    la a3, Y2
    lw a3, 0(a3)
    jal ra, dist_reg
    
    # Print result
    li a7, 1     
    ecall
    li a0, 10
    li a7, 11
    ecall
 
    # --- TEST 2: dist_stack ---
    addi sp, sp, -16 
    la a0, X1
    lw t0, 0(a0)        
    sw t0, 0(sp)        
    la a0, Y1
    lw t0, 0(a0)
    sw t0, 4(sp)        
    la a0, X2
    lw t0, 0(a0)
    sw t0, 8(sp)        
    la a0, Y2
    lw t0, 0(a0)
    sw t0, 12(sp)       
    jal ra, dist_stack
    lw a0, 0(sp)
    addi sp, sp, 16 
    
    # Print result
    li a7, 1     
    ecall
    li a0, 10
    li a7, 11
    ecall

    # --- TEST 3: find_nearest ---
    li a0, 3        # xref = 3
    li a1, 4        # yref = 4
    la a2, d1       
    la a3, d2       
    la a4, N
    lw a4, 0(a4)    # N = 10
    
    jal ra, find_nearest  
 
    # Print Result (The correct index should be 9)
    li a7, 1
    ecall
    
    # Exit
    li a7, 10       
    ecall

# -----------------------------------------------------------
# Functions
# -----------------------------------------------------------

dist_reg:   
    sub a0, a0, a2      
    sub a1, a1, a3      
    mul a0, a0, a0      
    mul a1, a1, a1      
    add a0, a0, a1      
    jr ra
    
dist_stack:
    addi sp, sp, -8
    sw s1, 0(sp)
    sw s2, 4(sp)
    lw s1, 8(sp)        # X1
    lw s2, 16(sp)       # X2
    sub s1, s1, s2      
    mul s1, s1, s1      
    lw s2, 12(sp)       # Y1
    lw a0, 20(sp)       # Y2 
    sub s2, s2, a0      
    mul s2, s2, s2      
    add s1, s1, s2      
    sw s1, 8(sp)        # Result
    lw s1, 0(sp)
    lw s2, 4(sp)
    addi sp, sp, 8
    jr ra

# -----------------------------------------------------------
# Program 1B: find_nearest
# -----------------------------------------------------------
find_nearest:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)    # k 
    sw s1, 8(sp)    # dmin
    sw s2, 12(sp)   # index
    sw s3, 16(sp)   # xref
    sw s4, 20(sp)   # yref
    sw s5, 24(sp)   # vx base
    sw s6, 28(sp)   # vy base
    
    mv s3, a0       # xref
    mv s4, a1       # yref
    mv s5, a2       # vx
    mv s6, a3       # vy
    mv t3, a4       # N
    
    # Init (k=0)
    lw a2, 0(s5)    
    lw a3, 0(s6)    
    mv a0, s3       
    mv a1, s4       
    jal ra, dist_reg 
    
    mv s1, a0       # dmin
    li s2, 0        # index
    li s0, 1        # k = 1

loop_nearest:
    bge s0, t3, end_nearest
    blez s1, end_nearest    

    # --- CRITICAL FIX: Calculate Offset Inside Loop ---
    slli t1, s0, 2      # t1 = k * 4
    
    # Load vx[k]
    add t2, s5, t1      
    lw a2, 0(t2)
    
    # Load vy[k]
    add t2, s6, t1      
    lw a3, 0(t2)

    mv a0, s3
    mv a1, s4
    jal ra, dist_reg    
    
    bge a0, s1, increment
    
    # New minimum found
    mv s1, a0           # dmin = d
    mv s2, s0           # index = k
    
    j increment         

increment:
    addi s0, s0, 1      # k++
    j loop_nearest

end_nearest:
    mv a0, s2           # Return INDEX (s2) in a0

    # RESTORE REGISTERS
    lw ra, 0(sp)    
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    
  
    
    jr ra