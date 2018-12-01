
// CSE 7381 Fall 2018, Southern Methodist University, Team E
// Final project :  Floating point addition & subtraction
// reference : https://github.com/dawsonjon/fpu/tree/master/adder

module test_floating_pont_addition;
 
	reg [31:0] A, B;
	wire [31:0] result;
	reg  clock;

	adder addition(A,B,result,clock);


	initial
	begin
		clock <= 1'b0;
		while (1) begin
			#5 clock <= ~clock;
		end
	end

  
	initial
    begin
		A = 32'b0;
		B = 32'b0;
    end
   
	initial
    begin

		// convert decimal to single precision & back from : https://www.h-schmidt.net/FloatConverter/IEEE754.html

		#200 
		$display("\n\nA=%b, B=%b, result=%b \n",A,B,result);
		A = 32'b01000001011110110011001100110011; 
		B = 32'b01000001011001001100110011001101;

		#200 
		$display("A=%b, B=%b, result=%b \n",A,B,result);
		A = 32'b01000001101010111011010000111001; 
		B = 32'b01000001110110100001010001111011; 	
		
		#200 
		$display("A=%b, B=%b, result=%b \n",A,B,result);
		A = 32'b01000000100111100001010001111011; 
		B = 32'b01000001100111001000111101011100;	
		
		// Enter more test cases here....

		#200 
		$display("A=%b, B=%b, result=%b \n",A,B,result);

    end

endmodule // test_floating_pont_addition

	
   
