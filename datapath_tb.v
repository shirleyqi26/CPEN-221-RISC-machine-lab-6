module datapath_tb();
  reg loada, loadb, asel, bsel, loadc, loads, write, clk;
  reg [3:0] vsel;
  reg[1:0] shift, ALUop;
  reg[2:0] readnum, writenum;
  reg[15:0] sximm8, sximm5, mdata;
  reg[8:0] PC;
 
  reg err = 0;

  wire[15:0] out;
  wire Z, N, V;

 datapath dut(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, sximm5, sximm8, PC, mdata, Z, N, V, out);
//Initialize clock to go until we finish our tests
  initial forever begin
    clk = 0; #5;
    clk = 1; #5;
  end

//Task checker to check for the data_in after using 
//vsel to choose between datapath_in and datapath_out
  task my_datachecker;
     input [15:0] expected_data_in;
  begin
//Throw an error if the results are not the same
    if(datapath_tb.dut.data_in !== expected_data_in)begin
       $display("!ERROR: data_in is %b, expected %b", datapath_tb.dut.data_in, expected_data_in);
       err = 1'b1;
    end
    end
  endtask

//Task checker to check for data_out after writing to either
//register A or B
  task my_dataoutchecker;
     input [15:0] expected_data_out;
  begin
    if(datapath_tb.dut.data_out !== expected_data_out)begin
       $display("!ERROR: data_out is %b, expected %b", datapath_tb.dut.data_out, expected_data_out);
       err = 1'b1;
end
    end
  endtask

//Task checker to check for datapath_out after performing
//the ALU/shift operations 
  task my_datapath_outchecker;
     input [15:0] expected_datapath_out;
  begin
    if( out !== expected_datapath_out)begin
       $display("!ERROR: datapath_out is %b, expected %b", out, expected_datapath_out);
       err = 1'b1;
end
    end
  endtask

initial begin
//Write 7 into register 0
sximm8 = 16'b0000000000000111;
vsel = 4'b0100;
writenum = 3'b000;
write = 1'b1;
#10;

//Check to see if the value has been loaded into R0
if(datapath_tb.dut.REGFILE.R0 !== sximm8)begin
       $display("!ERROR: R0 is %b, expected %b", datapath_tb.dut.REGFILE.R0, sximm8);
       err = 1'b1;
end
//Check to see if data_in in datapath.v matches with this value
my_datachecker(16'b0000000000000111);
 
//Write 2 into register 1
sximm8 = 16'b0000000000000010;
writenum = 3'b001;

#10;
if(datapath_tb.dut.REGFILE.R1 !== sximm8)begin
       $display("!ERROR: R1 is %b, expected %b", datapath_tb.dut.REGFILE.R1, sximm8);
       err = 1'b1;
end
my_datachecker(16'b0000000000000010);

//Load 7 in R0 to reg B
loadb = 1'b1;
readnum = 3'b000;

#10;
my_dataoutchecker(16'b0000000000000111);

loadb = 1'b0;

//Load 2 in R1 to reg A
loada = 1'b1;
readnum = 3'b001;

#10;
my_dataoutchecker(16'b0000000000000010);

loada = 1'b0;

//Perform addition and shifting, 7 should be shifted to the left to become 14 and then added with 2
ALUop = 2'b00;//Addition
asel = 0;
bsel = 0;
shift = 2'b01;//Left shift
loadc = 1;//Output to LED display
loads = 0;

#10;

//Check if the result is 16
my_datapath_outchecker(16'b0000000000010000);

loadc = 0;

//Store result into R2
vsel = 3'b0001;//vsel is 0 to take datapath_out instead of datapath_in
write = 1;
writenum = 3'b010;

#10;
//Check if it has been stored into R2
if(datapath_tb.dut.REGFILE.R2 !== 16'b0000000000010000)begin
       $display("!ERROR: R2 is %b, expected 0000000000010000", datapath_tb.dut.REGFILE.R2);
       err = 1'b1;
end

//Check if data_in is 16
my_datachecker(16'b0000000000010000);

write = 0;

// If any error was encountered, the if statement will run false (~1 = 0) and display a "FAILED" message
// Else, the if statement will be true (~0 = 1) and will display a PASSED message
    if (~err) begin
       $display("PASSED");
     end else begin
       $display("FAILED");
     end
     
#440;
$stop;
end

endmodule
