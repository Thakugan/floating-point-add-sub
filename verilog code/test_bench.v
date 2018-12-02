/*

CSE 7381: 	Computer Architecture
Fall 2018, 	Southern Methodist University,
Team: 		E
Topic: 		Floating point addition & subtraction

reference : https://github.com/dawsonjon/fpu

*/

module test_ADDER;
    real        double_A, double_B, double_result;
    wire [63:0] result_wire_double;
    reg [31:0]  float_A, float_B;
    wire [31:0] A_wire, B_wire, result_wire_float;
    reg         clock;

    double_to_float convert_2($realtobits(double_B), clock, B_wire);
    double_to_float convert_1($realtobits(double_A), clock, A_wire);
    adder addition(float_A, float_B, result_wire_float, clock);
    float_to_double convert_3(result_wire_double, clock, result_wire_float);


    initial
        begin
            clock <= 1'b0;
            while (1) begin
                #5 clock <= ~clock;
            end
        end




    initial
        begin
            $display("\n\nOUTPUTS======>>\n\n");
            
            // ===== TEST CASES (just change the value of C & D) =====
            
            // test case 1
            double_A = 5.5; double_B = -7.5;
            #200 float_A = A_wire; float_B = B_wire;
            #200 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // test case 2
            double_A = 13.3; double_B = 9.11;
            #200 float_A = A_wire; float_B = B_wire;
            #200 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

        end
endmodule // test_ADDER

	
   
