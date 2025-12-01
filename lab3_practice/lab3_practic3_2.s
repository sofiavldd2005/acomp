.data
    a: .word 1
    b: .word 3
    arr: .word 3, 20, -10, 3, 1
    N: .word 5
    txt_min: .string "Min: "
    txt_max: .string " Max: "
    txt_swap: .string " Swapped: "
    msg_start: .string "Array before: "
    msg_end:   .string "Array after:  "
    space:     .string " "
.text
 #load arguments for sort_el
    la a0, a
    lw a0, 0(a0)
    la a1, b
    lw a1, 0(a1)
 
    addi sp, sp, -8
    sw a1, 0(sp)
    sw a0, 4(sp)
    jal ra, sort_el


    lw, a0, 4(sp)
    lw a1, 0(sp)
    addi, sp, sp, 8
    mv t0, a0   # t0 = Min
    mv t1, a1   # t1 = Max
    mv t2, a2   # t2 = Swapped

    # Print "Min: "
    la a0, txt_min
    li a7, 4
    ecall
    
    # Print Min Value (t0)
    mv a0, t0
    li a7, 1
    ecall

    # Print " Max: "
    la a0, txt_max
    li a7, 4
    ecall

    # Print Max Value (t1)
    mv a0, t1
    li a7, 1
    ecall
    
    # Print " Swapped: "
    la a0, txt_swap
    li a7, 4
    ecall
    # Print Swapped Value (t2)
    mv a0, t2
    li a7, 1
    ecall
    
    # Newline
    li a0, 10
    li a7, 11
    ecall

    
  
main:
    # --- 1. Print Initial Array ---
    la a0, msg_start
    li a7, 4
    ecall
    
    la a0, arr
    lw a1, N
    jal ra, print_array_helper
    
    # Newline
    li a0, 10
    li a7, 11
    ecall

    # --- 2. Call Sort Function ---
    la a0, arr    # Argument 1: Base Address
    lw a1, N     # Argument 2: Size (N)
    jal ra, sort
    # --- 3. Print Sorted Array ---
    la a0, msg_end
    li a7, 4
    ecall

    la a0, arr
    lw a1, N
    jal ra, print_array_helper

    # Exit
    li a7, 10
    ecall
 ## sort_el 
 ## args: a0=a, a1=b
 ## args  a0= MIN, a1=MAX a2=swapped
 ## return values
 sort_el:
     
     li a2,0
     bge a0, a1, do_swapp
     # then swapped is false
     li a2, 0
     jr ra
     
do_swapp:
    li t0, 0 #temporary to store value of a
    mv t0, a0
    mv a0, a1
    mv a1, t0
    li a2, 1
    jr ra
   
 ## sort takes an a array and it  sorts it in a decreasing order 
 # array sort(array[], int N) 
sort: 
## assuming base of the array in a2 , 
#a1 for N
#t0 for i

#s1 will store arr[i], s2 wil store arr[i+1]
 
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)    # Outer loop counter (k)
    sw s1, 8(sp)    # Inner loop counter (i)
    sw s2, 12(sp)   # Value arr[i]
    sw s3, 16(sp)   # Value arr[i+1]
    sw s4, 20(sp)   # Base Address (Must be saved!)
    #becouse N will be overwritten
    mv s5, a1
    # Move Base Address to s4 so it survives calls to sort_el
    mv s4, a0       
    
   # Reset Inner Loop Counter for the new pass
      
    li s1, 0        # i = 0
    
    outer_loop_start:
    # Check Outer Loop Condition (k < N)
    bge s0, s5, sort_exit

  
    # Reset Inner Loop Counter for the new pass
    li s1, 0        # i = 0
    addi t6, s5, -1

    inner_loop:
    bge s1, t6, inner_loop_end
    #
    slli, t0, s1, 2 #array offset
    add t0, s4, t0 #we had saved in s4 the base of the array
    # 2. Load arr[i] and arr[i+1]
    lw a0, 0(t0)        # a0 = arr[i]
    lw a1, 4(t0)        # a1 = arr[i+1]
    
    
    mv t5, t0 #save current address
    ##checked if swapped (a0=min, a1=max, a2=swapped)
    jal ra sort_el
    
    beqz a2, no_need_to_store
    # 5. Store back sorted values
    sw a0, 0(t5)        # arr[i] = min
    sw a1, 4(t5)        # arr[i+1] = max
    
    no_need_to_store:
    # Increment Inner Loop (i++)
        addi s1, s1, 1
        j inner_loop
 

inner_loop_end:
    addi s0, s0, 1
    
    # JUMP BACK TO beging of outerlop
    j outer_loop_start  
    
sort_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)    # Outer loop counter (k)
    lw s1, 8(sp)    # Inner loop counter (i)
    lw s2, 12(sp)   # Value arr[i]
    lw s3, 16(sp)   # Value arr[i+1]
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    ret
        
print_array_helper:
    mv t0, a0       # Base
    mv t1, a1       # Size
    li t2, 0        # Counter

print_loop:
    bge t2, t1, print_end
    
    lw a0, 0(t0)    # Load number
    li a7, 1
    ecall
    
    la a0, space
    li a7, 4
    ecall

    addi t0, t0, 4  # Next address
    addi t2, t2, 1  # Next index
    j print_loop

print_end:
    jr ra