实验代码中vivado工程文件共有五个
每个工程文件内都有：
constraints（存放约束文件）
resources（存放verilog源代码）
instructions（存放需要的指令，asm或dat或coe文件）

其中 :
1.SINGLE_CYCLE_1_SIMULATION.zip 中存放的是单周期CPU仿真的结果
2.PIPELINE_3_SIMULATION.zip中存放的是流水线CPU仿真的结果
3.PIPELINE_3_AC.INSTRUCTION.zip中存放的是流水线CPU执行AC测试指令集（testac）的结果
4.PIPELINE_3_SNAKE.INSTRUCTION.zip中存放的是流水线CPU执行贪吃蛇指令集（snake）的结果
5.PIPELINE_4_APPLICATION.zip中存放的是用RISC-V汇编编写的简单应用程序（求输入数字n的平方）的执行结果