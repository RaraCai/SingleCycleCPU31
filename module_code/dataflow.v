//2252429������
`timescale 1ns / 1ps
//dataflow����������ͨ·
module sccomp_dataflow(
    input clk_in,                          //ʱ��
    input reset,                          //��λ
    output [31:0] inst,                //����ã���ǰ����ִ�е�ָ������
    output [31:0] pc                    //����ã���ǰ����ִ�е�ָ���ַ
    );
//---------------------------------------------------------------
//�ڲ���������
 /*cpu��*/   
    wire [31:0] out_pc_mars;            //cpu�����һ��ָ��ĵ�ַ��imem,Mars��ַ
    wire [31:0] dmem_addr_mars;         //cpu�����dmem�������ݽ�����dmem��ַ��Mars��ַ
    
 /*memory��*/
    wire [31:0] imem_in_addr;           //imemָ���ַ�˽ӿڣ���cpu������Mars��ַӳ�䣩
    wire [31:0] imem_out_instr;         //imem������ָ�����ݽӿ�
    
    wire dmem_ena;                      //dmemʹ�ܶ��ź�
    wire dmem_R;                        //dmem�����ź�
    wire dmem_W;                        //dmemд���ź�
    wire [31:0] dmem_in_data;           //dmemд�����ݽӿ�
    wire [31:0] dmem_out_data;          //dmem�������ݽӿ�
    wire [31:0] dmem_addr;              //dmem���ݶε�ַ����cpu������Mars��ַӳ�䣩

/*dataflow�����*/
    //instr(dataflow�ⲿ�ӿ�)����IMEM������ָ������imem_out_instr
    //��dataflow<->imem��
    assign inst=imem_out_instr;
    //pc(dataflow�ⲿ�ӿ�)����PC�����ĵ�ǰִ�е�ָ���ַout_pc
    //(dataflow<->cpu(pc))
    assign pc=out_pc_mars;

/*��ַӳ��*/
    //dmem��0��ʼ��Mars���ݶ�(cpu�ӿ�)��32'h1001_0000��ʼ
    assign dmem_addr=(dmem_addr_mars - 32'h1001_0000)/4;
    //imem��ַ��0��ʼ��Marsָ��洢�δ�32'h0040_0000��ʼ
    assign imem_in_addr=out_pc_mars-32'h0040_0000;
    
//---------------------------------------------------------------
//ģ��ʵ����
//instance of cpu
cpu sccpu(
    .clk(clk_in),                          //cpuʱ����ϵͳʱ��ͳһ
    .ena(1'b1),                         //cpuʹ��Ĭ�ϳ���
    .rst(reset),                          //cpu��λ�ź���ϵͳ��λͳһ
    
    .in_instr(imem_out_instr),          
    .out_pc(out_pc_mars),
    .dmem_ena(dmem_ena),
    .dmem_W(dmem_W),
    .dmem_R(dmem_R),
    .dmem_addr(dmem_addr_mars),
    .dmem_data_w(dmem_in_data),
    .dmem_data_r(dmem_out_data)
);

//instance of memory
MEM memory(
    .clk(clk_in),                          //�ڴ�ʱ����ϵͳʱ��ͳһ
    .ena(dmem_ena),                     //dmem����ʹ�ܶˣ�imemĬ�ϳ���
    .dmem_R(dmem_R),
    .dmem_W(dmem_W),
    .dmem_addr(dmem_addr),
    .dmem_in_data(dmem_in_data),
    .dmem_out_data(dmem_out_data),
    
    .imem_in_addr(imem_in_addr),
    .imem_out_instr(imem_out_instr)
);
//---------------------------------------------------------------
endmodule
