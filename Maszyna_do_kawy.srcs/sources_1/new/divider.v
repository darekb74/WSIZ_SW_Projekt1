`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WSIZ Copernicus
// Engineer: Rafa³ B., Szymon S., Darek B.
// 
// Create Date: 31.05.2017 15:40:43
// Design Name: 
// Module Name: divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Podzielnik czêstotliwoœci.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module divider(
    input clk,
    output reg CLK_250KHz,
	output reg CLK_1MHz);

reg [4:0] cc;
reg [4:0] ct;

always @(posedge clk)
     
    if (ct<24) 
        ct<=ct+1;
    else 
        begin 
            ct<=0; 
            CLK_1MHz<=(CLK_1MHz === 1'bX ? 1'b0 : ~CLK_1MHz);
        end 

always @(posedge CLK_1MHz) 
    if (cc<1) 
        cc<=cc+1;
    else 
        begin 
            cc<=0; 
            CLK_250KHz<=(CLK_250KHz === 1'bX ? 1'b0 : ~CLK_250KHz); 
        end

    
endmodule
