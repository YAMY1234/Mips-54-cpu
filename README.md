 

![img](./pic_source/wps124.png) 

 

 

# 54 Instructions for Multi-Cycle CPU Design

This paper realizes the specific implementation process of multi-cycle 54 Instruction CPUs , and the whole article is divided into three major sections: the first major section is the analysis part of each Instruction, including the specific design, principle, path, and design process of 54 Instruction CPUs; The second section is the construction of the entire CPU component path diagram, according to the design concept of multi-cycle CPU, the design of multi-cycle CPU, the construction of the microprogram flow of each Instruction, and the subdivision of each state, so as to better controthe generation of bit programs. The third section has the generated controsignatable and state transition table for code writing, so that the entire CPU workflow can be completed more clearly.

Through the 54 Instruction CPU learning also let me better understand the internaprinciples and basic knowledge of the CPU, from the front to the rear simulation and finally to the lower board process is gradually completed.

keyword

Multi-cycle CPU design, MIPS54, pre-simulation, post-simulation, synthesis, lower board implementation

## 1 Programming ideas

1.1 Analysis of 54 Instructions

1. ADD

Required operation: take Instruction, rd ← rs + rt, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps125.png)

Instruction flow chart

![img](./pic_source/wps126.png)

2. ADDU

Required operation: take Instruction, rd ← rs + rt, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps127.png)

Instruction flow chart

![img](./pic_source/wps128.png)

3. SUB

Required operation: take Instruction, rd ← rs-rt, PC ← PC + 4

Required parts: PC, NPC, IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps129.png)

Instruction flow chart

![img](./pic_source/wps130.png)

4. SUBU

Required operation: take Instruction, rd ← rs-rt, PC ← PC + 4

Required parts: PC, NPC, IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps131.png)

Instruction flow chart

![img](./pic_source/wps132.png)

5. AND

Required operation: take Instruction, rd ← rs and rt, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps133.png)

Instruction flow chart

![img](./pic_source/wps134.png)

6. OR

Required operation: take Instruction, rd ← rs ot rt, PC ← PC + 4

Required parts: PC, NPC, IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps135.png)

Instruction flow chart

![img](./pic_source/wps136.png)

7. XOR

Required operation: take Instruction, rd ← rs xor rt, PC ← PC + 4

Required parts: PC, NPC, IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps137.png)

Instruction flow chart

![img](./pic_source/wps138.png)

8. NOR

Required operation: take Instruction, rd ← rs nor rt, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps139.png)

Instruction flow chart

![img](./pic_source/wps140.png)

9. SLT

Required operation: take Instruction, if (rs < rt) rd = 1 else rd = 0, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT1

Instruction pathway

![img](./pic_source/wps141.png)

Instruction flow chart

![img](./pic_source/wps142.png)

10. SLTU

Required operation: take Instruction, if (rs < rt) rd = 1 else rd = 0, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT1

Enter source table

Instruction pathway

![img](./pic_source/wps143.png)

Instruction flow chart

![img](./pic_source/wps144.png)

11. SLL

Required operation: take Instruction, rd ← rt < < shamt, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT5

Instruction pathway

![img](./pic_source/wps145.png)

Instruction flow chart

![img](./pic_source/wps146.png)

12. SRL

Required operation: take Instruction, rd ← rt > > shamt, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT5

Instruction pathway

![img](./pic_source/wps147.png)

Instruction flow chart

![img](./pic_source/wps148.png)

\13. SRA

Required operation: take Instruction, rd ← rt > > shamt, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT5

Instruction pathway

![img](./pic_source/wps149.png)

Instruction flow chart

![img](./pic_source/wps150.png)

14. SLLV

Required operation: take Instruction, rd ← rt < < rs, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps151.png)

Instruction flow chart

![img](./pic_source/wps152.png)

15. SRLV

Required operation: take Instruction, rd ← rt > > rs, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps153.png)

Instruction flow chart

![img](./pic_source/wps154.png)

16. SRAV

Required operation: take Instruction, rd ← rt > > rs, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps155.png)

Instruction flow chart

![img](./pic_source/wps156.png)

17. JR

Required operation: take Instruction, PC ← rs

