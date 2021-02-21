`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2021 02:19:48 PM
// Design Name: 
// Module Name: max_pooling_test
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


module max_pooling_test#(
parameter memaddrbit = 13
)
(
clk,rst,
enable,
step,
dkr,dkc,dr,dc,di,
dr_out,dc_out,di_out,
ikr,ikc,ir,ic,ii,
ir_out,ic_out,ii_out,
memaddr,inaddr,outaddr,
mpdata_in,
mpdata_out,
buffer,
state,
store_finish,picture_finish,
count_store,
wea,
checkram,
memaddr_check
    );
    
localparam IDLE = 0;
localparam STORE = 1;//store all the data in one buffer, if data_in is bigger, store, if not, dump
localparam OUT = 2;//after store, output the data in buffer
localparam CHECK = 3;
    
input clk,rst;
input enable;
input [2:0] step;
input [memaddrbit-1:0] dkr,dkc,dr,dc,di; 
output [memaddrbit-1:0] ikr,ikc,ir,ic,ii;    
output [memaddrbit-1:0] memaddr;
input [memaddrbit-1:0] inaddr,outaddr;
output[7:0] mpdata_in;
output[7:0] mpdata_out;

output [7:0] buffer;

output [2:0] state;

output store_finish;
output picture_finish;

output [7:0] count_store; //counter for STORE

input [memaddrbit-1:0] dr_out,dc_out,di_out; 
output [memaddrbit-1:0] ir_out,ic_out,ii_out; 

output wea;
input checkram;

input [memaddrbit-1:0] memaddr_check;



test_sram u2 (
  .clka(clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(memaddr),  // input wire [13 : 0] addra
  .dina(mpdata_out),    // input wire [7 : 0] dina
  .douta(mpdata_in)  // output wire [7 : 0] douta
);

wire[memaddrbit-1:0] memaddr_w;

assign memaddr = (state == CHECK)? memaddr_check:memaddr_w;

max_pooling #(
.memaddrbit(memaddrbit)
)
uut(
clk,rst,
enable,
step,
dkr,dkc,dr,dc,di,
dr_out,dc_out,di_out,
ikr,ikc,ir,ic,ii,
ir_out,ic_out,ii_out,
memaddr_w,inaddr,outaddr,
mpdata_in,
mpdata_out,
buffer,
state,
store_finish,picture_finish,
count_store,
wea,
checkram
    );
    
endmodule
