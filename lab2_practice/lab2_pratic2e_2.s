## data segment

.data

vect: .zero 512

## text segment

.text


la a0 vect #load base address of the array vect into a0
li a1 10 # if we wanted N to be 10



init: 
  addi t0, zero, 0 # 1. Initialize i(t0) = 0
loop:
  
    bge     t0, a1, end_loop    # Branch to end_loop if i >= N
    slli    t2, t0, 2           # t2 = i << 2 (which is i * 4) t2 is the offset
    add     t2, a0, t2          # t2 = base address (a0) + offset (t2)
    slli    t1, t0, 5           # t1 = i << 5
    xori    t1, t1, 7           # t1 = t1 ^ 7  (Value to store)
    sw      t1, 0(t2)           # Store word from t1 into address at t2
    addi    t0, t0, 1           # i = i + 1
    j       loop   
end_loop: ret  