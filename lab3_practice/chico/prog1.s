.data



.text

addi a0, x0, 3 #x1
addi a1, x0, 4 #y1
addi a2, x0, 1 #x2
addi a3, x0, 2 #y2

addi sp, sp, -16
li t0, 3    # x1
sw t0, 0(sp)

li t0, 4           # y1
sw t0, 4(sp)

li t0, 1            # x2
sw t0, 8(sp)

li t0, 2             # y2
sw t0, 12(sp)
#jal ra, dist_reg
jal ra, dist_stack

lw a0, 0(sp)
addi sp, sp, 4
li a7, 10
    ecall 

dist_reg:
    sub t0, a0, a2
    sub t1, a1, a3
    mul t0, t0, t0
    mul t1, t1, t1
    add a0, t0, t1
    jr ra
    
dist_stack:
    lw t0, 0(sp)         # x1
    lw t1, 4(sp)         # y1
    lw t2, 8(sp)         # x2
    lw t3, 12(sp)        # y2
   
    sub t0, t0, t2        
    sub t1, t1, t3        
    mul t0, t0, t0
    mul t1, t1, t1     

    add t0, t0, t1 
    
    sw t0, 12(sp) 
    addi, sp, sp, 12   
     
    jr ra