Required parts: PC, NPC , IMEM, RegFiles

Instruction pathway

![img](./pic_source/wps157.png)

Instruction flow chart

![img](./pic_source/wps158.png)

18. ADDI

Required operation: take Instruction, rd ← rs + (sign-extend) immediate, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT16

Instruction pathway

![img](./pic_source/wps159.png)

Instruction flow chart

![img](./pic_source/wps160.png)

19. ADDIU

Required operation: take Instruction, rd ← rs + (zero-extend) immediate, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT16

Instruction pathway

![img](./pic_source/wps161.png)

Instruction flow chart

![img](./pic_source/wps162.png)

20. ANDI

Required operation: take Instruction, rd ← rs and (zero-extend) immediate, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT16

Instruction pathway

![img](./pic_source/wps163.png)

Instruction flow chart

![img](./pic_source/wps164.png)

21. ORI

Required operation: take Instruction, rd ← rs or (zero-extend) immediate, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT16

Instruction pathway

![img](./pic_source/wps165.png)

Instruction flow chart

![img](./pic_source/wps166.png)

22. XORI

Required operation: take Instruction, rd ← rs xor (zero-extend) immediate, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT16

Instruction pathway

![img](./pic_source/wps167.png)

Instruction flow chart

![img](./pic_source/wps168.png)

23. LW

Required operation: take Instruction, rt ← memory [rs + (signedextended) immediate], PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT16, DMEM

Instruction pathway

![img](./pic_source/wps169.png)

Instruction flow chart

![img](./pic_source/wps170.png)

24. SW

Required operation: take Instruction, memory [rs + (signedextended) immediate] ← rt, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT16, DMEM

Instruction pathway

![img](./pic_source/wps171.png)

Instruction flow chart

![img](./pic_source/wps172.png)

25. BEQ

所需操作：取指令、if(rs==rt) PC←PC+4+(sign-extend)immediate<<2 else PC←PC+4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT18, ADD

Instruction pathway

![img](./pic_source/wps173.png)

Instruction flow chart

![img](./pic_source/wps174.png)

26. BNE

所需操作：取指令、if(rs!=rt) PC←PC+4+(sign-extend)immediate<<2 else PC←PC+4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT18, ADD

Instruction pathway

![img](./pic_source/wps175.png)

Instruction flow chart

![img](./pic_source/wps176.png)

27. SLTI

Required operation: take Instruction, if (rs < (sign-extend) immediate) rt = 1 else rt = 0, PC ← PC + 4

Required parts: PC, NPC , IMEM, RegFiles, ALU, EXT1, EXT16

Instruction pathway

![img](./pic_source/wps177.png)

Instruction flow chart

![img](./pic_source/wps178.png)

28. SLTIU

Required operation: take Instruction, if (rs < (zero-extend) immediate) rt = 1 else rt = 0, PC ← PC + 4

Required parts: PC, NPC, IMEM, RegFiles, ALU, EXT1, EXT16

Instruction pathway

![img](./pic_source/wps179.png)

Instruction flow chart

![img](./pic_source/wps180.png)

29. LUI

Required operation: take Instruction, rt ← immediate < < 16, PC ← PC + 4

Required parts: PC, NPC, IMEM, RegFiles, ALU, EXT16

Instruction pathway

![img](./pic_source/wps181.png)

Instruction flow chart

![img](./pic_source/wps182.png)

30. J

Required operation: take Instruction, PC ← (PC + 4) [31:28], address, 0, 0

Required parts: PC, NPC, IMEM, RegFiles, II

Instruction pathway

![img](./pic_source/wps183.png)

Instruction flow chart

![img](./pic_source/wps184.png)

31. JAL

Required operation: Instruction, 31 dollars ← (PC + 4), PC ← (PC + 4) [31:28], address, 0, 0

Required parts: PC, NPC, IMEM, RegFiles, II, ADD4

Instruction pathway

![img](./pic_source/wps185.png)

Instruction flow chart

![img](./pic_source/wps186.png)

32. DIV

Required operation: take Instruction, PC ← (PC + 4), (hi, lo) ← rs/rt

Required parts: PC, NPC, IMEM, RegFiles, DIV, hi, lo

Instruction pathway

![img](./pic_source/wps187.png)

