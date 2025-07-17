`timescale 1ns/1ps

module tb_router_1x4;

    reg clk, rst;
    reg pkt_valid;
    reg [7:0] data_in;
    reg [1:0] dest_addr;
    reg [3:0] ready_out;

    wire [7:0] data_out0, data_out1, data_out2, data_out3;
    wire [3:0] valid_out;
    wire ready_in;
    wire [1:0] state_out;

    router_1x4 uut (
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
  
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period

    // Stimulus
    initial begin
        $monitor("T=%0t | State=%b | pkt_valid=%b | data=%h | dest=%b | ready_out=%b | valid_out=%b | data_out0=%h",
                  $time, state_out, pkt_valid, data_in, dest_addr, ready_out, valid_out, data_out0);

        rst = 1; pkt_valid = 0; data_in = 0; dest_addr = 0; ready_out = 4'b1111;
        #20;
        rst = 0;

        // Send packet to port 0
        @(posedge clk);
        pkt_valid = 1;
        data_in = 8'hA1;
        dest_addr = 2'b00;

        @(posedge clk);
        pkt_valid = 0; 

        repeat (5) @(posedge clk);
       
      // Sending packet to port 1
        @(posedge clk);
        pkt_valid = 1;
        data_in = 8'hB2;
        dest_addr = 2'b01;

        @(posedge clk);
        pkt_valid = 0;

        repeat (5) @(posedge clk);

        // Simulating WAIT 
        @(posedge clk);
        pkt_valid = 1;
        data_in = 8'hC3;
        dest_addr = 2'b10;
        ready_out[2] = 0; // Port 2 not ready

        @(posedge clk);
        pkt_valid = 0;

        // now port 2 is ready
        #30;
        ready_out[2] = 1;

        repeat (5) @(posedge clk);
        $finish;
    end

endmodule
