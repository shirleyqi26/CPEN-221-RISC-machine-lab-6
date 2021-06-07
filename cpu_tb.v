module cpu_tb();
  reg sim_clk, sim_reset, sim_s, sim_load;
  reg [15:0] sim_in;
  wire[15:0] sim_out;
  wire sim_N, sim_V, sim_Z, sim_w;
   
  reg err = 0;


  cpu dut(sim_clk, sim_reset, sim_s, sim_load, sim_in, sim_out, sim_N, sim_V, sim_Z, sim_w);

  initial forever begin
    sim_clk = 0; #5;
    sim_clk = 1; #5;
  end

  task Rn_checker;
    input [2:0] expected_Rn;
  begin
    if(cpu_tb.dut.Rn !== expected_Rn)begin
       $display("ERROR!: Rn is %b, expected %b", cpu_tb.dut.Rn, expected_Rn);
       err = 1'b1;
     end
end
endtask

 task im8_checker;
    input [15:0] expected_im8;
  begin
    if(cpu_tb.dut.sximm8 !== expected_im8)begin
       $display("ERROR!: sximm8 is %b, expected %b", cpu_tb.dut.sximm8, expected_im8);
       err = 1'b1;
     end
end
endtask

task w_checker;
    input expected_w;
  begin
    if(cpu_tb.dut.w !== expected_w)begin
       $display("ERROR!: w is %b, expected %b", cpu_tb.dut.w, expected_w);
       err = 1'b1;
     end
end
endtask

task out_checker;
    input [15:0] expected_out;
  begin
    if(cpu_tb.dut.out !== expected_out)begin
       $display("ERROR!: out is %b, expected %b", cpu_tb.dut.out, expected_out);
       err = 1'b1;
     end
end
endtask

task instruction_checker;
    input [15:0] expected_instruction;
  begin
    if(cpu_tb.dut.instruction !== expected_instruction)begin
       $display("ERROR!: instruction is %b, expected %b", cpu_tb.dut.instruction, expected_instruction);
       err = 1'b1;
     end
end
endtask

task status_checker;
    input [2:0] expected_status;
  begin
    if(cpu_tb.dut.Z !== expected_status[2])begin
       $display("ERROR!: Z is %b, expected %b", cpu_tb.dut.Z, expected_status[2]);
       err = 1'b1;
     end
    if(cpu_tb.dut.N !== expected_status[1])begin
       $display("ERROR!: N is %b, expected %b", cpu_tb.dut.N, expected_status[1]);
       err = 1'b1;
     end
    if(cpu_tb.dut.V !== expected_status[0])begin
       $display("ERROR!: V is %b, expected %b", cpu_tb.dut.V, expected_status[0]);
       err = 1'b1;
     end
end
endtask

initial begin
//Check that we are still in waiting state when reset = 1
  sim_reset = 1;
  sim_s = 0;
  #10;
  $display("Checking w when reset is 1..");

