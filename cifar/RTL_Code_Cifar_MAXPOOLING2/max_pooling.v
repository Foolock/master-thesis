//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2021 12:52:54 AM
// Design Name: 
// Module Name: max_pooling
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


module max_pooling#(
parameter memaddrbit = 14
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
data_in,
max_pooling_out,
buffer,
state,
store_finish,picture_finish,
count_store,
wea,
checkram
    );
    
input clk,rst;
input enable;
output wea;
input [2:0] step;
input [memaddrbit-1:0] dkr,dkc,dr,dc,di; 
input [memaddrbit-1:0] dr_out,dc_out,di_out; 
output reg[memaddrbit-1:0] ikr,ikc,ir,ic,ii;   
output reg[memaddrbit-1:0] ir_out,ic_out,ii_out; 
output reg[memaddrbit-1:0] memaddr;
input [memaddrbit-1:0] inaddr,outaddr;
input[7:0] data_in;
output[7:0] max_pooling_out;

output reg[7:0] buffer;

output reg[2:0] state;
reg[2:0] next_state;

localparam IDLE = 0;
localparam STORE = 1;//store all the data in one buffer, if data_in is bigger, store, if not, dump
localparam OUT = 2;//after store, output the data in buffer
localparam CHECK = 3;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        state <= 0;
    else
        state <= next_state;
end

output reg store_finish;
output reg picture_finish;

input checkram;

always@(*)
begin
    case(state)
        IDLE:begin
            if(enable)
                next_state = STORE;
            else
                next_state = IDLE;
        end
        STORE:begin
            if(store_finish)
                next_state = OUT;
            else
                next_state = STORE;
        end
        OUT:begin
            if(picture_finish)
                if(checkram)
                    next_state = CHECK;
                else
                    next_state = IDLE;
            else
                next_state = STORE;
        end
        CHECK:begin
            next_state = CHECK;
        end
        default:begin
            next_state = IDLE;
        end
    endcase
end

output reg[7:0] count_store; //counter for STORE
always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        count_store <= 0;
    end
    else if(state == STORE) begin
        if(count_store == 6)
            count_store <= 7;
        else
            count_store <= count_store+1;
    end
    else begin
        count_store <= 0;
    end
end

//control ikr, ikc
always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        ikr <= 0;
        ikc <= 0;
    end
    else if(state == STORE) begin
        if(count_store <= 3) begin
            if(ikc == dkc-1) begin
                ikc <= 0;
                if(ikr == dkr-1)
                    ikr <= 0;
                else
                    ikr <= ikr+1;
            end
            else begin
                ikc <= ikc+1;
            end
        end
        else begin
            ikr <= ikr;
            ikc <= ikc;
        end
    end
    else begin
        ikr <= 0;
        ikc <= 0;
    end
end

always@(posedge clk or negedge rst)
begin
    if(!rst)
        store_finish <= 0;
    else if(count_store == 6)
        store_finish <= 1;
    else
        store_finish <= 0;
end

//control ir, ic, ii
//ir, ic is the base
//when ir,ic is finish, which means one channel is finished, ii=ii+1
always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        ir <= 0;
        ic <= 0;
        ii <= 0;
        picture_finish <= 0;
    end
    else if(store_finish) begin
        if(ic == dc-2) begin //2 is the kernal size
            ic <= 0;
            if(ir == dr-2) begin //2 is the kernal size
                ir <= 0;
                if(ii == di-1) begin
                    ii <= 0;
                    picture_finish <= 1;
                end
                else begin
                    ii <= ii+1;
                end
            end
            else begin
                ir <= ir+step;
            end
        end
        else
            ic <= ic+step;
    end
    else begin
        ir <= ir;
        ic <= ic;
        ii <= ii;
        picture_finish <= picture_finish;
    end
end

always@(posedge clk or negedge rst)
begin
    if(!rst)
        memaddr <= 0;
    else if(state == STORE)
        if(count_store >= 7)
            memaddr <= outaddr+ii_out*dr_out*dc_out+ir_out*dc_out+ic_out;
        else
            memaddr <= inaddr+ii*dr*dc+(ir+ikr)*dc+ic+ikc;
    else
        memaddr <= 0;
end


//assign memaddr = (state == STORE)? inaddr+ii*dr*dc+(ir+ikr)*dc+ic+ikc:0;

always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        buffer <= 0;
    end
    else if(state == STORE) begin
        if(count_store == 3)  //count_store = 0, ii,ikr,ikc start moving, memaddr is one-clock delay, mem_out(data_in) is two clock delay, add up to three clocks delay
            buffer <= data_in;
        else if(count_store > 3&&count_store <= 6)
            if(data_in > buffer)
                buffer <= data_in;
            else
                buffer <= buffer;
        else
            buffer <= buffer; 
    end
end

assign max_pooling_out = (state == OUT)? buffer:0;

//control ir_out,ic_out,ii_out
always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        ir_out <= 0;
        ic_out <= 0;
        ii_out <= 0;
    end
    else if(state == OUT) begin
        if(ic_out == dc_out-1) begin
            ic_out <= 0;
            if(ir_out == dr_out-1) begin
                ir_out <= 0;
                if(ii_out == di_out-1)
                    ii_out <= 0;
                else
                    ii_out <= ii_out+1;
            end
            else begin
                ir_out <= ir_out+1;
            end
        end
        else begin
            ic_out <= ic_out+1;
        end
    end
    else begin
        ir_out <= ir_out;
        ic_out <= ic_out;
        ii_out <= ii_out;
    end
end

assign wea = (state == OUT)? 1:0;


















endmodule
