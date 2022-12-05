`timescale 1ns/1ns
//其实这个模块在这里面是有一定的问题的，因为这个CP0是放在CPU的内部并不是CPU的外部所以会有一些问题，我现在的一个目标就是把这一份代码当中不是特别完善的地方给弄完善一点就可以了
module cp0(
    input clk,
    input rst,
    input mfc0,//from cpu
    input mtc0,//from cpu
    input [31:0] pc,
    input [4:0] Rd,//from cpu specifies cp0's register
    input [31:0] wdata,//从GP到CP0的内容
    input exception,//是否出现异常的标志？
    input eret,
    input [4:0] cause,
    //input intr,
    output [31:0] rdata,//从cp0到GP的
    output [31:0] status,
    //output reg timer_int,
    output reg [31:0] exc_addr //开始中断的时候给到PC的值
);
    parameter EXC_syscall=5'b01000,EXC_break=5'b01001,EXC_teq=5'b01101;//我自己瞎写的EXC_teq=5'b01010;
    parameter reg_status=5'd12,         reg_cause=5'd13,        reg_epc=5'd14;//这个是寄存器的标号
    parameter IE=5'd0,IM_syscall=5'd8,IM_break=5'd9,IM_teq=5'd10;//中断静止，和三个屏蔽
    reg [31:0] regfiles [0:31];//定义了三十一个寄存器，但是我们只需要用到当中的3个就可以了
    
    assign rdata = mfc0? regfiles[Rd]:32'hxxxxxxxx;
    assign status = regfiles[reg_status];
    always@(negedge clk or posedge rst)
    begin
        if(rst)
        begin
            regfiles[reg_status]<=32'h00000701;//0000_0000_0000_0000_0000_0111_0000_0001
            regfiles[reg_cause]<=32'h0;
            regfiles[reg_epc]<=32'h0;
            exc_addr<=32'h0;
        end
        else if(mtc0)//由rd和sel选择协处理器0中的特殊寄存器，把通用寄存器 rt中的内容转移到特殊寄存器中。
        begin
            regfiles[Rd]<=wdata;//这个也就是 选择到的协处理器的特殊寄存器吧
        end  
        else if(exception)//如果出现了异常情况
        begin
            if(eret)//ERET返回到中断指令在所有中断处理过程结束后。ERET不执行下一条指令
            begin
                regfiles[reg_status]<=regfiles[reg_status]>>5;//右移5位，开中断
                exc_addr<=regfiles[reg_epc];//就给到我们的pc以我们现在的值
            end
            else 
            begin
                case(cause)//如果不是eret，那么看我们的异常原因
                    EXC_syscall:
                    begin
                        // if(regfiles[reg_status][IE]&regfiles[reg_status][IM_syscall])
                        if(1)
                        begin
                            exc_addr<=32'h00400004;
                            regfiles[reg_status]<=regfiles[reg_status]<<5;//左移五位，关中断
                            regfiles[reg_epc]<=pc;//当前的pc存放进来
                            regfiles[reg_cause][6:2]<=EXC_syscall;
                        end
                        else
                        begin
                            // exc_addr<=pc+4;
                            exc_addr<=pc;
                        end
                    end
                    EXC_break:
                    begin
                        // if(regfiles[reg_status][IE]&regfiles[reg_status][IM_break])
                        if(1)
                        begin
                            exc_addr<=32'h00400004;
                            regfiles[reg_status]<=regfiles[reg_status]<<5;//左移五位，关中断，status看样子还没过来
                            regfiles[reg_epc]<=pc;
                            regfiles[reg_cause][6:2]<=EXC_break;
                        end
                        else
                        begin
                            // exc_addr<=pc+4;
                            exc_addr<=pc;
                        end
                    end
                    EXC_teq:
                    begin
                        // if(regfiles[reg_status][IE]&regfiles[reg_status][IM_teq])
                        if(1)
                        begin
                            exc_addr<=32'h00400004;
                            regfiles[reg_status]<=regfiles[reg_status]<<5;//左移五位，关中断
                            regfiles[reg_epc]<=pc;
                            regfiles[reg_cause][6:2]<=EXC_teq;
                        end
                        else
                        begin
                            // exc_addr<=pc+4;
                            exc_addr<=pc;
                        end
                    end
                    default:;
                endcase
            end
        end
    end
endmodule


/*
异常中断控制实现
在异常中断控制功能的实现中，我们做如下规定：
实现的异常包括断点指令break和系统调用syscall以及自陷指令teq；  
异常发生时保存  当前指令的地址  作为返回地址；
响应异常时把    Status寄存器的内容  左移5位 关中断；
执行中断处理程序时保存Status寄存器内容，中断返回时写回；
异常入口地址为 0x4。

*/