module upsampler #(
        parameter DATA_SIZE = 32, 
        parameter STUFFING = 4,
        parameter TAP_LENGTH = 12,
        parameter [(DATA_SIZE-1):0] [0 : TAP_LENGTH-1] TAP_COEFFiCIENTS = { TAP_LENGTH {1}}
        ) (
    input newData,
    input [(DATA_SIZE-1):0] data,
    input clk,
    input reset,
    output [(DATA_SIZE-1):0] dataOut
);
    parameter DELAY_LINE_LENTGTH = TAP_LENGTH*(STUFFING+1);
    reg delayLine [(DATA_SIZE-1):0] [0:(DELAY_LINE_LENTGTH-1)] = { DELAY_LINE_LENTGTH {0}};
    assign dataOut = delayLine[(TAP_LENGTH*STUFFING) - 1];
    integer i;
    
    always @(posedge newData) begin 
        // Adding new data to the begining of the delay line and stuff the with zeros
        delayLine[0] <= data;
        // stuffing with zeros
        for (i = 1; i < STUFFING; i = i + 1) begin
            delayLine[0] <= 0;
        end
        // making existing data go throug 
        repeat (STUFFING+1) begin
            for (i = 0; i < DELAY_LINE_LENTGTH - 1; i = i + 1) begin
                delayLine[i+1] = delayLine[i] * TAP_COEFFiCIENTS[i+1];
            end
        end
    end
endmodule

//** Error: C:/dev/fpga_dac/upsampler.sv(15): Illegal assignment to type 'reg[DATA_SIZE-1:0]' from type 'reg $[0:DELAY_LINE_LENTGTH-1]': Cannot assign an unpacked type to a packed type.