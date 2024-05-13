一：计算机组成与设计课程设计：
代码中vivado工程文件共有五个
每个工程文件内都有：
constraints（存放约束文件）
resources（存放verilog源代码）
instructions（存放需要的指令，asm或dat或coe文件）

其中 :
1.SINGLE_CYCLE_1_SIMULATION文件夹中存放的是单周期CPU仿真的结果
2.PIPELINE_3_SIMULATION文件夹中存放的是流水线CPU仿真的结果
3.PIPELINE_3_AC.INSTRUCTION文件夹中存放的是流水线CPU执行AC测试指令集（testac）的结果
4.PIPELINE_3_SNAKE.INSTRUCTION文件夹中存放的是流水线CPU执行贪吃蛇指令集（snake）的结果
5.PIPELINE_4_APPLICATION文件夹中存放的是用RISC-V汇编编写的简单应用程序（求输入数字n的平方）的执行结果

此外还有三个文件专门存放代码文件：
1.SingleCycleCpu_tb文件中存放的是单周期CPU仿真的所有.v代码文件
2.PipelineCpu_Onboard_AC_SNAKE中存放的是实现AC和SNAKE指令集的上板的所有.v代码文件
3.PipelineCpu_tb文件中存放的是流水线CPU仿真的所有.v代码文件（包含控制冒险，数据冒险实现）

二：计算机组成与设计课间实验
four module 工程文件中存放的是四大模块搭建连接的结果
four module of CPU experiment 中存放的是该工程文件中所有的.v代码文件

三：实验报告
共有：
1.计算机组成与设计课程设计实验报告
2.计算机组成与设计课件实验实验报告