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

    parameter CENA_OP1 = `m300;				 // cena opcji 1 (3.00z³ - expresso )
    parameter CENA_OP2 = `m500;              // cena opcji 2 (5.00z³ - expresso grande :P )
    parameter CENA_OP3 = `m750;              // cena opcji 3 (7.50z³ - cappuccino :P )

    // pod³¹czamy modu³ g³ówny
    mdk_top #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) uut(.clk(clk), .panel_przyciskow_in(panel_przyciskow));
    
    // sterowanie i podgl¹d modu³u monet
    reg [2:0]monety_in;
    wire [2:0]monety_out;
    wire [4:0]stan;
    assign uut.wrzut_zwrot.mon_in = monety_in;
    assign monety_out = uut.wrzut_zwrot.mon_out;
    assign stan = uut.wrzut_zwrot.stan;

    // sterowanie i podgl¹d modu³u sprawnoœci
    wire sprawnosc;
    reg kubki, kawa, woda, mleko, bilon; 
    assign uut.spr_test.c_k = kubki;
    assign uut.spr_test.i_k = kawa;
    assign uut.spr_test.p_w = woda;
    assign uut.spr_test.i_m = mleko;
    assign uut.spr_test.p_b = bilon;
    assign sprawnosc = uut.spr_test.signal_s;     
   
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
            #50 monety_in <= `z0g50;             // wrzucamy 50 groszy
            #50 monety_in <= `z1g00;             // wrzucamy 1 z³
            #50 monety_in <= `z2g00;             // wrzucamy 2 z³
            #50 monety_in <= `z5g00;             // wrzucamy 5 z³
            #50 panel_przyciskow <= `CMD_OP1;    // wybieramy opcjê nr 1
            #50 panel_przyciskow <= `CMD_OP2;    // wybieramy opcjê nr 2 (bez resetu)
            #50 monety_in <= `z2g00;             // wrzucamy 2 z³
            #50 monety_in <= `z0g50;             // wrzucamy 50 gr
            #50 panel_przyciskow = `CMD_RESET;   // reset 
            #10 monety_in <= `z5g00;             // wrzucamy 5 z³

            
        end
    always
        begin
            #10 // 50MHz
                begin
                    clk <= ~clk;        // zegar - tick
                end
        end
     always @(clk)
        begin
            if (monety_in != `z0g00)
               #20 monety_in <= `z0g00;              // moneta wpad³a wiêc zerujemy sygna³
            if (panel_przyciskow != 1'b0)
               #20 panel_przyciskow <= `CMD_NIC;     // wciœniêto przycisk wiêc zerujemy
        end
    
endmodule
