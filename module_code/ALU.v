//2252429������
`timescale 1ns/1ps
//ALUģ��
module ALU(
    input [31:0] A,                 //������A
    input [31:0] B,                 //������B
    input [3:0] aluc,               //��λ����ָ���Ӧ���㷽ʽ
    output [31:0] alu_result,          //ALU������
    output Z,                       //ZF��־λ��zero
    output C,                       //CF��־λ��carry
    output N,                       //NF��־λ��negative
    output O                        //OF��־λ��overflow
);
//---------------------------------------------------------------
//��ָͬ�������Ӧ��aluc�ź�
    //��������
    parameter Addu=4'b0000;
    parameter Subu=4'b0001;
    parameter Add=4'b0010;
    parameter Sub=4'b0011;
    
    //�߼�����
    parameter And=4'b0100;
    parameter Or=4'b0101;
    parameter Xor=4'b0110;
    parameter Nor=4'b0111;
    
    //LUI��100x�����������ռλ
    parameter Lui_0=4'b1000;
    parameter Lui_1=4'b1001;

    //�Ƚ�����
    parameter Sltu=4'b1010;
    parameter Slt=4'b1011;
    
    //��λ����
    parameter Sra=4'b1100;
    parameter Srl=4'b1101;
    parameter Sla=4'b1110;
    parameter Sll=4'b1111;
//---------------------------------------------------------------
//�ڲ��������
    reg [32:0] tmp_result;                  //��ʱ�洢�������32λ���ڱ�־λ�ж�
    wire signed [31:0] signed_A;
    wire signed [31:0] signed_B;            //�з����������
    wire [31:0] unsigned_A;
    wire [31:0] unsigned_B;                 //�޷����������
    reg negative;                           //����λnegative�漰����
    assign signed_A=A;
    assign unsigned_A=A;
    
    assign signed_B=B;
    assign unsigned_B=B;
//---------------------------------------------------------------
//��ͬ����ָ���µĲ���
    always @(*)
    begin
    negative<=1'b0;                            //negative��־λ��������
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
                negative<=(unsigned_A<unsigned_B);      //negative��־λֻ��slt,sltu���õ�
                end
            Slt:
                begin   
                tmp_result<=signed_A-signed_B;
                negative<=(signed_A<signed_B);          //negative��־λֻ��slt,sltu���õ�
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
//ȷ�����
    assign alu_result=tmp_result[31:0];     //result
    assign Z=(tmp_result==32'b0);       //zero
    assign C=tmp_result[32];                //carry
    assign O=tmp_result[32];                //overflow
    assign N=negative;                      //negative
//---------------------------------------------------------------
endmodule