Instruction flow chart

![img](./pic_source/wps188.png)

33. DIVU

Required operation: take Instruction, PC ← (PC + 4), (hi, lo) ← rs/rt

Required parts: PC, NPC, IMEM, RegFiles, DIVU, hi, lo

Instruction pathway

![img](./pic_source/wps189.png)

Instruction flow chart

![img](./pic_source/wps190.png)

34. MULT

Required operation: take Instruction, PC ← (PC + 4), (hi, lo) ← rs * rt

Required parts: PC, NPC, IMEM, RegFiles, MULT, hi, lo

Instruction pathway

![img](./pic_source/wps191.png)

Instruction flow chart

![img](./pic_source/wps192.png)

35. MULTU

Required operation: take Instruction, PC ← (PC + 4), (hi, lo) ← rs * rt

Required parts: PC, NPC, IMEM, RegFiles, MULTU, hi, lo

Instruction pathway

![img](./pic_source/wps193.png)

Instruction flow chart

![img](./pic_source/wps194.png)

36. BGEZ

Required operation: take Instruction, if (rs > = 0) PC ← PC + 4 + (sign-extend) immediate < < 2 else PC ← PC + 4

Required parts: PC, NPC, IMEM, RegFiles, ALU, EXT18, ADD

Instruction pathway

![img](./pic_source/wps195.png)

Instruction flow chart

![img](./pic_source/wps196.png)

Instruction Explanation: According to whether rs is 0 to make decisions about the jump, the jump content is the current PC + 4 value and the 18-bit signed extension number shifted two bits to the left.

 

37. JALR

Required operation: take Instruction, rd (31 implied) ← return_addr, pc ← rs

Required parts: PC, NPC, IMEM, RegFiles, ALU

Instruction pathway

![img](./pic_source/wps197.png)

Instruction flow chart

![img](./pic_source/wps198.png)

Instruction Explanation: Store the current (after + 4) PC value in the rd register, put the corresponding value in the PC register, and execute the Instruction of the address in the corresponding register.

 

38. LBU

Required operation: take Instruction, PC ← (PC + 4), rt ← memory [base + offset]

Required parts: PC, NPC, IMEM, RegFiles, ALU, DMEM, CBW, EXT16

Instruction pathway

![img](./pic_source/wps199.png)

Instruction flow chart

![img](./pic_source/wps200.png)

Instruction explanation: In the effective address obtained by adding the base address and offset in memory, take the content of an 8bit byte and store it in the rt register through 0 extension (unsigned extension).

 

39. LHU

Required operation: take Instruction, PC ← (PC + 4), rt ← memory [base + offset]

Required parts: PC, NPC, IMEM, RegFiles, ALU, DMEM, CHW, EXT16

Instruction pathway

![img](./pic_source/wps201.png)

Instruction flow chart

![img](./pic_source/wps202.png)

Instruction explanation: In the memory corresponding to the effective address obtained by adding the base address and the offset, take a half-word content and store it in the rt register after 0 expansion.

 

40. LB

Required operation: take Instruction, PC ← (PC + 4), rt ← memory [base + offset]

Required parts: PC, NPC, IMEM, RegFiles, ALU, DMEM, CBW, EXT16

Instruction pathway

![img](./pic_source/wps203.png)

Instruction flow chart

![img](./pic_source/wps204.png)

Instruction explanation: In the memory corresponding to the effective address obtained by adding the base address and the offset, take an 8bit byte and store it in the rt register after signed expansion.

 

41. LH

Required operation: take Instruction, PC ← (PC + 4), rt ← memory [base + offset]

Required parts: PC, NPC, IMEM, RegFiles, ALU, DMEM, CHW, EXT16

Instruction pathway

![img](./pic_source/wps205.png)

Instruction flow chart

![img](./pic_source/wps206.png)

Instruction Explanation: In the memory corresponding to the effective address obtained by adding the base address and the offset, take a half-word length and store it in the rt register after signed expansion.

 

42. SB

Required operation: Instruction, PC ← (PC + 4), memory [base + offset] ← rt

Required parts: PC, NPC, IMEM, RegFiles, ALU, DMEM, CBW, EXT16

Instruction pathway

![img](./pic_source/wps207.png)

