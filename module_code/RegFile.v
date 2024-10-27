//2252429蔡宇轩
`timescale 1ns / 1ps
//regfile模块：寄存器堆
module Regfile(
    input reg_clock,                    //时钟
    input reg_ena,                      //使能端
    input rst,                          //复位
    
    input reg_W,                        //写信号
    input [4:0] rdc,                    //写入寄存器Rd地址
    input [4:0] rtc,                    //读出寄存器Rt地址
    input [4:0] rsc,                    //读出寄存器Rs地址
    input [31:0] rd_in_data,            //写入Rd数据
    output [31:0] rt_out_data,          //读出Rt数据
    output [31:0] rs_out_data           //读出Rs数据
    );
//---------------------------------------------------------------
//内部变量：pc存储空间
    reg [31:0] array_reg [31:0];
//---------------------------------------------------------------
//工作
    //read：异步读取
    assign rt_out_data=(reg_ena) ? array_reg[rtc] : 32'bz;
    assign rs_out_data=(reg_ena) ? array_reg[rsc] : 32'bz;
    //write：同步写入，每次写入前应注意清零
    always @(posedge reg_clock or posedge rst)
    begin
        if(reg_ena)     //使能端有效才工作
        begin
            if(rst)
            begin
                array_reg[0]<=32'h0;
                array_reg[1]<=32'h0;
                array_reg[2]<=32'h0;
                array_reg[3]<=32'h0;
                array_reg[4]<=32'h0;
                array_reg[5]<=32'h0;
                array_reg[6]<=32'h0;
                array_reg[7]<=32'h0;
                array_reg[8]<=32'h0;
                array_reg[9]<=32'h0;
                array_reg[10]<=32'h0;
                array_reg[11]<=32'h0;
                array_reg[12]<=32'h0;
                array_reg[13]<=32'h0;
                array_reg[14]<=32'h0;
                array_reg[15]<=32'h0;
                array_reg[16]<=32'h0;
                array_reg[17]<=32'h0;
                array_reg[18]<=32'h0;
                array_reg[19]<=32'h0;
                array_reg[20]<=32'h0;
                array_reg[21]<=32'h0;
                array_reg[22]<=32'h0;
                array_reg[23]<=32'h0;
                array_reg[24]<=32'h0;
                array_reg[25]<=32'h0;
                array_reg[26]<=32'h0;
                array_reg[27]<=32'h0;
                array_reg[28]<=32'h0;
                array_reg[29]<=32'h0;
                array_reg[30]<=32'h0;
                array_reg[31]<=32'h0;
            end
            else if(reg_W && rdc!=5'h0)     //0号reg始终为0，不允许修改
            begin
                array_reg[rdc]<=rd_in_data;
            end
        end
    end
 //---------------------------------------------------------------   
endmodule
