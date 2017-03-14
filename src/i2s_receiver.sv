module i2s_receiver #(parameter DATA_SIZE = 32) (
    input sck_clk,
    input wordSelect,
    input data,
    output reg [(DATA_SIZE-1):0] rightData = 0,
    output reg [(DATA_SIZE-1):0] leftData = 0
);

    localparam Left     = 0;
    localparam Right    = 1;

    always @(posedge sck_clk) begin 
        if (wordSelect == Right) begin
            rightData       = {rightData[(DATA_SIZE-2):0], data};
        end
    end
    always @(posedge sck_clk) begin 
        if (wordSelect == Left ) begin 
            leftData        = {leftData[(DATA_SIZE-2):0], data};
        end
    end  

endmodule