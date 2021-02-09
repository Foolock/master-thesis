module PE(clk,rst,ctl,i_in,i_w,i_out,o_in,o_w,o_out,buffer,mul);
parameter width=8;
parameter decimal=4;

input clk,rst;
input[1:0] ctl;

input[width-1:0] i_in,i_w;
input[width-1:0] i_out;

output reg[width-1:0] o_in,o_w;
output [width-1:0] o_out;

output reg[width-1:0] buffer;

//wire[width-1:0] mul0,mul1;

//assign mul0=i_in;
//assign mul1=i_w;

output[width-1:0] mul;

multiply #(.width(width),.decimal(decimal)) m0(i_in,i_w,mul);

always@(posedge clk or negedge rst)begin
	if(!rst)begin
		o_in<=0;
		o_w<=0;
//		o_out<=0;
		buffer<=0;
	end
	else if(ctl == 0) begin //reset
        o_in<=i_in;
		o_w<=i_w;
//		o_out<=0;
		buffer<=0;
	end
	else if(ctl == 1) begin //output pixel
//	    buffer<=buffer+i_in*i_w;
        buffer<=buffer+mul;
	    o_in<=i_in;
		o_w<=i_w;
//		o_out <= buffer;
	end
	else if(ctl == 2) begin //shift pixel, also calculation mode
//	    buffer<=buffer+i_in*i_w;
	    buffer<=buffer+mul;
	    o_in<=i_in;
		o_w<=i_w;
//		o_out <= buffer;
	end
end


assign o_out = (ctl == 1)?buffer:(ctl == 2)?i_out:0; //ctl == 1, output pixel, ctl == 2, shift pixel, also calculation mode

endmodule
