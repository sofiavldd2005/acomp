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
        # '!' (Keys[0]) -> Output[6] - Reusing the address of '!'
        sb x7, 6(x9)

        # 'O' (Keys[5]) -> Output[3]
        lb x7, 5(x8)
        sb x7, 3(x9)

        # 'L' (Keys[4]) -> Output[4]
        lb x7, 4(x8)
        sb x7, 4(x9)

        # 'A' (Keys[1]) -> Output[5]
        lb x7, 1(x8)   # Load 'A'
        sb x7, 5(x9)   # Output[5] = 'A'
  
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
      
        # x9 = Base address of Output, still is defined as such from QUESTION 6
        addi x6, x0, 0       # x6 = i = 0 (index)
        addi x7, x0, 7       # x7 = Loop Limit (7)
        addi x5, x0, 0x21    # x8 = ASCII value for '!' (MUST be loaded for beq comparison)

loop:
        # Check loop condition: if (i >= 7) goto loop_end
        bge x6, x7, loop_end

        # --- LOAD CHARACTER ---

        # 1. Load Output[i] into x8 (The Keys vector will one by one get distroyed)
        lb x8, 0(x9)   # x8 = Output[i] (Character value)     

        # 4. Check for '!' (If char == '!')
        beq x5, x8, skip_if # If x5 ('!') == x8 (char), skip.

        # 5. Perform conversion: Output[i] += 32 (Using immediate 32)
        addi x8, x8, 32 # x8 = x8 + 32 (Lowercase conversion)
        sb x8, 0(x9) # loading value in x8 back into the correct position in the Output

skip_if:
        #Incrementing 1 to i on Output[i]
        addi x9, x9, 1 # x9 = &Output + i
    
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
