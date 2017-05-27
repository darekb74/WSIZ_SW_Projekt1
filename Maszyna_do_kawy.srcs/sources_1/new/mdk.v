`include "defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: WSIZ Copernicus
// Engineer: Rafa³ B., Szymek S., Darek B.
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
    input wire licz_in,                     // 0 - stoi, 1 - liczy
    output reg [4:0] licz_out,              // wyjœcie do licznika        
    // sterowanie modu³em monet
    input wire[1:0]cmd_in,                  // odpowiedz na koendê z modu³u odpowedzialnego za monety
    output reg [2:0]cmd_out,                // komenda do modu³u odpowedzialnego za monety
    // wyœwietlacz
    output reg [4:0] L_1,                // segment 1
    output reg [4:0] L_2,                // segment 2
    output reg [4:0] L_3,                // segment 3
    output reg [4:0] L_4,                // segment 4
    // sterowanie poszczególnymi etapami parzenia kawy - do zmiany na [2:0]
    output reg kubek,                       // podstawienie kubka
    output reg woda,                        // w³¹czanie dozowania wody
    output reg kawa,                        // w³¹czanie m³ynka do kawy
    output reg mleko                        // w³¹czanie dozowania mleka (spieniacz)
    );
    
    
    parameter CENA_OP1 = `m300;				// cena opcji 1 (3.00z³ - expresso)
    parameter CENA_OP2 = `m500;				// cena opcji 2 (5.00z³ - expresso grande :P )
    parameter CENA_OP3 = `m750;				// cena opcji 3 (7.50z³ - cappucino :P )
    
    parameter tick_every = 20;              // pozwoli dostosowaæ czasy do zegaru (oraz przyspieszyæ symulacjê ;] )

    //reg [4:0]stan;                          // stan maszyny

    // ³¹czymy modu³y
    // pod³¹czamy modu³ monet
    modul_monet #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) wrzut_zwrot(.clk(clk), .cmd_in(cmd_out), .cmd_out(cmd_in));
    // pod³¹czamy modu³ sprawnosci
    sprawnosc spr_test(.signal_s(sprawnosc_in));
    // pod³¹czamy modu³ licznika
    counter #(.tick_every(tick_every)) licznik(.count_out(licz_in), .count_in(licz_out), .clk(clk));
    // pod³¹czamy modu³ wyœwietlacza
    wyswietlacz_4x7seg wys_pan(.clk(clk), .L_1(L_1), .L_2(L_2), .L_3(L_3), .L_4(L_4));

    reg [5:0]stan_top, stan_n;
    
    always @(panel_przyciskow_in)
        #1 begin
            if (panel_przyciskow_in == `CMD_RESET && cmd_in === 2'bXX) // automat nic nie robi - reset pocz¹tkowy
                begin
                    // ustawienia poczatkowe
                    stan_top = 0;
                    stan_n = 0;
                    kubek = `STAN_ZEROWY;
                    woda = `STAN_ZEROWY;
                    kawa = `STAN_ZEROWY;
                    mleko = `STAN_ZEROWY;
                    cmd_out = `CMD_RESET;       // resetujemy modu³ monet
                    licz_out = `LICZNIK_RESET;  // resetujemy licznik
                    // reset wyswietlacza
                    L_1 = 5'b00000;
                    L_2 = 5'b00000;
                    L_3 = 5'b00000;
                    L_4 = 5'b00000;
                end
            if (sprawnosc_in == 1'b0) begin     // sterowanie dostêpne tylko w przypadku sprawnej maszyny
                case (panel_przyciskow_in)
                    `CMD_OP1: // wciœniêto przycisk wyboru opcji 1
                        if(cmd_in == `ODP_NIC)   // jeœli modu³ nic nie robi
                            begin
                                cmd_out = `CMD_OP1; // rozpoczynamy pobór monet
                                stan_n = `POBIERAM;
                            end
                    `CMD_OP2: // wciœniêto przycisk wyboru opcji 2
                        if(cmd_in == `ODP_NIC)   // jeœli modu³ nic nie robi
                            begin
                                cmd_out = `CMD_OP2; // rozpoczynamy pobór monet
                                stan_n = `POBIERAM;
                            end
                    `CMD_OP3: // wciœniêto przycisk wyboru opcji 3
                        if(cmd_in == `ODP_NIC)   // jeœli modu³ nic nie robi
                            begin
                                cmd_out = `CMD_OP3; // rozpoczynamy pobór monet
                                stan_n = `POBIERAM;
                            end
                    `CMD_RESET:
                        case(cmd_out)
                            `CMD_OP1:
                                begin
                                    cmd_out = `CMD_RESET1;
                                    stan_n = `ZWRACAM;
                                end
                            `CMD_OP2:
                                begin
                                    cmd_out = `CMD_RESET2;
                                    stan_n = `ZWRACAM;
                                end
                            `CMD_OP3:
                                begin
                                    cmd_out = `CMD_RESET3;
                                    stan_n = `ZWRACAM;
                                end
                        endcase
                endcase
            end
        end
        always @(posedge clk)  // g³owna czêœæ
            begin
                stan_n <= stan_top;
                case (stan_top)
                    `CZEKAM:     
                        begin // NIC SIE NIE DZIEJE - PUSTY WYSWIETLACZ
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b0,`W_NULL,1'b0,`W_NULL,1'b0,`W_NULL};
                        end
                    `POBIERAM:   // pobieram op³atê
                        begin
                            stan_n <= `POBIERAM;
                        end
                    `ZWRACAM:
                        begin
                            case (L_1) // WIRUJ¥CE OKRÊGI NA WYŒWIETLACZU - ZWROT PIENIÊDZY
                                default: {L_1,L_2,L_3,L_4} <= {1'b0,`W_UM,1'b0,`W_MM,1'b0,`W_UM,1'b0,`W_MM}; 
                                `W_UM: {L_1,L_2,L_3,L_4} <= {1'b0,`W_UL,1'b0,`W_UR,1'b0,`W_UL,1'b0,`W_UR};
                                `W_UL: {L_1,L_2,L_3,L_4} <= {1'b0,`W_MM,1'b0,`W_UM,1'b0,`W_MM,1'b0,`W_UM};
                                `W_MM: {L_1,L_2,L_3,L_4} <= {1'b0,`W_UR,1'b0,`W_UL,1'b0,`W_UR,1'b0,`W_UL};
                            endcase
                        end
                        
                endcase
            end
        always @(negedge clk)
            begin
                if ((cmd_out == `CMD_RESET || cmd_out == `CMD_RESET1 || cmd_out == `CMD_RESET2 || cmd_out == `CMD_RESET3) && cmd_in == `ODP_NIC) 
                    begin
                        cmd_out <= `CMD_NIC;        // zerowanie linii komend po wstêpnym resecie
                        licz_out <= `LICZNIK_NULL;  // zerowanie linii komend licznika po wstepnym resecie
                    end
                stan_top <= stan_n;
            end
endmodule