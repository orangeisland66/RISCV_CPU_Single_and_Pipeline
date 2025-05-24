# 全局符号声明
.globl _start

.text
_start:
    # 初始化寄存器
    li x1, 0x0A               # x1 = 10
    li x2, 0x05               # x2 = 5
    li x3, 0x03               # x3 = 3
    li x4, 0x02               # x4 = 2

    # 算术运算指令
    add x5, x1, x2            # x5 = x1 + x2 = 15
    sub x6, x1, x2            # x6 = x1 - x2 = 5
    addi x7, x1, 3            # x7 = x1 + 3 = 13
    addi x8, x1, -2           # x8 = x1 - 2 = 8

    # 逻辑运算指令
    and x9, x1, x2            # x9 = x1 & x2 = 0x00
    or  x10, x1, x2           # x10 = x1 | x2 = 0x0F
    xor x11, x1, x2           # x11 = x1 ^ x2 = 0x0F
    andi x12, x1, 0x03        # x12 = x1 & 0x03 = 0x02
    ori  x13, x2, 0x08        # x13 = x2 | 0x08 = 0x0D
    xori x14, x1, 0x0F        # x14 = x1 ^ 0x0F = 0x05

    # 移位运算指令
    sll x15, x1, x3           # x15 = x1 << x3 = 0x50
    srl x16, x1, x3           # x16 = x1 >> x3 = 0x01
    sra x17, x1, x3           # x17 = x1 >> x3 (算术右移) = 0x01
    slli x18, x2, 2           # x18 = x2 << 2 = 0x14
    srli x19, x2, 1           # x19 = x2 >> 1 = 0x02
    srai x20, x1, 1           # x20 = x1 >> 1 (算术右移) = 0x05

    # 比较指令
    slt x21, x2, x1           # x21 = 1 (x2 < x1)
    sltu x22, x2, x1          # x22 = 1 (x2 < x1 无符号比较)
    slti x23, x1, 12          # x23 = 1 (x1 < 12)
    sltiu x24, x2, 6          # x24 = 1 (x2 < 6 无符号比较)

    # 加载存储指令
    # 假设内存基地址为 0x0，使用 x0 作为基地址寄存器
    sw x1, 0(x0)              # 将 x1 的值存储到内存地址 0x0
    lw x25, 0(x0)             # 从内存地址 0x0 加载数据到 x25

    # 分支指令
    beq x1, x2, branch_false  # 如果 x1 == x2 则跳转到 branch_false，实际不跳转
    bne x1, x2, branch_true   # 如果 x1 != x2 则跳转到 branch_true，实际跳转
    j branch_end              # 无条件跳转到 branch_end

branch_false:
    li x26, 0x00              # 不会执行到这里
    j branch_end

branch_true:
    li x26, 0x01              # x26 = 1

branch_end:
    bge x1, x2, branch_greater_equal # 如果 x1 >= x2 则跳转到 branch_greater_equal，实际跳转
    blt x1, x2, branch_less_than    # 如果 x1 < x2 则跳转到 branch_less_than，实际不跳转

branch_greater_equal:
    li x27, 0x01              # x27 = 1

branch_less_than:
    bgeu x1, x2, branch_greater_equal_unsigned # 如果 x1 >= x2 无符号比较 则跳转，实际跳转
    bltu x1, x2, branch_less_than_unsigned    # 如果 x1 < x2 无符号比较 则跳转，实际不跳转

branch_greater_equal_unsigned:
    li x28, 0x01              # x28 = 1

branch_less_than_unsigned:

    # 跳转指令
    jal x29, jump_label       # 跳转到 jump_label 并将下一条指令地址保存到 x29
    addi x30, x0, 0           # 不会执行到这里

jump_label:
    addi x30, x0, 1           # x30 = 1
    jalr x31, x0, 0xa8           # 从当前地址继续执行，这里只是示例

    # 系统调用相关指令（假设环境支持）
    # ecall                   # 系统调用，可用于结束程序等操作

    # 将结果存储到内存以便检查
    sw x5, 0x10(x0)           # 存储到地址 0x10
    sw x6, 0x14(x0)           # 存储到地址 0x14
    sw x7, 0x18(x0)           # 存储到地址 0x18
    sw x8, 0x1C(x0)           # 存储到地址 0x1C
    sw x9, 0x20(x0)           # 存储到地址 0x20
    sw x10, 0x24(x0)          # 存储到地址 0x24
    sw x11, 0x28(x0)          # 存储到地址 0x28
    sw x12, 0x2C(x0)          # 存储到地址 0x2C
    sw x13, 0x30(x0)          # 存储到地址 0x30
    sw x14, 0x34(x0)          # 存储到地址 0x34
    sw x15, 0x38(x0)          # 存储到地址 0x38
    sw x16, 0x3C(x0)          # 存储到地址 0x3C
    sw x17, 0x40(x0)          # 存储到地址 0x40
    sw x18, 0x44(x0)          # 存储到地址 0x44
    sw x19, 0x48(x0)          # 存储到地址 0x48
    sw x20, 0x4C(x0)          # 存储到地址 0x4C
    sw x21, 0x50(x0)          # 存储到地址 0x50
    sw x22, 0x54(x0)          # 存储到地址 0x54
    sw x23, 0x58(x0)          # 存储到地址 0x58
    sw x24, 0x5C(x0)          # 存储到地址 0x5C
    sw x25, 0x60(x0)          # 存储到地址 0x60
    sw x26, 0x64(x0)          # 存储到地址 0x64
    sw x27, 0x68(x0)          # 存储到地址 0x68
    sw x28, 0x6C(x0)          # 存储到地址 0x6C
    sw x29, 0x70(x0)          # 存储到地址 0x70
    sw x30, 0x74(x0)          # 存储到地址 0x74
    sw x31, 0x78(x0)          # 存储到地址 0x78

    # 无限循环结束程序
loop:
    j loop