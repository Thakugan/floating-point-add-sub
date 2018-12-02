/*

CSE 7381: 	Computer Architecture
Fall 2018, 	Southern Methodist University,
Team: 		E
Topic: 		Floating point addition & subtraction

reference : https://github.com/dawsonjon/fpu

*/
module double_to_float(
    input_a,
    clock,
    output_result
);

    input         clock;
    input  [63:0] input_a;

    output [31:0] output_result;

    reg [31:0]    saved_output_result;
    reg [1:0]     state;

    parameter
    get_a = 3'd0,
    unpack = 3'd1,
    denormalise = 3'd2,
    put_result = 3'd3;

    reg [63:0]    a;
    reg [31:0]    result;
    reg [10:0]    result_exponent;
    reg [23:0]    result_mantissa;
    reg           guard;
    reg           round;
    reg           sticky;


    initial begin
        state = get_a;
    end


    always @(posedge clock)
        begin

            case (state)

                get_a:
                    begin
                        assign a = input_a;
                        state <= unpack;
                    end

                unpack:
                    begin
                        result[31] <= a[63];
                        state <= put_result;
                        if (a[62:52] == 0) begin
                            result[30:23] <= 0;
                            result[22:0] <= 0;
                        end
                        else if (a[62:52] < 897) begin
                            result[30:23] <= 0;
                            result_mantissa <= {1'd1, a[51:29]};
                            result_exponent <= a[62:52];
                            guard <= a[28];
                            round <= a[27];
                            sticky <= a[26:0] != 0;
                            state <= denormalise;
                        end
                        else if (a[62:52] == 2047) begin
                            result[30:23] <= 255;
                            result[22:0] <= 0;
                            if (a[51:0]) begin
                                result[22] <= 1;
                            end
                        end
                        else if (a[62:52] > 1150) begin
                            result[30:23] <= 255;
                            result[22:0] <= 0;
                        end
                        else begin
                            result[30:23] <= (a[62:52]-1023)+127;
                            if (a[28] && (a[27] || a[26:0])) begin
                                result[22:0] <= a[51:29]+1;
                            end
                            else begin
                                result[22:0] <= a[51:29];
                            end
                        end
                    end

                denormalise:
                    begin
                        if (result_exponent == 897 || (result_mantissa == 0 && guard == 0)) begin
                            state <= put_result;
                            result[22:0] <= result_mantissa;
                            if (guard && (round || sticky)) begin
                                result[22:0] <= result_mantissa+1;
                            end
                        end
                        else begin
                            result_exponent <= result_exponent+1;
                            result_mantissa <= {1'd0, result_mantissa[23:1]};
                            guard <= result_mantissa[0];
                            round <= guard;
                            sticky <= sticky | round;
                        end
                    end

                put_result:
                    begin
                        saved_output_result <= result;
                        state <= get_a;

                    end

            endcase

        end
    assign output_result = saved_output_result;
endmodule

