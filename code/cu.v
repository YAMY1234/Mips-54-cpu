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
    
    //�������еĶ�Ӧָ��ı�ţ���Ӧ6λ��ű�ʾ
    parameter ADD=6'd1,ADDU=6'd2,SUB=6'd3,SUBU=6'd4,AND=6'd5,OR=6'd6,XOR=6'd7,NOR=6'd8,SLT=6'd9,SLTU=6'd10,SLL=6'd11,SRL=6'd12,SRA=6'd13,SLLV=6'd14,SRLV=6'd15,SRAV=6'd16,JR=6'd17,
    ADDI=6'd18,ADDIU=6'd19,ANDI=6'd20,ORI=6'd21,XORI=6'd22,LW=6'd23,SW=6'd24,BEQ=6'd25,BNE=6'd26,SLTI=6'd27,SLTIU=6'd28,LUI=6'd29,J=6'd30,JAL=6'd31,
    DIV=6'd32,DIVU=6'd33,MUL=6'd34,MULTU=6'd35,BGEZ=6'd36,JALR=6'd37,LBU=6'd38,LHU=6'd39,LB=6'd40,LH=6'd41,SB=6'd42,SH=6'd43,BREAK=6'd44,SYSCALL=6'd45,ERET=6'd46,MFHI=6'd47,MFLO=6'd48,
    MTHI=6'd49,MTLO=6'd50,MFC0=6'd51,MTC0=6'd52,CLZ=6'd53,TEQ=6'd54;//���������˵�����ǵ�mult�����mul
    
    //�������е�״̬���
    parameter SIF = 4'b0000, SID = 4'b0001, SEXE_M = 4'b0010, SEXE_DIV = 4'b0011, SEXE_MULT = 4'b0100,SPC = 4'b0101,SEXE_J = 4'b0110, 
    SEXE_LS = 4'b0111, SEXE_B1 = 4'b1000, SEXE_BREAK = 4'b1001, SEXE_ALU = 4'b1010, SWB_REG = 4'b1011, SMEM_LS = 4'b1100, SEXE_B2 = 4'b1101;

    //״̬�Ĵ���
    reg [3:0] state;
    
    /******************��·ѡ�����Ķ����־*****************/
    //PC�й�
    parameter mux_pc_NPC=8'd0,mux_pc_Rs=8'd1,mux_pc_ALU=8'd2,mux_pc_II=8'd3;
    parameter mux_pc_EPC=8'd4;//EPC�Ĵ���,�쳣����ʱ EPC��ŵ�ǰָ���ַ��Ϊ���ص�ַ��
    //regfile�������й�
    parameter mux_rf_ALU=8'd0,mux_rf_EXT1=8'd1,mux_rf_DM_Data=8'd2,mux_rf_PC=8'd3,mux_rf_CLZ=8'd4,mux_rf_HI=8'd5,mux_rf_LO=8'd6,mux_rf_CBW=8'd7,mux_rf_CHW=8'd8,mux_rf_CPR=8'd9,mux_rf_NPC=8'd10;
    //alu�������й�
    parameter mux_alu_Rs_Rt=8'd0,mux_alu_ext5_Rt=8'd1,mux_alu_Rs_EXT16=8'd2,mux_alu_x_EXT16=8'd3,mux_alu_Rs_0=8'd4,mux_alu_EXT18_PC=8'd5;
    //hi��lo�������й�
    parameter mux_hi_Rs=8'd0,mux_hi_DIV=8'd1,mux_hi_DIVU=8'd2,mux_hi_MUL=8'd3,mux_hi_MULTU=8'd4;
    parameter mux_lo_Rs=8'd0,mux_lo_DIV=8'd1,mux_lo_DIVU=8'd2,mux_lo_MUL=8'd3,mux_lo_MULTU=8'd4;

    //�쳣���ͣ�ExcCode��Exception Code����˵���쳣��ԭ�������ǵ�ʵ���У��쳣���ͺ�01000Ϊsyscall�쳣��01001Ϊbreak��01101Ϊteq��
    parameter EXC_syscall=5'b01000,EXC_break=5'b01001,EXC_teq=5'b01101;
    
    //״̬ת�Ʊ��ʵ��
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
                    state<=SWB_REG;//�����ͰѶ�Ӧ��rg��ֵ��ȥ��
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
    
    //����ÿһ��״̬�ڲ���ϸ�ڵĸ�ֵ�ʹ���
    always@(posedge clk or posedge rst)
    begin
        if(rst)//��ʼ״̬
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
                SIF:begin//SIF״̬�£���Ȼ���еĶ���ȡָ��Ĳ���
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
                              
                    IR_ena<=1;//IR�ź���Ч����ʾȡָ���������    
                end
                SPC:begin
                    IR_ena<=0;
                    
                    PC_ena<=1;//PC�ź���Ч����ʾ��PC��ֵ�����ȥ��Ҳ���ǰ�NPC��ֵ�����ȥ����˼
                    M_PC<=mux_pc_NPC;
                end
                SID:begin//SID�����������һ���ұȽ��Ի�Ķ�������һ���ڸ���
                    PC_ena<=0;
                    M_PC<=8'bxxxxxxxx;

                    case(inst)
                    ADDI,ADDIU,SLTI,LW,SW,LB,SB,LBU,LHU,LH,SH:begin
                        M_ALU<=mux_alu_Rs_EXT16;//5'b01xx0;//�����ʾ���ǰ�rs��ext16���Ž�ȥ
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
                        M_ALU<=mux_alu_Rs_Rt;//5'b00xxx;��rs��rt��ֵ���뵽���ǵ�alu����ȥ
                    BEQ,BNE,TEQ:begin//���beqд������ط��ǲ����е㲻�԰��Ҿ��ã�Ӧ������һ��İɣ����ﲻӦ����Rs_EXT16��
                        M_ALU<=mux_alu_Rs_Rt;//5'b00xxx;//�����������rs��rt�ŵ�����ȥ
                        Z_ena<=1;
                        aluc<=4'b0011;
                    end
                    BGEZ:begin
                        M_ALU<=mux_alu_Rs_0;
                        Z_ena<=1;
                        aluc<=4'b0011;
                    end
                    J,JR:;//������־�ֱ��û�У������Ҿ�����ʵ��Ӧ�õġ���ΪJ��JR�������ִ�е�����ת�йص�ָ��ܹ�ֱ�����Ͳ�Ӧ�����ӳ�һ������
                    //���Ǿ������ϵıȽϣ��Ҿ�����������Ĳ������Ǻܴ�ģ��ܶ�����ڶ�ֱ�ӵ��Ƶ���5�����ڣ������ǲ��Ǻܺ���ģ�������������Ż�
                    //����CP0���õ�λ�ã�����ǱȽϹؼ���
                    JAL:begin
                        RF_w<=1;//��ΪҪд��ǰ��PC��ֵ�����ǵ����յ�31�żĴ�������ȥ������˵��һ���Ǳ����
                        RF_waddr<=5'd31;//����ŵ����ǵ�rf31����ȥ
                        M_RF<=mux_rf_PC;//9'b1000x0xxx;//������ʲô�������뵽rf���У�������pc��ֵ���뵽rf����
                    end
                    JALR:begin
                        // // RF_w<=0;//��Ϊ���ù�rf��������һ����Ҫ����һ����rf�źŸ���Ϊ0
                        // // RF_waddr<=5'bxxxxx;
                        // // M_RF<=8'bxxxxxxxx;
                        
                        // PC_ena<=1;
                        // M_PC<=mux_pc_Rs;

                        RF_w<=1;//Ҳ��Ҫд��reg31����ȥ��
                        RF_waddr<=rd;//�����������д��addrΪʲô��rd�أ�����֣����rd������ѽ��д��ȥ����rd��Ⱥ�������ֵ��
                        M_RF<=mux_rf_PC;//������ʲô�������뵽rf���У�������pc��ֵ���뵽rf����
                    end
                    SLL,SRA,SRL:begin
                        M_ALU<=mux_alu_ext5_Rt;//��λ��ָ����ǰ����Ҫ�ƶ��Ķ����ŵ�alu����ȥ�������Ϊ�ź�
                    end
                    CLZ,MFHI,MTHI,MFLO,MTLO,MFC0,MFC0:;
                    // MFC0:
                    //     mfc0<=1;
                    // MFC0:
                    //     mtc0<=1;
                    DIV:DIV_start<=1;
                    DIVU:DIVU_start<=1;
                    MUL,MULTU:;
                    SYSCALL:begin//�����쳣�������ǰ��ֵ
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
                SEXE_ALU:begin//����ܲ�������ALU�йص�����ָ��
                    Z_ena<=1;
                    case(inst)
                    BEQ://�����ʱ��beq���Ѿ������˱Ƚϲ�����
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
                SWB_REG:begin //������й��ڴ���ʲô�������Ĵ�������ȥ��ָ��
                    Z_ena<=0;
                    M_ALU<=8'bxxxxxxxx;//5'bxxxxx;
                    EXT16_sign<=1'bx;
                    aluc<=4'bxxxx;
                
                    RF_w<=1;        
                    case(inst)
                    ADDI,ADDIU,ANDI,ORI,SLTIU,LUI,XORI,SLTI:begin
                        RF_waddr<=rt;//��ʾ����Ҫд������������Ҫ�ŵ�tr����ȥ
                        // M_RF<=mux_rf_ALU;//�������Ҽ���ȥ�ˣ��Է���һ����Ϊaddi���������Ľ��Ҳ��alu��������ģ��������еĶ��ǣ�or��lui���ǣ������ҹ���ûʲô�ã���Ϊ�����ܴ�Ҷ���
                    end
                    ADDU,AND,XOR,NOR,OR,SLL,SLLV,SLTU,SRA,SRL,SUBU,ADD,SUB,SLT,SRLV,SRAV,CLZ,MUL:begin
                        RF_waddr<=rd;//�����ʾ����Ҫд�������ݷŵ�rf�ĵ�ַ��Ҳ����Ŷ���ǵ�����Ҫ�ŵ�rd��ȥ
                        // M_RF<=mux_rf_ALU;
                    end
                    endcase
                            
                    case(inst)
                    SLTIU,SLTU:begin
                        M_RF<=mux_rf_EXT1;//9'b101x1xxxx;//Ҫ�����ext1�������ȥ�Ķ�·ѡ����
                        EXT1_n_c<=1;
                    end
                    SLTI,SLT:begin
                        M_RF<=mux_rf_EXT1;//9'b101x1xxxx;//Ҫ�����ext1�������ȥ��if��·ѡ���������ź�
                        EXT1_n_c<=0;
                    end
                    CLZ:
                        M_RF<=mux_rf_CLZ;
                    MUL:
                        M_RF<=mux_rf_LO;
                    default:M_RF<=mux_rf_ALU;//9'b101x0xxxx;//Ҫ�����alu�Ľ���������ȥ��if��·ѡ���������ź�
                    endcase
                end
                SEXE_B1:begin//BEQ,BNE,BGEZ,TEQ,Ӧ���������Ƿ���ȵıȽ�
                    M_ALU<=8'bxxxxxxxx;//5'bxxxxx;//���������ʲô��˼�أ������ɶ��û�ɣ�ֱ��ת����һ��״̬����ȥ
                    //���ԣ�ӦΪ֮ǰ��������ʱ����Ѿ������˱Ƚϲ����ˡ���������赱�У�Ϊ�˱���������һ��ִ�У����Խ����˸�ֵλXXX�Ĳ���
                    Z_ena<=0;
                    aluc<=4'bxxxx;
                    
                    if(inst==TEQ&&zero)
                    begin
                        exception<=1;
                        cause<=EXC_teq;
                    end
                end
                SEXE_B2:begin//BEQ&ZERO|BNE&~ZERO|BGEZ&~NEG  ��������״̬�ˣ�˵�������֮ǰ���ǵ�alu��ʵ�Ѿ��ǽ����˲������������ǵ�ֵ��Ӧ���Ѿ�������
                    M_ALU<=mux_alu_EXT18_PC;//������ǰѺϲ�֮������ݷŵ�pc����ȥ�����°���������������ǵ�alu����ȥext18����Ҫ���ƣ���Ϊ����һֱ���е�ͨ·
                    Z_ena<=1;
                    aluc<=4'b0010;
                    PC_ena<=1;
                    M_PC<=mux_pc_ALU;
                end
                SEXE_J:begin//ִ����ת�йص�ָ���
                    case(inst)
                    J:begin
                        PC_ena<=1;
                        M_PC<=mux_pc_II;
                    end
                    JAL:begin
                        RF_w<=0;//��Ҫ��֮ǰ��rf����Ϊ0����
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
                        // RF_w<=1;//Ҳ��Ҫд��reg31����ȥ��
                        // RF_waddr<=rd;//�����������д��addrΪʲô��rd�أ�����֣����rd������ѽ��д��ȥ����rd��Ⱥ�������ֵ��
                        // M_RF<=mux_rf_NPC;//������ʲô�������뵽rf���У�������pc��ֵ���뵽rf����
                        
                        RF_w<=0;//��Ϊ���ù�rf��������һ����Ҫ����һ����rf�źŸ���Ϊ0
                        RF_waddr<=5'bxxxxx;
                        M_RF<=8'bxxxxxxxx;
                        
                        PC_ena<=1;
                        M_PC<=mux_pc_Rs;
                    end
                    endcase        
                end
                SEXE_LS:begin //LB,LBU,LH,LHU,LW,SB,SH,SW
                    Z_ena<=1;//���������ŵ�Z�Ĵ���������ʱ�������
                    aluc<=4'b0010;
                end
                SMEM_LS:begin //�����������Щ����               
                    Z_ena<=0;//Z���Ŷ�����ȥ��
                    M_ALU<=8'bxxxxxxxx;//5'bxxxxx;
                    EXT16_sign<=1'bx;
                    aluc<=4'bxxxx;
                    
                    case(inst)
                    LW:begin
                        DM_ena<=1;
                        DM_w<=0;
                        data_type<=Wdata;//��ͨ��data�������
                        RF_w<=1;//��ȥ�ڴ浱��ȥȡ��ȡ���Ķ����Ҹ����ŵ����ǵ�RF����ȥ
                        RF_waddr<=rt;//���������Ҫ�ŵ��ļĴ����ĵ�ַ��Ҳ��������Ҫ�ŵ�rt����ȥ
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
                        data_type<=Bdata;//8�ֽ��ź�
                        RF_w<=1;
                        RF_waddr<=rt;//�����load byte�������
                        M_RF<=mux_rf_CBW;
                        CBW_sign<=1;
                    end
                    SB:begin
                        DM_ena<=1;
                        DM_w<=1;
                        data_type<=Bdata;//8�ֽ��ź�
                    end
                    LBU:begin
                        DM_ena<=1;
                        DM_w<=0;
                        data_type<=Bdata;//8�ֽ��ź�
                        RF_w<=1;
                        RF_waddr<=rt;
                        M_RF<=mux_rf_CBW;
                        CBW_sign<=0;
                    end
                    LHU:begin
                        DM_ena<=1;
                        DM_w<=0;
                        data_type<=Hdata;//�����ź�
                        RF_w<=1;
                        RF_waddr<=rt;
                        M_RF<=mux_rf_CHW;
                        CHW_sign<=0;
                    end
                    LH:begin
                        DM_ena<=1;
                        DM_w<=0;
                        data_type<=Hdata;//�����ź�
                        RF_w<=1;
                        RF_waddr<=rt;
                        M_RF<=mux_rf_CHW;
                        CHW_sign<=1;
                    end
                    SH:begin
                        DM_ena<=1;
                        DM_w<=1;
                        data_type<=Hdata;//�����ź�
                    end
                    endcase
                end
                SEXE_M:begin//MFHI,MFLO,MFC0,MTHI,MTLO,MTC0  ��Щ�¹�����Щ�Ĵ���������ź�
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
                        RF_w<=1;//��ΪҪ��mfc0���õ��Ķ����ó����ŵ����ǵļĴ��������������ѡ��Ҫ��
                        RF_waddr<=rt;
                        M_RF<=mux_rf_CPR;//��ʾ�ҵĶ�·ѡ������Ҫѡ�����CPR�ģ���������൱����һ�������ڵ�CPU��Ȼ�����ɾ�ֱ�ӿ��Թ�����
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
                    MUL:begin M_LO<=mux_lo_MUL;end//M_HI<=mux_hi_MUL; ����fyl��˵�� hi�Ĳ��־Ͳ�Ū��ȥ��
                    MULTU:begin M_HI<=mux_hi_MULTU;M_LO<=mux_lo_MULTU;end
                    endcase
                end
                SEXE_BREAK:begin//SYSCALL,ERET,BREAK
                    exception<=0;//���break��ʾ�ľ����ж��쳣�����ˣ����ڿ��Գ����˵���˼������˵��û����ģ�Ȼ�������֮�������ľͻ��Ǹ�ֵΪ��ʼֵ
                    eret<=0;
                    cause<=5'bxxxxx;
                
                    PC_ena<=1;
                    M_PC<=mux_pc_EPC;
                end
            endcase
        end
    end
endmodule