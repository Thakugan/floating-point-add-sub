
// CSE 7381 Fall 2018, Southern Methodist University, Team E
// Final project :  Floating point addition & subtraction
// reference : https://github.com/dawsonjon/fpu/tree/master/adder

module adder(
	input_a, 									// input value A
	input_b,									// input value B
	output_result,								// result of the additon
clk);

	input	[31:0] input_a;						
	input	[31:0] input_b;
	input  	clk;

	output 	[31:0] output_result;
  
	reg    	[3:0] state;						// addition is done in steps where we change state from to another
	reg    	[31:0] saved_output_result;

 
	parameter 	get_a         		= 4'd0,
				get_b         		= 4'd1,
				unpack        		= 4'd2,
				special_cases 		= 4'd3,
				align         		= 4'd4,
				add_exponent        = 4'd5,
				add_mantissa        = 4'd6,
				normalise_exponent  = 4'd7,
				normalise_mantissa  = 4'd8,
				round         		= 4'd9,
				pack          		= 4'd10,
				put_result         	= 4'd11;

	reg   	[31:0] a, b, result;
	reg    	[26:0] a_mantissa, b_mantissa;
	reg    	[23:0] result_mantissa;
	reg    	[9:0] a_exponent, b_exponent, result_exponent;
	reg    	a_sign, b_sign, result_sign;
	reg    	guard, round_bit, sticky;
	reg	    [27:0] sum;

initial begin
	state = get_a;
end

	always @(posedge clk)
	begin
		
		case(state)

		get_a:
		begin
			assign a = input_a;
			state <= get_b;
		end

		get_b:
		begin
			assign b = input_b;
			state <= unpack;
		end

		unpack:
		begin

			a_mantissa = {a[22 : 0], 3'd0};
			b_mantissa = {b[22 : 0], 3'd0};
			a_exponent = a[30 : 23] - 127;
			b_exponent = b[30 : 23] - 127;
			a_sign = a[31];
			b_sign = b[31];

			state <= special_cases; 
		end

		special_cases:
		begin

			//if a is NaN or b is NaN return NaN 
			if ((a_exponent == 128 && a_mantissa != 0) || (b_exponent == 128 && b_mantissa != 0)) 
			begin
				result[31] <= 1;
				result[30:23] <= 255;
				result[22] <= 1;
				result[21:0] <= 0;
				
				state <= put_result;
			end 
			
			//if a is inf return inf
			else if (a_exponent == 128) begin
				result[31] <= a_sign;
				result[30:23] <= 255;
				result[22:0] <= 0;
			  
				//if a is inf and signs don't match return nan
				if ((b_exponent == 128) && (a_sign != b_sign)) begin
					result[31] <= b_sign;
					result[30:23] <= 255;
					result[22] <= 1;
					result[21:0] <= 0;
				end
				
				state <= put_result;
			end 
			
			//if b is inf return inf
			else if (b_exponent == 128) begin
				result[31] <= b_sign;
				result[30:23] <= 255;
				result[22:0] <= 0;
				
				state <= put_result;
			end 
			
			//if a is zero return b
			else if ((($signed(a_exponent) == -127) && (a_mantissa == 0)) && (($signed(b_exponent) == -127) && (b_mantissa == 0))) begin
				result[31] <= a_sign & b_sign;
				result[30:23] <= b_exponent[7:0] + 127;
				result[22:0] <= b_mantissa[26:3];
				
				state <= put_result;
			end 
			
			//if a is zero return b
			else if (($signed(a_exponent) == -127) && (a_mantissa == 0)) begin
				result[31] <= b_sign;
				result[30:23] <= b_exponent[7:0] + 127;
				result[22:0] <= b_mantissa[26:3];
			
				state <= put_result;
			end 
			
			//if b is zero return a
			else if (($signed(b_exponent) == -127) && (b_mantissa == 0)) begin
				result[31] <= a_sign;
				result[30:23] <= a_exponent[7:0] + 127;
				result[22:0] <= a_mantissa[26:3];
				
				state <= put_result;
			end 
			
			else begin
			
				//Denormalised Number
				if ($signed(a_exponent) == -127) begin
					a_exponent <= -126;
				end 
				else begin
					a_mantissa[26] <= 1;
				end

				//Denormalised Number
				if ($signed(b_exponent) == -127) begin
					b_exponent <= -126;
				end 
				else begin
					b_mantissa[26] <= 1;
				end
				state <= align;
			end
		end

		align:
		begin
			
			if ($signed(a_exponent) > $signed(b_exponent)) begin
				b_exponent <= b_exponent + 1;
				b_mantissa <= b_mantissa >> 1;
				b_mantissa[0] <= b_mantissa[0] | b_mantissa[1];
			end 
			
			else if ($signed(a_exponent) < $signed(b_exponent)) begin
				a_exponent <= a_exponent + 1;
				a_mantissa <= a_mantissa >> 1;
				a_mantissa[0] <= a_mantissa[0] | a_mantissa[1];
			end 
			else begin
				state <= add_exponent;
			end
		end

		add_exponent:
		begin
			result_exponent <= a_exponent;
			if (a_sign == b_sign) begin
				sum <= a_mantissa + b_mantissa;
				result_sign <= a_sign;
			end 
			else begin
				if (a_mantissa >= b_mantissa) begin
					sum <= a_mantissa - b_mantissa;
					result_sign <= a_sign;
				end 
				else begin
					sum <= b_mantissa - a_mantissa;
					result_sign <= b_sign;
				end
			end
        state <= add_mantissa;
		end

		add_mantissa:
		begin
			if (sum[27]) begin
				result_mantissa <= sum[27:4];
				guard <= sum[3];
				round_bit <= sum[2];
				sticky <= sum[1] | sum[0];
				result_exponent <= result_exponent + 1;
			end 
			else begin
				result_mantissa <= sum[26:3];
				guard <= sum[2];
				round_bit <= sum[1];
				sticky <= sum[0];
			end
        state <= normalise_exponent;
		end

		normalise_exponent:
		begin
			if (result_mantissa[23] == 0 && $signed(result_exponent) > -126) begin
				result_exponent <= result_exponent - 1;
				result_mantissa <= result_mantissa << 1;
				result_mantissa[0] <= guard;
				guard <= round_bit;
				round_bit <= 0;
			end 
			else begin
				state <= normalise_mantissa;
			end
		end

		normalise_mantissa:
		begin
			if ($signed(result_exponent) < -126) begin
				result_exponent <= result_exponent + 1;
				result_mantissa <= result_mantissa >> 1;
				guard <= result_mantissa[0];
				round_bit <= guard;
				sticky <= sticky | round_bit;
			end 
			else begin
				state <= round;
			end
		end

		round:
		begin
			if (guard && (round_bit | sticky | result_mantissa[0])) begin
				result_mantissa <= result_mantissa + 1;
				if (result_mantissa == 24'hffffff) begin
					result_exponent <=result_exponent + 1;
				end
			end
        state <= pack;
		end

		pack:
		begin
			result[22 : 0] <= result_mantissa[22:0];
			result[30 : 23] <= result_exponent[7:0] + 127;
			result[31] <= result_sign;
			if ($signed(result_exponent) == -126 && result_mantissa[23] == 0) begin
				result[30 : 23] <= 0;
			end

			//if overflow occurs, return inf
			if ($signed(result_exponent) > 127) begin
				result[22 : 0] <= 0;
				result[30 : 23] <= 255;
				result[31] <= result_sign;
			end
        state <= put_result;
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

