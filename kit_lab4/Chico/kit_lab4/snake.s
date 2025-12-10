# Block filling
# LED_MATRIX_0_BASE is in s7
.equ SNAKE_START_X      LED_MATRIX_0_WIDTH/2
.equ SNAKE_START_Y      LED_MATRIX_0_HEIGHT/2
.equ SNAKE_START_ROW    SNAKE_START_Y*LED_MATRIX_0_WIDTH
.equ SNAKE_START_OFFSET SNAKE_START_ROW+SNAKE_START_X

.equ GRID_SIZE          LED_MATRIX_0_WIDTH*LED_MATRIX_0_HEIGHT
# directions on the grid
.equ GRID_U     1
.equ GRID_R     2
.equ GRID_D     3
.equ GRID_L     4
.equ GRID_FRUIT 5

# Colors
.equ BG_COLOR       0x00000000
.equ SNAKE_COLOR    0x00ffffff
.equ FRUIT_COLOR    0x0000ff00

# Flags
.equ FRUIT_FLAG     GRID_FRUIT
.equ DEATH_FLAG     3

.equ FRAME_TIME_MS  100
.equ TIMEOUT_MS     2000

.data
last_frame: .word 0         # the time the last frame occurred
timeout: .word TIMEOUT_MS   # current timeout (stops the game until it reaches 0)
direction: .byte GRID_U     # the current direction the snake is moving
direction_x: .byte 0        # same, but broken down into x
direction_y: .byte -1       #   and y
# stores the snake segments, their direction, and the fruit
game_grid: .zero LED_MATRIX_0_SIZE     # also in s6
head_x: .byte SNAKE_START_X # x and y positions of the head and tail
head_y: .byte SNAKE_START_Y
tail_x: .byte SNAKE_START_X
tail_y: .byte SNAKE_START_Y
rng_state: .word 0xfadebabe # state of the random number generator

.text
    j       main

init:
    addi    sp, sp, -4
    sw      ra, 0(sp)
    jal     init_saved_regs
    jal     reset_led_matrix
    jal     reset_game_grid
    jal     init_snake
    jal     spawn_fruit
    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret

init_saved_regs:
    la      s6, game_grid
    la      s7, LED_MATRIX_0_BASE
    la      s8, D_PAD_0_BASE
    li      s9, 0   # event flag (collision, fruit)
    ret

# Resets the LED matrix to 0 (black)
reset_led_matrix:
    mv      t0, s7
    la      t1, LED_MATRIX_0_BASE+LED_MATRIX_0_SIZE
    li      t2, BG_COLOR
1:
    sw      t2, 0(t0)   # store a 0
    addi    t0, t0, 4   # inc pointer
    blt     t0, t1, 1b
    ret

reset_game_grid:
    mv      t0, s6
    la      t1, game_grid+GRID_SIZE
1:
    sw      x0, 0(t0)   # store a 0
    addi    t0, t0, 1   # inc pointer
    blt     t0, t1, 1b
    ret

# Initializes and draws the snake at the start of the game
init_snake:
    # set direction
    la      t0, direction
    li      t3, GRID_U
    sb      t3, 0(t0)
    la      t0, direction_x
    sb      x0, 0(t0)
    li      t1, -1
    la      t0, direction_y
    sb      t1, 0(t0)
    # set head and tail position
    li      t0, SNAKE_START_X
    la      t1, head_x
    sb      t0, 0(t1)
    la      t1, tail_x
    sb      t0, 0(t1)
    li      t0, SNAKE_START_Y
    la      t1, head_y
    sb      t0, 0(t1)
    la      t1, tail_y
    sb      t0, 0(t1)
    li      t0, SNAKE_START_OFFSET
    # update it on the grid
    add     t1, s6, t0      # calc grid address
    sb      t3, 0(t1)       # update grid with the direction
    # draw
    slli    t2, t0, 2       # word offset
    add     t2, s7, t2      # calc LED matrix address
    li      t3, SNAKE_COLOR
    sw      t3, 0(t2)
    ret


spawn_fruit:
    addi    sp, sp, -12
    sw      ra, 0(sp)
    sw      s0, 4(sp)   # rng state address
    sw      s1, 8(sp)   # rng state value

    la      s1, rng_state
    lw      s0, 0(s1)
