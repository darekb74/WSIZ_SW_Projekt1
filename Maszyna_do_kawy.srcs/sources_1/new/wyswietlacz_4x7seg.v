`include "defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: WSIZ Copernicus
// Engineer: Darek B.
// 
// Create Date: 18.05.2017 17:42:28
// Design Name: 
// Module Name: wyswietlacz_4x7seg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
/*
    MULTIPLEXOWANY, CZTEROSEGMENTOWY WYŒWIETLACZ 7SEG Z KROPK¥
    
*/  
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wyswietlacz_4x7seg(
    input wire clk,                 // zegar (nie mniej, ni¿ 250Hz)
    input wire [5:0]licz1,          // liczba segement 1 (6 bit = kropka)
    input wire [5:0]licz2,          // liczba segement 2 (6 bit = kropka)
    input wire [5:0]licz3,          // liczba segement 3 (6 bit = kropka)
    input wire [5:0]licz4,          // liczba segement 4 (6 bit = kropka)
    output reg [3:0] segment_out,   // wskaŸnik wyœwietlanej liczby (0-wyœwietlany, 1-zgaszony)
    output reg seg_um,              // góra, œrodek
    output reg seg_ul,              // góra, lewo
    output reg seg_ur,              // góra, prawo
    output reg seg_mm,              // œrodek, œrodek
    output reg seg_dl,              // dó³, lewo
    output reg seg_dr,              // dó³, prawo
    output reg seg_dm,              // dól, œrodek
    output reg seg_dot              // kropka
    );
    
    reg [3:0]liczba;
    
    function [7:0]liczbaNAsygnaly;
    input [5:0]liczba;
    reg dot;
        begin
            dot = liczba[5:5];                             // 6 bit to kropka
            case (liczba[4:0])
                default: liczbaNAsygnaly = ~8'b00000000;       // nic nie œwieci
                4'b0000: liczbaNAsygnaly = ~{dot,7'b1110111};  // 0
                4'b0001: liczbaNAsygnaly = ~{dot,7'b0010010};  // 1
                4'b0010: liczbaNAsygnaly = ~{dot,7'b1011101};  // 2
                4'b0011: liczbaNAsygnaly = ~{dot,7'b1011011};  // 3
                4'b0100: liczbaNAsygnaly = ~{dot,7'b0111010};  // 4
                4'b0101: liczbaNAsygnaly = ~{dot,7'b1101011};  // 5
                4'b0110: liczbaNAsygnaly = ~{dot,7'b1101111};  // 6
                4'b0111: liczbaNAsygnaly = ~{dot,7'b1010010};  // 7
                4'b1000: liczbaNAsygnaly = ~{dot,7'b1111111};  // 8
                4'b1001: liczbaNAsygnaly = ~{dot,7'b1111011};  // 9
                4'b1010: liczbaNAsygnaly = ~{dot,7'b1111110};  // a
                4'b1011: liczbaNAsygnaly = ~{dot,7'b0101111};  // b
                4'b1100: liczbaNAsygnaly = ~{dot,7'b1100101};  // c
                4'b1101: liczbaNAsygnaly = ~{dot,7'b0011111};  // d
                4'b1110: liczbaNAsygnaly = ~{dot,7'b1101101};  // e
                4'b1111: liczbaNAsygnaly = ~{dot,7'b1101100};  // f
            endcase
         end
    endfunction
    
    
    always @(negedge clk)
        begin
            case (~segment_out) // ~ aby by³o czytelniej :)
                default: begin segment_out <= ~4'b0001; {seg_dot,seg_um,seg_ul,seg_ur,seg_mm,seg_dl,seg_dr,seg_dm} <= liczbaNAsygnaly(licz1); end // inicjalizacja - pierwszy segment zapalony
                4'b0001: begin segment_out <= ~4'b0010; {seg_dot,seg_um,seg_ul,seg_ur,seg_mm,seg_dl,seg_dr,seg_dm} <= liczbaNAsygnaly(licz2); end // z ka¿dym pe³nym cyklem zmieniamy wyœwietlany segment
                4'b0010: begin segment_out <= ~4'b0100; {seg_dot,seg_um,seg_ul,seg_ur,seg_mm,seg_dl,seg_dr,seg_dm} <= liczbaNAsygnaly(licz3); end // z ka¿dym pe³nym cyklem zmieniamy wyœwietlany segment
                4'b0100: begin segment_out <= ~4'b1000; {seg_dot,seg_um,seg_ul,seg_ur,seg_mm,seg_dl,seg_dr,seg_dm} <= liczbaNAsygnaly(licz4); end // z ka¿dym pe³nym cyklem zmieniamy wyœwietlany segment
                4'b1000: begin segment_out <= ~4'b0001; {seg_dot,seg_um,seg_ul,seg_ur,seg_mm,seg_dl,seg_dr,seg_dm} <= liczbaNAsygnaly(licz1); end // ustawiamy wyswietlany segment na pierwszy 
            endcase
        end
        
endmodule
