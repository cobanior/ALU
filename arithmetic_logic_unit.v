//Here lies declared the ripple carry adder
module full_adder(input b,a,ci, output co,s);

wire w;

assign w = a^b;
assign s = ci^w;
assign co = (~w&b)|(w&ci);

endmodule

module ripple_carry_adder(input [3:0]a,input [3:0]b,input ci, output [7:0]out);

wire [2:0]w;
wire [4:0]o;

full_adder adder1(a[0],b[0],ci,w[0],o[0]);
full_adder adder2(a[1],b[1],w[0],w[1],o[1]);
full_adder adder3(a[2],b[2],w[1],w[2],o[2]);
full_adder adder4(a[3],b[3],w[2],o[4],o[3]);

assign out[7:0] = {2'b00,o[4:0]};

endmodule
//here thy definition of thy ripple carry adder ends 

//here thy definition of the hex display lies
module seg7(input [3:0] SW, output [6:0] HEX0);
   // Logic functions describing each of the 7 segments of the display
   assign HEX0[0]=~((SW[3]|SW[2]|SW[1]|~SW[0])&(SW[3]|~SW[2]|SW[1]|SW[0])&(~SW[3]|SW[2]|~SW[1]|~SW[0])&(~SW[3]|~SW[2]|SW[1]|~SW[0]));
	assign HEX0[1]=~((SW[3]|~SW[2]|SW[1]|~SW[0])& (SW[3]|~SW[2]|~SW[1]|SW[0])&(~SW[3]|SW[2]|~SW[1]|~SW[0])&(~SW[3]|~SW[2]|SW[1]|SW[0])&(~SW[3]|~SW[2]|~SW[1]|SW[0])&(~SW[3]|~SW[2]|~SW[1]|~SW[0]));
	assign HEX0[2]=~((SW[3]|SW[2]|~SW[1]|SW[0])&(~SW[3]|~SW[2]|SW[1]|SW[0])&(~SW[3]|~SW[2]|~SW[1]|SW[0])&(~SW[3]|~SW[2]|~SW[1]|~SW[0]));
	assign HEX0[3]=~((SW[3]|SW[2]|SW[1]|~SW[0])&(SW[3]|~SW[2]|SW[1]|SW[0])&(SW[3]|~SW[2]|~SW[1]|~SW[0])&(~SW[3]|SW[2]|~SW[1]|SW[0])&(~SW[3]|~SW[2]|~SW[1]|~SW[0])); 
	assign HEX0[4]=~((SW[3]|SW[2]|SW[1]|~SW[0])&(SW[3]|SW[2]|~SW[1]|~SW[0])&(SW[3]|~SW[2]|SW[1]|SW[0])&(SW[3]|~SW[2]|SW[1]|~SW[0])&(SW[3]|~SW[2]|~SW[1]|~SW[0])&(~SW[3]|SW[2]|SW[1]|~SW[0]));
	assign HEX0[5]=~((SW[3]|SW[2]|SW[1]|~SW[0])&(SW[3]|SW[2]|~SW[1]|SW[0])&(SW[3]|SW[2]|~SW[1]|~SW[0])&(SW[3]|~SW[2]|~SW[1]|~SW[0])&(~SW[3]|~SW[2]|SW[1]|~SW[0]));
	assign HEX0[6]=~((SW[3]|SW[2]|SW[1]|SW[0])&(SW[3]|SW[2]|SW[1]|~SW[0])&(SW[3]|~SW[2]|~SW[1]|~SW[0])&(~SW[3]|~SW[2]|SW[1]|SW[0]));
endmodule
//here thy definition of thy hex display ends

//Top module for arithmetic logic unit
module arithmetic_logic_unit(input [9:0]SW, input [2:0]KEY, output [7:0]LEDR, 
                             output [6:0]HEX0,output [6:0]HEX1,output [6:0]HEX2,
									  output [6:0]HEX3, output [6:0]HEX4, output [6:0]HEX5);

	wire [7:0]w1;
   wire [7:0]w2;    
   wire [3:0]w3;
	wire [3:0]w4;
	wire [7:0]w5;
	wire [7:0]w7;
	
   ripple_carry_adder inst1(SW[7:4],SW[3:0],{1'b0},w1[7:0]);
	
	wire [4:0]temp;
	assign temp = SW[7:4]+SW[3:0];
	assign w2 = {3'b000,temp};
	assign w3 = SW[7:4]~^SW[3:0];
	assign w4 = ~(SW[7:4]&SW[3:0]);
	assign w5 = {w4,w3};
	
	
	reg [7:0]w8;
	
	always@(*)
	begin
		if(((SW[7:4]=={4'b0001})||(SW[7:4]=={4'b0010})||(SW[7:4]=={4'b0100})||(SW[7:4]=={4'b1000}))&&
			((SW[3:0]=={4'b0011})||(SW[3:0]=={4'b0110})||(SW[3:0]=={4'b1100})||(SW[3:0]=={4'b1001})||
			(SW[3:0]=={4'b0101})||(SW[3:0]=={4'b1010})))
			w8 = 8'b11110000;
			
		else
			w8 = 8'b00000000;
	end
	
	reg [7:0]w6;
	
	always@(*)
	begin
		if({SW[7:4],SW[3:0]}||{1'b0})
			w6 = 8'b00001111;
		
		else
			w6 = 8'b00000000;
	end
	
	assign w7 = {SW[7:4],~SW[3:0]};
	
	reg [7:0]ALUout;
	
	always@(*)
	begin
		case(KEY[2:0])
			3'b000: ALUout = w1;
			3'b001: ALUout = w2;
			3'b010: ALUout = w5;
			3'b100: ALUout = w6;
			3'b011: ALUout = w8;
			3'b110: ALUout = w7;
			default: ALUout = {8'b00000000};
		endcase
	end
		
	assign LEDR[7:0] = ALUout[7:0];
	seg7 HEx0(SW[3:0], HEX0[6:0]);
	seg7 HEx2(SW[7:4], HEX2[6:0]);
	assign HEX1[6:0]={7'b0000000};
	assign HEX3[6:0]={7'b0000000};
	seg7 HEx4(ALUout[3:0], HEX4[6:0]);
	seg7 HEx5(ALUout[7:4], HEX5[6:0]);
		
endmodule

