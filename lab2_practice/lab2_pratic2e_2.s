## data segment

.data

vect: .zero 512

## text segment

.text


la a0 vect #load base address of the array vect into a0
li a1 16 # if we wanted N to be 10

jal     ra, init    # Jump to init, save return address to ra
la a0 vect #load base address of the array vect into a0
li a1 16 # if we wanted N to be 10
jal     ra, average

li a7,1
ecall 

# Stop execution here 
    li      a7, 10
    ecall


init: 
  addi t0, zero, 0 # 1. Initialize i(t0) = 0
loop:
  
    bge     t0, a1, end_loop_1    # Branch to end_loop if i >= N
    slli    t2, t0, 2           # t2 = i << 2 (which is i * 4) t2 is the offset
    add     t2, a0, t2          # t2 = base address (a0) + offset (t2)
    slli    t1, t0, 5           # t1 = i << 5
    xori    t1, t1, 7           # t1 = t1 ^ 7  (Value to store)
    sw      t1, 0(t2)           # Store word from t1 into address at t2
    addi    t0, t0, 1           # i = i + 1
    j       loop   
end_loop_1: ret  
jal ra average
average:
    li      t0, 0               # t0 = i (Index) -> Must reset to 0!
    li      t1, 0               # t1 = sum (Accumulator) -> Must reset to 0!
 avg_loop:   
    bge     t0, a1, end_loop_avg    # Branch to end_loop if i >= N
    slli    t2, t0, 2           # t2 = i << 2 (which is i * 4) t2 is the offset
    add     t2, a0, t2          # t2 = base address (a0) + offset (t2)
    lw t3, 0(t2)
    add t1, t1, t3
    addi    t0, t0, 1           # i = i + 1
    j avg_loop 
end_loop_avg:
            div a0, t1, a1 # a0 = sum (t1) / N (a1)
            ret