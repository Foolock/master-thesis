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
parameter memaddrbit = 14;

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

controller uut(clk,rst,start,w,in,state,countin,countw,countcal,countpe,ctlpe,ctlbw,ctlbin,loadin_finish,loadw_finish,cal_finish,pixel_finish,picture_finish,output_finish,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address
,wea,memaddr,mem_out,mem_in,
do,di,dr,dc,dkc,dkr,io,ii,ir,ic,ikr,ikc,filter_size,
inaddr,waddr,outaddr,
checkbram,check_finish,countch,
ir_out,ic_out,io_out,
memaddr_check,memaddr_w,
di_out,dr_out,dc_out
);

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
    do = 50;
    di = 4;
    dr = 5;
    dc = 5;
    dkr = 5;
    dkc = 5;
    filter_size = 5;
    di_out = 50;
    dr_out = 1;
    dc_out = 1;
end

initial begin
    inaddr = 2501;
    waddr = 2601;
    outaddr = 7601;
end

initial begin
    checkbram = 0;
//    #618900 checkbram = 1;
//    #100 checkbram = 0;
end

initial begin
    memaddr_check = 0;
//    #618950 memaddr_check = 233;
//    #50 memaddr_check = 1537;//30
//    #50 memaddr_check = 1538;//00
//    #50 memaddr_check = 1539;//40
//    #50 memaddr_check = 1540;//00
//    #50 memaddr_check = 1541;//10
//    #50 memaddr_check = 1542;//00
//    #50 memaddr_check = 1543;//20
//    #50 memaddr_check = 1544;//00
//    #50 memaddr_check = 1545;//30
//    #50 memaddr_check = 1173;//30
//    #50 memaddr_check = 1675;//30
//    #50 memaddr_check = 1000;//10
//    #50 memaddr_check = 1002;//20
//    #50 memaddr_check = 1004;//30
//    #50 memaddr_check = 1006;//40
//    #50 memaddr_check = 1007;//00
//    #50 memaddr_check = 0;
end

endmodule
