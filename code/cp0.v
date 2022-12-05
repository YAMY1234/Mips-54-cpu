`timescale 1ns/1ns
//��ʵ���ģ��������������һ��������ģ���Ϊ���CP0�Ƿ���CPU���ڲ�������CPU���ⲿ���Ի���һЩ���⣬�����ڵ�һ��Ŀ����ǰ���һ�ݴ��뵱�в����ر����Ƶĵط���Ū����һ��Ϳ�����
module cp0(
    input clk,
    input rst,
    input mfc0,//from cpu
    input mtc0,//from cpu
    input [31:0] pc,
    input [4:0] Rd,//from cpu specifies cp0's register
    input [31:0] wdata,//��GP��CP0������
    input exception,//�Ƿ�����쳣�ı�־��
    input eret,
    input [4:0] cause,
    //input intr,
    output [31:0] rdata,//��cp0��GP��
    output [31:0] status,
    //output reg timer_int,
    output reg [31:0] exc_addr //��ʼ�жϵ�ʱ�����PC��ֵ
);
    parameter EXC_syscall=5'b01000,EXC_break=5'b01001,EXC_teq=5'b01101;//���Լ�Ϲд��EXC_teq=5'b01010;
    parameter reg_status=5'd12,         reg_cause=5'd13,        reg_epc=5'd14;//����ǼĴ����ı��
    parameter IE=5'd0,IM_syscall=5'd8,IM_break=5'd9,IM_teq=5'd10;//�жϾ�ֹ������������
    reg [31:0] regfiles [0:31];//��������ʮһ���Ĵ�������������ֻ��Ҫ�õ����е�3���Ϳ�����
    
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
        else if(mtc0)//��rd��selѡ��Э������0�е�����Ĵ�������ͨ�üĴ��� rt�е�����ת�Ƶ�����Ĵ����С�
        begin
            regfiles[Rd]<=wdata;//���Ҳ���� ѡ�񵽵�Э������������Ĵ�����
        end  
        else if(exception)//����������쳣���
        begin
            if(eret)//ERET���ص��ж�ָ���������жϴ�����̽�����ERET��ִ����һ��ָ��
            begin
                regfiles[reg_status]<=regfiles[reg_status]>>5;//����5λ�����ж�
                exc_addr<=regfiles[reg_epc];//�͸������ǵ�pc���������ڵ�ֵ
            end
            else 
            begin
                case(cause)//�������eret����ô�����ǵ��쳣ԭ��
                    EXC_syscall:
                    begin
                        // if(regfiles[reg_status][IE]&regfiles[reg_status][IM_syscall])
                        if(1)
                        begin
                            exc_addr<=32'h00400004;
                            regfiles[reg_status]<=regfiles[reg_status]<<5;//������λ�����ж�
                            regfiles[reg_epc]<=pc;//��ǰ��pc��Ž���
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
                            regfiles[reg_status]<=regfiles[reg_status]<<5;//������λ�����жϣ�status�����ӻ�û����
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
                            regfiles[reg_status]<=regfiles[reg_status]<<5;//������λ�����ж�
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
�쳣�жϿ���ʵ��
���쳣�жϿ��ƹ��ܵ�ʵ���У����������¹涨��
ʵ�ֵ��쳣�����ϵ�ָ��break��ϵͳ����syscall�Լ�����ָ��teq��  
�쳣����ʱ����  ��ǰָ��ĵ�ַ  ��Ϊ���ص�ַ��
��Ӧ�쳣ʱ��    Status�Ĵ���������  ����5λ ���жϣ�
ִ���жϴ������ʱ����Status�Ĵ������ݣ��жϷ���ʱд�أ�
�쳣��ڵ�ַΪ 0x4��

*/