Instruction flow chart

![img](./pic_source/wps208.png)

Instructions Explanation: The lowest 8 bits of data in the rt register are stored in the memory of the effective address obtained by adding the base address and the offset.

 

43. SH

Required operation: Instruction, PC ← (PC + 4), memory [base + offset] ← rt

Required parts: PC, NPC, IMEM, RegFiles, ALU, DMEM, CHW, EXT16

Instruction pathway

![img](./pic_source/wps209.png)

Instruction flow chart

![img](./pic_source/wps210.png)

Instructions Explanation: The lowest 16 bits of data in the rt register are stored in the memory of the effective address obtained by adding the base address and the offset.

 

44. BREAK

Required operation: take Instruction, PC ← (PC + 4) or EPC

Required parts: PC, NPC, IMEM, CP0

Instruction pathway

![img](./pic_source/wps211.png)

Instruction flow chart

![img](./pic_source/wps212.png)

Instruction Explanation: When a breakpoint exception occurs, it wilbe transferred to exception handling immediately and uncontrollably.

 

45. SYSCALL

Required operation: take Instruction, PC ← (PC + 4) or EPC

Required parts: PC, NPC, IMEM, CP0

Instruction pathway

![img](./pic_source/wps213.png)

Instruction flow chart

![img](./pic_source/wps214.png)

Instruction Explanation: When a system calexception occurs, it wilbe transferred to exception handling immediately and uncontrollably.

 

46. ERET

Required operation: take Instruction, PC ← (PC + 4) or EPC

Required parts: PC, NPC, IMEM, CP0

Instruction pathway

![img](./pic_source/wps215.png)

Instruction flow chart

![img](./pic_source/wps216.png)

Instruction explanation: ERET returns to interrupt Instruction after alinterrupt processing has ended. ERET does not execute the next Instruction.

 

47. MFHI

Required operation: take Instruction, PC ← PC + 4, rd ← hi

Required parts: PC, NPC, IMEM, RegFIles, hi

Instruction pathway

![img](./pic_source/wps217.png)

Instruction flow chart

![img](./pic_source/wps218.png)

Instructions: Data from speciaregister HI is copied to generapurpose register rd.

 

48. MFLO

Required operation: take Instruction, PC ← PC + 4, rd ← lo

Required parts: PC, NPC, IMEM, RegFIles, lo

Instruction pathway

![img](./pic_source/wps219.png)

Instruction flow chart

![img](./pic_source/wps220.png)

Instructions: The data in the speciaregister LO is copied to the generapurpose register rd.

 

49. MTHI

Required operation: Instruction, PC ← PC + 4, hi ← rs

Required parts: PC, NPC, IMEM, RegFIles, hi

Instruction pathway

![img](./pic_source/wps221.png)

Instruction flow chart

![img](./pic_source/wps222.png)

Instruction: Copy the contents of the generapurpose register rs to the speciaregister HI.

 

50. MTLO

Required operation: Instruction, PC ← PC + 4, lo ← rs

Required parts: PC, NPC, IMEM, RegFIles, lo

Instruction pathway

![img](./pic_source/wps223.png)

Instruction flow chart

![img](./pic_source/wps224.png)

Instructions: copy the contents of the generapurpose register rs to the speciaregister LO.

 

51. MFC0

Required operation: take Instruction, PC ← PC + 4, rt ← CPR [0, rd, sel]

Required parts: PC, NPC, IMEM, RegFIles, CP0

Instruction pathway

![img](./pic_source/wps225.png)

Instruction flow chart

![img](./pic_source/wps226.png)

Instruction Explanation: The rd and seselect a speciaregister in coprocessor 0 and transfer its contents to the generapurpose register rt.

 

52. MTC0

Required operation: take Instruction, PC ← PC + 4, CPR [0, rd, sel] ← rt

Required parts: PC, NPC, IMEM, RegFIles, CP0

Instruction pathway

![img](./pic_source/wps227.png)

Instruction flow chart

![img](./pic_source/wps228.png)

Instruction Explanation: RD and SEselect speciaregisters in coprocessor 0 and transfer the contents of generapurpose register RT to speciaregisters.

 

53. CLZ