//Begin with moving the value 1 to register 0
  sim_reset = 0;
  #10;
  sim_load = 1;
  sim_in = 16'b1101000000000001;
  #10;
  sim_s = 1;
  sim_load = 0;
  #10;
  sim_s = 0;
  @(posedge sim_w)
  #10;
  $display("Checking Rn..");
  Rn_checker(3'b000);
  $display("Checking sximm8..");
  im8_checker(16'b0000000000000001);
  $display("Checking R0..");
   if (cpu_tb.dut.DP.REGFILE.R0 !== 16'b0000000000000001) begin
      err = 1;
      $display("FAILED: MOV R0, #1");
    end

//load 1000 0001 to R5
sim_load = 1;
  sim_in = 16'b1101010110000001;
  #10;
  sim_s = 1;
  sim_load = 0;
  #10;
  sim_s = 0;
  @(posedge sim_w)
  #10;
 $display("Checking Rn..");
  Rn_checker(3'b101);
  $display("Checking sximm8..");
  im8_checker(16'b1111111110000001);
 $display("Checking R5..");
   if (cpu_tb.dut.DP.REGFILE.R5 !== 16'b1111111110000001) begin
      err = 1;
      $display("FAILED: MOV R5, 1000 0001");
    end

//Get value from R5, LSR #1 (shift to the right with 0 in MSB), and load it into R6
  sim_load = 1;
  sim_in = 16'b1100000011010101;
  #10;
  sim_s = 1;
  sim_load = 0;
  #10;
  sim_s = 0;
  @(posedge sim_w);
  #10;
  $display("Checking R6..");
   if (cpu_tb.dut.DP.REGFILE.R6 !== 16'b0111111111000000) begin
      err = 1;
      $display("FAILED: MOV R6, R5, LSR#1");
    end
   $display("Checking out..");
  out_checker(16'b0111111111000000);

//Get value from R5, ASR #1(shift to the right with B[15] in MSB), and load it into R7
  sim_load = 1;
  sim_in = 16'b1100000011111101;
  #10;
  sim_s = 1;
  sim_load = 0;
  #10;
  sim_s = 0;
  @(posedge sim_w);
  #10;
  $display("Checking R7..");
   if (cpu_tb.dut.DP.REGFILE.R7 !== 16'b1111111111000000) begin
      err = 1;
      $display("FAILED: MOV R7, R5, ASR#1");
    end
   $display("Checking out..");
  out_checker(16'b1111111111000000);

//Now we move the value 1(shifted to the right by 1) from R0 to R1. The value in R1 should now be 2.
  sim_load = 1;
  sim_in = 16'b1100000000101000;
  #10;
  sim_s = 1;
  sim_load = 0;
  #10;
  sim_s = 0;
  @(posedge sim_w);
  #10;
  $display("Checking R1..");
   if (cpu_tb.dut.DP.REGFILE.R1 !== 16'b0000000000000010) begin
      err = 1;
      $display("FAILED: MOV R1, R0, LSR#1");
    end
   $display("Checking out..");
  out_checker(16'b0000000000000010);

//Now check that if load is 0, the instruction register won't take in a new instruction
  sim_s = 1;
  sim_in = 16'b1100000000000000;
  #10;
  $display("Checking instruction..");
  instruction_checker(16'b1100000000101000);
  sim_s = 0;
  #10;
  
//Test ALU operations (ADD 00), add R0 (1) and R1 (2) and store into R2 (3)
  sim_load = 1;
  sim_in = 16'b1010000001000001;
  #10;
  sim_s = 1;
  sim_load = 0;
  #10;
  sim_s = 0;
  @(posedge sim_w);
  #10;
  $display("ADD: Checking out..");
  out_checker(16'b0000000000000011);
  $display("ADD: Checking status..");
  status_checker(3'bxxx);
 if (cpu_tb.dut.DP.REGFILE.R2 !== 16'b0000000000000011) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0");
    end


//SUBTRACT: subtract R1(2) and R0( 1 but perform LSL #1 makes it 2), should expect the status[2] = 1 (Zero status)
  sim_in = 16'b1010100100001000;
  sim_load = 1;
  #10;
  sim_load = 0;
  sim_s = 1;
  #10;
  sim_s = 0;
  @(posedge sim_w);
  #10;
  $display("SUB ZERO: Checking status..");
  status_checker(3'b100);

//SUBTRACT: but now R0 - R2 (1 - 3 = -2) we should expect the N = 1
  sim_in = 16'b1010100000000010;
  sim_load = 1;
  #10;
  sim_load = 0;
  sim_s = 1;
  #10;
  sim_s = 0;
  @(posedge sim_w);
  #10;
  $display("SUB NEG: Checking status..");
  status_checker(3'b010);

//AND: R1 & R2{ASR#1} into R3 (R1 & R2[ASR#1} = 0)
  sim_in = 16'b1011000101111010;
  sim_load = 1;
  #10;
  sim_load = 0;
  sim_s = 1;
  #10;
  sim_s = 0;
  @(posedge sim_w);
  #10;
  $display("AND: Checking out..");
  out_checker(16'b0);
  $display("AND: Checking status..");
  status_checker(3'b010);//This shouldn't change because we are not subtracting anymore
  if (cpu_tb.dut.DP.REGFILE.R3 !== 16'b0000000000000000) begin
      err = 1;
      $display("FAILED: AND R3, R1, R2, ASR#1");
    end


//MVN: ~R3 into R4, the negation of 0 is all ones so we should expect out = 16'b1111111111111111;
  sim_in = 16'b1011100010000011;
  sim_load = 1;
  #10;
  sim_s = 1;
  sim_load = 0;
  #10;
  sim_s = 0;
  @(posedge sim_w);
  #10;
  $display("MVN: Checking out..");
  out_checker(16'b1111111111111111);
  $display("AND: Checking status..");
  status_checker(3'b010);//This shouldn't change because we are not subtracting anymore
  if (cpu_tb.dut.DP.REGFILE.R4 !== 16'b1111111111111111) begin
      err = 1;
      $display("FAILED: MVN R4, R3");
    end

// If any error was encountered, the if statement will run false (~1 = 0) and display a "FAILED" message
// Else, the if statement will be true (~0 = 1) and will display a PASSED message
    if (~err)
       $display("PASSED");
    else
       $display("FAILED");
  $stop;
end
endmodule
