//2252429蔡宇轩
`timescale 1ns / 1ps
////////////////DMEM主存储器模块：异步读，同步写
module DMEM(
    input dmem_clock,                       //主存储时钟信号
    input dmem_ena,                         //主存储器地址端有效信号，使能端
    
    input dmem_R,                           //读信号，高电平有效
    input dmem_W,                           //写信号，高电平有效
    input [10:0] dmem_addr,                 //地址
    input [31:0] dmem_in_data,              //写入数据
    output [31:0] dmem_out_data             //读出数据
    );
//---------------------------------------------------------------
//内存
    reg [31:0] dmem [31:0];
//---------------------------------------------------------------
//工作
    //read：异步读，直接采用assign赋值即可
    assign dmem_out_data =(dmem_ena && dmem_R && ~dmem_W)?dmem[dmem_addr]:32'hz;
    //write：同步写，时钟上升沿写入
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


////////////////指令存储器IMEM模块：通过指令地址返回指令内容
module IMEM(
    input [10:0] in_imem_addr,
    output [31:0] out_imem_instr
    );
//---------------------------------------------------------------
//ip核实例化：ROM
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

////////////////内存主模块：包含了DMEM和IMEM
module MEM(
    input clk,                              //dmem用时钟
    input ena,                              //dmem使能端
    input dmem_R,                           //dmem读信号接口
    input dmem_W,                           //dmem写信号接口
    input [31:0] dmem_addr,                 //dmem地址段接口
    input [31:0] dmem_in_data,              //dmem写入数据接口
    output [31:0] dmem_out_data,            //dmem读出数据接口
    
    input [31:0] imem_in_addr,              //imem指令地址端接口
    output [31:0] imem_out_instr            //imem指令内容跟输出端接口
    );
//---------------------------------------------------------------
//dmem实例化
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
//imem实例化
    IMEM Imem(
        .in_imem_addr(imem_in_addr[12:2]),
        .out_imem_instr(imem_out_instr)
    );
//---------------------------------------------------------------
endmodule
/////////////////////////////////////////////////////////////////