Required operations: take Instruction, PC ← PC + 4, calculate the number of leading zeros in 32-bit words, and store the results in the rd register.

Required parts: PC, NPC, IMEM, RegFIles, CLZ

Instruction pathway

![img](./pic_source/wps229.png)

Instruction flow chart

![img](./pic_source/wps230.png)

Instruction explanation: Calculate the number of 32-bit leading zeros in the rs register and store it in the rd register, similar to the function of an operation Instruction.

 

54. TEQ

Required operations: Take Instruction, PC ← PC + 4, compare the values in the rs and rt registers, and raise a self-trapping exception if they are equal.

Required parts: PC, NPC, IMEM, RegFIles, ALU, CP0

Instruction pathway

![img](./pic_source/wps231.png)

Instruction flow chart

![img](./pic_source/wps232.png)

Instruction explanation: Compare the values of registers rs and rt, and raise a self-trapping exception if they are equal.

 

### 1.5 Draw data path structure diagram

![img](./pic_source/wps233.jpg) 

Figure 1 Data path structure diagram

### 1.6 Drawing state transition diagrams

![img](./pic_source/wps234.jpg) 

Figure 2 State transition diagram

## 2 CPU Module Design

### 2.1 Module Building Architecture

The structure of the CPU of the finalower board acceptance result is shown in the figure. The topmost layer consists of two frequency dividers (divider1, divider2), the CPU top-levecalmodule (sccomp_dataflow), and the 7-segment digitatube display module (display-seg7x16), which is used to display the CPU. Among them, the sccomp_dataflow sub-module consists of four large internaCPU blocks: sccpu, IMEM, DMEM, and cp0. The specific design is as follows.

![img](./pic_source/wps235.jpg) 

The overalcomposition of the sccpu is shown in the figure:

The CPU is generally divided into six components: controller, regfile, ALU, pcreg, extend, mux, in which the controller module is in charge of Instruction decoding, and the generation and controof microprogram controsignals; regfile is the internaregister component of the CPU, which is used to store register modules; ALU component contains alarithmetic components; pcreg is the pc register component in the computer, which contains PC and IR. extend component is alsub-extension components, according to different Instructions, some words in Instruction are extended to 32 bits according to the difference between signed and unsigned.

![img](./pic_source/wps236.jpg) 

### 2.2 CPU module design

#### 2.2.1 Controller Widget

In the overaldesign which has been described, the controller means comprises a CPU which generates and processes althe internamodules microprogram controsignals, including cu, the totamodule microprogram contromodule for generating a microprogram controsignaand althe design of the microprogram content; decoder for 54 Instruction decoding according to different Instruction content, generates different information.

![img](./pic_source/wps237.jpg) 

Table 1 controller components diagram

##### 2.2.1.1 Cu parts

This component is used to generate the design and generation of almicro-Instruction controsignals. According to the position zero-hour controsignatable, it is divided into 16 main states. Each state is divided into different in-process controsignals according to different internastates.

##### 2.2.1.2 dicoder module

The Decoder module is used to decode alopcodes. According to the junction of the 31st to 25th bits of Instruction and the sixth to first bits of different Instructions, different Instruction types are given, and the operands and addresses contained in the Instruction are assigned at the same time.

#### 2.2.2 Regfile widget

The Regfile component is used to store althe internaconditions of the registers in the computer, and it contains a module - reg_cpu, which is in charge of the read and write operations of the 32 registers inside the CPU.

![img](./pic_source/wps238.jpg) 



### 2.2.3 ALU widgets

The ALU component mainly includes althe internaarithmetic units and modules, and is mainly designed ALU modules, which are the same as the 31 Instruction CPUs and are mainly responsible for the basic arithmetic functions; the instantiated Z register is used to store the arithmetic results of the ALU module; the MUmodule is ordinary multiplication Instruction; MULTU module is unsigned multiplication; DIV is a division module; DIVU module is an unsigned departure module; in addition, there are flag_save modules for storing related symbobits; HI, LO registers are used to store the result after multiplication and division.

![img](./pic_source/wps239.jpg) 

##### 2.2.3.1 ALU module

ALU module includes other ordinary calculation modules in addition to the multiplication and division method, by giving the ALUC controsignato achieve the selection of the controInstruction for the ALU module, and the operation result is sent to the result register Z among them.

