module array(clk,rst,ctls,ins,ws,outs,buffer,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output
,mul1,mul2,mul3,mul4,mul5,mul6,mul7,mul8,mul9,mul10,mul11,mul12,mul13,mul14,mul15,mul16,checkpe01w,checkpe01in);
parameter width=16;
parameter decimal=8;
parameter rows=4;
parameter cols=4;

input clk,rst;

input[rows*cols*2-1:0] ctls;
input[cols*width-1:0] ins;
input[rows*width-1:0] ws;
output[cols*width-1:0] outs;
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
wire[rows*cols*width-1:0] muls;
output[width-1:0] mul1;
output[width-1:0] mul2;
output[width-1:0] mul3;
output[width-1:0] mul4;
output[width-1:0] mul5;
output[width-1:0] mul6;
output[width-1:0] mul7;
output[width-1:0] mul8;
output[width-1:0] mul9;
output[width-1:0] mul10;
output[width-1:0] mul11;
output[width-1:0] mul12;
output[width-1:0] mul13;
output[width-1:0] mul14;
output[width-1:0] mul15;
output[width-1:0] mul16;

assign mul1 = muls[width-1:0];
assign mul2 = muls[2*width-1:width];
assign mul3 = muls[3*width-1:2*width];
assign mul4 = muls[4*width-1:3*width];
assign mul5 = muls[5*width-1:4*width];
assign mul6 = muls[6*width-1:5*width];
assign mul7 = muls[7*width-1:6*width];
assign mul8 = muls[8*width-1:7*width];
assign mul9 = muls[9*width-1:8*width];
assign mul10 = muls[10*width-1:9*width];
assign mul11 = muls[11*width-1:10*width];
assign mul12 = muls[12*width-1:11*width];
assign mul13 = muls[13*width-1:12*width];
assign mul14 = muls[14*width-1:13*width];
assign mul15 = muls[15*width-1:14*width];
assign mul16 = muls[16*width-1:15*width];

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

output[width-1:0] checkpe01w;
output[width-1:0] checkpe01in;



wire [width-1:0] inwin[rows-1:0][cols-1:0];
wire [width-1:0] inwout[rows-1:0][cols-1:0];
wire [width-1:0] wwin[rows-1:0][cols-1:0];
wire [width-1:0] wwout[rows-1:0][cols-1:0];
wire [width-1:0] outwin[rows-1:0][cols-1:0];
wire [width-1:0] outwout[rows-1:0][cols-1:0];

assign checkpe01w = wwin[0][1];
assign checkpe01in = inwin[0][1];

genvar j;
generate
    for(j = 0; j<cols; j = j+1) begin: gentest
        assign row1_in_output[j*width+width-1:j*width] = inwin[1][j];
    end
endgenerate

genvar gr,gc;
generate
	for (gr=0; gr<rows; gr=gr+1) begin : genper
		for(gc=0;gc<cols;gc=gc+1)begin : genpec
		    (* DONT_TOUCH = 1|1 *)
		    //the PE controls are column by column
		    /*
		    [1:0] [5:4]
		    [3:2] [7:6]
		    */
			PE #(.width(width),.decimal(decimal)) PE_gi(clk,rst,ctls[2*((gc*rows)+gr)+1:2*((gc*rows)+gr)], 
			inwin[gr][gc],
			wwin[gr][gc],
			outwin[gr][gc],
			inwout[gr][gc],
			wwout[gr][gc],
			outwout[gr][gc],
			buffer[width*((gr*cols)+gc)+width-1:width*((gr*cols)+gc)],
			muls[width*((gr*cols)+gc)+width-1:width*((gr*cols)+gc)]
			);
		end
	end
endgenerate

reg[cols*width-1:0] ins_reg;

always@(posedge clk or negedge rst)
begin
    if(!rst) 
        ins_reg <= 0;
    else
        ins_reg <= ins;
end

reg[rows*width-1:0] ws_reg;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        ws_reg <= 0;
    else
        ws_reg <= ws;
end

generate
	for (gr=0; gr<rows; gr=gr+1) begin : gencontr
		for(gc=0;gc<cols;gc=gc+1)begin : gencontc
			if(gr==0)begin
				assign inwin[gr][gc]=ins_reg[(gc+1)*width-1:(gc)*width];
			end
			else begin
				assign inwin[gr][gc]=inwout[gr-1][gc];
			end
			
			if(gr==0)begin
				assign outs[(gc+1)*width-1:(gc)*width]=outwout[gr][gc];
				assign outwin[gr][gc]=outwout[gr+1][gc];
			end
			else if(gr==rows-1)begin
				assign outwin[gr][gc]=0;
			end
			else begin
				assign outwin[gr][gc]=outwout[gr+1][gc];
			end
			
			if(gc==0)begin
				assign wwin[gr][gc]=ws_reg[(gr+1)*width-1:(gr)*width];
			end
			else begin
				assign wwin[gr][gc]=wwout[gr][gc-1];
			end
		end
	end
endgenerate
	
endmodule