1:  # xorshift32 RNG
    slli    t2, s0, 13
    xor     s0, s0, t2
    srli    t2, s0, 17
    xor     s0, s0, t2
    slli    t2, s0, 5
    xor     s0, s0, t2
    # extract random coordinates from the RNG state
    li      t2, LED_MATRIX_0_WIDTH
    li      t3, LED_MATRIX_0_HEIGHT
    rem     a0, s0, t2  # random x
    srli    a1, s0, 8   # discard lower 8 bits of RNG state
    rem     a1, a1, t3  # random y
    jal     get_grid_offset
    # check if anything exists in the random position
    add     t0, s6, a0
    lb      t1, 0(t0)
    bnez    t1, 1b  # repeat if there's something there
    # put the fruit on the grid
    li      t1, GRID_FRUIT
    sb      t1, 0(t0)
    # draw the fruit
    slli    a0, a0, 2
    add     t0, s7, a0
    li      t1, FRUIT_COLOR
    sw      t1, 0(t0)
    # store rng state
    sw      s0, 0(s1)

    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    addi    sp, sp, 12
    ret


# inputs:
# a0 - position x
# a1 - position y
# a2 - direction x
# a3 - direction y
# outputs
# a0 - new position x
# a1 - new position y
get_next_grid_pos:
    # move x according to dir
    li      t0, LED_MATRIX_0_WIDTH
    add     a0, a0, a2
    blt     a0, t0, 1f
    addi    a0, a0, -LED_MATRIX_0_WIDTH # wrap around if we exceeded the right limit
1:
    bge     a0, x0, 2f
    addi    a0, a0, LED_MATRIX_0_WIDTH  # wrap around if we exceeded the left limit
2:  # move y according to dir
    li      t1, LED_MATRIX_0_HEIGHT
    add     a1, a1, a3
    blt     a1, t1, 3f
    addi    a1, a1, -LED_MATRIX_0_HEIGHT    # wrap around if we exceeded the lower limit
3:
    bge     a1, x0, 4f
    addi    a1, a1, LED_MATRIX_0_HEIGHT     # wrap around if we exceeded the upper limit
4:
    ret


# inputs:
# a0 - direction as encoded in the grid (GRID_U, GRID_D, etc.)
# outputs
# a0 - direction x
# a1 - direction y
get_vec_from_grid:
    li      t0, GRID_U  # up
    bne     a0, t0, 1f
    li      a0, 0
    li      a1, -1
    ret
1:
    li      t0, GRID_R  # right
    bne     a0, t0, 2f
    li      a0, 1
    li      a1, 0
    ret
2:
    li      t0, GRID_D  # down
    bne     a0, t0, 3f
    li      a0, 0
    li      a1, 1
    ret
3:  # assume left if none other
    li      a0, -1
    li      a1, 0
    ret


# inputs:
# a0 - position x
# a1 - position y
# outputs
# a0 - grid offset of the position
get_grid_offset:
    li      t0, LED_MATRIX_0_WIDTH
    mul     t0, t0, a1
    add     a0, a0, t0
    ret


move_snake:
    addi    sp, sp, -12
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)

    # update the grid to point to the new head
    la      s0, head_x      # prep func arguments
    lb      a0, 0(s0)
    la      s1, head_y
    lb      a1, 0(s1)
    jal     get_grid_offset
    add     t0, s6, a0
    la      t1, direction
    lb      t1, 0(t1)       # load the current direction
    sb      t1, 0(t0)       # store the direction in the current head position
    # move the head
    lb      a0, 0(s0)
    lb      a1, 0(s1)
    la      a2, direction_x
    lb      a2, 0(a2)
    la      a3, direction_y
    lb      a3, 0(a3)
    jal     get_next_grid_pos   # call grid movement routine
    sb      a0, 0(s0)           # store the new position
    sb      a1, 0(s1)
    # check if position has a fruit
    jal     get_grid_offset
    mv      s0, a0
    add     t0, s6, a0
    lb      t1, 0(t0)
    li      t2, GRID_FRUIT
    bne     t1, t2, 1f
    li      s9, FRUIT_FLAG      # set the game event to fruit collision if so
    jal     spawn_fruit         # spawn a new fruit
