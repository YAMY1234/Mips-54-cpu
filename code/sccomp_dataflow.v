`timescale 1ns / 1ns
// module sccomp_dataflow(
//     input clk_in,
//     input reset,
//     output [31:0] inst,
//     output [31:0] pc
// );
//     wire IM_ena;
//     wire IM_w;
//     wire DM_ena;
//     wire DM_w;
//     wire [31:0] addr;
//     wire [31:0] rdata;
//     wire [31:0] wdata;
//     wire finish;
//     wire [31:0] IM_wdata;
//     assign IM_wdata = 32'b0;

//     cpu sccpu (clk_in,reset,IM_ena,IM_w,pc,inst,DM_ena,DM_w,addr,rdata,wdata,finish);

//     memory IMEM (clk_in,IM_ena,IM_w,(pc-32'h00400000)/4,IM_wdata,inst);
//     //IMEM IMEM(pc[12:2],inst);

//     memory DMEM (clk_in,DM_ena,DM_w,(addr-32'h10010000)/4,wdata,rdata);
//     //DMEM DMEM(addr[12:2],wdata,clk_in,DM_w,rdata);

// endmodule


module sccomp_dataflow(
    input clk_in,
    input reset,
    output [31:0] inst,
    output [31:0] pc
);
    wire IM_ena;
    wire IM_w;
    wire DM_ena;
    wire DM_w;
    wire [31:0] addr;
    wire [31:0] rdata;
    wire [31:0] wdata;
    wire finish;
    wire [31:0] IM_wdata;
    assign IM_wdata = 32'b0;

    //cp0�йصĶ��� eret  cause  CP0_rdata  status   exc_addr  D_Rt
    wire mfc0,mtc0,exception;
    wire [4:0]cause;
    wire [4:0]Rd;
    wire [31:0]status,exc_addr,CP0_rdata,D_Rt,real_pc;//���D_RT����wdata

    cpu sccpu (clk_in,reset,IM_ena,IM_w,pc,inst,DM_ena,DM_w,addr,rdata,wdata,finish,mfc0,mtc0,Rd,D_Rt,exception,eret,cause,CP0_rdata,status,exc_addr,real_pc);

    IMEM IMEM(pc[12:2],inst);

    DMEM DMEM(addr[12:2],wdata,clk_in,DM_w,rdata);

    cp0  CP0 (clk_in, reset,  mfc0, mtc0, real_pc, Rd, D_Rt, exception, eret, cause, CP0_rdata, status, exc_addr);

endmodule


/*
    output mfc0,//from cpu
    output mtc0,//from cpu
    output [4:0] rd,//from cpu specifies cp0's register
    output [31:0] D_Rt,//��GP��CP0������
    output exception,//�Ƿ�����쳣�ı�־��
    output eret,
    output [4:0] cause,
    input [31:0] CP0_rdata,//��cp0��GP��
    input [31:0] status,
    input reg [31:0] exc_addr //��ʼ�жϵ�ʱ�����PC��ֵ
*/