module ALU_tb();
  reg [15:0] sim_Ain, sim_Bin;
  reg [1:0] sim_ALUop;
  reg err;
  wire[15:0] sim_out;
  wire [2:0] sim_status;

  ALU DUT(sim_Ain, sim_Bin, sim_ALUop, sim_out, sim_status);

//Create a task for repetitive checking
  task my_checker;
    input[15:0] expected_out;
    input expected_Z;
    input expected_N;
    input expected_V;
    begin // If sim_out or sim_Z are not equal to their expected values, we issue an error with err = 1
      if( sim_out !== expected_out) begin
       $display("Error: out is %b, expected %b", sim_out, expected_out);
       err = 1'b1;
      end
      if( sim_status[2] !== expected_Z ) begin
       $display("Error: Z is %b, expected %b", sim_status[2], expected_Z);
       err = 1'b1;
      end
      if( sim_status[1] !== expected_N ) begin
       $display("Error: N is %b, expected %b", sim_status[1], expected_N);
       err = 1'b1;
      end
      if( sim_status[0] !== expected_V ) begin
       $display("Error: V is %b, expected %b", sim_status[0], expected_V);
       err = 1'b1;
      end
    end
  endtask

//Begin checking the different operations to see if they run correctly
  initial begin
    $display("checking Ain + Bin");
    sim_Ain = 16'b0000000000000001; sim_Bin = 16'b0000000000000011; err = 1'b0; sim_ALUop = 2'b00;
    #5;
    my_checker(16'b0000000000000100, 1'b0, 1'b0, 1'b0);

    $display("checking Ain - Bin");
    sim_Ain = 16'b0000000000000011; sim_Bin = 16'b0000000000000001; sim_ALUop = 2'b01;
    #5;
    my_checker(16'b0000000000000010, 1'b0, 1'b0, 1'b0);

    $display("checking Ain & Bin");
    sim_Ain = 16'b0000000000000001; sim_Bin = 16'b0000000000000010; sim_ALUop = 2'b10;
    #5;
    my_checker(16'b0000000000000000, 1'b1, 1'b0, 1'b0);

    $display("checking ~Bin");
    sim_Ain = 16'b0000000000000011; sim_Bin = 16'b0000000000000001; sim_ALUop = 2'b11;
    #5;
    my_checker(16'b1111111111111110, 1'b0, 1'b1, 1'b0);

    //overflow (addition)
    $display("checking overflow flag (addition)");                                                  
    sim_Ain = 16'b0111111111111111; sim_Bin = 16'sb0111111111111111; sim_ALUop = 2'b00;
    #5;
    my_checker(16'b1111111111111110, 1'b0, 1'b1, 1'b1);

    //overflow (subtraction)
    $display("checking overflow flag (subtraction)");                                                  
    sim_Ain = 16'b1000000000000000; sim_Bin = 16'b0000000000000001; sim_ALUop = 2'b01;
    #5;
    my_checker(16'b0111111111111111, 1'b0, 1'b0, 1'b1);

    //negative flag (addition)
    $display("checking negative flag (addition)");                                                  
    sim_Ain = 16'b1111111111111110; sim_Bin = 16'b1111111111111110; sim_ALUop = 2'b00;
    #5;
    my_checker(16'b1111111111111100, 1'b0, 1'b1, 1'b0);

    //negative flag (subtraction)
    $display("checking negative flag (subtraction)");                                                  
    sim_Ain = 16'b1111111111111110; sim_Bin = 16'b0000000000000001; sim_ALUop = 2'b01;
    #5;
    my_checker(16'b1111111111111101, 1'b0, 1'b1, 1'b0);

// If any error was encountered, the if statement will run false (~1 = 0) and display a "FAILED" message
// Else, the if statement will be true (~0 = 1) and will display a PASSED message
    if (~err) 
       $display("PASSED");
    else
       $display("FAILED");

    #480;
    $stop;
   end

endmodule
