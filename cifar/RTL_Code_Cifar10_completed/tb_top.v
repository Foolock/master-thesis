`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2021 06:07:24 PM
// Design Name: 
// Module Name: tb_top_test
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


module tb_top();
parameter width=8;
parameter decimal=4;
parameter rows=4;
parameter cols=4;
parameter vector=4;
parameter memaddrbit = 20;


reg clk,rst;
wire start;

wire [2:0] step;
wire relu;
wire filter_finish;

wire[width-1:0] w,in;
wire [7:0] state;
wire [15:0] countin; //counter for input buffer
wire [15:0] countw; //counter for weight buffer
wire [15:0] countcal; //counter for calculation
wire [15:0] countpe; //counter for pe output
wire[rows*cols*2-1:0] ctlpe;
wire[rows*2-1:0] ctlbw;
wire[cols*2-1:0] ctlbin;
wire loadin_finish;
wire loadw_finish;
wire cal_finish;
wire pixel_finish;
wire picture_finish;
wire output_finish;

//probe signal for systolic array
wire[rows*cols*width-1:0] buffer;
wire[width-1:0] d1;
wire[width-1:0] d2;
wire[width-1:0] d3;
wire[width-1:0] d4;
wire[width-1:0] d5;
wire[width-1:0] d6;
wire[width-1:0] d7;
wire[width-1:0] d8;
wire[width-1:0] d9;
wire[width-1:0] d10;
wire[width-1:0] d11;
wire[width-1:0] d12;
wire[width-1:0] d13;
wire[width-1:0] d14;
wire[width-1:0] d15;
wire[width-1:0] d16;
wire[cols*width-1:0] row1_in_output;
wire[cols*width-1:0] ins_array; //output for each input buffer
wire[rows*width-1:0] ws_array; //output for each weight buffer
wire[cols*width-1:0] outs_array; //output from the array
wire[4*vector*width-1:0] input_buffer;
wire[4*width-1:0] input_address;

//memory
wire wea_w;
wire [memaddrbit-1:0] memaddr;
wire[7:0] mem_out;
wire[7:0] mem_in;

//address control
wire [memaddrbit-1:0] do,di,dr,dc,dkc,dkr;
wire [memaddrbit-1:0] io,ii,ir,ic,ikr,ikc;
wire[7:0] filter_size;
wire [memaddrbit-1:0] inaddr,waddr;
wire [memaddrbit-1:0] outaddr;
wire [memaddrbit-1:0] ir_out,ic_out,io_out;//calculate output address
wire [memaddrbit-1:0] di_out,dr_out,dc_out;//the output picture size


//verify sram(bram) input
reg checkbram;
wire check_finish;
wire [15:0] countch; //counter for checking bram
reg [memaddrbit-1:0] memaddr_check;
wire [memaddrbit-1:0] memaddr_w;

//now it is the max pooling part
wire maxpooling_or_not;
wire mp_enable;
//wire mp_wea;
wire [2:0] mp_step;
wire [memaddrbit-1:0] mp_dkr,mp_dkc,mp_dr,mp_dc,mp_di; 
wire [memaddrbit-1:0] mp_dr_out,mp_dc_out,mp_di_out; 
wire[memaddrbit-1:0] mp_ikr,mp_ikc,mp_ir,mp_ic,mp_ii;   
wire[memaddrbit-1:0] mp_ir_out,mp_ic_out,mp_ii_out; 
wire [memaddrbit-1:0] mp_inaddr,mp_outaddr;
reg mp_checkram;
wire mp_picture_finish;//finish signal for max pooling layer

reg cnn_start;
wire [7:0] cnn_state;
wire cnn_finish;

top entity(
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

initial begin
    clk = 0;
    forever #25 clk = ~clk;
end

initial begin
    rst = 0;
    #50 rst = 1;
end

initial begin
    cnn_start = 0;
    #100 cnn_start = 1;
    #50 cnn_start = 0;
end

initial begin
    checkbram = 0;
    mp_checkram = 0;
end

initial begin
    memaddr_check = 0;
end

endmodule
