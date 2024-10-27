//2252429蔡宇轩
`timescale 1ns/1ps
//ALU模块
module ALU(
    input [31:0] A,                 //操作数A
    input [31:0] B,                 //操作数B
    input [3:0] aluc,               //四位操作指令，对应运算方式
    output [31:0] alu_result,          //ALU运算结果
    output Z,                       //ZF标志位，zero
    output C,                       //CF标志位，carry
    output N,                       //NF标志位，negative
    output O                        //OF标志位，overflow
);
//---------------------------------------------------------------
//不同指令操作对应的aluc信号
    //算术运算
    parameter Addu=4'b0000;
    parameter Subu=4'b0001;
    parameter Add=4'b0010;
    parameter Sub=4'b0011;
    
    //逻辑运算
    parameter And=4'b0100;
    parameter Or=4'b0101;
    parameter Xor=4'b0110;
    parameter Nor=4'b0111;
    
    //LUI：100x，用两个标号占位
    parameter Lui_0=4'b1000;
    parameter Lui_1=4'b1001;

    //比较运算
    parameter Sltu=4'b1010;
    parameter Slt=4'b1011;
    
    //移位运算
    parameter Sra=4'b1100;
    parameter Srl=4'b1101;
    parameter Sla=4'b1110;
    parameter Sll=4'b1111;
//---------------------------------------------------------------
//内部运算变量
    reg [32:0] tmp_result;                  //临时存储结果，第32位用于标志位判断
    wire signed [31:0] signed_A;
    wire signed [31:0] signed_B;            //有符号数的情况
    wire [31:0] unsigned_A;
    wire [31:0] unsigned_B;                 //无符号数的情况
    reg negative;                           //符号位negative涉及讨论
    assign signed_A=A;
    assign unsigned_A=A;
    
    assign signed_B=B;
    assign unsigned_B=B;
//---------------------------------------------------------------
//不同运算指令下的操作
    always @(*)
    begin
    negative<=1'b0;                            //negative标志位需额外操作
        case(aluc)
            Addu:
                begin   
                tmp_result<=unsigned_A+unsigned_B;
                end
            Add:
                begin   
                tmp_result<=signed_A+signed_B;
                end
            Subu:
                begin  
                tmp_result<=unsigned_A-unsigned_B;
                end
            Sub:
                begin 
                tmp_result<=signed_A-signed_B;  
                end
            And:
                begin   
                tmp_result<=unsigned_A & unsigned_B;
                end
            Or:
                begin  
                tmp_result<=unsigned_A | unsigned_B; 
                end
            Xor:
                begin 
                tmp_result<=unsigned_A ^ unsigned_B;  
                end
            Nor:
                begin   
                tmp_result<=~(unsigned_A | unsigned_B);
                end
            Lui_0,Lui_1:
                begin   
                tmp_result<={unsigned_B[15:0],16'b0};
                end
            Sltu:
                begin 
                tmp_result<=unsigned_A-unsigned_B;
                negative<=(unsigned_A<unsigned_B);      //negative标志位只在slt,sltu中用到
                end
            Slt:
                begin   
                tmp_result<=signed_A-signed_B;
                negative<=(signed_A<signed_B);          //negative标志位只在slt,sltu中用到
                end
            Sra:
                begin   
                tmp_result=(signed_B>>>signed_A);
                end
            Srl:
                begin   
                tmp_result=(unsigned_B>>unsigned_A);
                end
            Sla,Sll:
                begin   
                tmp_result=(unsigned_B<<unsigned_A);
                end
        endcase
    end
//---------------------------------------------------------------
//确定输出
    assign alu_result=tmp_result[31:0];     //result
    assign Z=(tmp_result==32'b0);       //zero
    assign C=tmp_result[32];                //carry
    assign O=tmp_result[32];                //overflow
    assign N=negative;                      //negative
//---------------------------------------------------------------
endmodule
