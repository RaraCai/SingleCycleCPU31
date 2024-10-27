//2252429������
`timescale 1ns / 1ps
//Decoderģ�飺ָ��������
module Decoder(
    //////���������ָ��
    input [31:0] in_instr,      
    //////R-type
    output is_add,
    output is_addu,
    output is_sub,
    output is_subu,
    
    output is_and,
    output is_or,
    output is_xor,
    output is_nor,
    
    output is_slt,
    output is_sltu,
    
    output is_sra,
    output is_srl,
    output is_sll,
    output is_srav,
    output is_srlv,
    output is_sllv,
    
    output is_jr,
    
    //////I-type
    output is_addi,
    output is_addiu,
    
    output is_andi,
    output is_ori,
    output is_xori,
    
    output is_lw,
    output is_sw,
    
    output is_beq,
    output is_bne,
    
    output is_slti,
    output is_sltiu,
    
    output is_lui,
    
    //////J-type
    output is_j,
    output is_jal,
    
    //////reg
    output [4:0] Rsc,           //�Ĵ���Rs��regfile�еĵ�ַ
    output [4:0] Rtc,           //�Ĵ���Rt��regfile�еĵ�ַ
    output [4:0] Rdc,           //�Ĵ���Rd��regfile�еĵ�ַ
    
    //////ָ�����������
    output [4:0] shamt,         //λ��ƫ����
    output [15:0] immediate,    //������
    output [25:0] addr          //J-type 26 bits address
    );
//---------------------------------------------------------------
//�ڲ������������������ָ��õ�opr��func
    wire [5:0] opr;              //������opr
    wire [5:0] func;             //��������func
    assign opr=in_instr[31:26];
    assign func=in_instr[5:0];
//---------------------------------------------------------------
//��ָͬ�������Ӧ�ı���
    //////R-type��oprͳһΪ000000������func���ֲ�������
    parameter opr_Rtype=6'b000_000;
    parameter func_add=6'b100_000;
    parameter func_addu=6'b100_001;
    parameter func_sub=6'b100_010;
    parameter func_subu=6'b100_011;
    parameter func_and=6'b100_100;
    
    parameter func_or=6'b100_101;
    parameter func_xor=6'b100_110;
    parameter func_nor=6'b100_111;
    
    parameter func_slt=6'b101_010;
    parameter func_sltu=6'b101_011;
    
    parameter func_sll=6'b000_000;
    parameter func_srl=6'b000_010;
    parameter func_sra=6'b000_011;
    parameter func_sllv=6'b000_100;
    parameter func_srlv=6'b000_110;
    parameter func_srav=6'b000_111;
    
    parameter func_jr=6'b001000;
    //////I-type��ֱ����opr����
    parameter opr_addi=6'b001_000;
    parameter opr_addiu=6'b001_001;
    
    parameter opr_andi=6'b001_100;
    parameter opr_ori=6'b001_101;
    parameter opr_xori=6'b001_110;
    
    parameter opr_lw=6'b100_011;
    parameter opr_sw=6'b101_011;
    
    parameter opr_beq=6'b000_100;
    parameter opr_bne=6'b000_101;
    
    parameter opr_slti=6'b001_010;
    parameter opr_sltiu=6'b001_011;
    
    parameter opr_lui=6'b001_111;
    //////J-type��ֱ����opr����
    parameter opr_j=6'b000_010;
    parameter opr_jal=6'b000_011;
//---------------------------------------------------------------
//��������
    //////R-type:opr=6'b000_000
    assign is_add=(opr==opr_Rtype && func==func_add);
    assign is_addu=(opr==opr_Rtype && func==func_addu);
    assign is_sub=(opr==opr_Rtype && func==func_sub);
    assign is_subu=(opr==opr_Rtype && func==func_subu);
    
    assign is_and=(opr==opr_Rtype && func==func_and);
    assign is_or=(opr==opr_Rtype && func==func_or);
    assign is_xor=(opr==opr_Rtype && func==func_xor);
    assign is_nor=(opr==opr_Rtype && func==func_nor);
    
    assign is_slt=(opr==opr_Rtype && func==func_slt);
    assign is_sltu=(opr==opr_Rtype && func==func_sltu);
    
    assign is_sll=(opr==opr_Rtype && func==func_sll);
    assign is_srl=(opr==opr_Rtype && func==func_srl);
    assign is_sra=(opr==opr_Rtype && func==func_sra);
    assign is_sllv=(opr==opr_Rtype && func==func_sllv);
    assign is_srlv=(opr==opr_Rtype && func==func_srlv);
    assign is_srav=(opr==opr_Rtype && func==func_srav);
    
    assign is_jr=(opr==opr_Rtype && func==func_jr);
    //////I-type
    assign is_addi=(opr==opr_addi);
    assign is_addiu=(opr==opr_addiu);
    
    assign is_andi=(opr==opr_andi);
    assign is_ori=(opr==opr_ori);
    assign is_xori=(opr==opr_xori);
    
    assign is_lw=(opr==opr_lw);
    assign is_sw=(opr==opr_sw);
    
    assign is_beq=(opr==opr_beq);
    assign is_bne=(opr==opr_bne);
    
    assign is_slti=(opr==opr_slti);
    assign is_sltiu=(opr==opr_sltiu);
    
    assign is_lui=(opr==opr_lui);
    //////J-type
    assign is_j=(opr==opr_j);
    assign is_jal=(opr==opr_jal);
//---------------------------------------------------------------
//�Ĵ�����ַ����
    //Rs
    assign Rsc=(is_add   || is_addu || is_sub   || is_subu ||  
                is_and   || is_or   || is_xor   || is_nor  ||  
                is_slt   || is_sltu || is_sllv  || is_srlv ||  
                is_srav  || is_jr   || is_addi  || is_addiu ||  
                is_andi  || is_ori  || is_xori  || is_lw   ||  
                is_sw    || is_beq  || is_bne   || is_slti ||  
                is_sltiu) ? in_instr[25:21] : 5'hz;
    //Rt
    assign Rtc=(is_add   || is_addu  || is_sub   || is_subu ||  
                is_and   || is_or    || is_xor   || is_nor  ||  
                is_slt   || is_sltu  || is_sll   || is_srl  ||  
                is_sra   || is_sllv  || is_srlv  || is_srav ||  
                is_sw    || is_beq   || is_bne) ? in_instr[20:16] : 5'hz;
    //Rd
    //��ΪI��ָ�ʵ��д�������Rt��ʾ�ģ�ֻ������Ϊ��ͳһ��ʾ��д��Rdд��
    assign Rdc=(is_add   || is_addu  || is_sub   || is_subu  ||  
                is_and   || is_or    || is_xor   || is_nor   ||  
                is_slt   || is_sltu  || is_sll   || is_srl   ||  
                is_sra   || is_sllv  || is_srlv  || is_srav) ? in_instr[15:11] : ((  
                is_addi  || is_addiu || is_andi  || is_ori   ||   
                is_xori  || is_lw    || is_slti  || is_sltiu ||  
                is_lui) ? in_instr[20:16] : (is_jal ? 5'd31 : 5'hz));
//---------------------------------------------------------------
//ƫ��������
    assign shamt=(is_sll || is_srl || is_sra) ? in_instr[10:6] : 5'hz;
//---------------------------------------------------------------
//������
    assign immediate=(is_addi || is_addiu || is_andi || is_ori || is_xori || is_lw || is_sw || is_beq || is_bne || is_slti || is_sltiu || is_lui) ? in_instr[15:0] : 16'hz;
//---------------------------------------------------------------
//J-typeָ��26λ��ַ����
    assign addr=(is_j || is_jal) ? in_instr[25:0] : 26'hz; 
//---------------------------------------------------------------
endmodule
