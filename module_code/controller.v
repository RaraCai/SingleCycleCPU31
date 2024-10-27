//2252429蔡宇轩
`timescale 1ns / 1ps
//controller模块：控制器
//根据指令译码器的结果（decoder）产生微操作信号
module controller(
    ////////////输入decoder指令译码结果////////////
    //////Rtype
    input is_add,  
    input is_addu,  
    input is_sub,  
    input is_subu,  
  
    input is_and,  
    input is_or,  
    input is_xor,  
    input is_nor,  
  
    input is_slt,  
    input is_sltu,  
  
    input is_sra,  
    input is_srl,  
    input is_sll,  
    input is_srav,  
    input is_srlv,  
    input is_sllv,  
  
    input is_jr,  
  
    //////I-type  
    input is_addi,  
    input is_addiu,  
  
    input is_andi,  
    input is_ori,  
    input is_xori,  
  
    input is_lw,  
    input is_sw,  
  
    input is_beq,  
    input is_bne,  
  
    input is_slti,  
    input is_sltiu,  
  
    input is_lui,  
  
    //////J-type  
    input is_j,  
    input is_jal,
    
    //////ALU运算结果标志位Z(zero)，用于beq,bne分支判断
    input Z,
    
    ////////////产生的微操作信号////////////
    //多路选择器信号
    output [8:0]muxc,          //muxc[0]~muxc[1]:mux0_c,mux1_c,...,mux8_c
    
    //ALU功能选择aluc信号
    output [3:0]aluc,
    
    //拓展部件使能信号
    output [4:0]ext,            //拓展ext[0]~ext[4]:Ext1,Ext5,Ext16,S_Ext16,S_Ext18
    
    //DMEM读写信号
    output dmem_W,
    output dmem_R,
    
    //寄存器堆写信号
    output reg_W,
    
    //数位拼接信号
    output cat
    );
//---------------------------------------------------------------
//依据指令中的操作类型生成微操作信号
//muxc
    assign muxc[0]=(is_j    ||is_jal    );
    assign muxc[1]=(~is_lw  );
    assign muxc[2]=(is_sll      ||is_srl     ||is_sra    );
    assign muxc[3]=~(is_jr       ||is_j       ||is_jal    );
    assign muxc[4]=(is_andi     ||is_xori    ||is_ori    ||is_lui    ||
                    is_addi     ||is_addiu   ||is_lw     ||is_sw     ||
                    is_slti     ||is_sltiu      );
    assign muxc[5]=is_beq ? ~Z :(is_bne ? Z : 1'b1);
    assign muxc[6]=(is_jal      ) ;
    assign muxc[7]=(is_addi      ||is_addiu    ||is_lw       ||is_sw       ||
                    is_slti      ||is_sltiu     );
    assign muxc[8]=(is_add       || is_addu    || is_sub     || is_subu    ||  
                    is_and       || is_or      || is_xor     || is_nor     ||  
                    is_sll       || is_srl     || is_sra     || is_sllv    ||  
                    is_srlv      || is_srav    || is_lui     || is_addi    ||   
                    is_addiu     || is_andi    || is_ori     || is_xori);

//aluc
    assign aluc[0]=(is_sub     || is_subu   || is_or     || is_nor    ||    
                    is_slt     || is_srlv   || is_srl     || is_ori   || 
                    is_slti    || is_beq    || is_bne);
    assign aluc[1]=(is_add     || is_sub     || is_xor    || is_nor    ||  
                    is_slt     || is_sltu    || is_sllv   || is_sll    ||  
                    is_addi    || is_xori    || is_slti   || is_sltiu);
    assign aluc[2]=(is_and   || is_or    || is_xor   || is_nor   ||  
                    is_sllv  || is_srlv  || is_srav  || is_sll   ||  
                    is_srl   || is_sra   || is_andi  || is_ori   ||  
                    is_xori);    
    assign aluc[3]=(is_slt      || is_sltu    || is_sllv   || is_srlv   ||  
                    is_srav     || is_sll      || is_srl    || is_sra    ||  
                    is_slti     || is_sltiu   || is_lui);    
    
//ext
    assign ext[0]=(is_slt   ||is_sltu   ||is_slti   ||is_sltiu  );            //Ext1
    assign ext[1]=(is_sll   ||is_srl    ||is_sra    );                        //Ext5
    assign ext[2]=(is_andi  ||is_ori    ||is_xori   ||is_lui    );            //Ext16
    assign ext[3]=(is_addi  ||is_addiu  ||is_lw     ||is_sw     ||
                   is_slti  ||is_sltiu  );                                     //S_Ext16
    assign ext[4]=(is_beq   ||is_bne    );                                     //S_Ext18  

//dmem write and read
    assign dmem_W=is_sw;
    assign dmem_R=is_lw;

//regfile write
    assign reg_W=~(is_jr    ||is_sw    ||is_beq    ||is_bne    ||is_j  );
//cat
    assign cat=(is_j    ||is_jal    );
//---------------------------------------------------------------
endmodule