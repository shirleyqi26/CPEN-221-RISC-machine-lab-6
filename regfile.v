module regfile(data_in,writenum,write,readnum,clk,data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;

    //declare data_out as reg
    reg [15:0] data_out;
    //8 registers
    reg [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

    //wires to store the one hot code indicating 1 of 8 registers
    wire [7:0] onehotwritenum;
    wire [7:0] onehotreadnum;

    //decode the binary writenum and readnum to one hot code (3:8)
    Dec38 decodedwritenum(writenum, onehotwritenum);
    Dec38 decodedreadnum(readnum, onehotreadnum);

    //on a rising edge of clk if write is 1 then data_in is 
        //written into register indicated by onehotwritenum
    always @(posedge clk) begin
        if (write) begin 
            case(onehotwritenum)
                8'b00000001: R0 = data_in; //write data_in into register specified by writenum
                8'b00000010: R1 = data_in;
                8'b00000100: R2 = data_in;
                8'b00001000: R3 = data_in;
                8'b00010000: R4 = data_in;
                8'b00100000: R5 = data_in;
                8'b01000000: R6 = data_in;
                8'b10000000: R7 = data_in;
                //default: R0 = 16'bxxxxxxxxxxxxxxxx; 
            endcase
        end
    end

    //whenever onehotreadnum changes, value in R0 is written to data_out
    //always checking to see if onehotreadnum changes (not clk triggered)
    //case format from slideset 6, slide 21
    always @* begin
        case(onehotreadnum)
            8'b00000001: data_out = R0; //write value in register to dataout
            8'b00000010: data_out = R1;
            8'b00000100: data_out = R2;
            8'b00001000: data_out = R3;
            8'b00010000: data_out = R4;
            8'b00100000: data_out = R5;
            8'b01000000: data_out = R6;
            8'b10000000: data_out = R7;
            default: data_out = 16'bxxxxxxxxxxxxxxxx; 
        endcase
    end

endmodule

//decoder format from slideset 6
module Dec38(a,b);
    //instantiation format: Dec #(n,m) nameOfInstance(a,b);
    //               gives n -> m decoder
    parameter n=3;
    parameter m=8;

    input [n-1:0] a; //binary 
    output [m-1:0] b; //1 hot

    wire [m-1:0] b = 1 << a; //1 shifted to the left by a bit positions
endmodule

