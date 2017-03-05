//`timescale 1 ps / 1 ps
// synopsys translate_on
`include "./delta_sigma.sv"
module delta_sigma_tb ();
    
    reg clk = 0;
    reg [2:0] data = 3'b011;
    reg reset = 0;
    wire dataOut;

always begin
    #10
    clk <= ~clk;
end
    
delta_sigma #(.DATA_SIZE(3)) dut  (
    .data(data),
    .clk(clk),
    .reset(reset),
    .dataOut(dataOut)
);

reg [4:0] counter = 0;
reg [8:0] result = 0;

always @(posedge clk) begin
    $display("dataOut=%b",dataOut);
    counter = counter + 1;
    if (counter < 10) begin 
        result <= (result << 1) + dataOut;
    end
    else 
        begin
            // icarus verilog does not seem to support assert
            // assert (result == 9'b100100101 );
            if (result == 9'b100100101) begin
                $display("success");
                $finish;
            end
            else begin
                $display("failed");
                $finish;
            end
        end
end

    


endmodule

//     ?       ?OUT    ?       ?OUT    DacOut
// t0  11000   11011   10000   01011   1
// t1  00000   00011   01011   01110   0
// t2  00000   00011   01110   10001   0
// t3  11000   11011   10001   01100   1
// t4  00000   00011   01100   01111   0
// t5  00000   00011   01111   10010   0
// t6  11000   11011   10010   01101   1
// t7  00000   00011   01101   10000   0
// t8  11000   11011   10000   01011   1
// 

