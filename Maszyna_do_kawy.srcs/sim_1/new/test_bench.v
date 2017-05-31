`include "../../sources_1/new/defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: WSIZ Copernicus
// Engineer: Darek B.
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

    parameter CENA_OP1 = `m300;				 // cena opcji 1 (3.00z� - expresso )
    parameter CENA_OP2 = `m500;              // cena opcji 2 (5.00z� - expresso grande :P )
    parameter CENA_OP3 = `m750;              // cena opcji 3 (7.50z� - cappuccino :P )

    // pod��czamy modu� g��wny
    mdk_top #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) uut(.clk(clk), .panel_przyciskow_in(panel_przyciskow));
    // podgl�d zegara dzielnika
    wire clk_div;
    assign clk_div = mdk_top.clk_div;
    
    // sterowanie i podgl�d modu�u monet
    reg [2:0]monety_in;
    wire [2:0]monety_out;
    wire [4:0]stan;
    assign uut.wrzut_zwrot.mon_in = monety_in;
    assign monety_out = uut.wrzut_zwrot.mon_out;
    assign stan = uut.wrzut_zwrot.stan;

    // sterowanie i podgl�d modu�u sprawno�ci
    wire sprawnosc;
    reg kubki, kawa, woda, mleko, bilon; 
    assign uut.spr_test.c_k = kubki;
    assign uut.spr_test.i_k = kawa;
    assign uut.spr_test.p_w = woda;
    assign uut.spr_test.i_m = mleko;
    assign uut.spr_test.p_b = bilon;
    assign sprawnosc = uut.spr_test.signal_s;     
   
    // podgl�d wy�wietlacza
    wire [3:0]seg_out;
    wire seg_dl, seg_dm, seg_dot, seg_dr, seg_mm, seg_ul, seg_um, seg_ur; 
    assign seg_um = uut.wys_pan.seg_um;
    assign seg_ul = uut.wys_pan.seg_ul;
    assign seg_ur = uut.wys_pan.seg_ur;
    assign seg_mm = uut.wys_pan.seg_mm;
    assign seg_dl = uut.wys_pan.seg_dl;
    assign seg_dr = uut.wys_pan.seg_dr;
    assign seg_dm = uut.wys_pan.seg_dm;
    assign seg_dot = uut.wys_pan.seg_dot;
    assign seg_out= uut.wys_pan.segment_out;
    
    
    
    initial 
        begin
            clk = 1'b0;
            panel_przyciskow = `CMD_RESET;  // resetujemy autoamt
            // modu� sprawno�ci - emulacja czujnikow
            kubki <= 1'b0;
            kawa <= 1'b0;
            woda <= 1'b0;
            mleko <= 1'b0;
            bilon <= 1'b0;
            monety_in = `z0g00;
            // zaczynamy
            #200 monety_in <= `z0g50;             // wrzucamy 50 groszy
            #200 monety_in <= `z1g00;             // wrzucamy 1 z�
            #200 monety_in <= `z2g00;             // wrzucamy 2 z�
            #200 monety_in <= `z5g00;             // wrzucamy 5 z�
            #200 panel_przyciskow <= `CMD_OP1;    // wybieramy opcj� nr 1
            #200 panel_przyciskow <= `CMD_OP2;    // wybieramy opcj� nr 2 (bez resetu)
            #200 monety_in <= `z2g00;             // wrzucamy 2 z�
            #200 monety_in <= `z0g50;             // wrzucamy 50 gr
            #200 panel_przyciskow = `CMD_RESET;   // reset 
            #40 monety_in <= `z5g00;             // wrzucamy 5 z�

            
        end
    always
        begin
            #10 // 50kHz
                begin
                    clk <= ~clk;        // zegar - tick
                end
        end
     always @(clk)
        begin
            if (monety_in != `z0g00)
               #80 monety_in <= `z0g00;              // moneta wpad�a wi�c zerujemy sygna�
            if (panel_przyciskow != 1'b0)
               #80 panel_przyciskow <= `CMD_NIC;     // wci�ni�to przycisk wi�c zerujemy
        end
    
endmodule