##### 2.2.3.2 Z register module

By instantiating the 31-bit Z register, it is used to access the operation results of the ALU. At the same time, alsave_flag speciaflag bit storage modules are called to save the speciaflag bits generated after the alu operation.

##### 2.2.3.3 sign bit save module

The sign bit storage module actually instantiates a set of asynchronous reading modules. As shown in the figure below, it is determined by giving severabits in the result that the value of the corresponding flag bit should be negative and what value, so as to perform processing.

##### 2.2.3.4 normamultiplication module

Since the multiplication and division method Instruction cannot be carried out within another Instruction cycle, alInstructions are divided into clock cycles here, and the busy signais set to guide the entire multiplication and division method Instruction. After the completion, the busy signaInstruction can be put into the machine. Enter the micro-Instruction link of the next cycle.

##### 2.2.3.5 unsigned multiplication module

The instruction is an unsigned Multiplication Instruction MULTU. Since the Multiplication and Division Instruction cannot be performed within another Instruction cycle, alInstructions are divided into clock cycles, and the busy signais set to guide the entire Multiplication and Division Instruction method. After the completion of the Instruction, the busy signaInstruction can be used, and the machine enters the micro-Instruction link of the next cycle.

#### 2.2.3.6 normadivision module

The instruction is a normasigned division DIV. Since the multiplication and division method Instruction cannot be performed within one instruction cycle, alInstructions are divided into clock cycles, and the busy signais set to guide the entire multiplication and division method Instruction to complete.

##### 2.2.3.7 unsigned division module

The instruction is unsigned division DIVU. Since the multiplication and division method Instruction cannot be performed within another Instruction cycle, alInstructions are divided into clock cycles, and the busy signais set to guide the entire multiplication and division method Instruction to complete.

2.2.3.8 HI/LO registers

The HI/LO register is the storage location of the result after the end of the multiplication and division method Instruction, wherein the upper 32 bits are stored in the HI register, and the lower 32 bits are stored in the LO register.

#### 2.2.4 PC registers

PC registers are mainly used to store registers related to PC, including the Instruction register IR, the program counter PC, and the NPC with an Instruction address. The PC register out_pc that represents the output of the next cycle in order to meet the test requirements.

![img](./pic_source/wps240.jpg) 

##### 2.2.4.1 Pcreg

The 32-bit register used to store the pc has a relatively simple function and wilnot be repeated.

##### 2.2.4.2 INST_save

Instructions used to save the decoded content

##### 2.2.4.3 NPC

Used to store the next (non-jump case) Instruction address, NPC = PC + 4.

##### 2.2.4.4 Reg_pc

The pc value intermediate staging register used in jalr Instruction to swap with the value of register 31.

#### 2.2.5 EXTEND widget

The Extend component is mainly used to intercept the immediate number, offset and other content of the Instruction word for word expansion, and the finaexpansion result is required to 32 bits. The specific extension content includes, ext1 (one-bit extension); ext16 (sixteen-bit signed/unsigned extension); ext18 (18-bit signed/unsigned extension) | | (splicing Function), etc. The specific content is shown in the following figure:

![img](./pic_source/wps241.jpg) 

##### 2.2.5.1 Ext1_n/Ext1_c

One expansion part needs to select carry signaor negative signafor expansion

##### 2.2.5.2 EXT5

Extend the shamt5 bits contained in Instruction and expand it to 32 bits.

##### 2.2.5.3 EXT16

Extends the last 16 bits of the immediate number contained in the Instruction to 32 bits, which are divided into signed and unsigned types.

##### 2.2.5.4 EXT18

Expand the last 16 bits of the immediate number contained in the Instruction, shift it two bits to the left to 18 bits, and then expand it to 32 bits.

#### 2.2.6 MUX widget

The MUX component inherits the part of the multiplexer among alcomponents, including the multiplexer of the pc, the multiplexer of the alu input port, the multiplexer of the write port of the regfile, and the multiplexer of the input to the hi port.

![img](./pic_source/wps242.jpg) 

##### 2.2.6.1 Mux_pc

A multiplexer that stores the input of pc-related values, selected according to different sets of different inputs that wilbe input to pc values:

