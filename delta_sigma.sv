module delta_sigma #(parameter DATA_SIZE = 32) (
    input [(DATA_SIZE-1):0] data,
    input clk,
    input reset,
    output dataOut
);

    localparam UpperIndex    = (DATA_SIZE-1+2);
    reg [UpperIndex:0 ] DeltaAdder_d = 0;
    reg [UpperIndex:0 ] DeltaAdder_q = 0;
    reg [UpperIndex:0 ] SigmaAdder_d = 0;
    reg [UpperIndex:0 ] SigmaAdder_q = 0;
    reg [($clog2(DATA_SIZE)-1):0]counter = 0;
    reg [UpperIndex:0 ] outRegister = 0;

    assign dataOut = outRegister; //LSB

    always @(posedge clk) begin
        DeltaAdder_q <= DeltaAdder_d;
        SigmaAdder_q <= SigmaAdder_d;        

	if (counter == 0) begin 
            // reset adders 
            DeltaAdder_d <= 2'b11 << DATA_SIZE + data; /// mask and datas
            SigmaAdder_d <= 2'b01 << DATA_SIZE;
        end

       if (dataOut == 0)begin
           DeltaAdder_d <= 0;
       end
       else begin
           DeltaAdder_d <= 2'b11 << DATA_SIZE;
           //1?scomplement of the highest N bit number, sign-extendedto N+2 bits
       end
       SigmaAdder_d <= SigmaAdder_d + dataOut;

    end

endmodule