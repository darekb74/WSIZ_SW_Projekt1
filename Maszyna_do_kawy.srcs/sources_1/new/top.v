`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.04.2018 12:29:16
// Design Name: 
// Module Name: top
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


module top(
    input wire [2:0]mon_in,
    input wire [2:0]panel_przyciskow_in,
    input wire c_k, p_w, i_k, i_m, p_b,
    input wire clk, 
    
    output wire [2:0] mon_out,       // zwrot monet
    output wire [2:0] urzadzenia,
    output wire [3:0] segment_out,   // wska�nik wy�wietlanej liczby (0-wy�wietlany, 1-zgaszony)
    output wire seg_um,              // g�ra, �rodek
    output wire seg_ul,              // g�ra, lewo
    output wire seg_ur,              // g�ra, prawo
    output wire seg_mm,              // �rodek, �rodek
    output wire seg_dl,              // d�, lewo
    output wire seg_dr,              // d�, prawo
    output wire seg_dm,              // d�l, �rodek
    output wire seg_dot              // kropka
    
    );
    // pod��czamy modu� sprawnosci
    wire sprawnosc_out;
    sprawnosc spr_test(.c_k(c_k), .p_w(p_w), .i_k(i_k), .i_m(i_m), .p_b(p_b), .signal_s(sprawnosc_out));
    
    //dzielnik czestotliwo�ci
    wire clk_div;
    divider #(1) div(.clk(clk), .clk_div(clk_div));
    
    //modu� monet
    parameter CENA_OP1 = `m300;				 // cena opcji 1 (3.00z� - expresso )
    parameter CENA_OP2 = `m500;              // cena opcji 2 (5.00z� - expresso grande :P )
    parameter CENA_OP3 = `m750;              // cena opcji 3 (7.50z� - cappuccino :P )
    wire [2:0]cmd_out;
    wire [1:0]cmd_in;
    wire [4:0]stan_mm;
    modul_monet #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) wrzut_zwrot(.clk(clk_div), .cmd_in(cmd_out),
        .cmd_out(cmd_in), .stan_mm(stan_mm), .mon_in(mon_in), .mon_out(mon_out));
    
    // licznik
    parameter tick_every = 20;              // pozwoli dostosowa� czasy do zegaru (oraz przyspieszy� symulacj� ;] )
    wire licz_in;
    wire [3:0]licz_out;
    wire [6:0]count_secs;
    counter #(.tick_every(tick_every)) licznik(.clk(clk_div), .count_out(licz_in), .count_in(licz_out), .count_secs(count_secs));
    
    // wyswietlacz
    wire [4:0]L_1, L_2, L_3, L_4;
    wyswietlacz_4x7seg wys_pan(.clk(clk), .L_1(L_1), .L_2(L_2), .L_3(L_3), .L_4(L_4),
            .seg_um(seg_um), .seg_ul(seg_ul), .seg_ur(seg_ur), .seg_mm(seg_mm),
            .seg_dm(seg_dm), .seg_dl(seg_dl), .seg_dr(seg_dr), .seg_dot(seg_dot), .segment_out(segment_out));
    
    // pod��czenie starego top
    wire [2:0]u;
    mdk_top old_top(.sprawnosc_in(sprawnosc_out), .panel_przyciskow_in(panel_przyciskow_in), .clk_div(clk_div), 
                    .cmd_out(cmd_out), .cmd_in(cmd_in), .stan_mm(stan_mm), .licz_in(licz_in), .licz_out(licz_out), .count_secs(count_secs),
                    .L_1(L_1), .L_2(L_2), .L_3(L_3), .L_4(L_4),
                    
                    .urzadzenia(urzadzenia) );

    
endmodule
