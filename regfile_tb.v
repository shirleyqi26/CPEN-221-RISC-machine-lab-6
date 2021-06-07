module regfile_tb();
    reg         err;
    reg         sim_clk, sim_write;
    reg  [2:0]  sim_writenum, sim_readnum;
    reg  [15:0] sim_datain;
    wire [15:0] sim_dataout;

    regfile DUT(sim_datain, sim_writenum, sim_write, sim_readnum, 
                sim_clk, sim_dataout);

    //check that the data written to the register is the same as datain
    task check_write;
        input [15:0] registervalue;
        input [15:0] expected_datain;

        begin
            if (registervalue !== expected_datain ) begin
                $display("ERROR ** data in register is %b, expected %b", registervalue, expected_datain);
                err = 1'b1;
            end
        end
    endtask

    //check that dataout gets the value in the register
    task check_read;
        input [15:0] expected_registervalue;

        begin
            if (sim_dataout !== expected_registervalue ) begin
                $display("ERROR ** sim_dataout is %b, expected %b", sim_dataout, expected_registervalue);
                err = 1'b1;
            end
        end
    endtask

    //set the clock
    initial begin      
        forever begin               
            sim_clk = 1; #5;     
            sim_clk = 0; #5;    
        end 
    end

    //simulate the signals
    initial begin
        err = 1'b0;
        sim_write = 0;                     //test when !write, expect nothing on datain in same time step
        
        sim_datain = 16'b0000000000000000; //set datain to 0 in binary            
        #5;                                //wait 5
        sim_write = 1;                     //indicate we want to write on next posedge
        sim_writenum = 3'b000;             //indicate want to write to R0, expect R0 = 0000000000000000 on same time step
        #10;                               //wait 10
        check_write(regfile_tb.DUT.R0, sim_datain);
        sim_readnum = 3'b000;              //indicate we want to read R0 (not posedge triggered), expect dataout = 0000000000000000 on same time
        #5;                                //wait 5
        check_read(regfile_tb.DUT.R0);

        sim_datain = 16'b0000000000000001; //set datain to 1 in binary            
        sim_writenum = 3'b001;             //indicate want to write to R1, expect R1 = 16'0000000000000001
        #10;                               //wait 10
        check_write(regfile_tb.DUT.R1, sim_datain);
        sim_readnum = 3'b001;              //indicate we want to read R1, expect dataout = 16'0000000000000001
        #5;                                //wait 5
        check_read(regfile_tb.DUT.R1);

        sim_datain = 16'b0000000000000010; //set datain to 2 in binary            
        sim_writenum = 3'b010;             //indicate want to write to R2, expect R2 = 0000000000000010
        #10;                               //wait 10
        check_write(regfile_tb.DUT.R2, sim_datain);
        sim_readnum = 3'b010;              //indicate we want to read R2, expect dataout = 0000000000000010
        #5;                                //wait 5
        check_read(regfile_tb.DUT.R2);

        sim_datain = 16'b0000000000000011; //set datain to 3 in binary            
        sim_writenum = 3'b011;             //indicate want to write to R3, expect R3 = 0000000000000011
        #10;                               //wait 10
        check_write(regfile_tb.DUT.R3, sim_datain);
        sim_readnum = 3'b011;              //indicate we want to read R3, expect dataout = 0000000000000011
        #5;                                //wait 5
        check_read(regfile_tb.DUT.R3);

        sim_datain = 16'b0000000000000100; //set datain to 4 in binary            
        sim_writenum = 3'b100;             //indicate want to write to R4, expect R4 = 0000000000000100
        #10;                               //wait 10
        check_write(regfile_tb.DUT.R4, sim_datain);
        sim_readnum = 3'b100;              //indicate we want to read R4, expect dataout = 0000000000000100
        #5;                                //wait 5
        check_read(regfile_tb.DUT.R4);

        sim_datain = 16'b0000000000000101; //set datain to 5 in binary            
        sim_writenum = 3'b101;             //indicate want to write to R5, expect R5 = 0000000000000101
        #10;                               //wait 10
        check_write(regfile_tb.DUT.R5, sim_datain);
        sim_readnum = 3'b101;              //indicate we want to read R5, expect dataout = 0000000000000101
        #5;                                //wait 5
        check_read(regfile_tb.DUT.R5);

        sim_datain = 16'b0000000000000110; //set datain to 6 in binary            
        sim_writenum = 3'b110;             //indicate want to write to R6, expect R6 = 0000000000000110
        #10;                               //wait 10
        check_write(regfile_tb.DUT.R6, sim_datain);
        sim_readnum = 3'b110;              //indicate we want to read R6, expect dataout = 0000000000000110
        #5;                                //wait 5
        check_read(regfile_tb.DUT.R6);

        sim_datain = 16'b0000000000000111; //set datain to 0 in binary            
        sim_writenum = 3'b111;             //indicate want to write to R7, expect R7 = 0000000000000111
        #10;                               //wait 10
        check_write(regfile_tb.DUT.R7, sim_datain);
        sim_readnum = 3'b111;              //indicate we want to read R7, expect dataout = 0000000000000111
        #5;                                //wait 5        
        check_read(regfile_tb.DUT.R7);

        #50;
        #325;
        $stop;
    end
endmodule
