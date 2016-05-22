module i2s_receiver #(parameter DATA_SIZE = 32) (
    input sck_clk,
    input wordSelect,
    input data,
    output reg outputSelect,
    output reg [(DATA_SIZE-1):0] leftData,
    output reg [(DATA_SIZE-1):0] rightData
);

    localparam Left     = 0;
    localparam Right    = 1;
    
    always @(negedge sck_clk) begin 
        if (wordSelect == Right) begin
            rightData       <= (rightData << 1) + data;
            outputSelect    <= Left; // we activate the left Output when receiving the right data
        end
        else begin 
            leftData        <= (leftData << 1) + data;
            outputSelect    <= Right;
        end
    end  

endmodule