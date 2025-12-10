.data

vx: .word 1, 2, -1, 0, 1

vy: .word 1, 1, 0, 0, 0

N: .word 5

x_ref: .word 0

y_ref: .word 0

.text

addi sp, sp, -20
la a1, x_ref
lw a1, 0(a1)
sw a1, 0(sp)
la a2, y_ref
lw a2, 0(a2)
sw a2, 4(sp)
la a5, N
lw a5, 0(a5)
sw a5, 8(sp)

la a6, vx
sw a6, 12(sp)
la a7, vy
sw a7, 16(sp)

j find_nearest
out: 
li a7, 10
ecall

find_nearest: 
lw s0, 0(sp)         # x_ref
lw s1, 4(sp)         # y_ref
lw s2, 8(sp)         # N
lw s3, 12(sp)        # *vx
lw s4, 16(sp)        # *vy
li s5, 1 #k
li s6, 0 #index
addi sp, sp, -8
lw a3, 0(s3) #vx[0]
sw a3, 0(sp)
lw a4, 0(s4) #vy[0]
sw a4, 4(sp)

jal ra, dist_stack
lw a0, 0(sp)
addi sp, sp, 4
add s8, x0, a0 #dmin

for:
    bge s5, s2, endfor
    bge x0, s8, endfor
    addi sp, sp, -8
    lw a1, 0(s3)
    sw a1, 0(sp)
    lw a2, 0(s4) 
    sw a2, 4(sp)
    jal ra, dist_stack
    lw a0, 0(sp)
    addi sp, sp, 4
    add s7, x0, a0 #d
    bge s7, s8, endif
    add s8, x0, s7
    add s6, x0, s5
    
    endif:
    addi s5, s5, 1
    addi s3, s3, 4
    addi s4, s4, 4
    j for
 
endfor: add a0, x0, s6
        j out

dist_stack:
    lw s0, 8(sp)         # x1
    lw s1, 12(sp)         # y1
    lw s9, 0(sp)         # x2
    lw s10, 4(sp)        # y2
   
    sub s9, s0, s9        
    sub s10, s1, s10        
    mul s9, s9, s9
    mul s10, s10, s10     

    add s10, s9, s10 
    
    sw s10, 4(sp) 
    addi, sp, sp, 4   
     
    jr ra