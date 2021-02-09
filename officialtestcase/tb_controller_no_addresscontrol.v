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
reg pixel_finish;
reg picture_finish;
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

reg ena;
reg wea;
reg[7:0] memaddr;
wire[7:0] mem_out;
wire[7:0] mem_in;

controller uut(clk,rst,start,w,in,state,countin,countw,countcal,countpe,ctlpe,ctlbw,ctlbin,loadin_finish,loadw_finish,cal_finish,pixel_finish,picture_finish,output_finish,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address
,ena,wea,memaddr,mem_out,mem_in);

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
    ena = 1;
end

initial begin
    wea = 0;
    #2450
    wea = 1;
    #800
    wea = 0;
end

initial begin
    memaddr = 0;
    #100
    //input input data
    memaddr = 0;
    #50 memaddr = 1;
    #50 memaddr = 2;
    #50 memaddr = 3;
    
    #50 memaddr = 4;
    #50 memaddr = 5;
    #50 memaddr = 6;
    #50 memaddr = 7;
    
    #50 memaddr = 8;
    #50 memaddr = 9;
    #50 memaddr = 10;
    #50 memaddr = 11;
    
    #50 memaddr = 12;
    #50 memaddr = 13;
    #50 memaddr = 14;
    #50 memaddr = 15;
    
    #100
    //now input weight data
    memaddr = 16;
    #50 memaddr = 17;
    #50 memaddr = 18;
    #50 memaddr = 19;
    
    #50 memaddr = 20;
    #50 memaddr = 21;
    #50 memaddr = 22;
    #50 memaddr = 23;
    
    #50 memaddr = 24;
    #50 memaddr = 25;
    #50 memaddr = 26;
    #50 memaddr = 27;
    
    #50 memaddr = 28;
    #50 memaddr = 29;
    #50 memaddr = 30;
    #50 memaddr = 31;
    #50
    
    memaddr = 0;
    #800
    memaddr = 40;
    #50 memaddr = 41;
    #50 memaddr = 42;
    #50 memaddr = 43;
    
    #50 memaddr = 44;
    #50 memaddr = 45;
    #50 memaddr = 46;
    #50 memaddr = 47;
    
    #50 memaddr = 48;
    #50 memaddr = 49;
    #50 memaddr = 50;
    #50 memaddr = 51;
    
    #50 memaddr = 52;
    #50 memaddr = 53;
    #50 memaddr = 54;
    #50 memaddr = 55;
    
    //output
    #50 memaddr = 40;
    #50 memaddr = 41;
    #50 memaddr = 42;
    #50 memaddr = 43;
    
    #50 memaddr = 44;
    #50 memaddr = 45;
    #50 memaddr = 46;
    #50 memaddr = 47;
    
    #50 memaddr = 48;
    #50 memaddr = 49;
    #50 memaddr = 50;
    #50 memaddr = 51;
    
    #50 memaddr = 52;
    #50 memaddr = 53;
    #50 memaddr = 54;
    #50 memaddr = 55;
    
end



initial begin
    pixel_finish = 0;
    #2450
    pixel_finish = 1;
    #50
    pixel_finish = 0;
end

initial begin
    picture_finish = 0;
    #3300
    picture_finish = 1;
    #50
    picture_finish = 0;
end

endmodule
