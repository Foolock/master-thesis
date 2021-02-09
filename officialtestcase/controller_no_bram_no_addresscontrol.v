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


module controller(clk,rst,start,w,in,state,countin,countw,countcal,countpe,ctlpe,ctlbw,ctlbin,loadin_finish,loadw_finish,cal_finish,pixel_finish,picture_finish,output_finish,buffer,ins_array,ws_array,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,row1_in_output,outs_array,input_buffer,input_address);
parameter width=8;
parameter decimal=4;
parameter rows=4;
parameter cols=4;
parameter vector=4;

input clk,rst;
input start;

output[rows*cols*2-1:0] ctlpe;
output[rows*2-1:0] ctlbw;
output[cols*2-1:0] ctlbin;
input[width-1:0] w,in;


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
input pixel_finish;
input picture_finish;
output reg output_finish;

always@(*)
begin
    case(state)
        IDLE:begin
            if(start)
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
                if(picture_finish)
                    next_state = IDLE;
                else
                    next_state = LOADIN;
            end
            else begin
                next_state = OUT;
            end 
        end
        default:next_state = IDLE;
    endcase
end

output reg[15:0] countin; //counter for input buffer
output reg[15:0] countw; //counter for weight buffer
always@(posedge clk)
begin
    if(state == IDLE) begin
        countin <= 0;
    end
    else if(state == LOADIN) begin
        if(countin == 15)
            countin <= 16; //set ctlbinr as IDLE, make sure it doesn't output data.
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
        if(countw == 15)
            countw <= 16; //set ctlbinr as IDLE, make sure it doesn't output data.
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
                16'd0:begin ctlbinr[0] = 1; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd1:begin ctlbinr[0] = 1; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd2:begin ctlbinr[0] = 1; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd3:begin ctlbinr[0] = 1; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd4:begin ctlbinr[0] = 0; ctlbinr[1] = 1; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd5:begin ctlbinr[0] = 0; ctlbinr[1] = 1; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd6:begin ctlbinr[0] = 0; ctlbinr[1] = 1; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd7:begin ctlbinr[0] = 0; ctlbinr[1] = 1; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd8:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 1; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd9:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 1; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd10:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 1; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd11:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 1; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd12:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 1; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd13:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 1; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd14:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 1; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd15:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 1; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end  
                default:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
            endcase
        end
        LOADW: begin
            case(countw)
                16'd0:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 1; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd1:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 1; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd2:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 1; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd3:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 1; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd4:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 1; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd5:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 1; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd6:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 1; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd7:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 1; ctlbwr[2] = 0; ctlbwr[3] = 0; end
                16'd8:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 1; ctlbwr[3] = 0; end
                16'd9:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 1; ctlbwr[3] = 0; end
                16'd10:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 1; ctlbwr[3] = 0; end
                16'd11:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 1; ctlbwr[3] = 0; end
                16'd12:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 1; end
                16'd13:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 1; end
                16'd14:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 1; end
                16'd15:begin ctlbinr[0] = 0; ctlbinr[1] = 0; ctlbinr[2] = 0; ctlbinr[3] = 0; ctlbwr[0] = 0; ctlbwr[1] = 0; ctlbwr[2] = 0; ctlbwr[3] = 1; end
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
        if(countpe == 15)
            countpe <= 16; //when output finish, reset all the PEs
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
                    ctlper[0] = 1; ctlper[1] = 2; ctlper[2] = 2; ctlper[3] = 2; //output coloumn 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd1:begin
                    ctlper[0] = 2; ctlper[1] = 1; ctlper[2] = 2; ctlper[3] = 2; //output coloumn 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd2:begin
                    ctlper[0] = 2; ctlper[1] = 2; ctlper[2] = 1; ctlper[3] = 2; //output coloumn 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd3:begin
                    ctlper[0] = 2; ctlper[1] = 2; ctlper[2] = 2; ctlper[3] = 1; //output coloumn 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; 
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                
                16'd4:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 1; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 2; //output coloumn 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd5:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 2; ctlper[5] = 1; ctlper[6] = 2; ctlper[7] = 2; //output coloumn 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd6:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 1; ctlper[7] = 2; //output coloumn 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd7:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 2; ctlper[5] = 2; ctlper[6] = 2; ctlper[7] = 1; //output coloumn 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; 
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                
                16'd8:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 1; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 2; //output column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd9:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 2; ctlper[9] = 1; ctlper[10] = 2; ctlper[11] = 2; //output column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd10:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 1; ctlper[11] = 2; //output column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                16'd11:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 2; ctlper[9] = 2; ctlper[10] = 2; ctlper[11] = 1; //output column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2;
                end
                
                16'd12:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 0; ctlper[9] = 0; ctlper[10] = 0; ctlper[11] = 0; //reset column 3
                    ctlper[12] = 1; ctlper[13] = 2; ctlper[14] = 2; ctlper[15] = 2; //output column 4
                end
                16'd13:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 0; ctlper[9] = 0; ctlper[10] = 0; ctlper[11] = 0; //reset column 3
                    ctlper[12] = 2; ctlper[13] = 1; ctlper[14] = 2; ctlper[15] = 2; //output column 4
                end
                16'd14:begin
                    ctlper[0] = 0; ctlper[1] = 0; ctlper[2] = 0; ctlper[3] = 0; //reset column 1
                    ctlper[4] = 0; ctlper[5] = 0; ctlper[6] = 0; ctlper[7] = 0; //reset column 2
                    ctlper[8] = 0; ctlper[9] = 0; ctlper[10] = 0; ctlper[11] = 0; //reset column 3
                    ctlper[12] = 2; ctlper[13] = 2; ctlper[14] = 1; ctlper[15] = 2; //output column 4
                end
                16'd15:begin
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
    else if(countin == 15) 
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
    else if(countw == 15) 
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

//when countpe == 15, the output is finished
always@(posedge clk or negedge rst)
begin
    if(!rst)
        output_finish <= 0;
    else if(countpe == 15)
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

endmodule
