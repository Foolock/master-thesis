module top#(
//calculation
parameter width=8,
parameter decimal=4,
parameter rows=4,
parameter cols=4,
parameter vector=4,
parameter memaddrbit = 14,
//convolution layer
parameter do1=4,
parameter di1=1,
parameter dr1=28,
parameter dc1=28,
parameter dkc1=4,
parameter dkr1=4,
parameter di_out1=4,
parameter dr_out1=13,
parameter dc_out1=13,
parameter do2=4,
parameter di2=4,
parameter dr2=13,
parameter dc2=13,
parameter dkc2=5,
parameter dkr2=5,
parameter di_out2=4,
parameter dr_out2=5,
parameter dc_out2=5,
//fc layer
parameter do3=40,
parameter di3=4,
parameter dr3=5,
parameter dc3=5,
parameter dkc3=5,
parameter dkr3=5,
parameter di_out3=40,
parameter dr_out3=1,
parameter dc_out3=1,
parameter do4=10,
parameter di4=40,
parameter dr4=1,
parameter dc4=1,
parameter dkc4=1,
parameter dkr4=1,
parameter di_out4=10,
parameter dr_out4=1,
parameter dc_out4=1,

parameter filter_size1 = 4,
parameter filter_size2 = 5,
parameter filter_size3 = 5,
parameter filter_size4 = 1,

parameter inaddr1 = 2,
parameter waddr1 = 806,
parameter outaddr1 = 1001,
parameter inaddr2 = 1001,
parameter waddr2 = 2001,
parameter outaddr2 = 2501,
parameter inaddr3 = 2501,
parameter waddr3 = 2601,
parameter outaddr3 = 6601,
parameter inaddr4 = 6601,
parameter waddr4 = 6701,
parameter outaddr4 = 7101
)
(clk,rst,cnn_start,cnn_finish,
start,w,in,state,countin,countw,countcal,countpe,ctlpe,ctlbw,ctlbin,loadin_finish,loadw_finish,cal_finish,pixel_finish,picture_finish,output_finish,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address,wea,memaddr,mem_out,mem_in,
do,di,dr,dc,dkc,dkr,io,ii,ir,ic,ikr,ikc,filter_size,
inaddr,waddr,outaddr,
checkbram,check_finish,countch,
ir_out,ic_out,io_out,
memaddr_check,memaddr_w,
di_out,dr_out,dc_out,
//top module port
cnn_state
);

input clk,rst;
input cnn_start;
output reg cnn_finish;

//controller ports
output[rows*cols*2-1:0] ctlpe;
output[rows*2-1:0] ctlbw;
output[cols*2-1:0] ctlbin;
output[width-1:0] w,in;
output [7:0] state;
input checkbram;
output check_finish;
output loadin_finish;
output loadw_finish;
output cal_finish;
output pixel_finish;
output picture_finish;
output output_finish;
output[15:0] countch; //counter for checking bram
output[15:0] countin; //counter for input buffer
output[15:0] countw; //counter for weight buffer
output[15:0] countcal; //counter for calculation
output[15:0] countpe; //counter for pe output


//probe signal for systolic array
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
output[cols*width-1:0] ins_array; //output for each input buffer
output[rows*width-1:0] ws_array; //output for each weight buffer
output[cols*width-1:0] outs_array; //output from the array
output[4*vector*width-1:0] input_buffer;
output[4*width-1:0] input_address;


//bram
output wea;
output [memaddrbit-1:0] memaddr;
input[memaddrbit-1:0] memaddr_check;
//wire[12:0] memaddr_w;
output[memaddrbit-1:0] memaddr_w;
output[7:0] mem_out;
output[7:0] mem_in;


//base parameter for address calculating
output[memaddrbit-1:0] io,ii,ir,ic,ikr,ikc;
output[memaddrbit-1:0] ir_out,ic_out,io_out;//calculate output address


//things that need to be controlled in top module
output start;//start convolution layer
output [memaddrbit-1:0] do,di,dr,dc,dkc,dkr;
output [7:0] filter_size;
output [memaddrbit-1:0] di_out,dr_out,dc_out;//the output picture size
output [memaddrbit-1:0] inaddr,waddr;
output [memaddrbit-1:0] outaddr;


controller uut(clk,rst,start,w,in,state,countin,countw,countcal,countpe,ctlpe,ctlbw,ctlbin,loadin_finish,loadw_finish,cal_finish,pixel_finish,picture_finish,output_finish,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address,wea,memaddr,mem_out,mem_in,
do,di,dr,dc,dkc,dkr,io,ii,ir,ic,ikr,ikc,filter_size,
inaddr,waddr,outaddr,
checkbram,check_finish,countch,
ir_out,ic_out,io_out,
memaddr_check,memaddr_w,
di_out,dr_out,dc_out
);

