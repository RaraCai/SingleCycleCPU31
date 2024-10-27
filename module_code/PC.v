//2252429蔡宇轩
`timescale 1ns / 1ps
//PC模块：指令地址寄存器
module PC(
    input pc_clock,                          //时钟
    input pc_ena,                            //使能端
    input rst,                               //复位信号
    
    input [31:0] pc_in_next_addr,            //下一条要执行的指令地址
    output [31:0] pc_out_now_addr            //当前执行的指令地址
    );
//---------------------------------------------------------------
//内部变量：pc存储空间
    parameter pc_start=32'h0040_0000;       //PC起始位置在0040_0000
    reg [31:0] pc_reg=pc_start;
//---------------------------------------------------------------
//工作
    //read：异步读取
    assign pc_out_now_addr=(pc_ena)? pc_reg :32'hz;
    //write：同步写入，时钟上升沿
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
