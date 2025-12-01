.data 
#A matrix A allocated row-wise as an array of NxN integer elements
# example in int v[4][4] =  { {1, 2, 3, 4}, {5, 6, 7,8} , {9, 10,11,12} , {13, 14, 15,16} };
#row major formula Address of A[i] = $$\text{Address} = B + ( (i*W) + j) *E

#Index = The index of the element whose address is to be found 
#B = Base address of the array.
#E = Storage size of one element in bytes.
#W = width of the matrix ->number of colls


arr: .word 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16

.text

la a0, arr #base adress of the array
# element (i,j) in the matrix
li a1, 1 # "row" we want ->i
li a2, 1 # "column" we want -> j 
li a3, 4 # width of the array

jal ra read_matrix_element
li a7, 1
ecall
la a0, arr #base adress of the array
li a1, 1 # "row" we want ->i
li a2, 1 # "column" we want -> j 
li a3, 4 # width of the array
li a4, 1

jal ra store_matrix_element
li a7, 10
ecall



read_matrix_element: #assuming a1= i, a2 = j, a3 = N a0= *A
    mul a1, a1, a3
    add a1, a1, a2
    slli a1, a1,2
    add t0, a0, a1    # Add offset to Base Address (store in temp t0)
    lw a0, 0(t0)      # Load value
    jr ra

store_matrix_element: #let a4 have the element we want to store
    mul a1, a1, a3
    add a1, a1, a2
    slli a1, a1,2
    add t0, a0, a1    # Add offset to Base Address (store in temp t0)
    sw a4, 0(t0)      # Load value
    jr ra
    
