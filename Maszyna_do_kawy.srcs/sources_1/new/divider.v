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
    input wire clk,
    output reg clk_div
    );
    
    parameter div = 1;
    
    reg [div:0] c = 0;
    
    always @(negedge c)
            begin
                clk_div <= (clk_div === 1'bX ? 1'b0 : ~clk_div);
            end
    always @(posedge clk)
        begin
            c <= c + 1;
        end
    
endmodule
