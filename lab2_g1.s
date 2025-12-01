       .data
vec:   .byte 153
arr:   .zero 128
dummy: .half 25
chars: .string "DEFG-1256"

       .text

       # YOUR
       # WARMUP CODE
       # GOES HERE

print: # PRINT STRING #
       la a0, chars
       li a7, 4
       ecall

main:  # YOUR
       # MAIN CODE
       # GOES HERE

       jal x5, ends

ends:
       addi x5, x5, -4
	jalr x5, x5, 0


init:  # YOUR
       # INIT FUNC
       # GOES HERE

exit:  # exit program
       li a7, 10
       ecall
