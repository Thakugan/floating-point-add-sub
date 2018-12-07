/*

CSE 7381: 	Computer Architecture
Fall 2018, 	Southern Methodist University,
Team: 		E
Topic: 		Floating point addition & subtraction

here we convert (real /ordouble or 64-bit) values to (shortreal or float or 32-bit)
note:- short real data type not supported by cadense's verilog-XL , thus the conversion
this conversation is similar to real-to-shortreal followed by $shortreaftobits(); method

adding the 2 floating values in single precision format

the resultant value is converted back to double value to display in the terminal
this conversation is similar to real-to-shortreal followed by $bitstoshortreal(); method

*/

module test_ADDER;
    // inputs real values (floating point 64 bits)
    real        double_A, double_B, double_result;

        // output for final result
    wire [63:0] result_wire_double;

        // input for addition n single precision format
    reg [31:0]  float_A, float_B;

        // inputs & output wires for adder module
    wire [31:0] A_wire, B_wire, result_wire_float;

        // modules executes on every postedge cycle of the clock
    reg         clock;

        // converts 1st double value (64 bit) into float (32bit)
    double_to_float convert_2($realtobits(double_B), clock, B_wire);

        // converts 2nd double value (64 bit) into float (32bit)
    double_to_float convert_1($realtobits(double_A), clock, A_wire);

        // adds the 2 newly formed 32 bit float values using single precision method
    adder addition(float_A, float_B, result_wire_float, clock);

        // converts the resultant (32 bit) float value back to real value (64 bit) for displaying in terminal
    float_to_double convert_3(result_wire_float, clock, result_wire_double);

        // initializing clock, clock starting from 0 switches between 0 & 1 every 5 milliseconds
    initial
        begin
            clock <= 1'b0;
            while (1) begin
                #1 clock <= ~clock;
            end
        end




    initial
        begin
            $display("\n\nOUTPUTS======>>\n\n");

            // ===== TEST CASES (just change the value of double_A & double_B & copy the other 3 lines) =====

            // test case 1
            double_A = 5.5; double_B = -7.5;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // test case 2
            double_A = 13.3; double_B = 9.11;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // test case 2
            double_A = -13.3; double_B = 9.11;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // testing 0 additions
            // test case 3
            double_A = 0.0; double_B = 0.0;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // test case 4
            double_A = 0.0; double_B = 1.1;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // test case 5
            double_A = 1.1; double_B = 0.0;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // testing smaller nummbers
            // test case 6
            double_A = 0.000001; double_B = 0.000001;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // test case 7
            double_A = 1.1; double_B = 2.2;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // testing large mantissas
            // test case 8
            double_A = 3.3333333333; double_B = 4.4444444444;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // testing large mantissas with small ones
            // test case 9
            double_A = 3.3333333333; double_B = 4.4;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // testing large numbers
            // test case 10
            double_A = 3333333.333; double_B = 44444444.444;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // test case 11
            double_A = 3.333; double_B = 44444444.444;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // test case 12
            double_A = -3333333.333; double_B = 44444444.444444444;
            #300 float_A = A_wire; float_B = B_wire;
            #300 double_result = $bitstoreal(result_wire_double);
            #100 $display("A = %f,\tB = %f,\tresult = %f", double_A, double_B, double_result);

            // add new test cases here...

        end
endmodule // test_ADDER

	
   
