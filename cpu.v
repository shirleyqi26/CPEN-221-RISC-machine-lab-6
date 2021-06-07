module cpu(clk, reset, s, load, in, out, N, V, Z, w);
  input clk, reset, s, load;
  input [15:0] in;
  output [15:0] out;
  output N, V, Z, w;

//Intermediate values
  wire [15:0] sximm5, sximm8;
  wire [2:0] Rn, Rd, Rm;
  wire [2:0] readnum, writenum, opcode;
  wire [1:0] ALUop, shift, op;

//If a cycle is finished, this will indicate to stay in waiting
  reg finished;

  reg [15:0] instruction;

  reg w, loada, loadb, loadc, loads, asel, bsel, write;
  reg [3:0] vsel;
  reg [2:0] nsel, ALU_state, move_state;
 
//Instruction Register
//If load is 1, the new instruction will be taken, else it will not change
  always @(posedge clk) begin
    if(load == 1)
      instruction = in;
    else
      instruction = instruction;
  end

//Assign accordingly to solve for readnum and writenum
  assign Rn = instruction[10:8];
  assign Rd = instruction[7:5];
  assign Rm = instruction[2:0];

//Instruction Decoder
  instructionDecoder iD(instruction, Rn, Rd, Rm, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, op, opcode);

//State Machine
  always @(posedge clk) begin
    if( reset || ((~s && ALU_state == 3'b000) && (~s && move_state == 3'b000)) || (~s && finished)) begin //If reset or s is 0, the state machine is stilling in a waiting state
       ALU_state = 3'b000; move_state = 3'b000; w = 1; nsel = 3'bxxx; loada = 1'b0; loadb = 1'b0; asel = 1'bx; bsel = 1'bx; loadc = 1'b0; vsel = 4'bxxxx; write = 1'b0; loads = 0; // 3'b000 is the waiting state for both ALU and move, w = 1 to indicate the waiting state
    end else begin//Else we are carrying out the operations
    w = 0;
    if( opcode == 3'b101) begin//ALU operations
    case(ALU_state)//Depending on what ALU_state is, go to the next state at rising edge of clk
      3'b000: ALU_state = 3'b001;
      3'b001: ALU_state = 3'b010;
      3'b010: ALU_state = 3'b011;
      3'b011: ALU_state = 3'b100;
      3'b100: ALU_state = 3'b000;
      default: ALU_state = 3'bxxx;
    endcase

    case(ALU_state)//At each stage, set the specified data path control signals
      3'b001: begin nsel = 3'b100; loada = 1'b1; loadb = 1'b0; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; vsel = 4'bxxxx; write = 1'b0; finished = 0; loads = 0; end //Load Rn to reg A
      3'b010: begin nsel = 3'b001; loada = 1'b0; loadb = 1'b1; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; vsel = 4'bxxxx; write = 1'b0; finished = 0; loads = 0; end // Load Rm to reg B
      3'b011: begin //Perform ALU operations with the appropriate data path values
              if(ALUop == 2'b01) begin //If we are subtracting, we set loadc to 0 because we do not want to carry the value through the datapath
                nsel = 3'bxxx; loada = 1'b0; loadb = 1'b0; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; vsel = 4'bxxxx; write = 1'b0;  finished = 0; loads = 1;
              end else begin     
              if(ALUop == 2'b11)begin// If we are negating, we want asel = 1 to add 0 to what is stored in reg B
                nsel = 3'bxxx; loada = 1'b0; loadb = 1'b0; asel = 1'b1; bsel = 1'b0; loadc = 1'b1; vsel = 4'bxxxx; write = 1'b0; finished = 0; loads = 0;
              end else begin
                nsel = 3'bxxx; loada = 1'b0; loadb = 1'b0; asel = 1'b0; bsel = 1'b0; loadc = 1'b1; vsel = 4'bxxxx; write = 1'b0; finished =0; loads = 0; //Else we take whatever is in reg A and B
              end
              end
              end
      3'b100: begin // Write to register
              if(ALUop == 2'b01) begin//DO not write anything to a register when subtracting
                nsel = 3'bxxx; loada = 1'b0; loadb = 1'b0; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; vsel = 4'bxxxx; write = 1'b0; finished = 1; loads = 0;
              end else begin// Else we write to the desired register
                nsel = 3'b010; loada = 1'b0; loadb = 1'b0; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; vsel = 4'b0001; write = 1'b1; finished = 1; loads = 0;
              end
              end
      default: begin nsel = 3'bxxx; loada = 1'bx; loadb = 1'bx; asel = 1'bx; bsel = 1'bx; loadc = 1'bx; vsel = 4'bxxxx; write = 1'bx; finished = 1'bx; loads = 1'bx; end
    endcase
   
    end else begin//move operations

    case(move_state)//Depending on what move_state is, go to the next state at rising edge of clk
      3'b000: move_state = 3'b001;
      3'b001: move_state = 3'b010;
      3'b010: move_state = 3'b011;
      3'b011: move_state = 3'b000;
      default: move_state = 3'bxxx;
    endcase

    case(move_state)//At each stage, set the specified data path control signals
      3'b001: begin //Load to appropriate registers
         if(op == 2'b10) begin // We are not carrying out any operation paths, just loading a register with a value
            nsel = 3'b100; loada = 1'b0; loadb = 1'b0; write = 1'b1; vsel = 4'b0100; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; finished = 1; loads = 0;
         end else begin 
         if (op == 2'b00) begin// We are shifting a value from a register 
            nsel = 3'b001; loada = 1'b0; loadb = 1'b1; vsel = 4'bxxxx; write = 1'b0; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; finished = 0; loads = 0;
         end else begin
            nsel = 3'bxxx; loada = 1'b0; loadb = 1'b0; vsel = 4'bxxxx; write = 1'b0; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; finished = 1'bx; loads = 0;
         end
         end
         end

      3'b010: if( op == 2'b00 ) begin //carry out ALU operations with the correct data path values
                nsel = 3'bxxx; loada = 1'b0; loadb = 1'b0; vsel = 4'bxxxx; write = 1'b0; asel = 1'b1; bsel = 1'b0; loadc = 1'b1; finished = 0; loads = 0;
              end else begin
                nsel = 3'bxxx; loada = 1'b0; loadb = 1'b0; vsel = 4'bxxxx; write = 1'b0; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; finished = 1'bx; loads = 0;
              end

      3'b011: if( op == 2'b00 ) begin//Load back into register 
                 nsel = 3'b010; loada = 1'b0; loadb = 1'b0; vsel = 4'b0001; write = 1'b1; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; finished = 1; loads = 0;
              end else begin
                 nsel = 3'bxxx; loada = 1'b0; loadb = 1'b0; vsel = 4'bxxxx; write = 1'b0; asel = 1'b0; bsel = 1'b0; loadc = 1'b0; finished = 1'bx; loads = 0;
              end

      default: begin nsel = 3'bxxx; loada = 1'b0; loadb = 1'bx; vsel = 4'bxxxx; write = 1'bx; asel = 1'bx; bsel = 1'bx; loadc = 1'bx;  finished = 1'bx; loads = 1'bx; end 
    endcase

    end
   end
end

//If ALUop indicates subtraction, we want to update the status register, else the status register stays the same
 // always @(*) begin
//    if(ALUop == 2'b01)
 //      loads = 1'b1;
 //   else
 //      loads = 1'b0;
  //end 

//Carrying out operations in datapath
  datapath DP(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, sximm5, sximm8, Z, N, V, out);
               

endmodule


//Instruction Decoder to decode sequences of bits in instruction into the values for ALUop, op, sximm5, etc.
module instructionDecoder(instruction, Rn, Rd, Rm, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, op, opcode);
  input [15:0] instruction;
  input [2:0] Rn, Rd, Rm;
  input [2:0] nsel;
  output[15:0] sximm5, sximm8;
  output[1:0] ALUop, shift, op;
  output[2:0] readnum, writenum, opcode;

  wire [2:0] muxOut;

//Assign accordingly
  assign sximm5 = {{11{instruction[4]}}, instruction[4:0]};
  assign sximm8 = {{8{instruction[7]}}, instruction[7:0]};
  assign ALUop = instruction[12:11];
  assign shift = instruction[4:3];
  assign opcode = instruction[15:13];
  assign op = instruction[12:11];
  

//Multiplexer to assign the designated registers to use
  Muxcpu mux(nsel, Rn, Rd, Rm, muxOut);
  
  assign readnum = muxOut;
  assign writenum = muxOut;

endmodule


//Multiplexer to select which register to use for the operation
module Muxcpu(sel, a, b, c, out);
  input [2:0] a, b, c;
  input [2:0] sel;
  output [2:0] out;

  reg [2:0] out;

//Assign each output value according to what sel is
  always @(*) begin
    case(sel)
      3'b001: out = c;
      3'b010: out = b;
      3'b100: out = a;
      default: out = {3{1'bx}};
    endcase
  end
endmodule
  

