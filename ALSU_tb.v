module ALSU_tb;

reg clk , rst , cin , serial_in, direction , red_op_A , red_op_B , bypass_A , bypass_B;
reg [2:0] A ,B , opcode;

wire [5:0]  out ;
wire [15:0] leds;



ALSU A_instance (.clk(clk) ,.rst(rst) ,.cin(cin) , .serial_in(serial_in) ,.direction(direction) ,.red_op_A(red_op_A) ,.red_op_B(red_op_B) ,
	              .bypass_A(bypass_A) , .bypass_B(bypass_B) ,.A(A) , .B(B) ,.opcode(opcode) ,.out(out) , .leds(leds) );



integer i ;

//------------- CLOCK GENERATOR ---------------------------

initial begin 
clk = 0 ;

forever begin
	#1 clk = ~clk;
end

end


//------------- INPUT RANDOMIZATION ---------------------------

initial begin 

for(i =0 ; i <99 ; i = i+1) begin

@(negedge clk);
A = $random ;
B = $random ;
serial_in = $random;
cin = $random;

#2;
end

end

//----------------------------------------


initial begin
opcode = 0;
bypass_A = 0;
bypass_B = 0;
red_op_A = 0;
red_op_B = 0;
rst = 1;
# 10 ;
rst = 0; 
#6;

// testing bypass A and bypass B
//---------------------------------------------------

bypass_A = 1 ;                     
bypass_B = 0 ;
#6;

bypass_A = 0 ;
bypass_B = 1 ;
#6;

bypass_A = 1 ;
bypass_B = 1 ;
#6;
bypass_A = 0;
bypass_B = 0;
#2;

//----------------------------------------------------


opcode = 3'b001;            
#6; 
red_op_A = 2'b1;             // testing XOR Operation with reduction A
#6;
red_op_B = 1'b1;             // testing XOR Operation with reduction B
#6
red_op_A =0;
red_op_B = 0;
#2;

opcode = 3'b001;            // testing XOR Operation with no reduction
#6;


opcode = 3'b010;           
#6;
red_op_A = 1'b1;            // testing AND Operation with reduction A
#6;
red_op_A = 1'b0;
#1;

opcode = 3'b011;            // testing multiplication
#6;


direction = 1;
#2;                         // shift left operation 
opcode = 3'b100;
#4;
direction = 0;              // shift right opertaion
#4;


opcode = 3'b101;            // testing rotating Operation
#6;


opcode = 3'b110;            // invalid operation
#4;
opcode = 3'b111;            // invalid operation
#4;


$stop;
end




endmodule
