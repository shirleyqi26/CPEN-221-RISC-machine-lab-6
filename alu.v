module ALU(Ain, Bin, ALUop, out, status);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output reg [15:0] out;
  output reg [2:0] status;
  //wire subtract;//, ovf;
  //wire ovf;
  //wire [15:0] out2;

  //reg[15:0] out;
  //reg Z, N, V;
  
  reg subtract;
  
  //check if subtraction
  always @* begin 
    case(ALUop) 
      2'b01: subtract = 1'b1;    
      default: subtract = 1'b0;
    endcase
  end


  // //to get overflow ovf
  // AddSub #16 adds(Ain,Bin,subtract,out2,ovf);

//Whenever ALUop changes, the operation changes, so we use an always block and 
//a case statement to show the different outcomes of each operation
  always @* begin
    case(ALUop)
      2'b00: out = Ain + Bin;
      2'b01: out = Ain - Bin;         
      2'b10: out = Ain & Bin;
      2'b11: out = ~Bin;
      default: out = 16'bxxxxxxxxxxxxxxxx; //Assign don't cares to default to prevent latches
    endcase

    case(out) //Zero flag
      16'b0: status[2] = 1'b1;
      default: status[2] = 1'b0;
    endcase

    casex(out) //Negative flag
      16'b1xxxxxxxxxxxxxxx: status[1] = 1'b1;
      default: status[1] = 1'b0;
    endcase

    case ({Ain[15], Bin[15], out[15], ALUop}) //overflow flag
      {1'b1, 1'b1, 1'b0, 2'b00}: status[0] = 1'b1;  //overflow if result of adding 2 neg numbers = pos number
      {1'b0, 1'b0, 1'b1, 2'b00}: status[0] = 1'b1;  //overflow if result of adding 2 pos numbers = neg number
      {1'b0, 1'b1, 1'b1, 2'b01}: status[0] = 1'b1;  //overflow if result of subtracting a neg number from a pos number = neg number
      {1'b1, 1'b0, 1'b0, 2'b01}: status[0] = 1'b1;  //overflow if result of subtracting a pos number from a neg number = pos number
      default: status[0] = 1'b0;
    endcase

    // case(ovf) //Overflow flag
    //   1'b1: status[2] = 1'b1;
    //   default: status[2] = 1'b0;
    // endcase
  end
endmodule

// //from slideset 6
// // add a+b or subtract a-b, check for overflow
// module AddSub(a,b,sub,s,ovf) ;
//   parameter n = 8 ;
//   input [n-1:0] a, b ;
//   input sub ;           // subtract if sub=1, otherwise add
//   output [n-1:0] s ;
//   output ovf ;          // 1 if overflow
//   wire c1, c2 ;         // carry out of last two bits
//   wire ovf = c1 ^ c2 ;  // overflow if signs don't match


//   // add non sign bits
//   Adder1 #(n-1) ai(a[n-2:0],b[n-2:0]^{n-1{sub}},sub,c1,s[n-2:0]) ;
//   // add sign bits
//   Adder1 #(1)   as(a[n-1],b[n-1]^sub,c1,c2,s[n-1]) ;
// endmodule

// //from slideset 6
// // multi-bit adder - behavioral
// module Adder1(a,b,cin,cout,s) ;
//   parameter n = 8 ;
//   input [n-1:0] a, b ;
//   input cin ;
//   output [n-1:0] s ;
//   output cout ;
//   //wire [n-1:0] s;
//   wire cout ;

//   assign {cout, s} = a + b + cin ;
// endmodule 
