module systolic_array(clk,rst,ctlpe,ctlbw,ctlbin,w,in,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array);
parameter width=16;
parameter decimal=8;
parameter rows=4;
parameter cols=4;
parameter vector=4;

input clk,rst;
input[rows*cols*2-1:0] ctlpe;
input[rows*2-1:0] ctlbw;
input[cols*2-1:0] ctlbin;
input[width-1:0] w,in;
output[rows*cols*width-1:0] buffer;
output[width-1:0] d1;
output[width-1:0] d2;
output[width-1:0] d3;
output[width-1:0] d4;
output[width-1:0] d5;
output[width-1:0] d6;
output[width-1:0] d7;
output[width-1:0] d8;
output[width-1:0] d9;
output[width-1:0] d10;
output[width-1:0] d11;
output[width-1:0] d12;
output[width-1:0] d13;
output[width-1:0] d14;
output[width-1:0] d15;
output[width-1:0] d16;
output[cols*width-1:0] row1_in_output;

assign d1 = buffer[width-1:0];
assign d2 = buffer[2*width-1:width];
assign d3 = buffer[3*width-1:2*width];
assign d4 = buffer[4*width-1:3*width];
assign d5 = buffer[5*width-1:4*width];
assign d6 = buffer[6*width-1:5*width];
assign d7 = buffer[7*width-1:6*width];
assign d8 = buffer[8*width-1:7*width];
assign d9 = buffer[9*width-1:8*width];
assign d10 = buffer[10*width-1:9*width];
assign d11 = buffer[11*width-1:10*width];
assign d12 = buffer[12*width-1:11*width];
assign d13 = buffer[13*width-1:12*width];
assign d14 = buffer[14*width-1:13*width];
assign d15 = buffer[15*width-1:14*width];
assign d16 = buffer[16*width-1:15*width];

output[cols*width-1:0] ins_array; //output for each input buffer
output[rows*width-1:0] ws_array; //output for each weight buffer
output[cols*width-1:0] outs_array; //output from the array

////check output buffer
//output[rows*width-1:0] cbuffer1;
//output[rows*width-1:0] cbuffer2;
//output[rows*width-1:0] cbuffer3;
//output[rows*width-1:0] cbuffer4;
//wire[rows*width-1:0] cbuffer[cols-1:0];
//assign cbuffer1 = cbuffer[0];
//assign cbuffer2 = cbuffer[1];
//assign cbuffer3 = cbuffer[2];
//assign cbuffer4 = cbuffer[3];
//output [8*cols-1:0] addr;


array #(.width(width),.decimal(decimal),.rows(rows),.cols(cols)) a0(clk,rst,ctlpe,ins_array,ws_array,outs_array,buffer,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output);

wire [width-1:0] wbin[rows-1:0]; //input for each weight buffer
wire [width-1:0] inbin[cols-1:0]; //input for each input buffer
//wire [width-1:0] outbout[cols-1:0]; //output from the buffer
wire [width-1:0] outbprev[cols-1:0]; //output from the adjacent output buffer

genvar gi;
generate
	for (gi=0; gi<rows; gi=gi+1) begin : genbr
//	    (* DONT_TOUCH = "true|yes" *)
		IB #(.width(width),.vector(vector)) ibw_gi(clk,rst,ctlbw[2*gi+1:2*gi],wbin[gi],ws_array[(gi+1)*width-1:gi*width]);
	end
	for (gi=0; gi<cols; gi=gi+1) begin : genbc
//	    (* DONT_TOUCH = "true|yes" *)
		IB #(.width(width),.vector(vector)) ibin_gi(clk,rst,ctlbin[2*gi+1:2*gi],inbin[gi],ins_array[(gi+1)*width-1:gi*width]);
//		if(gi==0) begin
//		  OB #(.width(width),.rows(rows)) ob_gi(clk,rst,ctlbout[2*gi+1:2*gi],outs_array[(gi+1)*width-1:gi*width],outbprev[gi],out,cbuffer[gi],addr[gi*width+width-1:gi*width]);
//	    end
//	    else if(gi==cols-1) begin
//	      OB #(.width(width),.rows(rows)) ob_gi(clk,rst,ctlbout[2*gi+1:2*gi],outs_array[(gi+1)*width-1:gi*width],0,outbprev[gi-1],cbuffer[gi],addr[gi*width+width-1:gi*width]);
//	    end 
//	    else begin
//	      OB #(.width(width),.rows(rows)) ob_gi(clk,rst,ctlbout[2*gi+1:2*gi],outs_array[(gi+1)*width-1:gi*width],outbprev[gi],outbprev[gi-1],cbuffer[gi],addr[gi*width+width-1:gi*width]);
//	    end
	end
endgenerate

generate
	for (gi=0; gi<rows; gi=gi+1) begin : genw
		assign wbin[gi]=w; // assign all the weight buffer with the same input wire, but during storing, enable one weight buffer each time
	end
	for (gi=0; gi<cols; gi=gi+1) begin : genin
		assign inbin[gi]=in; // similar to weight buffer
	end
//	for (gi=0; gi<cols; gi=gi+1) begin : genout
//		if(gi==0)begin
//			assign out=outbout[gi];
//			assign outbprev[gi]=outbout[gi+1];
//		end
//		else if(gi==cols-1)begin
//			assign outbprev[gi]=0;
//		end
//		else begin
//			assign outbprev[gi]=outbout[gi+1];
//		end
//	end
endgenerate

endmodule
