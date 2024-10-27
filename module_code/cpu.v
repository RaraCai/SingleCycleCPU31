//2252429蔡宇轩
`timescale 1ns / 1ps
//cpu模块：保留与PC,IMEM,DMEM的接口
module cpu(
    input clk,                              //cpu时钟
    input ena,                              //cpu启用使能端
    input rst,                              //复位信号
    
    input [31:0] in_instr,                  //从IMEM读入的指令内容
    output [31:0] out_pc,                   //向pc输出下一条指令地址
    output dmem_ena,                        //是否启用DMEM
    output dmem_W,                          //DMEM写信号
    output dmem_R,                          //DMEM读信号
    output [31:0] dmem_addr,                //DMEM地址
    output [31:0] dmem_data_w,              //向DMEM写入的数据
    input [31:0] dmem_data_r                //从DMEM读出的数据
    );
//---------------------------------------------------------------
//////定义内部变量，用于实例化各模块
//ports of ALU    
    wire [31:0] A,B;            //操作数A，B
    wire [3:0] aluc;            //运算类型
    wire [31:0] alu_result;    //运算结果
    wire Z,C,N,O;               //运算结果标志位（zero,carry,negative,overflow）

//ports of PC
    wire [31:0] pc_in_next_addr;            //下一条要执行的指令地址
    wire [31:0] pc_out_now_addr ;           //当前执行的指令地址

//ports of Decoder
/*操作类型*/
    /* R-type*/  
    wire is_add, is_addu, is_sub, is_subu,  
         is_and, is_or, is_xor, is_nor,  
         is_slt, is_sltu,  
         is_sra, is_srl, is_sll, is_srav, is_srlv, is_sllv,  
         is_jr;  
    /* I-type*/  
    wire is_addi, is_addiu,  
         is_andi, is_ori, is_xori,  
         is_lw, is_sw,  
         is_beq, is_bne,  
         is_slti, is_sltiu,  
         is_lui;  
    /* J-type */
    wire is_j, is_jal;  
    /* reg */  
    wire [4:0] Rsc, Rtc, Rdc;   //寄存器Rs, Rt, Rd在regfile中的地址  
/*指令的其他部分*/  
    wire [4:0] shamt;           //位移偏移量  
    wire [15:0] immediate;      //立即数  
    wire [25:0] addr;           //J-type 26 bits address

//ports of CU(controller)
/*操作类型与decoder共用*/
    wire reg_W;                 //寄存器堆写入信号
    wire [8:0] muxc;            //多路选择器片选信号
    wire [4:0] ext;             //拓展模块片选信号
    wire cat;                   //拼接模块使能信号

//ports of Regfile
    /*寄存器堆写信号与CU共用*/
    /*寄存器堆写入读出地址Rs,Rt,Rd与Decoder共用*/
    /*寄存器堆进出数据*/
    wire [31:0] rd_in_data;     //写入Rd数据
    wire [31:0] rt_out_data;    //读出Rt数据
    wire [31:0] rs_out_data;    //读出Rs数据
    
//ports of ext
    wire [31:0] out_ext1;               //1 bit to 32 bits
    wire [31:0] out_ext5;               //5 bits to 32 bits
    wire [31:0] out_ext16;              //16 bits to 32 bits
    wire signed [31:0] out_Sext16;      //signed 16 bits to 32 bits
    wire signed [31:0] out_Sext18;      //signed 18 bits to 32 bits

//ports of cat
    wire [31:0] out_cat;

//ports of npc
    wire [31:0] npc;
    
//ports of mux
    wire [31:0] mux0;
    wire [31:0] mux1;
    wire [31:0] mux2;
    wire [31:0] mux3;
    wire [31:0] mux4;
    wire [31:0] mux5;
    wire [31:0] mux6;
    wire [31:0] mux7;
    wire [31:0] mux8;
   
//---------------------------------------------------------------
/////////各模块实例化
//instance of ALU
ALU alu(
    .A(A),
    .B(B),
    .aluc(aluc),
    .alu_result(alu_result),
    .Z(Z),
    .C(C),
    .N(N),
    .O(O)
);

//instance of PC
PC pc(
    .pc_clock(clk),
    .pc_ena(ena),
    .rst(rst),
    .pc_in_next_addr(pc_in_next_addr),
    .pc_out_now_addr(pc_out_now_addr)
);

//instance of Decoder
Decoder decoder(
    .in_instr(in_instr),
    .is_add(is_add),
    .is_addu(is_addu),
    .is_sub(is_sub),
    .is_subu(is_subu),
    .is_and(is_and),
    .is_or(is_or),
    .is_xor(is_xor),
    .is_nor(is_nor),
    .is_slt(is_slt),
    .is_sltu(is_sltu),
    .is_sra(is_sra),
    .is_srl(is_srl),
    .is_sll(is_sll),
    .is_srav(is_srav),
    .is_srlv(is_srlv),
    .is_sllv(is_sllv),
    .is_jr(is_jr),
    .is_addi(is_addi),
    .is_addiu(is_addiu),
    .is_andi(is_andi),
    .is_ori(is_ori),
    .is_xori(is_xori),
    .is_lw(is_lw),
    .is_sw(is_sw),
    .is_beq(is_beq),
    .is_bne(is_bne),
    .is_slti(is_slti),
    .is_sltiu(is_sltiu),
    .is_lui(is_lui),
    .is_j(is_j),
    .is_jal(is_jal),
    
    .Rsc(Rsc),
    .Rtc(Rtc),
    .Rdc(Rdc),
    
    .shamt(shamt),
    .immediate(immediate),
    .addr(addr)
);

//instance of CU
controller cu(
    .is_add(is_add),
    .is_addu(is_addu),
    .is_sub(is_sub),
    .is_subu(is_subu),
    .is_and(is_and),
    .is_or(is_or),
    .is_xor(is_xor),
    .is_nor(is_nor),
    .is_slt(is_slt),
    .is_sltu(is_sltu),
    .is_sra(is_sra),
    .is_srl(is_srl),
    .is_sll(is_sll),
    .is_srav(is_srav),
    .is_srlv(is_srlv),
    .is_sllv(is_sllv),
    .is_jr(is_jr),
    .is_addi(is_addi),
    .is_addiu(is_addiu),
    .is_andi(is_andi),
    .is_ori(is_ori),
    .is_xori(is_xori),
    .is_lw(is_lw),
    .is_sw(is_sw),
    .is_beq(is_beq),
    .is_bne(is_bne),
    .is_slti(is_slti),
    .is_sltiu(is_sltiu),
    .is_lui(is_lui),
    .is_j(is_j),
    .is_jal(is_jal),
    
    .muxc(muxc),
    .aluc(aluc),
    .ext(ext),
    .dmem_W(dmem_W),
    .dmem_R(dmem_R),
    .reg_W(reg_W),
    .cat(cat),
    .Z(Z)
);

//instance of Regfile
Regfile cpu_ref(
    .reg_clock(clk),
    .reg_ena(ena),
    .rst(rst),
    .reg_W(reg_W),
    .rdc(Rdc),
    .rtc(Rtc),
    .rsc(Rsc),
    .rd_in_data(rd_in_data),
    .rt_out_data(rt_out_data),
    .rs_out_data(rs_out_data)
);

//---------------------------------------------------------------
//////模块间线路连接
//拼接模块线路连接
    assign out_cat = cat ? {pc_out_now_addr[31:28],addr[25:0],2'h0} : 32'hz;

//拓展模块连接
    assign out_ext1 = ( is_slt   || is_sltu   ) ? N 
                        : (is_slti    || is_sltiu   ) ? C : 32'hz;
    assign out_ext5 = ( is_sll  || is_srl   || is_sra   ) ? shamt : 32'hz;
    assign out_ext16 = ( is_andi    || is_ori   || is_xori  || is_lui   ) ? 
                          {16'h0, immediate[15:0]} : 32'hz;
    //只有运算时可以直接将unsigned拓展为signed，表达式赋值时需显示复制16个符号位
    assign out_Sext16 = ( is_addi   || is_addiu || is_lw    || is_sw    ||
                          is_slti   || is_sltiu ) ? 
                          {{16{immediate[15]}},immediate[15:0]} : 32'hz;        
    assign out_Sext18 = ( is_beq    || is_bne   )?
                        {{14{immediate[15]}},immediate[15:0],2'h0} : 32'hz;

//npc模块连接
    assign npc = pc_out_now_addr + 4;

//多路选择器模块连接
    //依据多路选择器信号muxc决定选择器mux的输出
    //使用三目运算符完成选择的功能
    assign mux0 = muxc[0] ? out_cat : mux3;
    assign mux1 = muxc[1] ? mux8 : dmem_data_r;
    //若为寄存器移位，需拼接：只取rs_out_data低5位与高27位0拼接
    assign mux2 = muxc[2] ? out_ext5 : (( is_sllv   ||  is_srlv || is_srav  ) ? {27'h0,rs_out_data[4:0]} : rs_out_data );
    assign mux3 = muxc[3] ? mux5 : rs_out_data;
    assign mux4 = muxc[4] ? mux7 : rt_out_data;
    assign mux5 = muxc[5] ? npc : out_Sext18 + npc;
    assign mux6 = muxc[6] ? pc_out_now_addr+4 : mux1;
    assign mux7 = muxc[7] ? out_Sext16 : out_ext16;
    assign mux8 = muxc[8] ? alu_result : out_ext1;

//pc线路连接
    assign pc_in_next_addr = mux0;
    assign out_pc = pc_out_now_addr;

//imem线路连接
    assign A = mux2;
    assign B = mux4;

//dmem线路连接
    assign dmem_ena = (dmem_W || dmem_R );
    assign dmem_addr = alu_result;
    assign dmem_data_w = rt_out_data;

//regfile线路连接
    assign rd_in_data = mux6;

//---------------------------------------------------------------
endmodule
