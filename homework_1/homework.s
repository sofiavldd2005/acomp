### Data segment
        .data
Output: .zero    8
Keys:   .string "!AHILO"

### Program segment
        .text

        ### TODO ###
        # here you should provide 
        # your code for QUESTION 6
        
        # Load the base addresses of the arrays
        la x8, Keys    # x5 = Base address of Keys ("!AHILO")
        la x9, Output  # x6 = Base address of Output (where "HI!OLA!" goes)
    
        # 'H' (Keys[2]) -> Output[0]
        lb x7, 2(x8)
        sb x7, 0(x9)

        # 'I' (Keys[3]) -> Output[1]
        lb x7, 3(x8)
        sb x7, 1(x9)

        # '!' (Keys[0]) -> Output[2]
        lb x7, 0(x8)
        sb x7, 2(x9)

        # 'O' (Keys[5]) -> Output[3]
        lb x7, 5(x8)
        sb x7, 3(x9)

        # 'L' (Keys[4]) -> Output[4]
        lb x7, 4(x8)
        sb x7, 4(x9)

        # 'A' (Keys[1]) -> Output[5]
        # '!' (Keys[0]) -> Output[6] - Reusing the address of '!'
        lb x7, 1(x8)   # Load 'A'
        sb x7, 5(x9)   # Output[5] = 'A'
        lb x7, 0(x8)   # Load '!'
        sb x7, 6(x9)   # Output[6] = '!'
        # Null terminator (\0) at Output[7]
        # Since Output is .zero 8, Output[7] is already 0. We can omit the 'li x7, 0; sb x7, 7(x6)'
        # or we can explicitly place it if the array was not pre-zeroed.
        
        ###################################
        #####      PRINT  ECALLS      #####
        #####   !!! DON'T TOUCH !!!   #####
        li a0, 0xA   # new line char ecall
        li a7, 11    # print char 
        ecall 
        la a0, Output # string to print
        li a7, 4      # print string ecall
        ecall 
        ###################################

        ### TODO ###
        # here you should provide 
        # your code for QUESTION 7
        
  
        
        la x9, Output  # x9 = Base address of Output
        addi x6, 0       # x6 = i = 0 (index)
        addi x7, 7       # x7 = Loop Limit (7)
        addi x8, 33      # x8 = ASCII value for '!' (MUST be loaded for beq comparison)

loop:
        # Check loop condition: if (i >= 7) goto loop_end
        bge x6, x7, loop_end

        # --- LOAD CHARACTER ---
        # 1. Calculate Address into x8
        add x8, x9, x6 # x8 = &Output + i. (x8, '!', is destroyed)

        # 2. Load Output[i] into x5 (x5 is set here, no prior init needed)
        lb x5, 0(x8)   # x5 = Output[i] (Character value)
        
        # 3. Restore x8 ('!' constant)
        addi x8, 33      

        # 4. Check for '!' (If char == '!')
        beq x5, x8, skip_if # If x5 (char) == x8 ('!'), skip.

        # 5. Perform conversion: Output[i] += 32 (Using immediate 32)
        addi x5, x5, 32 # x5 = x5 + 32 (Lowercase conversion)
        
        # --- STORE CHARACTER ---
        # 6. Store Back (Address must be recalculated)
        add x8, x9, x6 # x8 now holds the address of Output[i]. ('!' is destroyed)
        sb x5, 0(x8)   # Store converted character back into Output[i]
        
        # 7. Restore x8
        addi x8, 33      

skip_if:
        # Increment Index: i++
        addi x6, x6, 1 
        
        # Loop back
        jal x0, loop

loop_end: #does nothing,straight to ecall
        
        ###################################
        ###################################
        #####      PRINT  ECALLS      #####
        #####   !!! DON'T TOUCH !!!   #####
        li a0, 0xA   # new line char ecall
        li a7, 11    # print char 
        ecall 
        la a0, Output # string to print
        li a7, 4      # print string ecall
        ecall 
        ###################################

        # INSTRUCTIONS TO CONSIDER 
        # FOR QUESTION 4 
        auipc x5, 0
        jalr x0, x5, 0 # the same as jalr x0, 0(x5)
