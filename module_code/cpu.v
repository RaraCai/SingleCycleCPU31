//2252429������
`timescale 1ns / 1ps
//cpuģ�飺������PC,IMEM,DMEM�Ľӿ�
module cpu(
    input clk,                              //cpuʱ��
    input ena,                              //cpu����ʹ�ܶ�
    input rst,                              //��λ�ź�
    
    input [31:0] in_instr,                  //��IMEM�����ָ������
    output [31:0] out_pc,                   //��pc�����һ��ָ���ַ
    output dmem_ena,                        //�Ƿ�����DMEM
    output dmem_W,                          //DMEMд�ź�
    output dmem_R,                          //DMEM���ź�
    output [31:0] dmem_addr,                //DMEM��ַ
    output [31:0] dmem_data_w,              //��DMEMд�������
    input [31:0] dmem_data_r                //��DMEM����������
    );
//---------------------------------------------------------------
//////�����ڲ�����������ʵ������ģ��
//ports of ALU    
    wire [31:0] A,B;            //������A��B
    wire [3:0] aluc;            //��������
    wire [31:0] alu_result;    //������
    wire Z,C,N,O;               //��������־λ��zero,carry,negative,overflow��

//ports of PC
    wire [31:0] pc_in_next_addr;            //��һ��Ҫִ�е�ָ���ַ
    wire [31:0] pc_out_now_addr ;           //��ǰִ�е�ָ���ַ

//ports of Decoder
/*��������*/
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
    wire [4:0] Rsc, Rtc, Rdc;   //�Ĵ���Rs, Rt, Rd��regfile�еĵ�ַ  
/*ָ�����������*/  
    wire [4:0] shamt;           //λ��ƫ����  
    wire [15:0] immediate;      //������  
    wire [25:0] addr;           //J-type 26 bits address

//ports of CU(controller)
/*����������decoder����*/
    wire reg_W;                 //�Ĵ�����д���ź�
    wire [8:0] muxc;            //��·ѡ����Ƭѡ�ź�
    wire [4:0] ext;             //��չģ��Ƭѡ�ź�
    wire cat;                   //ƴ��ģ��ʹ���ź�

//ports of Regfile
    /*�Ĵ�����д�ź���CU����*/
    /*�Ĵ�����д�������ַRs,Rt,Rd��Decoder����*/
    /*�Ĵ����ѽ�������*/
    wire [31:0] rd_in_data;     //д��Rd����
    wire [31:0] rt_out_data;    //����Rt����
    wire [31:0] rs_out_data;    //����Rs����
    
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
/////////��ģ��ʵ����
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
//////ģ�����·����
//ƴ��ģ����·����
    assign out_cat = cat ? {pc_out_now_addr[31:28],addr[25:0],2'h0} : 32'hz;

//��չģ������
    assign out_ext1 = ( is_slt   || is_sltu   ) ? N 
                        : (is_slti    || is_sltiu   ) ? C : 32'hz;
    assign out_ext5 = ( is_sll  || is_srl   || is_sra   ) ? shamt : 32'hz;
    assign out_ext16 = ( is_andi    || is_ori   || is_xori  || is_lui   ) ? 
                          {16'h0, immediate[15:0]} : 32'hz;
    //ֻ������ʱ����ֱ�ӽ�unsigned��չΪsigned�����ʽ��ֵʱ����ʾ����16������λ
    assign out_Sext16 = ( is_addi   || is_addiu || is_lw    || is_sw    ||
                          is_slti   || is_sltiu ) ? 
                          {{16{immediate[15]}},immediate[15:0]} : 32'hz;        
    assign out_Sext18 = ( is_beq    || is_bne   )?
                        {{14{immediate[15]}},immediate[15:0],2'h0} : 32'hz;

//npcģ������
    assign npc = pc_out_now_addr + 4;

//��·ѡ����ģ������
    //���ݶ�·ѡ�����ź�muxc����ѡ����mux�����
    //ʹ����Ŀ��������ѡ��Ĺ���
    assign mux0 = muxc[0] ? out_cat : mux3;
    assign mux1 = muxc[1] ? mux8 : dmem_data_r;
    //��Ϊ�Ĵ�����λ����ƴ�ӣ�ֻȡrs_out_data��5λ���27λ0ƴ��
    assign mux2 = muxc[2] ? out_ext5 : (( is_sllv   ||  is_srlv || is_srav  ) ? {27'h0,rs_out_data[4:0]} : rs_out_data );
    assign mux3 = muxc[3] ? mux5 : rs_out_data;
    assign mux4 = muxc[4] ? mux7 : rt_out_data;
    assign mux5 = muxc[5] ? npc : out_Sext18 + npc;
    assign mux6 = muxc[6] ? pc_out_now_addr+4 : mux1;
    assign mux7 = muxc[7] ? out_Sext16 : out_ext16;
    assign mux8 = muxc[8] ? alu_result : out_ext1;

//pc��·����
    assign pc_in_next_addr = mux0;
    assign out_pc = pc_out_now_addr;

//imem��·����
    assign A = mux2;
    assign B = mux4;

//dmem��·����
    assign dmem_ena = (dmem_W || dmem_R );
    assign dmem_addr = alu_result;
    assign dmem_data_w = rt_out_data;

//regfile��·����
    assign rd_in_data = mux6;

//---------------------------------------------------------------
endmodule
