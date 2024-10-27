//2252429������
`timescale 1ns / 1ps
//PCģ�飺ָ���ַ�Ĵ���
module PC(
    input pc_clock,                          //ʱ��
    input pc_ena,                            //ʹ�ܶ�
    input rst,                               //��λ�ź�
    
    input [31:0] pc_in_next_addr,            //��һ��Ҫִ�е�ָ���ַ
    output [31:0] pc_out_now_addr            //��ǰִ�е�ָ���ַ
    );
//---------------------------------------------------------------
//�ڲ�������pc�洢�ռ�
    parameter pc_start=32'h0040_0000;       //PC��ʼλ����0040_0000
    reg [31:0] pc_reg=pc_start;
//---------------------------------------------------------------
//����
    //read���첽��ȡ
    assign pc_out_now_addr=(pc_ena)? pc_reg :32'hz;
    //write��ͬ��д�룬ʱ��������
    always @ (posedge pc_clock )   
    begin
        if(rst)
        begin
            pc_reg<=pc_start;
        end
        else
        begin
            pc_reg<=pc_in_next_addr;
        end
    end
//---------------------------------------------------------------
endmodule
