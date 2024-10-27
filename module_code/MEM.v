//2252429������
`timescale 1ns / 1ps
////////////////DMEM���洢��ģ�飺�첽����ͬ��д
module DMEM(
    input dmem_clock,                       //���洢ʱ���ź�
    input dmem_ena,                         //���洢����ַ����Ч�źţ�ʹ�ܶ�
    
    input dmem_R,                           //���źţ��ߵ�ƽ��Ч
    input dmem_W,                           //д�źţ��ߵ�ƽ��Ч
    input [10:0] dmem_addr,                 //��ַ
    input [31:0] dmem_in_data,              //д������
    output [31:0] dmem_out_data             //��������
    );
//---------------------------------------------------------------
//�ڴ�
    reg [31:0] dmem [31:0];
//---------------------------------------------------------------
//����
    //read���첽����ֱ�Ӳ���assign��ֵ����
    assign dmem_out_data =(dmem_ena && dmem_R && ~dmem_W)?dmem[dmem_addr]:32'hz;
    //write��ͬ��д��ʱ��������д��
    always @(posedge dmem_clock)
    begin
        if(dmem_ena)
        begin
            if(~dmem_R && dmem_W)
                begin
                dmem[dmem_addr]<=dmem_in_data;
                end
        end
    end
//---------------------------------------------------------------   
endmodule
/////////////////////////////////////////////////////////////////


////////////////ָ��洢��IMEMģ�飺ͨ��ָ���ַ����ָ������
module IMEM(
    input [10:0] in_imem_addr,
    output [31:0] out_imem_instr
    );
//---------------------------------------------------------------
//ip��ʵ������ROM
    dist_mem_gen_1 imem_ip(
    .a(in_imem_addr),
    .spo(out_imem_instr)
    );
    
/*    reg [31:0] ram [31:0];
    initial begin
    $readmemh("instr.txt",ram);
    end
*///---------------------------------------------------------------
endmodule
/////////////////////////////////////////////////////////////////

////////////////�ڴ���ģ�飺������DMEM��IMEM
module MEM(
    input clk,                              //dmem��ʱ��
    input ena,                              //dmemʹ�ܶ�
    input dmem_R,                           //dmem���źŽӿ�
    input dmem_W,                           //dmemд�źŽӿ�
    input [31:0] dmem_addr,                 //dmem��ַ�νӿ�
    input [31:0] dmem_in_data,              //dmemд�����ݽӿ�
    output [31:0] dmem_out_data,            //dmem�������ݽӿ�
    
    input [31:0] imem_in_addr,              //imemָ���ַ�˽ӿ�
    output [31:0] imem_out_instr            //imemָ�����ݸ�����˽ӿ�
    );
//---------------------------------------------------------------
//dmemʵ����
    DMEM Dmem(
        .dmem_clock(clk),
        .dmem_ena(ena),
        .dmem_R(dmem_R),
        .dmem_W(dmem_W),
        .dmem_addr(dmem_addr[10:0]),
        .dmem_in_data(dmem_in_data),
        .dmem_out_data(dmem_out_data)
    );
//---------------------------------------------------------------
//imemʵ����
    IMEM Imem(
        .in_imem_addr(imem_in_addr[12:2]),
        .out_imem_instr(imem_out_instr)
    );
//---------------------------------------------------------------
endmodule
/////////////////////////////////////////////////////////////////
