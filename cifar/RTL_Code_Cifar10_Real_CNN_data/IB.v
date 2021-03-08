module IB(clk,rst,ctl,in,out,cbuffer,addr);
parameter width=16;
parameter vector=4;

input clk,rst;
input[1:0] ctl;
input[width-1:0] in;
output reg[width-1:0] out;

reg[width-1:0] buffer[vector-1:0];

output[vector*width-1:0] cbuffer;

assign cbuffer[width-1:0] = buffer[0];
assign cbuffer[2*width-1:width] = buffer[1];
assign cbuffer[3*width-1:2*width] = buffer[2];
assign cbuffer[4*width-1:3*width] = buffer[3];

reg[7:0] i;

output reg[7:0] addr;

always@(posedge clk or negedge rst)begin
	if(!rst)begin
		for(i=0;i<vector;i=i+1)begin
			buffer[i]<=0;
		end
		out<=0;
		addr<=0;
	end
	else begin
	    if(ctl==3)begin
	       for(i=0;i<vector;i=i+1)begin
			buffer[i]<=0;
		   end
		   out<=0;
		   addr<=0;
	    end
		else if(ctl==0)begin//idle
			addr<=0;
			out<=0;
		end
		else if(ctl==1)begin//store
			if(addr<vector)begin
				buffer[addr]<=in;
				addr<=addr+1;
			end		
			out<=0;
		end
		else if(ctl==2)begin//out
			if(addr<vector)begin
				out<=buffer[addr];
                addr<=addr+1;
			end
			else begin
				out<=0; 
				addr <= 0;  //after store, addr == vector, so before out we need one clock period to reset the address
			end
		end
	end
end

//reg[2:0] countb; //counter for buffer
//always@(posedge clk or negedge rst)
//begin
//    if(!rst) begin
//        countb <= 0;
//    end
//    else if(ctl == 0) begin
//        countb <= 0;
//    end
//    else if(ctl == 1 || ctl == 2) begin //each time the store is finished(ctl = 1), make sure reset the countb(ctl = 0) before output(ctl = 2)
//        if(countb == 3)
//            countb <= countb;
//        else
//            countb <= countb + 1;
//    end
//    else begin
//        countb <= 0;
//    end
//end

//always@(ctl,countb)
//begin
//    case(ctl)
//        2'd0:begin
//            out = 0;
//        end
//        2'd1:begin
//            case(countb)
//                3'd0:begin buffer[0] = in; out = 0; end
//                3'd1:begin buffer[1] = in; out = 0; end
//                3'd2:begin buffer[2] = in; out = 0; end
//                3'd3:begin buffer[3] = in; out = 0; end
//            endcase
//        end
//        2'd2:begin
//            case(countb)
//                3'd0: out = buffer[0];
//                3'd1: out = buffer[1];
//                3'd2: out = buffer[2];
//                3'd3: out = buffer[3];
//            endcase
//        end      
//    endcase
//end

























//assign out = (ctl == 2)? buffer[addr]:0;

endmodule
