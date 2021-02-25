`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2021 03:50:10 PM
// Design Name: 
// Module Name: top_test
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


module top_test#(
//calculation
parameter width=8,
parameter decimal=4,
parameter rows=4,
parameter cols=4,
parameter vector=4,
parameter memaddrbit = 17,
//CONV1
parameter do1=8,
parameter di1=3,
parameter dr1=15,
parameter dc1=15,
parameter dkc1=4,
parameter dkr1=4,
parameter di_out1=8,
parameter dr_out1=12,
parameter dc_out1=12,
parameter filter_size1 = 4,
parameter step1 = 1,
parameter inaddr1 = 2,
parameter waddr1 = 677,
parameter outaddr1 = 1061,
//MAX POOLING1
parameter mp_di1=8,
parameter mp_dr1=12,
parameter mp_dc1=12,
parameter mp_dkc1=2,
parameter mp_dkr1=2,
parameter mp_di_out1=8,
parameter mp_dr_out1=6,
parameter mp_dc_out1=6,
parameter mp_step1 = 2,
parameter mp_inaddr1 = 1061,
parameter mp_outaddr1 = 2213,
//CONV2
parameter do2=16,
parameter di2=8,
parameter dr2=6,
parameter dc2=6,
parameter dkc2=4,
parameter dkr2=4,
parameter di_out2=16,
parameter dr_out2=4,
parameter dc_out2=4,
parameter filter_size2 = 4,
parameter step2 = 1,
parameter inaddr2 = 2213,
parameter waddr2 = 2501, //2213+6*6*8 = 2501
parameter outaddr2 = 4549 //2501+4*4*8*16 = 4549
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
output[7:0] mem_out;
output[7:0] mem_in;

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

controller u1(clk,rst,start,w,in,state,countin,countw,countcal,countpe,ctlpe,ctlbw,ctlbin,loadin_finish,loadw_finish,cal_finish,pixel_finish,picture_finish,output_finish,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address,wea_w,memaddr,mem_out,mem_in,
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

reg picture_finish_d;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        picture_finish_d <= 0;
    else
        picture_finish_d <= picture_finish;
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
            if(!picture_finish&picture_finish_d)
                next_cnn_state = IDLE;
            else
                next_cnn_state = CONV2;
        end
        default:begin
            next_cnn_state = IDLE;
        end
    endcase
end

assign cnn_finish = (cnn_state == CONV2)? (!picture_finish&picture_finish_d)? 1:0:0;

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

assign start = (cnn_state == CONV1)? cnn_start_dd:(cnn_state == CONV2)? (!mp_picture_finish_d&mp_picture_finish_dd):0;

assign do = (cnn_state == CONV1)? do1:(cnn_state == CONV2)? do2:0;
assign di = (cnn_state == CONV1)? di1:(cnn_state == CONV2)? di2:0;
assign dr = (cnn_state == CONV1)? dr1:(cnn_state == CONV2)? dr2:0;
assign dc = (cnn_state == CONV1)? dc1:(cnn_state == CONV2)? dc2:0;
assign dkr = (cnn_state == CONV1)? dkr1:(cnn_state == CONV2)? dkr2:0;
assign dkc = (cnn_state == CONV1)? dkc1:(cnn_state == CONV2)? dkc2:0;
assign di_out = (cnn_state == CONV1)? di_out1:(cnn_state == CONV2)? di_out2:0;
assign dr_out = (cnn_state == CONV1)? dr_out1:(cnn_state == CONV2)? dr_out2:0;
assign dc_out = (cnn_state == CONV1)? dc_out1:(cnn_state == CONV2)? dc_out2:0;
assign filter_size = (cnn_state == CONV1)? filter_size1:(cnn_state == CONV2)? filter_size2:0;
assign step = (cnn_state == CONV1)? step1:(cnn_state == CONV2)? step2:0;
assign inaddr = (cnn_state == CONV1)? inaddr1:(cnn_state == CONV2)? inaddr2:0;
assign waddr = (cnn_state == CONV1)? waddr1:(cnn_state == CONV2)? waddr2:0;
assign outaddr = (cnn_state == CONV1)? outaddr1:(cnn_state == CONV2)? outaddr2:0;

assign mp_step = 2;
assign maxpooling_or_not = (cnn_state == CONV1)? 1:0;

assign mp_di=8;
assign mp_dr=12;
assign mp_dc=12;
assign mp_dkc=2;
assign mp_dkr=2;
assign mp_di_out=8;
assign mp_dr_out=6;
assign mp_dc_out=6;
assign mp_step = 2;
assign mp_inaddr = 1061;
assign mp_outaddr = 2213;

assign relu = 0;

endmodule
