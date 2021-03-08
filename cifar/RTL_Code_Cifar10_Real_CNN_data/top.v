`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2021 08:47:41 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top#(
//calculation
parameter width=16,
parameter decimal=8,
parameter rows=4,
parameter cols=4,
parameter vector=4,
parameter memaddrbit = 20,
//CONV1
parameter do1=16,
parameter di1=3,
parameter dr1=32,
parameter dc1=32,
parameter dkc1=3,
parameter dkr1=3,
parameter di_out1=16,
parameter dr_out1=30,
parameter dc_out1=30,
parameter filter_size1 = 3,
parameter step1 = 1,
parameter inaddr1 = 2,
parameter waddr1 = 3074,
parameter outaddr1 = 3506,
//MAX POOLING1
parameter mp_di1=16,
parameter mp_dr1=30,
parameter mp_dc1=30,
parameter mp_dkc1=2,
parameter mp_dkr1=2,
parameter mp_di_out1=16,
parameter mp_dr_out1=15,
parameter mp_dc_out1=15,
parameter mp_step1 = 2,
parameter mp_inaddr1 = 3506,
parameter mp_outaddr1 = 17906,
//CONV2
parameter do2=32,
parameter di2=16,
parameter dr2=15,
parameter dc2=15,
parameter dkc2=4,
parameter dkr2=4,
parameter di_out2=32,
parameter dr_out2=12,
parameter dc_out2=12,
parameter filter_size2 = 4,
parameter step2 = 1,
parameter inaddr2 = 17906,
parameter waddr2 = 21506, 
parameter outaddr2 = 29698, 
//MAX POOLING2
parameter mp_di2=32,
parameter mp_dr2=12,
parameter mp_dc2=12,
parameter mp_dkc2=2,
parameter mp_dkr2=2,
parameter mp_di_out2=32,
parameter mp_dr_out2=6,
parameter mp_dc_out2=6,
parameter mp_step2 = 2,
parameter mp_inaddr2 = 29698,
parameter mp_outaddr2 = 34306,
//CONV3
parameter do3=64,
parameter di3=32,
parameter dr3=6,
parameter dc3=6,
parameter dkc3=3,
parameter dkr3=3,
parameter di_out3=64,
parameter dr_out3=4,
parameter dc_out3=4,
parameter filter_size3 = 3,
parameter step3 = 1,
parameter inaddr3 = 34306,
parameter waddr3 = 35458, 
parameter outaddr3 = 53890, 
//FC1
parameter do4=500,
parameter di4=64,
parameter dr4=4,
parameter dc4=4,
parameter dkc4=4,
parameter dkr4=4,
parameter di_out4=500,
parameter dr_out4=1,
parameter dc_out4=1,
parameter filter_size4 = 4,
parameter step4 = 1,
parameter inaddr4 = 53890,
parameter waddr4 = 54914, 
parameter outaddr4 = 566914, 
//FC2
parameter do5=10,
parameter di5=500,
parameter dr5=1,
parameter dc5=1,
parameter dkc5=1,
parameter dkr5=1,
parameter di_out5=10,
parameter dr_out5=1,
parameter dc_out5=1,
parameter filter_size5 = 1,
parameter step5 = 1,
parameter inaddr5 = 566914,
parameter waddr5 = 567414, 
parameter outaddr5 = 572414
)
(
clk,rst,start,w,in,state,countin,countw,countcal,countpe,ctlpe,ctlbw,ctlbin,loadin_finish,loadw_finish,cal_finish,pixel_finish,picture_finish,output_finish,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address,wea_w,memaddr,mem_out,mem_in,
do,di,dr,dc,dkc,dkr,io,ii,ir,ic,ikr,ikc,filter_size,
inaddr,waddr,outaddr,
checkbram,check_finish,countch,
ir_out,ic_out,io_out,
memaddr_check,memaddr_w,
di_out,dr_out,dc_out,
step,
relu,
filter_finish,
//now for the ports for max pooling
mp_step,
mp_dkr,mp_dkc,mp_dr,mp_dc,mp_di,
mp_dr_out,mp_dc_out,mp_di_out,
mp_inaddr,mp_outaddr,
mp_checkram,
maxpooling_or_not, //decide to do maxpooling after the CONV or not
mp_picture_finish,
mp_ikr,mp_ikc,mp_ir,mp_ic,mp_ii,
mp_ir_out,mp_ic_out,mp_ii_out,
mp_enable,
//top ports
cnn_start,cnn_state,cnn_finish
);

input clk,rst;
output start;

output [2:0] step;
output relu;
output filter_finish;

output[width-1:0] w,in;
output [7:0] state;
output [15:0] countin; //counter for input buffer
output [15:0] countw; //counter for weight buffer
output [15:0] countcal; //counter for calculation
output [15:0] countpe; //counter for pe output
output[rows*cols*2-1:0] ctlpe;
output[rows*2-1:0] ctlbw;
output[cols*2-1:0] ctlbin;
output loadin_finish;
output loadw_finish;
output cal_finish;
output pixel_finish;
output picture_finish;
output output_finish;

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

//memory
output wea_w;
output [memaddrbit-1:0] memaddr;
output[width-1:0] mem_out;
output[width-1:0] mem_in;

//address control
output [memaddrbit-1:0] do,di,dr,dc,dkc,dkr;
output [memaddrbit-1:0] io,ii,ir,ic,ikr,ikc;
output[7:0] filter_size;
output [memaddrbit-1:0] inaddr,waddr;
output [memaddrbit-1:0] outaddr;
output [memaddrbit-1:0] ir_out,ic_out,io_out;//calculate output address
output [memaddrbit-1:0] di_out,dr_out,dc_out;//the output picture size


//verify sram(bram) input
input checkbram;
output check_finish;
output [15:0] countch; //counter for checking bram
input [memaddrbit-1:0] memaddr_check;
output [memaddrbit-1:0] memaddr_w;

//now it is the max pooling part
output maxpooling_or_not;
output mp_enable;
//wire mp_wea;
output [2:0] mp_step;
output [memaddrbit-1:0] mp_dkr,mp_dkc,mp_dr,mp_dc,mp_di; 
output [memaddrbit-1:0] mp_dr_out,mp_dc_out,mp_di_out; 
output[memaddrbit-1:0] mp_ikr,mp_ikc,mp_ir,mp_ic,mp_ii;   
output[memaddrbit-1:0] mp_ir_out,mp_ic_out,mp_ii_out; 
output [memaddrbit-1:0] mp_inaddr,mp_outaddr;
input mp_checkram;
output mp_picture_finish;//finish signal for max pooling layer

controller #(.width(width),
.decimal(decimal),
.rows(rows),
.cols(cols),
.vector(vector),
.memaddrbit(memaddrbit))
u1(clk,rst,start,w,in,state,countin,countw,countcal,countpe,ctlpe,ctlbw,ctlbin,loadin_finish,loadw_finish,cal_finish,pixel_finish,picture_finish,output_finish,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address,wea_w,memaddr,mem_out,mem_in,
do,di,dr,dc,dkc,dkr,io,ii,ir,ic,ikr,ikc,filter_size,
inaddr,waddr,outaddr,
checkbram,check_finish,countch,
ir_out,ic_out,io_out,
memaddr_check,memaddr_w,
di_out,dr_out,dc_out,
step,
relu,
filter_finish,
//now for the ports for max pooling
mp_step,
mp_dkr,mp_dkc,mp_dr,mp_dc,mp_di,
mp_dr_out,mp_dc_out,mp_di_out,
mp_inaddr,mp_outaddr,
mp_checkram,
maxpooling_or_not, //decide to do maxpooling after the CONV or not
mp_picture_finish,
mp_ikr,mp_ikc,mp_ir,mp_ic,mp_ii,
mp_ir_out,mp_ic_out,mp_ii_out,
mp_enable
);

input cnn_start;
output reg[7:0] cnn_state;
reg[7:0] next_cnn_state;
output cnn_finish;

localparam IDLE = 0;
localparam CONV1 = 1;
localparam CONV2 = 2;
localparam CONV3 = 3;
localparam FC1 = 4;
localparam FC2 = 5;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        cnn_state <= 0;
    else
        cnn_state <= next_cnn_state;
end

reg mp_picture_finish_d,mp_picture_finish_dd;

always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        mp_picture_finish_d <= 0;
        mp_picture_finish_dd <= 0;
    end
    else begin
        mp_picture_finish_d <= mp_picture_finish;
        mp_picture_finish_dd <= mp_picture_finish_d;
    end
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
                next_cnn_state = CONV1;
            else
                next_cnn_state = IDLE;
        end
        CONV1:begin
            if(!mp_picture_finish&mp_picture_finish_d)
                next_cnn_state = CONV2;
            else
                next_cnn_state = CONV1;
        end
        CONV2:begin
            if(!mp_picture_finish&mp_picture_finish_d)
                next_cnn_state = CONV3;
            else
                next_cnn_state = CONV2;
        end
        CONV3:begin
            if(!picture_finish&picture_finish_d)
                next_cnn_state = FC1;
            else
                next_cnn_state = CONV3;
        end
        FC1:begin
            if(!picture_finish&picture_finish_d)
                next_cnn_state = FC2;
            else
                next_cnn_state = FC1;
        end
        FC2:begin
            if(!picture_finish&picture_finish_d)
                next_cnn_state = IDLE;
            else
                next_cnn_state = FC2;
        end
        default:begin
            next_cnn_state = IDLE;
        end
    endcase
end

assign cnn_finish = (cnn_state == FC2)? (!picture_finish&picture_finish_d)? 1:0:0;

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

assign start = (cnn_state == CONV1)? cnn_start_dd:(cnn_state == CONV2||cnn_state == CONV3)? (!mp_picture_finish_d&mp_picture_finish_dd):(cnn_state == FC1||cnn_state == FC2)? (!picture_finish_d&picture_finish_dd):0;

assign do = (cnn_state == CONV1)? do1:(cnn_state == CONV2)? do2:(cnn_state == CONV3)? do3:(cnn_state == FC1)? do4:(cnn_state == FC2)? do5:0;
assign di = (cnn_state == CONV1)? di1:(cnn_state == CONV2)? di2:(cnn_state == CONV3)? di3:(cnn_state == FC1)? di4:(cnn_state == FC2)? di5:0;
assign dr = (cnn_state == CONV1)? dr1:(cnn_state == CONV2)? dr2:(cnn_state == CONV3)? dr3:(cnn_state == FC1)? dr4:(cnn_state == FC2)? dr5:0;
assign dc = (cnn_state == CONV1)? dc1:(cnn_state == CONV2)? dc2:(cnn_state == CONV3)? dc3:(cnn_state == FC1)? dc4:(cnn_state == FC2)? dc5:0;
assign dkr = (cnn_state == CONV1)? dkr1:(cnn_state == CONV2)? dkr2:(cnn_state == CONV3)? dkr3:(cnn_state == FC1)? dkr4:(cnn_state == FC2)? dkr5:0;
assign dkc = (cnn_state == CONV1)? dkc1:(cnn_state == CONV2)? dkc2:(cnn_state == CONV3)? dkc3:(cnn_state == FC1)? dkc4:(cnn_state == FC2)? dkc5:0;

assign di_out = (cnn_state == CONV1)? di_out1:(cnn_state == CONV2)? di_out2:(cnn_state == CONV3)? di_out3:(cnn_state == FC1)? di_out4:(cnn_state == FC2)? di_out5:0;
assign dr_out = (cnn_state == CONV1)? dr_out1:(cnn_state == CONV2)? dr_out2:(cnn_state == CONV3)? dr_out3:(cnn_state == FC1)? dr_out4:(cnn_state == FC2)? dr_out5:0;
assign dc_out = (cnn_state == CONV1)? dc_out1:(cnn_state == CONV2)? dc_out2:(cnn_state == CONV3)? dc_out3:(cnn_state == FC1)? dc_out4:(cnn_state == FC2)? dc_out5:0;

assign filter_size = (cnn_state == CONV1)? filter_size1:(cnn_state == CONV2)? filter_size2:(cnn_state == CONV3)? filter_size3:(cnn_state == FC1)? filter_size4:(cnn_state == FC2)? filter_size5:0;
assign step = (cnn_state == CONV1)? step1:(cnn_state == CONV2)? step2:(cnn_state == CONV3)? step3:(cnn_state == FC1)? step4:(cnn_state == FC2)? step5:0;

assign inaddr = (cnn_state == CONV1)? inaddr1:(cnn_state == CONV2)? inaddr2:(cnn_state == CONV3)? inaddr3:(cnn_state == FC1)? inaddr4:(cnn_state == FC2)? inaddr5:0;
assign waddr = (cnn_state == CONV1)? waddr1:(cnn_state == CONV2)? waddr2:(cnn_state == CONV3)? waddr3:(cnn_state == FC1)? waddr4:(cnn_state == FC2)? waddr5:0;
assign outaddr = (cnn_state == CONV1)? outaddr1:(cnn_state == CONV2)? outaddr2:(cnn_state == CONV3)? outaddr3:(cnn_state == FC1)? outaddr4:(cnn_state == FC2)? outaddr5:0;

assign maxpooling_or_not = (cnn_state == CONV1||cnn_state == CONV2)? 1:0;

assign mp_di=(cnn_state == CONV1)?mp_di1:(cnn_state == CONV2)?mp_di2:0;
assign mp_dr=(cnn_state == CONV1)?mp_dr1:(cnn_state == CONV2)?mp_dr2:0;
assign mp_dc=(cnn_state == CONV1)?mp_dc1:(cnn_state == CONV2)?mp_dc2:0;
assign mp_dkc=(cnn_state == CONV1)?mp_dkc1:(cnn_state == CONV2)?mp_dkc2:0;
assign mp_dkr=(cnn_state == CONV1)?mp_dkr1:(cnn_state == CONV2)?mp_dkr2:0;

assign mp_di_out=(cnn_state == CONV1)?mp_di_out1:(cnn_state == CONV2)?mp_di_out2:0;
assign mp_dr_out=(cnn_state == CONV1)?mp_dr_out1:(cnn_state == CONV2)?mp_dr_out2:0;
assign mp_dc_out=(cnn_state == CONV1)?mp_dc_out1:(cnn_state == CONV2)?mp_dc_out2:0;

assign mp_step = 2;

assign mp_inaddr = (cnn_state == CONV1)?mp_inaddr1:(cnn_state == CONV2)?mp_inaddr2:0;
assign mp_outaddr = (cnn_state == CONV1)?mp_outaddr1:(cnn_state == CONV2)?mp_outaddr2:0;

assign relu = (cnn_state == FC2)?0:1;


endmodule
