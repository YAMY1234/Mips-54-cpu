`timescale 1ns / 1ns
module cu(
    input clk,
    input rst,
    input zero,
    input negative,
    output reg DIV_start,
    output reg DIVU_start,
    input DIV_busy,
    input DIVU_busy,
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] rd,
    input [4:0] shamt,
    input [15:0] immediate,
    input [25:0] address,
    input [5:0] inst,
    
    output reg PC_ena,
    output IM_ena, 
    output IM_w,
    output reg IR_ena,
    output reg DM_ena,   
    output reg DM_w,
    output reg [1:0] data_type,
    output reg RF_w,
    output reg [4:0] RF_waddr,
    output reg Z_ena,
    output reg [3:0] aluc,
    output reg HI_ena,
    output reg LO_ena,
    output reg [7:0] M_PC,
    output reg [7:0] M_RF,
    output reg [7:0] M_ALU,
    output reg [7:0] M_HI,
    output reg [7:0] M_LO,
    output reg EXT16_sign,
    output reg EXT1_n_c,
    output reg CBW_sign,
    output reg CHW_sign,
    output reg mfc0,
    output reg mtc0,
    output reg exception,
    output reg eret,
    output reg [4:0] cause,
    output reg finish,
    output reg [1:0]jump_class,
    output reg [4:0]T
    );
    assign IM_ena = 1;
    assign IM_w = 0;
    


    parameter Wdata=2'b00,Hdata=2'b01,Bdata=2'b10;
    
    //定义所有的对应指令的标号，对应6位编号表示
    parameter ADD=6'd1,ADDU=6'd2,SUB=6'd3,SUBU=6'd4,AND=6'd5,OR=6'd6,XOR=6'd7,NOR=6'd8,SLT=6'd9,SLTU=6'd10,SLL=6'd11,SRL=6'd12,SRA=6'd13,SLLV=6'd14,SRLV=6'd15,SRAV=6'd16,JR=6'd17,
    ADDI=6'd18,ADDIU=6'd19,ANDI=6'd20,ORI=6'd21,XORI=6'd22,LW=6'd23,SW=6'd24,BEQ=6'd25,BNE=6'd26,SLTI=6'd27,SLTIU=6'd28,LUI=6'd29,J=6'd30,JAL=6'd31,
    DIV=6'd32,DIVU=6'd33,MUL=6'd34,MULTU=6'd35,BGEZ=6'd36,JALR=6'd37,LBU=6'd38,LHU=6'd39,LB=6'd40,LH=6'd41,SB=6'd42,SH=6'd43,BREAK=6'd44,SYSCALL=6'd45,ERET=6'd46,MFHI=6'd47,MFLO=6'd48,
    MTHI=6'd49,MTLO=6'd50,MFC0=6'd51,MTC0=6'd52,CLZ=6'd53,TEQ=6'd54;//这里相对来说把我们的mult变成了mul
    
    //定义所有的状态编号
    parameter SIF = 4'b0000, SID = 4'b0001, SEXE_M = 4'b0010, SEXE_DIV = 4'b0011, SEXE_MULT = 4'b0100,SPC = 4'b0101,SEXE_J = 4'b0110, 
    SEXE_LS = 4'b0111, SEXE_B1 = 4'b1000, SEXE_BREAK = 4'b1001, SEXE_ALU = 4'b1010, SWB_REG = 4'b1011, SMEM_LS = 4'b1100, SEXE_B2 = 4'b1101;

    //状态寄存器
    reg [3:0] state;
    
    /******************多路选择器的定义标志*****************/
    //PC有关
    parameter mux_pc_NPC=8'd0,mux_pc_Rs=8'd1,mux_pc_ALU=8'd2,mux_pc_II=8'd3;
    parameter mux_pc_EPC=8'd4;//EPC寄存器,异常发生时 EPC存放当前指令地址作为返回地址。
    //regfile的输入有关
    parameter mux_rf_ALU=8'd0,mux_rf_EXT1=8'd1,mux_rf_DM_Data=8'd2,mux_rf_PC=8'd3,mux_rf_CLZ=8'd4,mux_rf_HI=8'd5,mux_rf_LO=8'd6,mux_rf_CBW=8'd7,mux_rf_CHW=8'd8,mux_rf_CPR=8'd9,mux_rf_NPC=8'd10;
    //alu的输入有关
    parameter mux_alu_Rs_Rt=8'd0,mux_alu_ext5_Rt=8'd1,mux_alu_Rs_EXT16=8'd2,mux_alu_x_EXT16=8'd3,mux_alu_Rs_0=8'd4,mux_alu_EXT18_PC=8'd5;
    //hi，lo的输入有关
    parameter mux_hi_Rs=8'd0,mux_hi_DIV=8'd1,mux_hi_DIVU=8'd2,mux_hi_MUL=8'd3,mux_hi_MULTU=8'd4;
    parameter mux_lo_Rs=8'd0,mux_lo_DIV=8'd1,mux_lo_DIVU=8'd2,mux_lo_MUL=8'd3,mux_lo_MULTU=8'd4;

    //异常类型（ExcCode：Exception Code）：说明异常的原因。在我们的实验中，异常类型号01000为syscall异常，01001为break，01101为teq。
    parameter EXC_syscall=5'b01000,EXC_break=5'b01001,EXC_teq=5'b01101;
    
    //状态转移表的实现
    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            state<=SIF;
            finish<=1;
            T<=5'b00001;
        end
        else
        begin
            case(state)
            SIF:begin
                state<=SPC;
                finish<=0;
                T<=5'b00010;
            end
            SPC:begin
                state<=SID;
                T<=5'b00100;
            end
            SID:begin
                T<=5'b01000;

                case(inst)
                MFHI,MFLO,MFC0,MTC0,MTHI,MTLO:state<=SEXE_M;
                DIV,DIVU:state<=SEXE_DIV;
                MUL,MULTU:state<=SEXE_MULT;
                CLZ:state<=SWB_REG;
                J,JAL,JR,JALR:state<=SEXE_J;
                LB,LBU,LH,LHU,LW,SB,SH,SW:state<=SEXE_LS;
                BEQ,BNE,BGEZ,TEQ:state<=SEXE_B1;
                SYSCALL,ERET,BREAK:state<=SEXE_BREAK;
                default:state<=SEXE_ALU;
                endcase
            end
            SEXE_DIV:begin
                T<=5'b00001;

                if((inst==DIV&&DIV_busy)||(inst==DIVU&&DIVU_busy)) state<=SEXE_DIV;
                else begin 
                    state<=SIF;
                    finish<=1;
                end
            end
            SEXE_LS:begin
                T<=5'b10000;
                state<=SMEM_LS;
            end
            SEXE_B1:begin
                T<=5'b00001;
                if((inst==BEQ&&zero)||(inst==BNE&&~zero)||(inst==BGEZ&&~negative)) state<=SEXE_B2;
                else if(inst==TEQ&&zero) state<=SEXE_BREAK;
                else begin
                    state<=SIF;
                    finish<=1;
                end
            end
            SEXE_ALU:begin
                T<=5'b10000;
                state<=SWB_REG;
            end
            SEXE_B2:begin
                T<=5'b00001;
                if(inst==TEQ)  state<=SEXE_BREAK;
                else
                begin
                    state<=SIF;
                    finish<=1;
                end
            end
            SEXE_BREAK,SWB_REG,SMEM_LS,SEXE_J,SEXE_MULT,SEXE_M:
            begin
                if(inst==MUL&&state==SEXE_MULT)begin
                    T<=5'b10000;
                    state<=SWB_REG;//这样就把对应的rg赋值进去了
                end
                else begin
                    T<=5'b00001;
                    state<=SIF;
                    finish<=1;
                end
            end
            endcase
        end
    end
    
    //对于每一种状态内部的细节的赋值和处理
    always@(posedge clk or posedge rst)
    begin
        if(rst)//初始状态
        begin
            DIV_start<=0;
            DIVU_start<=0;
            PC_ena<=0;
            IR_ena<=0;
            M_PC<=8'bxxxxxxxx;
            DM_ena<=0;
            DM_w<=0;
            RF_w<=0;
            Z_ena<=0;
            aluc<=4'bxxxx;
            HI_ena<=0;
            LO_ena<=0;
            RF_waddr<=5'bxxxxx;
            M_RF<=8'bxxxxxxxx;
            M_ALU<=8'bxxxxxxxx;
            M_HI<=8'bxxxxxxxx;
            M_LO<=8'bxxxxxxxx;
            EXT16_sign<=1'bx;
            EXT1_n_c<=1'bx;
            CBW_sign<=1'bx;
            CHW_sign<=1'bx;
            mfc0<=0;
            mtc0<=0;
            exception<=0;
            eret<=0;
            cause<=5'bxxxxx;
            jump_class=2'b00;
        end
        else
        begin
            case(state)
                SIF:begin//SIF状态下，必然所有的都是取指令的步骤
                    DIV_start<=0;
                    DIVU_start<=0;
                    PC_ena<=0;
                    M_PC<=8'bxxxxxxxx;
                    DM_ena<=0;
                    DM_w<=0;
                    data_type<=2'bxx;
                    RF_w<=0;
                    RF_waddr<=5'bxxxxx;
                    M_RF<=8'bxxxxxxxx;
                    EXT1_n_c<=1'bx;
                    M_ALU<=8'bxxxxxxxx;//5'bxxxxx;
                    Z_ena<=0;
                    aluc<=4'bxxxx;
                    HI_ena<=0;
                    LO_ena<=0;
                    M_HI<=8'bxxxxxxxx;
                    M_LO<=8'bxxxxxxxx;
                    CBW_sign<=1'bx;
                    CHW_sign<=1'bx;
                    mfc0<=0;
                    mtc0<=0;
                    jump_class<=2'b00;
                              
                    IR_ena<=1;//IR信号有效，表示取指令放在这里    
                end
                SPC:begin
                    IR_ena<=0;
                    
                    PC_ena<=1;//PC信号有效，表示把PC的值输入进去，也就是把NPC的值输入进去的意思
                    M_PC<=mux_pc_NPC;
                end
                SID:begin//SID的这个部分是一个我比较迷惑的东西，这一步在干嘛
                    PC_ena<=0;
                    M_PC<=8'bxxxxxxxx;

                    case(inst)
                    ADDI,ADDIU,SLTI,LW,SW,LB,SB,LBU,LHU,LH,SH:begin
                        M_ALU<=mux_alu_Rs_EXT16;//5'b01xx0;//这个表示的是把rs和ext16给放进去
                        EXT16_sign<=1;
                    end
                    ANDI,ORI,SLTIU,XORI:begin
                        M_ALU<=mux_alu_Rs_EXT16;//5'b01xx0;
                        EXT16_sign<=0;
                    end
                    LUI:begin
                        M_ALU<=mux_alu_x_EXT16;//5'bx1xx0;
                        EXT16_sign<=0;
                    end
                    ADDU,AND,XOR,NOR,OR,SLLV,SLTU,SUBU,ADD,SUB,SLT,SRLV,SRAV:
                        M_ALU<=mux_alu_Rs_Rt;//5'b00xxx;将rs，rt的值放入到我们的alu当中去
                    BEQ,BNE,TEQ:begin//这个beq写到这个地方是不是有点不对啊我觉得，应该是有一点的吧，这里不应该是Rs_EXT16吗
                        M_ALU<=mux_alu_Rs_Rt;//5'b00xxx;//这个是让你让rs、rt放到里面去
                        Z_ena<=1;
                        aluc<=4'b0011;
                    end
                    BGEZ:begin
                        M_ALU<=mux_alu_Rs_0;
                        Z_ena<=1;
                        aluc<=4'b0011;
                    end
                    J,JR:;//这个部分就直接没有，但是我觉得其实不应该的。因为J和JR这个部分执行的是跳转有关的指令，能够直接跳就不应该再延迟一个周期
                    //但是经过书上的比较，我觉得这个东西的差距真的是很大的，很多的周期都直接的推到了5个周期，所以是不是很合理的，这个后面再来优化
                    //关于CP0放置的位置，这个是比较关键的
                    JAL:begin
                        RF_w<=1;//因为要写当前的PC的值到我们的最终的31号寄存器里面去，所以说这一步是必须的
                        RF_waddr<=5'd31;//结果放到我们的rf31当中去
                        M_RF<=mux_rf_PC;//9'b1000x0xxx;//控制是什么东西输入到rf当中，现在是pc的值输入到rf当中
                    end
                    JALR:begin
                        // // RF_w<=0;//因为调用过rf，所以下一步需要把上一步的rf信号给置为0
                        // // RF_waddr<=5'bxxxxx;
                        // // M_RF<=8'bxxxxxxxx;
                        
                        // PC_ena<=1;
                        // M_PC<=mux_pc_Rs;

                        RF_w<=1;//也是要写到reg31里面去的
                        RF_waddr<=rd;//但是这个里面写的addr为什么是rd呢，很奇怪，这个rd很离谱呀，写进去的是rd及群里里面的值？
                        M_RF<=mux_rf_PC;//控制是什么东西输入到rf当中，现在是pc的值输入到rf当中
                    end
                    SLL,SRA,SRL:begin
                        M_ALU<=mux_alu_ext5_Rt;//移位置指令提前将需要移动的东西放到alu当中去，这个作为信号
                    end
                    CLZ,MFHI,MTHI,MFLO,MTLO,MFC0,MFC0:;
                    // MFC0:
                    //     mfc0<=1;
                    // MFC0:
                    //     mtc0<=1;
                    DIV:DIV_start<=1;
                    DIVU:DIVU_start<=1;
                    MUL,MULTU:;
                    SYSCALL:begin//三个异常处理的提前赋值
                        exception<=1;
                        cause<=EXC_syscall;
                    end
                    ERET:begin
                        exception<=1;
                        eret<=1;
                    end
                    BREAK:begin
                        exception<=1;
                        cause<=EXC_break;
                    end
                    endcase
                end
                SEXE_ALU:begin//这个管不都是与ALU有关的所有指令
                    Z_ena<=1;
                    case(inst)
                    BEQ://如果此时是beq，已经进行了比较操作了
                        aluc<=4'b0011;
                    ADDI,ADD:
                        // aluc<=4'b001x;
                        aluc<=4'b0010;
                    ADDIU,ADDU:
                        aluc<=4'b0000;
                    ANDI,AND:
                        aluc<=4'b0100;
                    ORI,OR:
                        aluc<=4'b0101;
                    SLTIU,SLTU:
                        aluc<=4'b1010;
                    LUI:
                        aluc<=4'b100x;
                    XORI,XOR:
                        aluc<=4'b0110;
                    SLTI,SLT:
                        aluc<=4'b1011;
                    NOR:
                        aluc<=4'b0111;
                    SLL,SLLV:
                        aluc<=4'b111x;
                    SRA,SRAV:
                        aluc<=4'b1100;
                    SRL,SRLV:
                        aluc<=4'b1101;
                    SUBU:
                        aluc<=4'b0001;
                    SUB:
                        aluc<=4'b0011;
                    endcase
                end
                SWB_REG:begin //这个是有关于储存什么东西当寄存器里面去的指令
                    Z_ena<=0;
                    M_ALU<=8'bxxxxxxxx;//5'bxxxxx;
                    EXT16_sign<=1'bx;
                    aluc<=4'bxxxx;
                
                    RF_w<=1;        
                    case(inst)
                    ADDI,ADDIU,ANDI,ORI,SLTIU,LUI,XORI,SLTI:begin
                        RF_waddr<=rt;//表示我们要写到的内容我们要放到tr里面去
                        // M_RF<=mux_rf_ALU;//这两行我加上去了，以防万一，因为addi，本身最后的结果也是alu里面给到的，这里所有的都是，or，lui都是，但是我估计没什么用，因为不可能大家都错
                    end
                    ADDU,AND,XOR,NOR,OR,SLL,SLLV,SLTU,SRA,SRL,SUBU,ADD,SUB,SLT,SRLV,SRAV,CLZ,MUL:begin
                        RF_waddr<=rd;//这个表示我们要写道的内容放到rf的地址，也就是哦我们的内容要放到rd里去
                        // M_RF<=mux_rf_ALU;
                    end
                    endcase
                            
                    case(inst)
                    SLTIU,SLTU:begin
                        M_RF<=mux_rf_EXT1;//9'b101x1xxxx;//要把这个ext1的输入进去的多路选择器
                        EXT1_n_c<=1;
                    end
                    SLTI,SLT:begin
                        M_RF<=mux_rf_EXT1;//9'b101x1xxxx;//要把这个ext1的输入进去的if多路选择器控制信号
                        EXT1_n_c<=0;
                    end
                    CLZ:
                        M_RF<=mux_rf_CLZ;
                    MUL:
                        M_RF<=mux_rf_LO;
                    default:M_RF<=mux_rf_ALU;//9'b101x0xxxx;//要把这个alu的结果的输入进去的if多路选择器控制信号
                    endcase
                end
                SEXE_B1:begin//BEQ,BNE,BGEZ,TEQ,应该是两者是否相等的比较
                    M_ALU<=8'bxxxxxxxx;//5'bxxxxx;//但是这个是什么意思呢，这个是啥都没干，直接转到下一个状态里面去
                    //，对，应为之前第三部的时候就已经进行了比较操作了。在这个步骤当中，为了避免重新再一次执行，所以进行了赋值位XXX的操作
                    Z_ena<=0;
                    aluc<=4'bxxxx;
                    
                    if(inst==TEQ&&zero)
                    begin
                        exception<=1;
                        cause<=EXC_teq;
                    end
                end
                SEXE_B2:begin//BEQ&ZERO|BNE&~ZERO|BGEZ&~NEG  这个是这个状态了，说明在这个之前我们的alu其实已经是进行了操作，至少我们的值都应该已经出来了
                    M_ALU<=mux_alu_EXT18_PC;//这个就是把合并之后的数据放到pc里面去，重新把这个东西给到我们的alu当中去ext18不需要控制，因为他是一直都有的通路
                    Z_ena<=1;
                    aluc<=4'b0010;
                    PC_ena<=1;
                    M_PC<=mux_pc_ALU;
                end
                SEXE_J:begin//执行跳转有关的指令集合
                    case(inst)
                    J:begin
                        PC_ena<=1;
                        M_PC<=mux_pc_II;
                    end
                    JAL:begin
                        RF_w<=0;//先要把之前的rf给置为0才行
                        RF_waddr<=5'bxxxxx;
                        M_RF<=8'bxxxxxxxx;//9'bxxxxxxxxx;
                        
                        PC_ena<=1;
                        M_PC<=mux_pc_II;
                    end
                    JR:begin
                        PC_ena<=1;
                        M_PC<=mux_pc_Rs;
                    end
                    JALR:begin
                        // RF_w<=1;//也是要写到reg31里面去的
                        // RF_waddr<=rd;//但是这个里面写的addr为什么是rd呢，很奇怪，这个rd很离谱呀，写进去的是rd及群里里面的值？
                        // M_RF<=mux_rf_NPC;//控制是什么东西输入到rf当中，现在是pc的值输入到rf当中
                        
                        RF_w<=0;//因为调用过rf，所以下一步需要把上一步的rf信号给置为0
                        RF_waddr<=5'bxxxxx;
                        M_RF<=8'bxxxxxxxx;
                        
                        PC_ena<=1;
                        M_PC<=mux_pc_Rs;
                    end
                    endcase        
                end
                SEXE_LS:begin //LB,LBU,LH,LHU,LW,SB,SH,SW
                    Z_ena<=1;//将运算结果放到Z寄存器当中暂时存放起来
                    aluc<=4'b0010;
                end
                SMEM_LS:begin //还是上面的哪些东西               
                    Z_ena<=0;//Z不放东西进去了
                    M_ALU<=8'bxxxxxxxx;//5'bxxxxx;
                    EXT16_sign<=1'bx;
                    aluc<=4'bxxxx;
                    
                    case(inst)
                    LW:begin
                        DM_ena<=1;
                        DM_w<=0;
                        data_type<=Wdata;//普通的data这个就是
                        RF_w<=1;//我去内存当中去取，取到的东西我给他放到我们的RF里面去
                        RF_waddr<=rt;//这个是我们要放到的寄存器的地址，也就是我们要放到rt里面去
                        M_RF<=mux_rf_DM_Data;//9'b1001xxx1x;
                    end
                    SW:begin
                        DM_ena<=1;
                        DM_w<=1;
                        data_type<=Wdata;
                    end
                    LB:begin
                        DM_ena<=1;
                        DM_w<=0;
                        data_type<=Bdata;//8字节信号
                        RF_w<=1;
                        RF_waddr<=rt;//这个是load byte，这个的
                        M_RF<=mux_rf_CBW;
                        CBW_sign<=1;
                    end
                    SB:begin
                        DM_ena<=1;
                        DM_w<=1;
                        data_type<=Bdata;//8字节信号
                    end
                    LBU:begin
                        DM_ena<=1;
                        DM_w<=0;
                        data_type<=Bdata;//8字节信号
                        RF_w<=1;
                        RF_waddr<=rt;
                        M_RF<=mux_rf_CBW;
                        CBW_sign<=0;
                    end
                    LHU:begin
                        DM_ena<=1;
                        DM_w<=0;
                        data_type<=Hdata;//半字信号
                        RF_w<=1;
                        RF_waddr<=rt;
                        M_RF<=mux_rf_CHW;
                        CHW_sign<=0;
                    end
                    LH:begin
                        DM_ena<=1;
                        DM_w<=0;
                        data_type<=Hdata;//半字信号
                        RF_w<=1;
                        RF_waddr<=rt;
                        M_RF<=mux_rf_CHW;
                        CHW_sign<=1;
                    end
                    SH:begin
                        DM_ena<=1;
                        DM_w<=1;
                        data_type<=Hdata;//半字信号
                    end
                    endcase
                end
                SEXE_M:begin//MFHI,MFLO,MFC0,MTHI,MTLO,MTC0  这些事关于这些寄存器里面的信号
                    case(inst)
                    MFHI:begin
                        RF_w<=1; 
                        RF_waddr<=rd;
                        M_RF<=mux_rf_HI;
                    end
                    MTHI:begin
                        HI_ena<=1;
                        M_HI<=mux_hi_Rs;
                    end
                    MFLO:begin
                        RF_w<=1;
                        RF_waddr<=rd;
                        M_RF<=mux_rf_LO;
                    end
                    MTLO:begin
                        LO_ena<=1;
                        M_LO<=mux_lo_Rs;
                    end

                    MFC0:begin
                        mfc0<=1;
                        RF_w<=1;//因为要把mfc0所得到的东西拿出来放到我们的寄存器里面所以这个选项要打开
                        RF_waddr<=rt;
                        M_RF<=mux_rf_CPR;//表示我的多路选择器是要选择这个CPR的，这个里面相当于是一个单周期的CPU，然后理解成就直接可以过来了
                    end
                    MTC0:begin
                        mtc0<=1;
                    end
                    endcase
                end
                SEXE_DIV:begin
                    HI_ena<=1;
                    LO_ena<=1;
                    case(inst)
                    DIV:begin DIV_start<=0;M_HI<=mux_hi_DIV;M_LO<=mux_lo_DIV;end
                    DIVU:begin DIVU_start<=0;M_HI<=mux_hi_DIVU;M_LO<=mux_lo_DIVU;end
                    endcase
                end
                SEXE_MULT:begin
                    HI_ena<=1;
                    LO_ena<=1;
                    case(inst)
                    MUL:begin M_LO<=mux_lo_MUL;end//M_HI<=mux_hi_MUL; 按照fyl的说法 hi的部分就不弄进去了
                    MULTU:begin M_HI<=mux_hi_MULTU;M_LO<=mux_lo_MULTU;end
                    endcase
                end
                SEXE_BREAK:begin//SYSCALL,ERET,BREAK
                    exception<=0;//这个break表示的就是中断异常结束了，现在可以出来了的意思，所以说是没问题的，然后出来了之后其他的就还是赋值为初始值
                    eret<=0;
                    cause<=5'bxxxxx;
                
                    PC_ena<=1;
                    M_PC<=mux_pc_EPC;
                end
            endcase
        end
    end
endmodule