output reg[7:0] cnn_state;
reg[7:0] next_cnn_state;

localparam IDLE = 0;
localparam CONV1 = 1;
localparam CONV2 = 2;
localparam FC1 = 3;
localparam FC2 = 4;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        cnn_state <= 0;
    else
        cnn_state <= next_cnn_state;
end

reg picture_finish_d,picture_finish_dd;

always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        picture_finish_d <= 0;
        picture_finish_dd <= 0;
    end
    else begin
        picture_finish_d <= picture_finish;
        picture_finish_dd <= picture_finish_d;
    end
end 

always@(*)
begin
    case(cnn_state)
        IDLE:begin
            if(cnn_start) 
                next_cnn_state <= CONV1;
            else
                next_cnn_state <= IDLE;
        end
        CONV1:begin
            if(!picture_finish&picture_finish_d)
                next_cnn_state <= CONV2;
            else
                next_cnn_state <= CONV1;
        end
        CONV2:begin
            if(!picture_finish&picture_finish_d) 
                next_cnn_state <= FC1;
            else
                next_cnn_state <= CONV2;
        end
        FC1:begin
            if(!picture_finish&picture_finish_d) 
                next_cnn_state <= FC2;
            else 
                next_cnn_state <= FC1;
        end
        FC2:begin
            if(!picture_finish&picture_finish_d) 
                next_cnn_state <= IDLE;
            else 
                next_cnn_state <= FC2;
        end
        default:begin
            next_cnn_state <= IDLE;
        end
    endcase
end

reg cnn_start_d,cnn_start_dd;

always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        cnn_start_d <= 0;
        cnn_start_dd <= 0;
    end
    else begin
        cnn_start_d <= cnn_start;
        cnn_start_dd <= cnn_start_d;
    end
end

assign start = (cnn_state == CONV1)? cnn_start_dd:(cnn_state == CONV2 || cnn_state == FC1 || cnn_state == FC2)? (!picture_finish_d&picture_finish_dd):0;

assign do = (cnn_state == CONV1)? do1:(cnn_state == CONV2)?do2:(cnn_state == FC1)?do3:(cnn_state == FC2)?do4:0;
assign di = (cnn_state == CONV1)? di1:(cnn_state == CONV2)?di2:(cnn_state == FC1)?di3:(cnn_state == FC2)?di4:0;
assign dr = (cnn_state == CONV1)? dr1:(cnn_state == CONV2)?dr2:(cnn_state == FC1)?dr3:(cnn_state == FC2)?dr4:0;
assign dc = (cnn_state == CONV1)? dc1:(cnn_state == CONV2)?dc2:(cnn_state == FC1)?dc3:(cnn_state == FC2)?dc4:0;
assign dkc = (cnn_state == CONV1)? dkc1:(cnn_state == CONV2)?dkc2:(cnn_state == FC1)?dkc3:(cnn_state == FC2)?dkc4:0;
assign dkr = (cnn_state == CONV1)? dkr1:(cnn_state == CONV2)?dkr2:(cnn_state == FC1)?dkr3:(cnn_state == FC2)?dkr4:0;
assign filter_size = (cnn_state == CONV1)? filter_size1:(cnn_state == CONV2)? filter_size2:(cnn_state == FC1)? filter_size3:(cnn_state == FC2)? filter_size4:0;
assign di_out = (cnn_state == CONV1)? di_out1:(cnn_state == CONV2)? di_out2:(cnn_state == FC1)? di_out3:(cnn_state == FC2)? di_out4:0;
assign dr_out = (cnn_state == CONV1)? dr_out1:(cnn_state == CONV2)? dr_out2:(cnn_state == FC1)? dr_out3:(cnn_state == FC2)? dr_out4:0;
assign dc_out = (cnn_state == CONV1)? dc_out1:(cnn_state == CONV2)? dc_out2:(cnn_state == FC1)? dc_out3:(cnn_state == FC2)? dc_out4:0;
assign inaddr = (cnn_state == CONV1)? inaddr1:(cnn_state == CONV2)? inaddr2:(cnn_state == FC1)? inaddr3:(cnn_state == FC2)? inaddr4:0;
assign waddr = (cnn_state == CONV1)? waddr1: (cnn_state == CONV2)? waddr2:(cnn_state == FC1)? waddr3:(cnn_state == FC2)? waddr4:0;
assign outaddr = (cnn_state == CONV1)? outaddr1: (cnn_state == CONV2)? outaddr2:(cnn_state == FC1)? outaddr3:(cnn_state == FC2)? outaddr4:0;

endmodule