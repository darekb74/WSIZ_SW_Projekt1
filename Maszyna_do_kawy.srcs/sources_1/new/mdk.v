`include "defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: WSIZ Copernicus
// Engineer: Darek B.
// 
// Create Date: 25.04.2017 18:46:49
// Design Name:  
// Module Name: mdk
// Project Name: Maszyna do kawy 
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


module mdk_top(
    input wire clk,                         // zegar
    // sygna³ z przycisków
    input wire [2:0]panel_przyciskow_in,    // przyciski - wybór kawy 
    // czujnik sprawnoœci maszyny 
    input wire sprawnosc_in,                // czujnikami zajmie siê inny modu³ - tu wystarczy sygna³: 0-sprawny, 1-niesprawny
    // licznik
    input reg licz_in,                      // 0 - stoi, 1 - liczy        
    // sterowanie modu³em monet
    input wire[1:0]cmd_in,                  // odpowiedz na koendê z modu³u odpowedzialnego za monety
    output reg [2:0]cmd_out,                // komenda do modu³u odpowedzialnego za monety
    // sterowanie poszczególnymi etapami parzenia kawy - do zmiany na [2:0]
    output reg kubek,                       // podstawienie kubka
    output reg woda,                        // w³¹czanie dozowania wody
    output reg kawa,                        // w³¹czanie m³ynka do kawy
    output reg mleko                        // w³¹czanie dozowania mleka (spieniacz)
    );
    
    
    parameter CENA_OP1 = `m300;				// cena opcji 1 (3.00z³ - expresso)
    parameter CENA_OP2 = `m500;				// cena opcji 2 (5.00z³ - expresso grande :P )
    parameter CENA_OP3 = `m750;				// cena opcji 3 (7.50z³ - cappucino :P )

    //reg [4:0]stan;                          // stan maszyny

    // ³¹czymy modu³y
    // pod³¹czamy modu³ monet
    modul_monet #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) wrzut_zwrot(.clk(clk), .cmd_in(cmd_out), .cmd_out(cmd_in));
    // pod³¹czamy modu³ sprawnosci
    sprawnosc spr_test(.signal_s(sprawnosc_in));
    // pod³¹czamy modu³ licznika
    counter licznik(.count_out(licz_in));

    always @(panel_przyciskow_in)
        #1 begin
            if (panel_przyciskow_in == `CMD_RESET && cmd_in === 2'bXX) // automat nic nie robi - reset pocz¹tkowy
                begin
                    // ustawienia poczatkowe
                    kubek = `STAN_ZEROWY;
                    woda = `STAN_ZEROWY;
                    kawa = `STAN_ZEROWY;
                    mleko = `STAN_ZEROWY;
                    cmd_out = `CMD_RESET;   // resetujemy modu³ monet
                end
            if (sprawnosc_in == 1'b0) begin     // sterowanie dostêpne tylko w przypadku sprawnej maszyny
                case (panel_przyciskow_in)
                    `CMD_OP1: // wciœniêto przycisk wyboru opcji 1
                        if(cmd_in == `ODP_NIC)   // jeœli modu³ nic nie robi
                            cmd_out = `CMD_OP1; // rozpoczynamy pobór monet
                    `CMD_OP2: // wciœniêto przycisk wyboru opcji 2
                        if(cmd_in == `ODP_NIC)   // jeœli modu³ nic nie robi
                            cmd_out = `CMD_OP2; // rozpoczynamy pobór monet
                    `CMD_OP3: // wciœniêto przycisk wyboru opcji 3
                        if(cmd_in == `ODP_NIC)   // jeœli modu³ nic nie robi
                            cmd_out = `CMD_OP3; // rozpoczynamy pobór monet
                    `CMD_RESET:
                        case(cmd_out)
                            `CMD_OP1:
                                cmd_out = `CMD_RESET1;
                            `CMD_OP2:
                                cmd_out = `CMD_RESET2;
                            `CMD_OP3:
                                cmd_out = `CMD_RESET3;
                        endcase
                endcase
            end
        end
        always @(negedge clk)
            begin
                if (cmd_out == `CMD_RESET && cmd_in == `ODP_NIC) cmd_out <= `CMD_NIC;  // zerowanie linii komend po wstêpnym resecie
            end
endmodule
