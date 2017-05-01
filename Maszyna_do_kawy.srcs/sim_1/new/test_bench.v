`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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
    
    reg [2:0]monety_in;
    wire [2:0]monety_out;
    
    localparam [4:0]NIC   = 5'b00000;      // bezczynnosc
    localparam [4:0]m050  = 5'b00001;      // 50 groszy
    localparam [4:0]m100  = 5'b00010;      // 1 z³
    localparam [4:0]m150  = 5'b00011;      // 1.50 z³
    localparam [4:0]m200  = 5'b00100;      // 2 z³
    localparam [4:0]m250  = 5'b00101;      // 2.50 z³
    localparam [4:0]m300  = 5'b00110;      // 3 z³
    localparam [4:0]m350  = 5'b00111;      // 3.50 z³
    localparam [4:0]m400  = 5'b01001;      // 4 z³
    localparam [4:0]m450  = 5'b01010;      // 4.50 z³
    localparam [4:0]m500  = 5'b01011;      // 5 z³
    localparam [4:0]m550  = 5'b01100;      // 5.50 z³
    localparam [4:0]m600  = 5'b01101;      // 6 z³
    localparam [4:0]m650  = 5'b01110;      // 6.50 z³
    localparam [4:0]m700  = 5'b01111;      // 7.00 z³
    localparam [4:0]m750  = 5'b10000;      // 7.50 z³
    localparam [4:0]m800  = 5'b10001;      // 8.00 z³
    localparam [4:0]m850  = 5'b10010;      // 8.50 z³
    localparam [4:0]m900  = 5'b10011;      // 9.00 z³
    localparam [4:0]m950  = 5'b10100;      // 9.50 z³
    localparam [4:0]m1000 = 5'b10101;      // 10.00 z³ 
    
    localparam [2:0]z0g00 = 3'b000;      // brak monety - stan zerowy
    localparam [2:0]z0g50 = 3'b001;      // 50 groszy
    localparam [2:0]z1g00 = 3'b010;      // 1 z³
    localparam [2:0]z2g00 = 3'b011;      // 2 z³
    localparam [2:0]z5g00 = 3'b100;      // 5 z³
   
    // OBS£UGA PRZYCISKÓW
    localparam [2:0] CMD_NIC    = 3'b000;
    localparam [2:0] CMD_OP1    = 3'b001;
    localparam [2:0] CMD_OP2    = 3'b010;
    localparam [2:0] CMD_OP3    = 3'b011;
    localparam [2:0] CMD_RESET  = 3'b100;
    // konieczne
    localparam [2:0] CMD_RESET1  = 3'b101;
    localparam [2:0] CMD_RESET2  = 3'b110;
    localparam [2:0] CMD_RESET3  = 3'b111;
 
    parameter CENA_OP1 = m300;				// cena opcji 1 (3.00z³ - expresso )
    parameter CENA_OP2 = m500;              // cena opcji 2 (5.00z³ - expresso grande :P )
    parameter CENA_OP3 = m750;              // cena opcji 3 (7.50z³ - cappuccino :P )
   
    reg [4:0]stan;
    reg sprawnosc;                          // chwilowo zastêpuje oddzielny modu³
    
    
    mdk_top #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) uut(.clk(clk), .panel_przyciskow_in(panel_przyciskow), .sprawnosc_in(sprawnosc));
    modul_monet #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) uut2(.clk(clk), .mon_in(monety_in), .mon_out(monety_out), .cmd_in(uut.cmd_out));
   
    initial 
        begin
            clk = 1'b0;
            monety_in = z0g00;
            panel_przyciskow = CMD_NIC;
            stan = uut2.stan;
            sprawnosc = 1'b1;
            // zaczynamy
            #20 monety_in <= z0g50;             // wrzucamy 50 groszy
            #20 monety_in <= z1g00;             // wrzucamy 1 z³
            #20 monety_in <= z2g00;             // wrzucamy 2 z³
            #20 monety_in <= z5g00;             // wrzucamy 5 z³
            #20 panel_przyciskow <= CMD_OP1;    // wybieramy opcjê nr 1
            #20 panel_przyciskow <= CMD_OP2;    // wybieramy opcjê nr 2 (bez resetu)
            #20 monety_in <= z2g00;             // wrzucamy 2 z³
            #20 monety_in <= z0g50;             // wrzucamy 50 gr
            #20 panel_przyciskow = CMD_RESET;   // reset 
            #10 monety_in <= z5g00;             // wrzucamy 5 z³

            
        end
    always
        begin
            #5 
                begin
                    clk <= ~clk;        // zegar - tick
                    stan = uut2.stan;   // pobieramy zmienn¹ stan z modu³u monet (do podgl¹du)
                end
        end
     always @(clk)
        begin
            if (monety_in != z0g00)
               #10 monety_in <= z0g00;              // moneta wpad³a wiêc zerujemy sygna³
            if (panel_przyciskow != 1'b0)
               #10 panel_przyciskow <= CMD_NIC;     // moneta wpad³a wiêc zerujemy sygna³
        end
    
endmodule
