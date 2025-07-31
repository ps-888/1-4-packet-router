module router(
    input clk,
    input rst,
    input pkt_valid,
    input [7:0] data_in,
    input [1:0] dest_addr,
    input [3:0] ready_out,

    output reg [7:0] data_out0, data_out1, data_out2, data_out3,
    output reg [3:0] valid_out,
    output reg ready_in,
    output reg [1:0] state_out
);

    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter ROUTE = 2'b10;
    parameter WAIT  = 2'b11;

    reg [1:0] current_state, next_state;
    reg [7:0] data_reg;
    reg [1:0] dest_reg;
    reg wait_done;

    always @(posedge clk) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                if (pkt_valid)
                    next_state = START;
                else
                    next_state = IDLE;
            end

            START: begin
                if (ready_out[dest_reg])   
                   
                  next_state = ROUTE;
                else
                    next_state = START;   // Backpressure stall
            end

            ROUTE: begin
                next_state = WAIT;
            end

            WAIT: begin
                if (wait_done)
                    next_state = IDLE;
                else
                    next_state = WAIT;
            end

            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            data_reg <= 8'b0;
            dest_reg <= 2'b0;
            wait_done <= 1'b0;
        end else begin
            if (current_state == IDLE && pkt_valid) begin
                data_reg <= data_in;
                dest_reg <= dest_addr;
            end

            if (current_state == ROUTE)
                wait_done <= 1'b0;
            else if (current_state == WAIT)
                wait_done <= 1'b1;
            else
                wait_done <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            data_out0 <= 8'b0;
            data_out1 <= 8'b0;
            data_out2 <= 8'b0;
            data_out3 <= 8'b0;
            valid_out <= 4'b0;
            ready_in  <= 1'b1;
        end else begin
            case (current_state)
                IDLE: begin
                    valid_out <= 4'b0;
                    ready_in  <= 1'b1;
                    data_out0 <= 8'b0;
                    data_out1 <= 8'b0;
                    data_out2 <= 8'b0;
                    data_out3 <= 8'b0;
                end

                START: begin
                    valid_out <= 4'b0;
                    ready_in  <= 1'b0;
                end

                ROUTE: begin
                    ready_in <= 1'b0;
                    case (dest_reg)
                        2'b00: begin
                            data_out0 <= data_reg;
                            valid_out <= 4'b0001;
                        end
                        2'b01: begin
                            data_out1 <= data_reg;
                            valid_out <= 4'b0010;
                        end
                        2'b10: begin
                            data_out2 <= data_reg;
                            valid_out <= 4'b0100;
                        end
                        2'b11: begin
                            data_out3 <= data_reg;
                            valid_out <= 4'b1000;
                        end
                        default: begin
                            valid_out <= 4'b0000;
                        end
                    endcase
                end

                WAIT: begin
                    ready_in <= 1'b0;
                    case (dest_reg)
                        2'b00: valid_out <= 4'b0001;
                        2'b01: valid_out <= 4'b0010;
                        2'b10: valid_out <= 4'b0100;
                        2'b11: valid_out <= 4'b1000;
                        default: valid_out <= 4'b0000;
                    endcase
                end
            endcase
        end
    end

    always @(*) begin
        state_out = current_state;
    end

endmodule

