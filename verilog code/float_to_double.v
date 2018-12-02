/*

CSE 7381: 	Computer Architecture
Fall 2018, 	Southern Methodist University,
Team: 		E
Topic: 		Floating point addition & subtraction

reference : https://github.com/dawsonjon/fpu

*/

module float_to_double(
    input_a,
    clock,
    output_result);

    input         clock;


    input  [31:0] input_a;
    output [63:0] output_result;

    reg [63:0]    saved_output_result;

    reg [1:0]     state;
    parameter get_a = 3'd0,
              convert_0 = 3'd1,
              normalise_0 = 3'd2,
              put_result = 3'd3;

    reg [63:0]    result;
    reg [10:0]    result_exponent;
    reg [52:0]    result_mantissa;
    reg [31:0]    a;

    initial begin
        state = get_a;
    end


    always @(posedge clock)
        begin

            case (state)

                get_a:
                    begin
                        assign a = input_a;
                        state <= convert_0;

                    end

                convert_0:
                    begin
                        result[63] <= a[31];
                        result[62:52] <= (a[30:23]-127)+1023;
                        result[51:0] <= {a[22:0], 29'd0};
                        if (a[30:23] == 255) begin
                            result[62:52] <= 2047;
                        end
                        state <= put_result;
                        if (a[30:23] == 0) begin
                            if (a[23:0]) begin
                                state <= normalise_0;
                                result_exponent <= 897;
                                result_mantissa <= {1'd0, a[22:0], 29'd0};
                            end
                            result[62:52] <= 0;
                        end
                    end

                normalise_0:
                    begin
                        if (result_mantissa[52]) begin
                            result[62:52] <= result_exponent;
                            result[51:0] <= result_mantissa[51:0];
                            state <= put_result;
                        end else begin
                            result_mantissa <= {result_mantissa[51:0], 1'd0};
                            result_exponent <= result_exponent-1;
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

