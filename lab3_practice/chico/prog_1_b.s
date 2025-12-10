.data

vx: .word 1, 2, -1, 0, 1

vy: .word 1, 1, 0, 0, 0

N: .word 5

x_ref: .word 0

y_ref: .word 0

.text

la a1, x_ref
lw a1, 0(a1)
la a2, y_ref
lw a2, 0(a2)
la a5, N
lw a5, 0(a5)

la a6, vx
la a7, vy

j find_nearest
out: 
li a7, 10
ecall

find_nearest: 
li s0, 1 #k
li s1, 0 #index
lw a3, 0(a6) #vx[0]
lw a4, 0(a7) #vy[0]

jal ra, dist_reg
add s3, x0, a0 #dmin

for:
    bge s0, a5, endfor
    bge x0, s3, endfor
    lw a3, 0(a6)
    lw a4, 0(a7) 
    jal ra, dist_reg
    add s2, x0, a0 #d
    bge s2, s3, endif
    add s3, x0, s2
    add s1, x0, s0
    
    endif:
    addi s0, s0, 1
    addi a6, a6, 4
    addi a7, a7, 4
    j for
 
endfor: add a0, x0, s1
        j out

dist_reg:
    sub s4, a1, a3
    sub s5, a2, a4
    mul s4, s4, s4
    mul s5, s5, s5
    add a0, s4, s5
    jr ra
