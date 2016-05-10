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