1:  # if there is no fruit, check that there is no other obstacle either
    lb      t1, 0(t0)
    beqz    t1, 2f
    li      s9, DEATH_FLAG
2:  # draw head
    slli    t0, s0, 2
    add     t0, s7, t0
    li      t1, SNAKE_COLOR
    sw      t1, 0(t0)

    # skip tail movement if a fruit was eaten
    li      t1, FRUIT_FLAG
    beq     s9, t1, 2f
    # move tail forward
    la      s0, tail_x          # prep func arguments
    lb      a0, 0(s0)
    la      s1, tail_y
    lb      a1, 0(s1)
    jal     get_grid_offset     # get the tail's grid offset
    add     t0, s6, a0
    lb      t1, 0(t0)           # load tail direction
    sb      x0, 0(t0)           # delete old tail on the grid
    slli    t0, a0, 2           # and on the LED matrix
    add     t0, s7, t0
    mv      a0, t1              # prep args
    li      t1, BG_COLOR
    sw      t1, 0(t0)
    jal     get_vec_from_grid   # get direction as a vector
    mv      a2, a0              # prep func arguments
    mv      a3, a1
    lb      a0, 0(s0)
    lb      a1, 0(s1)
    jal     get_next_grid_pos   # get next tail pos
    sb      a0, 0(s0)           # store tail pos
    sb      a1, 0(s1)
2:
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    addi    sp, sp, 12
    ret


poll_dpad:
    la      t0, direction
    la      t2, direction_x
    la      t3, direction_y

    lb      t1, D_PAD_0_UP_OFFSET(s8)   # remember that s8 has the DPAD base address
    beqz    t1, 1f      # if the up button is pressed, set the values, otherwise, check the next button
    li      t1, GRID_U
    sb      t1, 0(t0)   # store GRID_U in the direction
    sb      x0, 0(t2)   # store a 0 in direction_x (the movement is vertical)
    li      t1, -1      
    sb      t1, 0(t3)   # store a -1 in direction_y (up is -y)
    j       4f
1:
    # check the right button
2:
    lb      t1, D_PAD_0_DOWN_OFFSET(s8)
    beqz    t1, 3f
    li      t1, GRID_D
    sb      t1, 0(t0)
    sb      x0, 0(t2)
    li      t1, 1
    sb      t1, 0(t3)
    j       4f
3:
    lb      t1, D_PAD_0_LEFT_OFFSET(s8)
    beqz    t1, 4f
    li      t1, GRID_L
    sb      t1, 0(t0)
    li      t1, -1
    sb      t1, 0(t2)
    sb      x0, 0(t3)
    j       4f
4:
    ret


wait_and_poll:
    addi    sp, sp, -16
    sw      ra, 0(sp)
    sw      s0, 4(sp)   # timeout val
    sw      s1, 8(sp)   # frame time constant
    sw      s2, 12(sp)  # last frame address

    li      a7, 30 # get time syscall
    la      s2, last_frame
    lw      a2, 0(s2)
    li      s1, FRAME_TIME_MS
    la      t0, timeout
    lw      s0, 0(t0)
1:
    # poll the controls
    jal     poll_dpad
    ecall               # get real-time ms
    sub     t1, a0, a2  # difference to the last frame
    bltu    t1, s1, 1b  # loop if it's under FRAME_TIME_MS
    sw      a0, 0(s2)   # store the new frame time
    # update the timeout
    sub     s0, s0, s1  # reduce timeout
    bgez    s0, 2f
    li      s0, 0       # reset the timeout to 0 if negative
2:
    la      t0, timeout
    sw      s0, 0(t0)   # store timeout again

    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    addi    sp, sp, 16
    ret


main_loop:
    addi    sp, sp, -4
    sw      ra, 0(sp)
1:
    # move the snake only when there is no timeout
    la      t0, timeout
    lw      t1, 0(t0)
    bgtz    t1, 2f
    jal     move_snake
    # check the death flag
    li      t0, DEATH_FLAG
    bne     s9, t0, 2f
    jal     init            # reset everything
    la      t0, timeout     # apply timeout
    li      t1, TIMEOUT_MS
    sw      t1, 0(t0)
2:
    li      s9, 0           # clear flags
    jal     wait_and_poll
    j       1b

    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret


main:
    jal     init
    jal     main_loop
    nop