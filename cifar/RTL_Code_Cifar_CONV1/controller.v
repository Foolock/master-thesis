`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2021 05:08:39 PM
// Design Name: 
// Module Name: controller
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


module controller(clk,rst,start,w,in,state,countin,countw,countcal,countpe,ctlpe,ctlbw,ctlbin,loadin_finish,loadw_finish,cal_finish,pixel_finish,picture_finish,output_finish,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address,wea,memaddr,mem_out,mem_in,
do,di,dr,dc,dkc,dkr,io,ii,ir,ic,ikr,ikc,filter_size,
inaddr,waddr,outaddr,
checkbram,check_finish,countch,
ir_out,ic_out,io_out,
memaddr_check,memaddr_w,
di_out,dr_out,dc_out,
step,
relu,
filter_finish
);
parameter width=8;
parameter decimal=4;
parameter rows=4;
parameter cols=4;
parameter vector=4;
parameter memaddrbit = 14;

input [2:0] step;
input relu;
input clk,rst;
input start;

output[rows*cols*2-1:0] ctlpe;
output[rows*2-1:0] ctlbw;
output[cols*2-1:0] ctlbin;
output[width-1:0] w,in;


reg[1:0] ctlper[rows*cols-1:0];
reg[1:0] ctlbwr[rows-1:0];
reg[1:0] ctlbinr[cols-1:0];



genvar gr,gc;
generate
    for(gr=0; gr<rows; gr=gr+1) begin:genper
        for(gc=0; gc<cols; gc=gc+1) begin:genpec
            assign ctlpe[2*((gc*rows)+gr)+1:2*((gc*rows)+gr)] = ctlper[gc*rows+gr];
        end
    end
endgenerate

genvar gi;
generate 
    for(gi=0; gi<rows; gi=gi+1) begin:genr
        assign ctlbw[2*gi+1:2*gi] = ctlbwr[gi];
    end
    for(gi=0; gi<cols; gi=gi+1) begin:genc
        assign ctlbin[2*gi+1:2*gi] = ctlbinr[gi];
    end
endgenerate

output reg[7:0] state;
reg[7:0] next_state;

localparam IDLE = 0;
localparam LOADW = 1;
localparam LOADIN = 2;
localparam CAL = 3;
localparam OUT = 4;
localparam TEST = 5; //to test if data is stored in the bram
input checkbram;
output reg check_finish;

always@(posedge clk or negedge rst)
begin
    if(!rst)
        state <= 0;
    else
        state <= next_state;
end

//output reg loadin_finish;
//output reg loadw_finish;
output reg loadin_finish;
output reg loadw_finish;
output reg cal_finish;
output reg pixel_finish;
output reg picture_finish;
output reg output_finish;

reg startd,startdd;

always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        startd <= 0;
    end
    else begin
        startd <= start;
    end
end

always@(*)
begin
    case(state)
        IDLE:begin
            if(startd)
                next_state = LOADIN;
            else
                next_state = IDLE;
        end
        LOADIN:begin
            if(loadin_finish)
                next_state = LOADW;
            else
                next_state = LOADIN;
        end
        LOADW:begin
            if(loadw_finish)
                next_state = CAL;
            else
                next_state = LOADW; 
        end
        CAL:begin
            if(cal_finish) begin
                if(pixel_finish) 
                    next_state = OUT;
                else
                    next_state = LOADIN;
            end
            else begin
                next_state = CAL;
            end
        end
        OUT:begin
            if(output_finish) begin
                if(checkbram) begin
                    next_state = TEST;
                end
                else begin
                    if(picture_finish)
                        next_state = IDLE;
                    else
                        next_state = LOADIN;
                end
            end
            else begin
                next_state = OUT;
            end 
        end
        TEST:begin
            if(check_finish) 
                next_state = IDLE;
            else
                next_state = TEST;  
        end
        default:next_state = IDLE;
    endcase
end

output reg[15:0] countch; //counter for checking bram
always@(posedge clk)
begin
    if(state == IDLE) begin
        countch <= 0;
    end
    else if(state == TEST) begin
        if(countch == 15) 
            countch <= 16;
        else
            countch <= countch+1;
    end
    else begin
        countch <= 0;
    end
end

always@(posedge clk or negedge rst)
begin
    if(!rst)
        check_finish <= 0;
    else if(countch == 15)
        check_finish <= 1;
    else
        check_finish <= 0;
end

output reg[15:0] countin; //counter for input buffer
output reg[15:0] countw; //counter for weight buffer
always@(posedge clk)
begin
    if(state == IDLE) begin
        countin <= 0;
    end
    else if(state == LOADIN) begin
        if(countin == 19)
            countin <= 20; //set ctlbinr as IDLE, make sure it doesn't output data.
        else
            countin <= countin + 1;
    end
    else begin
        countin <= 0;
    end
end

always@(posedge clk)
begin
    if(state == IDLE) begin
        countw <= 0;
    end
    else if(state == LOADW) begin
        if(countw == 19)
            countw <= 20; //set ctlbinr as IDLE, make sure it doesn't output data.
        else
            countw <= countw + 1;
    end
    else begin
        countw <= 0;
    end
end

output reg[15:0] countcal; //counter for calculation
always@(posedge clk)
begin
    if(state == IDLE) begin
        countcal <= 0;
    end
    else if(state == CAL) begin
        if(countcal == 11)
            countcal <= 12; //a 4X4 array need 10 clocks to produce result,and i add 2 more clocks to make sure it is done
        else 
            countcal <= countcal + 1;
    end
    else begin
        countcal <= 0;
    end
end

always@(state,countin,countw,countcal) 
begin
    case(state)
        LOADIN: begin
            case(countin)
                16'd4:begin ctlbinr[0] = 1; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd5:begin ctlbinr[0] = 1; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd6:begin ctlbinr[0] = 1; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd7:begin ctlbinr[0] = 1; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd8:begin ctlbinr[0] = 0; ctlbinr[1] = 1; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd9:begin ctlbinr[0] = 0; ctlbinr[1] = 1; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd10:begin ctlbinr[0] = 0; ctlbinr[1] = 1; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd11:begin ctlbinr[0] = 0; ctlbinr[1] = 1; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd12:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 1; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd13:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 1; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd14:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 1; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd15:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 1; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd16:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 1; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd17:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 1; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd18:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 1; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd19:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 1; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end  
                default:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
            endcase
        end
        LOADW: begin
            case(countw)
                16'd4:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 1; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd5:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 1; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd6:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 1; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd7:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 1; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd8:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 1; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd9:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 1; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd10:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 1; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd11:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 1; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd12:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 1; ctlbwr[3] = 0; end
                16'd13:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 1; ctlbwr[3] = 0; end
                16'd14:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 1; ctlbwr[3] = 0; end
                16'd15:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 1; ctlbwr[3] = 0; end
                16'd16:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 1; end
                16'd17:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 1; end
                16'd18:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 1; end
                16'd19:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 1; end
                default:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
            endcase
        end
        CAL: begin
            case(countcal)
                16'd0:begin ctlbinr[0] = 2; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 2; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd1:begin ctlbinr[0] = 2; ctlbinr[1] = 2; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 2; ctlbwr[1] = 2; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd2:begin ctlbinr[0] = 2; ctlbinr[1] = 2; ctlbinr[2] = 2; ctlbinr[3] = 0; ctlbwr[0] = 2; ctlbwr[1] = 2; ctlbwr[2] = 2; ctlbwr[3] = 0; end
                16'd3:begin ctlbinr[0] = 2; ctlbinr[1] = 2; ctlbinr[2] = 2; ctlbinr[3] = 2; ctlbwr[0] = 2; ctlbwr[1] = 2; ctlbwr[2] = 2; ctlbwr[3] = 2; end
                16'd4:begin ctlbinr[0] = 0; ctlbinr[1] = 2; ctlbinr[2] = 2; ctlbinr[3] = 2; ctlbwr[0] = 0; ctlbwr[1] = 2; ctlbwr[2] = 2; ctlbwr[3] = 2; end
                16'd5:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 2; ctlbinr[3] = 2; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 2; ctlbwr[3] = 2; end
                16'd6:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 2; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 2; end
                default:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
            endcase
        end
        default:begin
            ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0;
        end
    endcase
end

output reg[15:0] countpe; //counter for pe output
always@(posedge clk)
begin
    if(state == IDLE) begin
        countpe <= 0;
    end
    else if(state == OUT) begin
        if(countpe == 16)
            countpe <= 17; //when output finish, reset all the PEs
        else 
            countpe <= countpe + 1;
    end
    else begin
        countpe <= 0;
    end
end

always@(state,countpe)
begin
    case(state)
        IDLE:begin
            ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; 
            ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; 
            ctlper[8] = 0; ctlper[9] = 0; ctlper[10] = 0; ctlper[11] = 0; 
            ctlper[12] = 0; ctlper[13] = 0; ctlper[14] = 0; ctlper[15] = 0;
        end
        //because once start = 1, state = LOADIN, and it keeps the same until loadin_finish = 1, so during this period, this always block will not be actiavted, and ctlper keeps it value(=0).
//        LOADIN:begin 
//            ctlper[0] = 2; ctlper[1] = 2; ctlper[2] = 2; ctlper[3] = 2; 
//            ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
//            ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
//            ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
//        end
//        LOADW:begin 
//            ctlper[0] = 2; ctlper[1] = 2; ctlper[2] = 2; ctlper[3] = 2; 
//            ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
//            ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
//            ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
//        end
        CAL, LOADW, LOADIN:begin 
            ctlper[0] = 2; ctlper[1] = 2; ctlper[2] = 2; ctlper[3] = 2; 
            ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
            ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
            ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
        end
        OUT:begin
            case(countpe)
                16'd0:begin
                    ctlper[0] = 2; ctlper[1] = 2; ctlper[2] = 2; ctlper[3] = 2; //bc memaddr will delay one clk than ic_out,ir_out,io_out, so countpe == 0, still shifting
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd1:begin
                    ctlper[0] = 1; ctlper[1] = 2; ctlper[2] = 2; ctlper[3] = 2; //output coloumn 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd2:begin
                    ctlper[0] = 2; ctlper[1] = 1; ctlper[2] = 2; ctlper[3] = 2; //output coloumn 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd3:begin
                    ctlper[0] = 2; ctlper[1] = 2; ctlper[2] = 1; ctlper[3] = 2; //output coloumn 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd4:begin
                    ctlper[0] = 2; ctlper[1] = 2; ctlper[2] = 2; ctlper[3] = 1; //output coloumn 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                
                16'd5:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 1; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; //output coloumn 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd6:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 2; ctlper[5] = 1; ctlper[6] = 2; ctlper[7] = 2; //output coloumn 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd7:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 1; ctlper[7] = 2; //output coloumn 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd8:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 1; //output coloumn 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                
                16'd9:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 1; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; //output column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd10:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 2; ctlper[9] = 1; ctlper[10] = 2; ctlper[11] = 2; //output column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd11:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 1; ctlper[11] = 2; //output column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd12:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 1; //output column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                
                16'd13:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 0; ctlper[9] = 0; ctlper[10] = 0; ctlper[11] = 0; //reset column 3
                    ctlper[12] = 1; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2; //output column 4
                end
                16'd14:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 0; ctlper[9] = 0; ctlper[10] = 0; ctlper[11] = 0; //reset column 3
                    ctlper[12] = 2; ctlper[13] = 1; ctlper[14] = 2; ctlper[15] = 2; //output column 4
                end
                16'd15:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 0; ctlper[9] = 0; ctlper[10] = 0; ctlper[11] = 0; //reset column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 1; ctlper[15] = 2; //output column 4
                end
                16'd16:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 0; ctlper[9] = 0; ctlper[10] = 0; ctlper[11] = 0; //reset column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 1; //output column 4
                end
                default:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; 
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; 
                    ctlper[8] = 0; ctlper[9] = 0; ctlper[10] = 0; ctlper[11] = 0; 
                    ctlper[12] = 0; ctlper[13] = 0; ctlper[14] = 0; ctlper[15] = 0;
                end
            endcase
        end
        default:begin
            ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; 
            ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; 
            ctlper[8] = 0; ctlper[9] = 0; ctlper[10] = 0; ctlper[11] = 0; 
            ctlper[12] = 0; ctlper[13] = 0; ctlper[14] = 0; ctlper[15] = 0;
        end
    endcase
end

//when countin == 15,last data load in, and the next clock, LOADW start 
always@(posedge clk or negedge rst)
begin
    if(!rst) 
        loadin_finish <= 0;
    else if(countin == 19) 
        loadin_finish <= 1;
    else
        loadin_finish <= 0;
end

//assign loadin_finish = (countin == 15)? 1:0;

//when countw == 15,last weight data load in, and the next clock, CAL start 
always@(posedge clk or negedge rst)
begin
    if(!rst) 
        loadw_finish <= 0;
    else if(countw == 19) 
        loadw_finish <= 1;
    else
        loadw_finish <= 0;
end

//assign loadw_finish = (countw == 15)?1:0;

//when countcal == 10, the calculation is finished
always@(posedge clk or negedge rst)
begin
    if(!rst)
        cal_finish <= 0;
    else if(countcal == 11)
        cal_finish <= 1;
    else
        cal_finish <= 0;
end

//when countpe == 16, the output is finished
always@(posedge clk or negedge rst)
begin
    if(!rst)
        output_finish <= 0;
    else if(countpe == 16)
        output_finish <= 1;
    else 
        output_finish <= 0;
end

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

systolic_array #(.width(width),.decimal(decimal),.rows(rows),.cols(cols),.vector(vector)) s0(clk,rst,ctlpe,ctlbw,ctlbin,w,in,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address);

//output reg ena;
output reg wea;
output reg[memaddrbit-1:0] memaddr;
input[memaddrbit-1:0] memaddr_check;
//wire[memaddrbit-1:0] memaddr_w;
output[memaddrbit-1:0] memaddr_w;
//I use it to check if the output data is written into the memory correctly
assign memaddr_w = (state == TEST)? memaddr_check:memaddr;
output[7:0] mem_out;
output[7:0] mem_in;
wire[7:0] mem_in_relu; 

//before relu
assign mem_in_relu = (ctlpe[1:0] == 2'b01 || ctlpe[3:2] == 2'b01 || ctlpe[5:4] == 2'b01 || ctlpe[7:6] == 2'b01)? outs_array[7:0]:(ctlpe[9:8] == 2'b01 || ctlpe[11:10] == 2'b01 || ctlpe[13:12] == 2'b01 || ctlpe[15:14] == 2'b01)? outs_array[15:8]:(ctlpe[17:16] == 2'b01 || ctlpe[19:18] == 2'b01 || ctlpe[21:20] == 2'b01 || ctlpe[23:22] == 2'b01)? outs_array[23:16]:(ctlpe[25:24] == 2'b01 || ctlpe[27:26] == 2'b01 || ctlpe[29:28] == 2'b01 || ctlpe[31:30] == 2'b01)? outs_array[31:24]:0;

assign mem_in = (relu)? ((mem_in_relu[7])? 0:mem_in_relu):mem_in_relu;

assign in = (state == LOADIN)? mem_out:0;
assign w = (state == LOADW)? mem_out:0;




sram uut (
  .clka(clk),    // input wire clka
  .ena(1'b1),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(memaddr_w),  // input wire [12 : 0] addra
  .dina(mem_in),    // input wire [7 : 0] dina
  .douta(mem_out)  // output wire [7 : 0] douta
);

input[memaddrbit-1:0] do,di,dr,dc,dkc,dkr;
output reg[memaddrbit-1:0] io,ii,ir,ic,ikr,ikc;
reg[memaddrbit-1:0] po,pi,pr,pc,pkr,pkc;
input[7:0] filter_size;

//always@(state, countin)
//begin
//    case(state)
//        IDLE:begin
//            ii = 0;
//            ikr = 0;
//            ikc = 0;
//            pi = 0;
//            pkr = 0;
//            pkc = 0;
//        end
//        LOADIN:begin
//            case(countin)
//                16'd0,16'd4,16'd8,16'd12:begin
//                    pkc = pkc; pkr = pkr; pi = pi; //prevent latch
//                    ikc = pkc; ikr = pkr; ii = pi;
//                end
//                16'd1,16'd2,16'd3,16'd5,16'd6,16'd7,16'd9,16'd10,16'd11,16'd13,16'd14,16'd15,16'd16:begin //when 16'd16, still need to do it for the next round(or for next round, address will be the same as the end of this round
//                    if(ikc == dkc-1) begin
//                        ikc = 0;
//                        if(ikr == dkr-1) begin
//                            ikr = 0;
//                            if(ii == di-1) begin
//                                ii = 0;
//                            end
//                            else begin
//                                ii = ii+1;
//                            end
//                        end
//                        else begin
//                            ikr = ikr+1;
//                        end
//                    end
//                    else begin
//                        ikc = ikc+1;
//                    end
//                    pi = pi; pkr = pkr; pkc = pkc; //prevent latch
//                end
//                default:begin
//                    ii = ii; ikr = ikr; ikc = ikc; //prevent latch
//                    pi = ii; pkr = ikr; pkc = ikc; //record the ii, ikr, ikc for next round 
//                end
//            endcase
//        end
//        default:begin
//            ii = ii;
//            ikr = ikr;
//            ikc = ikc;
//            pi = pi;
//            pkr = pkr;
//            pkc = pkc;
//        end
//    endcase
//end

//control ii, ikr, ikc
//originally ii*ikr*ikc shoould be the multiple of 4
//now when ii, ikr, ikc are finished in LOADW or LOADIN, set filter_finish = 1
//which means ii = di-1, ikr = dkr-1, ikc = dkc-1, filter_finish = 1
//when filter_finish = 1, keep ii, ikr, ikc unchanged
output reg filter_finish;
wire filter_finish_wire;
assign filter_finish_wire = (state == LOADIN || state == LOADW)? ((ii == di-1 && ikr == dkr-1 && ikc == dkc-1)?1:0):0;
always@(posedge clk or negedge rst)
begin
    if(!rst)
        filter_finish <= 0;
    else
        filter_finish <= filter_finish_wire;
end

//always@(posedge clk or negedge rst)
//begin
//    if(!rst) begin
//        filter_finish <= 0;
//    end
//    else if(state == LOADIN) begin
//        if(countin == 19) //clear the filter_finish for LOADW
//            filter_finish <= 0;
//        else if(ii == di-1 && ikr == dkr-1 && ikc == dkc-1) 
//            filter_finish <= 1;
//        else
//            filter_finish <= filter_finish;
//    end
//    else if(state == LOADW) begin
//        if(ii == di-1 && ikr == dkr-1 && ikc == dkc-1) 
//            filter_finish <= 1;
//        else
//            filter_finish <= filter_finish;
//    end
//    else
//        filter_finish <= 0;//in other status, filter_finish = 0
//end

always@(posedge clk)
begin
    case(state)
        IDLE:begin
            ii <= 0;
            ikr<=0;
            ikc<=0;
            pi<=0;
            pkr<=0;
            pkc<=0;
        end
        LOADIN:begin
            case(countin)
                16'd0,16'd4,16'd8,16'd12:begin
                    pkc<=pkc; pkr<=pkr; pi<=pi; //prevent latch
                    ikc<=pkc; ikr<=pkr; ii<=pi; 
                end
                16'd1,16'd2,16'd3,16'd5,16'd6,16'd7,16'd9,16'd10,16'd11,16'd13,16'd14,16'd15:begin 
                    if(ikc == dkc-1) begin
                        ikc<=0;
                        if(ikr == dkr-1) begin
                            ikr<=0;
                            if(ii == di-1) begin
                                ii<=0;
                            end
                            else begin
                                ii<=ii+1;
                            end
                        end
                        else begin
                            ikr<=ikr+1;
                        end
                    end
                    else begin
                        ikc<=ikc+1;
                    end
                    pi<=pi; pkr<=pkr; pkc<=pkc; //prevent latch
                end
                default:begin
                    ii<=ii; ikr<=ikr; ikc<=ikc; //prevent latch
                    pi<=pi; pkr<=pkr; pkc<=pkc; //keep pi,pkr,pkc the same for weight
                end
            endcase
        end
        //loading weight will be the same as loading input data, but at the end will need to update pi,pkr,pkc
        LOADW:begin
           case(countw)
                16'd0,16'd4,16'd8,16'd12:begin
                    pkc<=pkc; pkr<=pkr; pi<=pi; //prevent latch
                    ikc<=pkc; ikr<=pkr; ii<=pi; 
                end
                16'd1,16'd2,16'd3,16'd5,16'd6,16'd7,16'd9,16'd10,16'd11,16'd13,16'd14,16'd15:begin //when 16'd16, still need to do it for the next round(or for next round, address will be the same as the end of this round
                    if(ikc == dkc-1) begin
                        ikc<=0;
                        if(ikr == dkr-1) begin
                            ikr<=0;
                            if(ii == di-1) begin
                                ii<=0;
                            end
                            else begin
                                ii<=ii+1;
                            end
                        end
                        else begin
                            ikr<=ikr+1;
                        end
                    end
                    else begin
                        ikc<=ikc+1;
                    end
                    pi<=pi; pkr<=pkr; pkc<=pkc; //prevent latch
                end
                16'd16:begin
                    if(filter_finish) begin
                        ii<=0; ikr<=0; ikc<=0; //now ii, ikr, ikc = 0, which means they have finished one pixel and because ii*ikr*ikc is not mutiple of 4(vector length), so there will be one extra data to be ignored. so I set ii, ikr, ikc=0 (keeping they are the same can work too i think) here to make sure the next pixel will have correct start
                    end
                    else begin
                        if(ikc == dkc-1) begin
                            ikc<=0;
                            if(ikr == dkr-1) begin
                                ikr<=0;
                                if(ii == di-1) begin
                                    ii<=0;
                                end
                                else begin
                                    ii<=ii+1;
                                end
                            end
                            else begin
                                ikr<=ikr+1;
                            end
                        end
                        else begin
                            ikc<=ikc+1;
                        end
                    end
                    pi<=ii; pkr<=ikr; pkc<=ikc; //keep the value for next round
                end
                default:begin
                    ii<=ii; ikr<=ikr; ikc<=ikc; //prevent latch
                    pi<=ii; pkr<=ikr; pkc<=ikc; //record the ii, ikr, ikc for next round 
                end
            endcase
        end
        default:begin
            ii<=ii;
            ikr<=ikr;
            ikc<=ikc;
            pi<=pi;
            pkr<=pkr;
            pkc<=pkc;
        end
    endcase
end

//assign pixel_finish = (state == CAL)? ((ikc == dkc-1 && ikr == dkr-1 && ii == di-1)? 1:0):0;
always@(posedge clk or negedge rst)
begin
    if(!rst) begin
        pixel_finish <= 0;
    end
    else if(state == LOADIN) begin
        if(ikc == dkc-1 && ikr == dkr-1 && ii == di-1)
            pixel_finish <= 1;
        else
            pixel_finish <= pixel_finish;
    end
    else if(state == OUT) begin
        pixel_finish <= 0; //when output data, set pixel_finish = 0;
    end
    else begin
        pixel_finish <= pixel_finish;
    end
end

//control ir
reg pixel_finish_d;
always@(posedge clk or negedge rst)
begin
    if(!rst)
        pixel_finish_d <= 0;
    else
        pixel_finish_d <= pixel_finish;
end

always@(posedge clk)
begin
    case(state) 
        IDLE:begin
            ir <= 0;
        end
        OUT:begin
            if(~pixel_finish&pixel_finish_d) //so there would be a one-clock pixel finish signal in OUT, to prevent ir add multiple times
            begin
                if(ir == dr-filter_size) //4 is the filter size
                    ir <= 0; //now all the ic, io pixel are finished
                else
//                    ir <= ir+2;
                    ir <= ir+step; 
                //step is 2
            end
            else 
            begin
                ir <= ir;
            end
        end
        default:begin
            ir <= ir;
        end
    endcase
end

//control ic,io
//when one round of ir,ii,ikr,ikc is finished, update ic,io
always@(posedge clk)
begin
    case(state)
        IDLE:begin
            io <= 0;
            ic <= 0;
            picture_finish <= 0;
        end
        OUT:begin
//            io <= 0; //well, io has not changed, so .....
            //now it is time for io managing
            if(~pixel_finish&pixel_finish_d) begin
                if(ir == dr-filter_size) begin
                    //because ic, io is all base address, so when ic+4 > dc-1, and io+4 > do-1, everything should be done
                    if(ic+4 > dc-1) begin
                        ic <= 0;
                        if(io+4 > do-1) begin
                            io <= 0;
                            picture_finish <= 1;
                        end
                        else begin
                            io <= io+4; //io stand for the base,too, for 4 buffer we have io+0, io+1, io+2, io+3;
                        end
                    end
                    else begin
//                        ic <= ic+8; //ic actually stand for the base, for 4 buffer we have ic+0, ic+2, ic+4, ic+6.
                        ic <= ic+4*step;
                    end
                end
                else begin
                    ic <= ic;
                end
            end
            else begin
                ic <= ic;
            end
        end
        default:begin
            io <= io;
            ic <= ic;
            picture_finish <= picture_finish;
        end
    endcase
end

//when io is finished, picture is finished
//always@(posedge clk)
//begin
//    case(state)
//        IDLE:begin
//            picture_finish <= 0;
//        end
//        OUT:begin
//            if((~pixel_finish&pixel_finish_d) && (ir == dr-filter_size) && (ic == dc-filter_size) && (io >= do-1))
//                picture_finish <= 1;
//            else
//                picture_finish <= 0;
//        end
//        default:begin
//            picture_finish <= picture_finish;
//        end
//    endcase
//end

input[memaddrbit-1:0] di_out,dr_out,dc_out;//the output picture size
output reg[memaddrbit-1:0] ir_out,ic_out,io_out;//calculate output address


always@(posedge clk)
begin
    case(state)
        IDLE:begin
            ir_out <= 0;
            ic_out <= 0;
            io_out <= 0;
        end
        OUT:begin
//            io_out <= 0;
            if(countpe == 17) begin
                if(ir_out == dr_out-1) begin
                    ir_out <= 0;
                    if(ic_out == dc_out-1) begin
                        ic_out <= 0;
                        if(io_out+4 > di_out-1) 
                            io_out <= 0;
                        else 
                            io_out <= io_out+4;
                    end
                    else begin
                        ic_out <= ic_out+4;
                    end
                end
                else begin
                    ir_out <= ir_out+1;
                end
            end
            else begin
                ir_out <= ir_out;
                ic_out <= ic_out;
                io_out <= io_out;
            end
        end
        default:begin
            ir_out <= ir_out;
            ic_out <= ic_out;
            io_out <= io_out;
        end
    endcase
end

//control memaddr
input[memaddrbit-1:0] inaddr,waddr;
input[memaddrbit-1:0] outaddr;
//always@(*)
always@(posedge clk)
begin
    case(state)
        IDLE:begin
            memaddr <= 0; //address = 0, i put 00(read mode), address = 1, i put 00 too, but address = 1 is used for write mode
        end
        LOADIN:begin
            case(countin) 
                16'd1,16'd2,16'd3,16'd4:begin
                    if(filter_finish) begin
                        memaddr <= 0;
                    end
                    else begin
                        if(ic > dc-filter_size)
                            memaddr <= 0;
                        else
                            memaddr <= inaddr+ii*dr*dc+(ir+ikr)*dc+ic+ikc; //ic+0
                    end
                end
                16'd5,16'd6,16'd7,16'd8:begin
                    if(filter_finish) begin
                        memaddr <= 0;
                    end
                    else begin
                        if(ic+step > dc-filter_size)
                            memaddr <= 0;
                        else
                            memaddr <= inaddr+ii*dr*dc+(ir+ikr)*dc+ic+ikc+step; //ic+2
                    end
                end
                16'd9,16'd10,16'd11,16'd12:begin
                    if(filter_finish) begin
                        memaddr <= 0;
                    end
                    else begin
                        if(ic+2*step > dc-filter_size)
                            memaddr <= 0;
                        else
                            memaddr <= inaddr+ii*dr*dc+(ir+ikr)*dc+ic+ikc+2*step; //ic+4
                    end
                end
                16'd13,16'd14,16'd15,16'd16:begin
                    if(filter_finish) begin
                        memaddr <= 0;
                    end
                    else begin
                        if(ic+3*step > dc-filter_size)
                            memaddr <= 0;
                        else
                            memaddr <= inaddr+ii*dr*dc+(ir+ikr)*dc+ic+ikc+3*step; //ic+6
                    end
                end
                default:begin
                    memaddr <= 0;
                end
            endcase
        end
        LOADW:begin
            case(countw)
                16'd1,16'd2,16'd3,16'd4:begin
                    if(filter_finish) begin
                        memaddr <= 0;
                    end
                    else begin
                        if(io > do-1)
                            memaddr <= 0;
                        else
                            memaddr <= waddr+io*di*dkr*dkc+ii*dkr*dkc+ikr*dkc+ikc; //io+0
                    end
                end
                16'd5,16'd6,16'd7,16'd8:begin
                    if(filter_finish) begin
                        memaddr <= 0;
                    end
                    else begin
                        if(io > do-2)
                            memaddr <= 0;
                        else
                            memaddr <= waddr+(io+1)*di*dkr*dkc+ii*dkr*dkc+ikr*dkc+ikc; //io+1
                    end
                end
                16'd9,16'd10,16'd11,16'd12:begin
                    if(filter_finish) begin
                        memaddr <= 0;
                    end
                    else begin
                        if(io > do-3)
                            memaddr <= 0;
                        else
                            memaddr <= waddr+(io+2)*di*dkr*dkc+ii*dkr*dkc+ikr*dkc+ikc; //io+2
                    end
                end
                16'd13,16'd14,16'd15,16'd16:begin
                    if(filter_finish) begin
                        memaddr <= 0;
                    end
                    else begin
                        if(io > do-4)
                            memaddr <= 0;
                        else
                            memaddr <= waddr+(io+3)*di*dkr*dkc+ii*dkr*dkc+ikr*dkc+ikc; //io+3
                    end
                end
                default:begin
                    memaddr <= 0;
                end
            endcase
        end
        OUT:begin
            case(countpe)
                16'd0:begin 
                    if(ic_out+1 > dc_out || io_out+1 > di_out)
                        memaddr <= 1;
                    else 
                        memaddr <= outaddr+io_out*dr_out*dc_out+ir_out*dc_out+ic_out; end
                16'd1:begin  
                    if(ic_out+1 > dc_out || io_out+2 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+1)*dr_out*dc_out+ir_out*dc_out+ic_out; end
                16'd2:begin  
                    if(ic_out+1 > dc_out || io_out+3 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+2)*dr_out*dc_out+ir_out*dc_out+ic_out; end
                16'd3:begin  
                    if(ic_out+1 > dc_out || io_out+4 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+3)*dr_out*dc_out+ir_out*dc_out+ic_out; end
                16'd4:begin  
                    if(ic_out+2 > dc_out || io_out+1 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+io_out*dr_out*dc_out+ir_out*dc_out+(ic_out+1); end
                16'd5:begin   
                    if(ic_out+2 > dc_out || io_out+2 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+1)*dr_out*dc_out+ir_out*dc_out+(ic_out+1); end
                16'd6:begin   
                    if(ic_out+2 > dc_out || io_out+3 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+2)*dr_out*dc_out+ir_out*dc_out+(ic_out+1); end
                16'd7:begin   
                    if(ic_out+2 > dc_out || io_out+4 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+3)*dr_out*dc_out+ir_out*dc_out+(ic_out+1); end
                16'd8:begin   
                    if(ic_out+3 > dc_out || io_out+1 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+io_out*dr_out*dc_out+ir_out*dc_out+(ic_out+2); end
                16'd9:begin    
                    if(ic_out+3 > dc_out || io_out+2 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+1)*dr_out*dc_out+ir_out*dc_out+(ic_out+2); end
                16'd10:begin    
                    if(ic_out+3 > dc_out || io_out+3 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+2)*dr_out*dc_out+ir_out*dc_out+(ic_out+2); end
                16'd11:begin    
                    if(ic_out+3 > dc_out || io_out+4 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+3)*dr_out*dc_out+ir_out*dc_out+(ic_out+2); end
                16'd12:begin    
                    if(ic_out+4 > dc_out || io_out+1 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+io_out*dr_out*dc_out+ir_out*dc_out+(ic_out+3); end
                16'd13:begin     
                    if(ic_out+4 > dc_out || io_out+2 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+1)*dr_out*dc_out+ir_out*dc_out+(ic_out+3); end
                16'd14:begin     
                    if(ic_out+4 > dc_out || io_out+3 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+2)*dr_out*dc_out+ir_out*dc_out+(ic_out+3); end
                16'd15:begin     
                    if(ic_out+4 > dc_out || io_out+4 > di_out)
                        memaddr <= 1;
                    else
                        memaddr <= outaddr+(io_out+3)*dr_out*dc_out+ir_out*dc_out+(ic_out+3); end
                default:begin
                    memaddr <= 1;
                end
            endcase
        end
        default:begin
            memaddr <= 0;
        end
    endcase
end

//control wea

always@(state)
begin
    case(state)
        OUT:begin
            wea = 1;
        end
        default:begin
            wea = 0;
        end
    endcase
end

endmodule
