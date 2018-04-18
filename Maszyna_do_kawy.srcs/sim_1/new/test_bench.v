`include "../../sources_1/new/defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: WSIZ Copernicus
// Engineer: Rafa³ B., Szymon S., Darek B.
// 
// Create Date: 26.04.2017 18:27:52
// Design Name: 
// Module Name: test_bench
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


module test_bench();

    reg clk;
    reg [2:0]panel_przyciskow;

    parameter CENA_OP1 = `m300;				 // cena opcji 1 (3.00z³ - expresso )
    parameter CENA_OP2 = `m500;              // cena opcji 2 (5.00z³ - expresso grande :P )
    parameter CENA_OP3 = `m750;              // cena opcji 3 (7.50z³ - cappuccino :P )
    
    parameter tick_every = 20;               // w³aœciwie nie nale¿y zmieniaæ - regulacja czêstotliwoœci maszyny
                                             // aktualnie: (1 000 000 us / 20 us) cykli/s = 50 000 Hz = 50 kHz
    parameter speed_up = 50000;              // zwiêkszenie spowoduje przyspieszenie licznika (tylko licznika)
                                             // ustawienie na 50 000 spowoduje przyspieszenia licznika do wartoœci:
                                             // 1 cykl = 1 sek (pomocne w symulacji)

    // pod³¹czamy modu³ g³ówny
    reg [2:0]monety_in;
    wire [2:0]monety_out;
    reg kubki, kawa, woda, mleko, bilon;
    top #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3), .tick_every(tick_every*speed_up))
      uut(.clk(clk), .mon_in(monety_in), .panel_przyciskow_in(panel_przyciskow), .mon_out(monety_out),
      .c_k(kubki), .i_k(kawa), .p_w(woda), .i_m(mleko), .p_b(bilon));
    // podgl¹d zegara dzielnika oraz stanu modu³u g³ównego
    wire clk_div;
    wire [3:0]stan_top;
    assign clk_div = top.clk_div;
    assign stan_top = top.old_top.stan_top;
    
    // sterowanie i podgl¹d modu³u monet

    wire [1:0]cmd_out_mm;
    wire [4:0]stan_mm;

    assign stan_mm = top.wrzut_zwrot.stan;
    assign cmd_out_mm = top.cmd_out;

    // sterowanie i podgl¹d modu³u sprawnoœci
    wire sprawnosc;
    assign sprawnosc = top.sprawnosc_out;
         
   
    // podgl¹d wyœwietlacza
    wire [3:0]seg_out;
    wire seg_dl, seg_dm, seg_dot, seg_dr, seg_mm, seg_ul, seg_um, seg_ur; 
    assign seg_um = top.seg_um;
    assign seg_ul = top.seg_ul;
    assign seg_ur = top.seg_ur;
    assign seg_mm = top.seg_mm;
    assign seg_dl = top.seg_dl;
    assign seg_dr = top.seg_dr;
    assign seg_dm = top.seg_dm;
    assign seg_dot = top.seg_dot;
    assign seg_out = top.segment_out;
    
    // podgl¹d licznika
    wire [6:0] count_secs;
    wire count_out;
    assign count_secs = top.count_secs; 
    assign count_out = top.licz_in;
    
    
    
    initial 
        begin
            clk = 1'b0;
            panel_przyciskow = `CMD_RESET;  // resetujemy autoamt
            // modu³ sprawnoœci - emulacja czujnikow
            kubki <= 1'b0;
            kawa <= 1'b0;
            woda <= 1'b0;
            mleko <= 1'b0;
            bilon <= 1'b0;
            monety_in = `z0g00;
            // zaczynamy
            #(tick_every*10) monety_in <= `z0g50;             // wrzucamy 50 groszy
            #(tick_every*10) monety_in <= `z1g00;             // wrzucamy 1 z³
            #(tick_every*10) monety_in <= `z2g00;             // wrzucamy 2 z³
            #(tick_every*10) monety_in <= `z5g00;             // wrzucamy 5 z³
            #(tick_every*10) panel_przyciskow <= `CMD_OP1;    // wybieramy opcjê nr 1
            #(tick_every*10) panel_przyciskow <= `CMD_OP2;    // wybieramy opcjê nr 2 (bez resetu)
            #(tick_every*10) monety_in <= `z2g00;             // wrzucamy 2 z³
            #(tick_every*10) monety_in <= `z0g50;             // wrzucamy 50 gr
            #(tick_every*10) panel_przyciskow = `CMD_RESET;   // reset 
            #(tick_every*2) monety_in <= `z5g00;              // wrzucamy 5 z³
            // ok, teraz zrtobimy kawkê
            #(tick_every*30) panel_przyciskow <= `CMD_OP3;    // wybieramy opcjê nr 3
            #(tick_every*10) monety_in <= `z2g00;             // wrzucamy 2 z³
            #(tick_every*10) monety_in <= `z0g50;             // wrzucamy 50 gr
            #(tick_every*10) monety_in <= `z2g00;             // wrzucamy 2 z³
            #(tick_every*10) monety_in <= `z5g00;             // wrzucamy 5 z³
            
        end
    always
        begin
            #(tick_every/2)
                begin
                    clk <= ~clk;        // zegar - tick
                end
        end
     always @(clk)
        begin
            if (monety_in != `z0g00)
               #(tick_every*4) monety_in <= `z0g00;              // moneta wpad³a wiêc zerujemy sygna³
            if (panel_przyciskow != 1'b0)
               #(tick_every*4) panel_przyciskow <= `CMD_NIC;     // wciœniêto przycisk wiêc zerujemy
        end
    
endmodule
