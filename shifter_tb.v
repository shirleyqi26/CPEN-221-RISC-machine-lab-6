module shifter_tb();
  reg[15:0] sim_in;
  reg[1:0] sim_shift;
  reg err;
  wire[15:0] sim_sout;

  shifter DUT(sim_in, sim_shift, sim_sout);
 
//Create a checker for repetitive testing
  task my_checker;
    input[15:0] expected_sout;
  begin // If sim_sout is not equal to expected_sout, we throw an error and err = 1
    if(sim_sout !== expected_sout) begin
       $display("Error: sout is %b, expected %b", sim_sout, expected_sout);
       err = 1'b1;
    end
  end
  endtask


//Begin testing all the different operations 
  initial begin
    $display("No shift");
    sim_in = 16'b1111000011110000; sim_shift = 2'b00; err = 1'b0; #5;
    my_checker(sim_in);

    $display("Shift 1 place to the left");
    sim_in = 16'b1111000011110000; sim_shift = 2'b01; #5;
    my_checker({sim_in[14:0], 1'b0});

    $display("Shift 1 place to the right");
    sim_in = 16'b1111000011110000; sim_shift = 2'b10; #5;
    my_checker({1'b0, sim_in[15:1]});

    $display("Shift 1 place to the right and puts a B[15} at the end");
    sim_in = 16'b1111000011110000; sim_shift = 2'b11; #5;
    my_checker({sim_in[15], sim_in[15:1]});
   
//If we encounter an error (~1 = 0) a "FAILED" message will be displayed
//Else the if statement will be true and we display a "PASSED" message (~0 = 1)
    if (~err)
       $display("PASSED");
    else
       $display("FAILED");

    #480;
    $stop;
    end

endmodule
