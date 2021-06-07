module datapath(clk, readnum, vsel, loada, loadb, shift, asel, 
                bsel, ALUop, loadc, loads, writenum, write, 
                sximm5, sximm8, PC, mdata, Z, N, V, out);
  input loada, loadb, asel, bsel, loadc, loads, write, clk;
  input [1:0] shift, ALUop;
  input [2:0] readnum, writenum;
  input [3:0] vsel;
  input [15:0] sximm5, sximm8;

  wire[15:0] data_in, data_out, sout;

  wire [15:0] aout, in, ALUout, Ain, Bin;
  input [15:0] mdata;
  input [8:0] PC;
  wire [2:0] status;

  output [15:0] out;
  output Z, N, V;

//Multiplexer to choose which value (mdata, sximm8, {7'b0, PC}, or C) to write to the registers
  MuxDataInput #16 mux(vsel, mdata, sximm8, {7'b0, PC}, out, data_in);

//Write or read that value
  regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);


//Instantiate flip-flop to save the values to the corresponding register
//if the corresponding load value is 1
  vdFF #16 a(clk, data_out, loada, aout);

  vdFF #16 b(clk, data_out, loadb, in);

//Shift the value written to register B
  shifter toshift(in, shift, sout);

//Choose which value to do operations on in the ALU block
//1 for 16'b0, 0 for Ain
  Mux #16 muxa(asel, 16'b0, aout, Ain);
//Choose which value to do operations on in the ALU block
//1 for sximm5, 0 for Bin
  Mux #16 muxb(bsel, sximm5, sout, Bin);


//Perform the chosen operation 
  ALU alu(Ain, Bin, ALUop, ALUout, status);

//Output status
  vdFF #1 z(clk, status[2], loads, Z);
  vdFF #1 n(clk, status[1], loads, N);
  vdFF #1 v(clk, status[0], loads, V);

  vdFF #16 c(clk, ALUout, loadc, out);

endmodule

// Flip Flop - Register with Load Enable
// Assign outputs according to the load value, if load is 1, out = in,
// else out will keep its original value
module vdFF(clk, in, load, out);
  parameter n = 1;
  input clk, load;
  input [n-1:0] in;
  wire [n-1:0] next_out;
  output [n-1:0] out;
  reg [n-1:0] out;
 
  assign next_out = load ? in: out;

  always @(posedge clk) begin
    out = next_out;
  end

endmodule


//Multiplexer block to choose which values to proceed through the machine
module Mux(sel, in1, in2, out);
  parameter k = 16;
  input sel;
  input[k-1:0] in1, in2;
  output[k-1:0] out;
  
  assign out = sel ? in1 : in2;

endmodule

//Multiplexer block to choose which values to proceed through the machine
module MuxDataInput(vsel, mdata, sximm8, PC, datapath_out, out);
  parameter k = 16;
  input [3:0] vsel;
  input[k-1:0] mdata, sximm8, PC, datapath_out;
  output reg [k-1:0] out;
  
  always @(*) begin
    case(vsel)
      4'b0001: out = datapath_out;
      4'b0010: out = PC;
      4'b0100: out = sximm8;
      4'b1000: out = mdata;
      default: out = {k{1'bx}};
    endcase
  end
endmodule



