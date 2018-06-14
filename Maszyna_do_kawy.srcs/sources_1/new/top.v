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
    output wire [3:0] segment_out,   // wskaŸnik wyœwietlanej liczby (0-wyœwietlany, 1-zgaszony)
    output wire seg_um,              // góra, œrodek
    output wire seg_ul,              // góra, lewo
    output wire seg_ur,              // góra, prawo
    output wire seg_mm,              // œrodek, œrodek
    output wire seg_dl,              // dó³, lewo
    output wire seg_dr,              // dó³, prawo
    output wire seg_dm,              // dól, œrodek
    output wire seg_dot,             // kropka
    // lcd
    output wire [7:0]LCD_DB,
    output wire LCD_RS, 
    output wire LCD_RW,
    output wire LCD_E 
    );
    // pod³¹czamy modu³ sprawnosci
    wire sprawnosc_out;
    wire [7:0]sprawnosc_map;
    //sprawnosc spr_test(.c_k(c_k), .p_w(p_w), .i_k(i_k), .i_m(i_m), .p_b(p_b), .signal_s(sprawnosc_out), .sprawnosc_map(sprawnosc_map));
    sprawnosc spr_test(.c_k(c_k), .p_w(p_w), .i_k(i_k), .i_m(i_m), .p_b(p_b), .sprawnosc_map(sprawnosc_map));
    
    //dzielnik czestotliwoœci
    wire clk_div;
    wire CLK_1MHz, CLK_250KHz;
    divider div(.clk(clk), .CLK_1MHz(CLK_1MHz), .CLK_250KHz(CLK_250KHz));
    
    //modu³ monet
    parameter CENA_OP1 = `m300;				 // cena opcji 1 (3.00z³ - expresso )
    parameter CENA_OP2 = `m500;              // cena opcji 2 (5.00z³ - expresso grande :P )
    parameter CENA_OP3 = `m750;              // cena opcji 3 (7.50z³ - cappuccino :P )
    wire [2:0]cmd_out;
    wire [1:0]cmd_in;
    wire [4:0]stan_mm;
    modul_monet #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) wrzut_zwrot(.clk(CLK_1MHz), .cmd_in(cmd_out),
        .cmd_out(cmd_in), .stan_mm(stan_mm), .mon_in(mon_in), .mon_out(mon_out));
    
    // licznik
    parameter tick_every = 20;              // pozwoli dostosowaæ czasy do zegaru (oraz przyspieszyæ symulacjê ;] )
    wire licz_in;
    wire [3:0]licz_out;
    wire [6:0]count_secs;
    counter #(.tick_every(tick_every)) licznik(.clk(CLK_250KHz), .count_out(licz_in), .count_in(licz_out), .count_secs(count_secs));
    
    // wyswietlacz
    wire [4:0]L_1, L_2, L_3, L_4;
    wyswietlacz_4x7seg wys_pan(.clk(clk), .L_1(L_1), .L_2(L_2), .L_3(L_3), .L_4(L_4),
            .seg_um(seg_um), .seg_ul(seg_ul), .seg_ur(seg_ur), .seg_mm(seg_mm),
            .seg_dm(seg_dm), .seg_dl(seg_dl), .seg_dr(seg_dr), .seg_dot(seg_dot), .segment_out(segment_out));
    
    // pod³¹czenie starego top
    wire [2:0]u;
    wire [3:0]stan_data;
    wire reset;
    mdk_top old_top(.sprawnosc_in(~sprawnosc_out), .panel_przyciskow_in(panel_przyciskow_in), .clk_div(CLK_1MHz), 
                    .cmd_out(cmd_out), .cmd_in(cmd_in), .stan_mm(stan_mm), .licz_in(licz_in), .licz_out(licz_out), .count_secs(count_secs),
                    .L_1(L_1), .L_2(L_2), .L_3(L_3), .L_4(L_4),
                    
                    .urzadzenia(urzadzenia), .stan_data(stan_data), .reset(reset) );
    
    // podlaczenie procesora
    wire [7:0]out_data;
   
   Procesor porcesor (
        // in
        .clk(clk),
        .reset(reset),
        .interrupt_data(sprawnosc_map),
        .stan_data(stan_data),
        // out
        .out_data(out_data)
        
    );
    
    /*
    Procesor_v2 porcesor (
            // in
            .clk(clk),
            .reset(reset),
            .interrupt_data(sprawnosc_map),
            .stan_data(stan_data),
            // out
            .out_data(out_data)
            
        );
    */
     
    // LCD Decoder
    wire [8:0]lcd_out;
    wire WR;
    LCD_decoder lcddec(
        //in
        .clk(clk),
        .CLK_250KHz(CLK_250KHz),
        .in_data(out_data),
        // out
        .sprawnosc(sprawnosc_out),
        .lcd_out(lcd_out),
        .WR(WR)
    );
   // lcd_putchar_8
   
   lcd_putchar_8 lcd_putchar_8(
        // input
        .CLK_1MHZ(CLK_1MHz), .CLK_WR(clk), .WR_EN(WR), .RST(~reset), .DATA_IN(lcd_out),
        // output
        .LCD_DB(LCD_DB), .LCD_RS(LCD_RS), .LCD_RW(LCD_RW), .LCD_E(LCD_E) 
    );
    
endmodule
