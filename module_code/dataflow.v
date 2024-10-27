//2252429蔡宇轩
`timescale 1ns / 1ps
//dataflow：顶层数据通路
module sccomp_dataflow(
    input clk_in,                          //时钟
    input reset,                          //复位
    output [31:0] inst,                //输出用，当前正在执行的指令内容
    output [31:0] pc                    //输出用，当前正在执行的指令地址
    );
//---------------------------------------------------------------
//内部变量定义
 /*cpu用*/   
    wire [31:0] out_pc_mars;            //cpu输出下一条指令的地址给imem,Mars编址
    wire [31:0] dmem_addr_mars;         //cpu输出与dmem发生数据交换的dmem地址，Mars编址
    
 /*memory用*/
    wire [31:0] imem_in_addr;           //imem指令地址端接口（经cpu给出的Mars编址映射）
    wire [31:0] imem_out_instr;         //imem读出的指令内容接口
    
    wire dmem_ena;                      //dmem使能端信号
    wire dmem_R;                        //dmem读出信号
    wire dmem_W;                        //dmem写入信号
    wire [31:0] dmem_in_data;           //dmem写入数据接口
    wire [31:0] dmem_out_data;          //dmem读出数据接口
    wire [31:0] dmem_addr;              //dmem数据段地址（经cpu给出的Mars编址映射）

/*dataflow输出用*/
    //instr(dataflow外部接口)链接IMEM读出的指令内容imem_out_instr
    //（dataflow<->imem）
    assign inst=imem_out_instr;
    //pc(dataflow外部接口)链接PC读出的当前执行的指令地址out_pc
    //(dataflow<->cpu(pc))
    assign pc=out_pc_mars;

/*地址映射*/
    //dmem从0开始，Mars数据段(cpu接口)从32'h1001_0000开始
    assign dmem_addr=(dmem_addr_mars - 32'h1001_0000)/4;
    //imem地址从0开始，Mars指令存储段从32'h0040_0000开始
    assign imem_in_addr=out_pc_mars-32'h0040_0000;
    
//---------------------------------------------------------------
//模块实例化
//instance of cpu
cpu sccpu(
    .clk(clk_in),                          //cpu时钟与系统时钟统一
    .ena(1'b1),                         //cpu使能默认常开
    .rst(reset),                          //cpu置位信号与系统置位统一
    
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
    .clk(clk_in),                          //内存时钟与系统时钟统一
    .ena(dmem_ena),                     //dmem设置使能端，imem默认常开
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
