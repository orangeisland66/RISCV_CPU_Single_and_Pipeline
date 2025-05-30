# RISCV_CPU_Single_and_Pipeline

 武汉大学计算机学院计算机系统基础综合设计代码
 
任务分为四个部分：单周期CPU的设计仿真与下板、多周期CPU的设计仿真与下板、基于流水线CPU的简单应用实现、基于流水线CPU的复杂应用。

# 环境
软件环境：Vivado (Windows 11)、riscv-gnu-toolchain (Ubuntu 24.04)

硬件环境：NEXYS A7 100T 开发板

# 陈述一些步骤

## 单周期CPU

使用Vivado Simulator先单独对CPU仿真，使用https://venus.cs61c.org/ 网站构建37条指令的测试机器码，无问题后上版测试testac.coe代码若能显示闪烁AC则测试通过。

**一些细节：**

1、dm_ctrl信号需要传出CPU，原代码是没有实现的。

2、dm_controller模块老师要求手写，代替edf文件，这段代码所有变量建议全部初始化（posedge rstn），否则可能代码正确运行错误或在不同版本vivado上运行结果不同。

3、仔细确认single.pdf中的信号，一个信号不对CPU就无法正确运行。

## 多周期CPU

与单周期类似，先使用Vivado Simulator单独对CPU仿真，主要修改SCPU.v（PCPU.v）文件。最后testac和贪吃蛇代码运行正确则通过。

**一些细节**：

1、可以让ai先写个大致框架，流水线寄存器的赋值建议一个个对齐赋值（类似EX_MEM_in[62:31]=var[31:0])而不是使用大括号赋值，便于调试观察。

2、熟悉使用仿真工具，追踪观察各种变量的值，确保指令执行正确。可以与单周期运行结果进行对比。这是最重要的一个环节。

3、除了RF在时钟下降沿写数据，其他所有模块均使用时钟上升沿。

4、clk_div.v时钟分频改为0:assign Clk_CPU=(SW2)? clkdiv[23] : clkdiv[0];

5、如果仿真找不出问题但是下板死活过不了，建议参考通过测试了的同学的代码在代码里找是否有逻辑错误。

## 简单应用

在流水线基础上使用riscv-gnu-toolchain交叉编译，实现具有简单交互的应用。笔者认为这个任务是最简单的一个。

**一些细节**：

1、难点主要在环境的配置，riscv-gnu-toolchain整套环境30G+，请确保磁盘空间充足。

2、使用右移运算和按位与运算获取按钮/拨码开关状态。

3、尽量使用简单语法的C语言实现，不使用库函数。这是血与汗的经验。

## 复杂应用

任务描述：

实验内容三 —— 复杂应用

例如：
・实现一款游戏，支持键盘操作和图形界面。

・实现中断，支持计数器中断等三种以上中断处理。

・实现 cache，提升 CPU 性能，给出 CPU 的主频。

・完成网口驱动，实现两块板卡之间通信。

・等等………

注意：完成复杂应用可以两人组队，明确任务分工。


笔者与https://github.com/mowang-mw 实现了一个推箱子的游戏和简单音频播放功能。

**一些细节**：

1、不需要被上面的任务局限了，NEXYS A7 100T 开发板有许多外部接口，都可以尝试实现一下（如例1中的键盘操作、例4中的网卡驱动），也可以实现CPU性能的优化，但是效果就不是那么直观。

2、设计游戏方面：

①使用简单应用中的riscv-gnu-toolchain进行交叉编译。

②重写总线，设计VGARAM，修改约束文件等。

③先测试VGA接口，实现通过VGA实现内容。

④代码建议先在计算机上测试运行，确保游戏功能的实现。之后进行以下操作：

⑤不使用复杂函数（尽量定义void函数，函数实参只使用指针、数组和变量）和任何复杂语句与不常用的关键词！不使用外部库函数，不使用多文件编译。

⑥不要定义全局变量！！！亲测无法赋值，可以使用#define语句。

⑦数组的赋值建议使用循环赋值+单独赋值而不使用int a[rol][col]={{……},{……},{……}};的方式。

⑧修改代码后在本机环境测试通过，再修改代码，将输入和输出代码改为对应总线地址，其他部分就尽量不要修改了。

最后附一张运行图片，祝所有人实验顺利。
![image](https://github.com/user-attachments/assets/90418f37-c53a-474b-9bef-6cd20698c136)

