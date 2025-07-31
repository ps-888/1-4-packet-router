`timescale 1ns / 1ps

module tb_router;

    reg clk, rst;
    reg pkt_valid;
    reg [7:0] data_in;
    reg [1:0] dest_addr;
    reg [3:0] ready_out;

    wire [7:0] data_out0, data_out1, data_out2, data_out3;
    wire [3:0] valid_out;
    wire ready_in;
    wire [1:0] state_out;

    router uut (
        .clk(clk),
        .rst(rst),
        .pkt_valid(pkt_valid),
        .data_in(data_in),
        .dest_addr(dest_addr),
        .ready_out(ready_out),
        .data_out0(data_out0),
        .data_out1(data_out1),
        .data_out2(data_out2),
        .data_out3(data_out3),
        .valid_out(valid_out),
        .ready_in(ready_in),
        .state_out(state_out)
    );


    always #5 clk = ~clk;

    initial begin
        $dumpfile("router.vcd");
        $dumpvars(0, tb_router);

        clk = 0;
        rst = 1;
        pkt_valid = 0;
        data_in = 8'h00;
        dest_addr = 2'b00;
        ready_out = 4'b1111;

        #15 rst = 0;

        #10 pkt_valid = 1;
            data_in = 8'hAA;
            dest_addr = 2'b00;

        #10 pkt_valid = 0;

        #30;

        ready_out = 4'b1101; // port 1 not ready
        #10 pkt_valid = 1;
            data_in = 8'hBB;
            dest_addr = 2'b01;

        #10 pkt_valid = 0;

        #20 ready_out = 4'b1111;

        #40;

        $finish;
    end

endmodule

