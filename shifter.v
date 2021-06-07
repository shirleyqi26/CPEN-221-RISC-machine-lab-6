module shifter(in, shift, sout);
  input [15:0] in;
  input [1:0] shift;
  output [15:0] sout;

  reg[15:0] sout;

//Use an always block and case statement: Whenever shift changes value, a different
//operation must be done. Each case produces a different sout from its respective operation
  always @* begin
    case(shift)
      2'b00: sout = in;
      2'b01: sout = {in[14:0], 1'b0};
      2'b10: sout = {1'b0, in[15:1]};
      2'b11: sout = {in[15], in[15:1]};
      default: sout = 16'bxxxxxxxxxxxxxxxx; // set default to don't cares to prevent latches
    endcase
  end
endmodule