##### 2.2.6.2 Mux_alu

Stored with the input value of the multiplexer ALU, according to a plurality of different sets of different inputs to be input to the ALU value to be selected; and here is divided into a different ALU input port A port and the ALU input port B port.

##### 2.2.6.3 Mux_rf

The multiplexer storing the input of the regfile-related value is selected according to different sets of different inputs to be input to the regfile value; at the same time, it is divided into 31 regfile input addresses, and the specific input addresses are given by the ref_addr.

##### 2.2.6.4 Mux_HI

The multiplexer that stores the results related to multiplication and division is selected according to different sets of different inputs to be input to the hi value; here it is divided into four different Instructions of DIV/DIVU/MUL/MULTU.

##### 2.2.6.5 Mux_LO

The multiplexer that stores the results related to multiplication and division is selected according to different sets of different inputs to be input to the lo value; here it is divided into four different Instructions of DIV/DIVU/MUL/MULTU.

### 2.3 CPU Module Test

#### 2.3.1 Front True Test

2.3.1.1 test overview and code implementation

The pre-simulation test checks the correctness of the result of the run for a given Instruction by checking whether the value of each register is consistent with the required one. It is carried out by instantiating the sccpu, and the method of $fdisplay is used at the same time.



##### 2.3.1.2 test result

Example of pre-simulation waveform diagram:

![img](./pic_source/wps243.jpg) 

Example of pre-simulation output:

![img](./pic_source/wps244.jpg) 

#### 2.3.2 post simulation test

##### After 2.3.2.1 simulation test overview and code implementation

The post-simulation test cannot detect intermediate variables welbecause it cannot output alregister values. The specific test code is as follows:

##### Simulation test results after 2.3.2.2

Example of post-simulation waveform results

![img](./pic_source/wps245.jpg) 

### 2.4 CPU lower board implementation

The result of the CPU lower board is shown in the figure below

![img](./pic_source/wps246.jpg) 

 

## 3 Experience

### 3.1 Experience

① Through this 54 multi-cycle CPU design experiments, I have basically mastered the design method of non-pipelined CPU, have a further understanding of the internaexecution mechanism of CPU, and strengthen the hands-on ability.

② In the process of writing multiple cycles, I realized that Instruction works in different cycles. Combined with the knowledge about CPU learned in books, practice is the only criterion for testing the truth, and I have a deeper understanding of the CPU work cycle. However, I have a deep understanding of the internaarchitecture and composition of the CPU, and when I complete the CPU, I can better understand the content of the CPU.

③ Through the process of writing Verilog code to realize MIPS54-bit single-cycle CPU, the thinking ability of Hardware design is exercised and improved, and the writing skills of Verilog language are improved; the verilog code corresponding to the path can be constructed according to the internapath of the CPU in a relatively fast time.

④ The working principle of the various components learned in the "DigitaLogic" course has been strengthened, and new methods are used to write them, continuous improvement, and the spirit of engineering practice has been cultivated; so that we can skillfully use the MIPS31cpu and The content learned in the previous digitalogic class is applied to the learning process of 54 Instruction CPUs.

⑤ There wilbe many problems in the process of practice. The process of gradually solving problems is a process of graduaprogress and learning. The study of theory stilhas to be matched with practice in order to truly accept knowledge.

### 3.2 Experiment Summary

This paper realizes the specific implementation process of multi-cycle 54 Instruction CPUs. The whole article is divided into three major sections: the first major section is the analysis part of each Instruction, including the specific design, principle, path, and design process of 54 Instruction CPUs; the second section is the construction of the entire CPU component path diagram, according to the design concept of multi-cycle CPU, the design of multi-cycle CPU, the construction of the microprogram flow of each Instruction, and the subdivision of each state, so as to better controthe generation of bit programs. The third section has the generated controsignatable and state transition table for code writing, so that the entire CPU workflow can be completed more clearly.

Through this 54 Instruction CPU learning also let me better understand the internaprinciples and basic knowledge of the CPU, from the front to the rear simulation and finally to the lower board process is gradually completed. In the future CPU more in-depth learning process which wilfurther understand more knowledge of the CPU, so as to better promote their understanding of the CPU and other Hardware knowledge.

 