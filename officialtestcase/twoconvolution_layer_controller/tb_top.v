`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2021 06:30:25 PM
// Design Name: 
// Module Name: tb_top
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


reg clk,rst;
reg cnn_start;
wire cnn_finish;

//controller ports
wire[rows*cols*2-1:0] ctlpe;
wire[rows*2-1:0] ctlbw;
wire[cols*2-1:0] ctlbin;
wire[width-1:0] w,in;
wire [7:0] state;
reg checkbram;
wire check_finish;
wire loadin_finish;
wire loadw_finish;
wire cal_finish;
wire pixel_finish;
wire picture_finish;
wire output_finish;
wire[15:0] countch; //counter for checking bram
wire[15:0] countin; //counter for input buffer
wire[15:0] countw; //counter for weight buffer
wire[15:0] countcal; //counter for calculation
wire[15:0] countpe; //counter for pe wire

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
wire[cols*width-1:0] ins_array; //wire for each input buffer
wire[rows*width-1:0] ws_array; //wire for each weight buffer
wire[cols*width-1:0] outs_array; //wire from the array
wire[4*vector*width-1:0] input_buffer;
wire[4*width-1:0] input_address;


//bram
wire wea;
wire [12:0] memaddr;
reg[12:0] memaddr_check;
//wire[12:0] memaddr_w;
wire[12:0] memaddr_w;
wire[7:0] mem_out;
wire[7:0] mem_in;


//base parameter for address calculating
wire[12:0] io,ii,ir,ic,ikr,ikc;
wire[12:0] ir_out,ic_out,io_out;//calculate wire address


//things that need to be controlled in top module
wire start;//start convolution layer
wire [12:0] do,di,dr,dc,dkc,dkr;
wire [7:0] filter_size;
wire [12:0] di_out,dr_out,dc_out;//the wire picture size
wire [12:0] inaddr,waddr;
wire [12:0] outaddr;

wire [7:0] cnn_state;

top uut1(clk,rst,cnn_start,cnn_finish,
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
    // #1315625
    // checkbram = 1;
    // #100
    // checkbram = 0;
end

initial begin
    memaddr_check = 0;
    // #1315675
    // memaddr_check = 3095; //20
    // #50 memaddr_check = 3096; //40
    // #50 memaddr_check = 3097; //60
    // #50 memaddr_check = 3098; //80
    // #50 memaddr_check = 3099; //20
    // #50 memaddr_check = 3041; //40
    // #50 memaddr_check = 3042; //60
    // #50 memaddr_check = 3043; //80
    // #50 memaddr_check = 3044; //20
    // #50 memaddr_check = 3008; //80
    // #50 memaddr_check = 3009; //20
    // #50 memaddr_check = 3069; //20
    // #50 memaddr_check = 3068; //80
    // #50 memaddr_check = 3067; //60
    // #50 memaddr_check = 3066; //40
    // #50 memaddr_check = 3065; //20
end


endmodule
