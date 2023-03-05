module  ALSU #(parameter INPUT_PERIORITY = "A" , parameter FULL_ADDER = "ON") (

 input clk          ,
 input rst          ,
 input [2:0] A      ,
 input [2:0] B      ,
 input [2:0] opcode ,
 input cin          ,
 input serial_in    ,
 input direction    ,
 input red_op_A     ,
 input red_op_B     ,
 input bypass_A     ,
 input bypass_B     ,

 output reg [5:0]  out  ,
 output reg [15:0] leds );

 reg  in_serial_in , in_red_op_A , in_direction , in_red_op_B , in_bypass_A , in_bypass_B ,in_cin;
 reg flag; 
 reg [3:0] in_opcode;
 reg [2:0] in1 , in2;
 
 
 reg [5:0] out_reg ;
 reg [5:0] shift_temp;

 reg [2:0] counter;
 
 reg [3:0] current_state , next_state;


 parameter OPERATION  =  4'b0001;
 parameter INVALID    =  4'b0010;
 parameter AND_OP     =  4'b0011;
 parameter XOR_OP     =  4'b0100;
 parameter ADD_OP     =  4'b0101;
 parameter MULT_OP    =  4'b0110;
 parameter SHIFT_OP   =  4'b0111;
 parameter ROTATE_OP  =  4'b1000;




 always @(posedge clk or posedge rst) begin
     if (rst) begin
         
         out  <= 0;
         leds <= 0;
         
     end
     else begin
         
         in1     <= A   ;
         in2     <= B   ;
         in_serial_in <= serial_in;
         in_opcode <= opcode;
         in_cin <= cin ;
         in_direction <= direction ;
         in_red_op_A <= red_op_A;
         in_red_op_B <= red_op_B;
         in_bypass_A <= bypass_A;
         in_bypass_B <= bypass_B;

         if(out_reg)
         out <= out_reg ;
         else begin
         out <= 6'b0;   
         end

     end
 end

//____________________________________________________

always @(posedge clk or posedge rst) begin

 if(rst) begin
     current_state <= OPERATION;
 end

 else begin
     current_state <= next_state;
 end

end


//______________________________________________________

 
 always @(*) begin 
  
  case(current_state)



  OPERATION :begin

                if(in_opcode == 3'b110 || in_opcode == 3'b111)
                      next_state = INVALID;
  
 
                else if(in_bypass_A || in_bypass_B)
                      next_state = OPERATION;

                else begin
                      case (opcode)

                         3'b000 : next_state = AND_OP          ;
                         3'b001 : next_state = XOR_OP          ;
                         3'b010 : begin
                                       if(in_red_op_A || in_red_op_B)
                                           next_state = INVALID;
                                        else   
                                           next_state = ADD_OP ;
                                   end                     

                         3'b011 : begin
                                       if(in_red_op_A || in_red_op_B)
                                           next_state = INVALID;
                                        else   
        
                                        next_state = MULT_OP ;

                                   end 
                                       
                         3'b100 : begin
                                       if(in_red_op_A || in_red_op_B)
                                           next_state = INVALID;
                                        else   
                                           next_state = SHIFT_OP     ;
                                     end

                         3'b101 : begin
                                       if(in_red_op_A || in_red_op_B)
                                           next_state = INVALID;
                                        else   
                                           next_state = ROTATE_OP  ;
                                   end

                        endcase
                 end 
           
             end




   AND_OP : begin
       
            next_state = OPERATION;
            end          



   XOR_OP : begin
       
            next_state = OPERATION;
            end          

   ADD_OP : begin
       
            next_state = OPERATION;
            end          




   MULT_OP : begin
       
            next_state = OPERATION;
            end         



   SHIFT_OP : begin
              next_state = OPERATION;
              end


   ROTATE_OP : begin

              next_state = OPERATION;

                end



   INVALID : begin
           
              if(counter != 5)
               next_state <= INVALID;
              else
               next_state <= OPERATION;

           end


    endcase
 end



//______________________________________________


always @(*) begin
    
  case (current_state)

 

 OPERATION : begin
               //out_reg = 0;
               leds    = 0;
               leds    = 0;
               counter = 0;
               flag    = 1; 

                if(in_bypass_A && in_bypass_B) begin 
                    if(INPUT_PERIORITY == "A")
                     out_reg = in1;
                    else
                     out_reg = in2;
                end

                else if(bypass_A)
                   out_reg = in1;

                
                else if(bypass_B)
                   out_reg = in2;

                end




 AND_OP    : begin
               if(in_red_op_A && in_red_op_B) begin
                 if(INPUT_PERIORITY == "A")
                     out_reg = &(in1);

                 else if(INPUT_PERIORITY == "B")
                     out_reg = &(in2);
              end

              else if(in_red_op_A)
                     out_reg = &(in1); 
               
              else if(in_red_op_B)
                     out_reg = &(in2); 
               
               else 
                     out_reg = in1 & in2;
            end     




 XOR_OP  :  begin
                  
              if(in_red_op_A && in_red_op_B) begin
                 if(INPUT_PERIORITY == "A")
                     out_reg = ^(in1);

                 else if(INPUT_PERIORITY == "B")
                     out_reg = ^(in2);
              end

              else if(in_red_op_A)
                     out_reg = ^(in1); 
               
              else if(in_red_op_B)
                     out_reg = ^(in2); 
               
              else 
                     out_reg = in1 ^ in2;

            end      



 
 ADD_OP : begin
     
             if(FULL_ADDER == "ON")
                 out_reg = A + B + cin;

             else if(FULL_ADDER == "OFF")
                 out_reg = A + B ;

          end


  
 
 MULT_OP : begin

          out_reg = in1 * in2 ;
     
          end



 SHIFT_OP : begin

             if(in_direction) begin
                //shift_temp = out_reg;
               if(flag == 1)begin
                out_reg = {out_reg[4:0],in_serial_in};
                flag = 0;
              end
              end

             else 
                // shift_temp = out_reg;
               if(flag == 1)begin
                out_reg = {in_serial_in , out_reg[5:1]};
                flag = 0;
              end
                
     
            end
 


 ROTATE_OP : begin
   
             if(flag == 1)begin
               out_reg = {out_reg[0],out_reg[5:1]} ;
                flag = 0;
              end
             end


  INVALID : begin
            out_reg =  0;
            if(counter != 5) begin
              leds = ~leds ; 
              counter = counter + 1; 
            end 

            end


endcase
end

endmodule

