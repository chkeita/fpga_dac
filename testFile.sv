//`timescale 1 ps / 1 ps
// synopsys translate_on
module deltaSigma_tb (
    );
    
    reg clk;
    reg [2:0] data = 3'b011;
    reg reset;
    wire dataOut;
    
// initial begin 
//     assign clk     = 0;
//     assign reset   = 0;
//     assign dataOut = 0;
// end

always begin
    #10
    clk <= ~clk;
end
    

delta_sigma #(.DATA_SIZE(3)) dut  (
    .data(data),
    .clk(clkl),
    .reset(reset),
    .dataOut(dataOut)
);
    
initial begin
    $monitor("dataOut=%b",dataOut);
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

