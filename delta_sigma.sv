module delta_sigma #(parameter DATA_SIZE = 32) (
    input [(DATA_SIZE-1):0] data,
    input clk,
    input reset,
    output dataOut
);

    localparam UpperIndex    = (DATA_SIZE-1+2);
    wire    [UpperIndex:0 ] SigmaAdder;
    wire    [UpperIndex:0 ] DeltaAdder;
    
    reg     [UpperIndex:0 ] SigmaRegister = 1 << DATA_SIZE + 1; // initializing to 100..00

    assign dataOut = SigmaRegister >> (DATA_SIZE + 1); //LSB
    assign DeltaAdder = (dataOut == 0 ? 0 : 2'b11 << DATA_SIZE) + data ;  
    assign SigmaAdder = DeltaAdder + SigmaRegister;

    always @(posedge clk) begin
        SigmaRegister = SigmaAdder;        
    end

endmodule