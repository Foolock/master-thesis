`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2021 04:35:03 PM
// Design Name: 
// Module Name: tb_controller
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


module tb_controller();
parameter width=8;
parameter decimal=4;
parameter rows=4;
parameter cols=4;
parameter vector=4;
parameter memaddrbit = 17;

reg clk,rst;
reg start;

wire[rows*cols*2-1:0] ctlpe;
wire[rows*2-1:0] ctlbw;
wire[cols*2-1:0] ctlbin;
wire[width-1:0] w,in;

wire [7:0] state;

wire loadin_finish;
wire loadw_finish;
wire cal_finish;
wire pixel_finish;
wire picture_finish;
wire output_finish;

wire[15:0] countin; //counter for input buffer
wire[15:0] countw; //counter for weight buffer
wire[15:0] countcal; //counter for calculation

wire[15:0] countpe; //counter for pe output

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

//wire ena;
wire wea;
wire[memaddrbit-1:0] memaddr;
wire[7:0] mem_out;
wire[7:0] mem_in;

reg[memaddrbit-1:0] do,di,dr,dc,dkc,dkr;
wire[memaddrbit-1:0] io,ii,ir,ic,ikr,ikc;
reg[7:0] filter_size;
reg[memaddrbit-1:0] inaddr,waddr;
reg checkbram;
wire check_finish;
wire[15:0] countch; //counter for checking bram
reg[memaddrbit-1:0] outaddr;
wire[memaddrbit-1:0] ir_out,ic_out,io_out;
reg[memaddrbit-1:0] di_out,dr_out,dc_out;
reg[memaddrbit-1:0] memaddr_check;
wire[memaddrbit-1:0] memaddr_w;

reg[2:0] step;
reg relu;
wire filter_finish;

//control ports for max pooling
reg maxpooling_or_not;
reg [2:0] mp_step;
reg [memaddrbit-1:0] mp_dkr,mp_dkc,mp_dr,mp_dc,mp_di; 
reg [memaddrbit-1:0] mp_dr_out,mp_dc_out,mp_di_out; 
reg [memaddrbit-1:0] mp_inaddr,mp_outaddr;
reg mp_checkram;
wire mp_picture_finish;//finish signal for max pooling layer
wire[memaddrbit-1:0] mp_ikr,mp_ikc,mp_ir,mp_ic,mp_ii;   
wire[memaddrbit-1:0] mp_ir_out,mp_ic_out,mp_ii_out; 
wire mp_enable;

controller uut(clk,rst,start,w,in,state,countin,countw,countcal,countpe,ctlpe,ctlbw,ctlbin,loadin_finish,loadw_finish,cal_finish,pixel_finish,picture_finish,output_finish,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address
,wea,memaddr,mem_out,mem_in,
do,di,dr,dc,dkc,dkr,io,ii,ir,ic,ikr,ikc,filter_size,
inaddr,waddr,outaddr,
checkbram,check_finish,countch,
ir_out,ic_out,io_out,
memaddr_check,memaddr_w,
di_out,dr_out,dc_out,
step,
relu,
filter_finish,
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

initial begin
    step = 1;
    relu = 0;
end

initial begin
    clk = 1;
    forever #25 clk = ~clk;
end

initial begin
    rst = 0;
    #50 rst = 1;
end

initial begin
    start = 0;
    #100 start = 1;
    #50 start = 0;
end

initial begin
    do = 8;
    di = 3;
    dr = 15;
    dc = 15;
    dkr = 4;
    dkc = 4;
    filter_size = 4;
    di_out = 8;
    dr_out = 12;
    dc_out = 12;
end

initial begin
    inaddr = 2;
    waddr = 677;
    outaddr = 1061;
end

initial begin
    checkbram = 0;
//    #19344150 checkbram = 1;
//    #100 checkbram = 0;
end

initial begin
    memaddr_check = 0;
//    #19344200 memaddr_check = 17874;//40
//    #50 memaddr_check = 17870;//30
//    #50 memaddr_check = 12626;//10
//    #50 memaddr_check = 4406;//10
//    #50 memaddr_check = 4374;//40
//    #50 memaddr_check = 0;
end

initial begin
    maxpooling_or_not = 1;
    mp_step = 2;
    mp_dkr = 2;
    mp_dkc = 2;
    mp_dr = 12;
    mp_dc = 12;
    mp_di = 8; 
    mp_dr_out = 6;
    mp_dc_out = 6;
    mp_di_out = 8; 
    mp_inaddr = 1061;
    mp_outaddr = 2213;
    mp_checkram = 0;
end

endmodule
