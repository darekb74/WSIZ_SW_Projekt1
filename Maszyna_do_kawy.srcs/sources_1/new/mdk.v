`include "defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: WSIZ Copernicus
// Engineer: Rafa� B., Szymek S., Darek B.
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
    input wire clk_div,                     // zegar z dzielnika cz�stotliwo�ci
    // sygna� z przycisk�w
    input wire [2:0]panel_przyciskow_in,    // przyciski - wyb�r kawy 
    // czujnik sprawno�ci maszyny 
    input wire sprawnosc_in,                // czujnikami zajmie si� inny modu� - tu wystarczy sygna�: 0-sprawny, 1-niesprawny
    // licznik
    input wire licz_in,                     // 0 - stoi, 1 - liczy
    output reg [4:0] licz_out,              // wyj�cie do licznika        
    // sterowanie modu�em monet
    input wire[1:0]cmd_in,                  // odpowiedz na koend� z modu�u odpowedzialnego za monety
    input wire[4:0]stan_mm,                 // potrzebne do obs�ugi wy�wietlacza
    output reg [2:0]cmd_out,                // komenda do modu�u odpowedzialnego za monety
    // wy�wietlacz
    output reg [4:0] L_1,                // segment 1
    output reg [4:0] L_2,                // segment 2
    output reg [4:0] L_3,                // segment 3
    output reg [4:0] L_4,                // segment 4
    // sterowanie poszczeg�lnymi etapami parzenia kawy - do zmiany na [2:0]
    output reg kubek,                       // podstawienie kubka
    output reg woda,                        // w��czanie dozowania wody
    output reg kawa,                        // w��czanie m�ynka do kawy
    output reg mleko                        // w��czanie dozowania mleka (spieniacz)
    );
    
    
    parameter CENA_OP1 = `m300;				// cena opcji 1 (3.00z� - expresso)
    parameter CENA_OP2 = `m500;				// cena opcji 2 (5.00z� - expresso grande :P )
    parameter CENA_OP3 = `m750;				// cena opcji 3 (7.50z� - cappucino :P )
    
    parameter tick_every = 20;              // pozwoli dostosowa� czasy do zegaru (oraz przyspieszy� symulacj� ;] )

    //reg [4:0]stan;                          // stan maszyny

    // ��czymy modu�y
    // pod��czamy modu� monet
    modul_monet #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) wrzut_zwrot(.clk(clk_div), .cmd_in(cmd_out), .cmd_out(cmd_in), .stan_mm(stan_mm));
    // pod��czamy modu� sprawnosci
    sprawnosc spr_test(.signal_s(sprawnosc_in));
    // pod��czamy modu� licznika
    counter #(.tick_every(tick_every)) licznik(.count_out(licz_in), .count_in(licz_out), .clk(clk_div));
    // pod��czamy modu� wy�wietlacza
    wyswietlacz_4x7seg wys_pan(.clk(clk), .L_1(L_1), .L_2(L_2), .L_3(L_3), .L_4(L_4));
    // pod��czamy dzielnik cz�stotliwo�ci
    divider #(1) div(.clk(clk), .clk_div(clk_div));

    reg [5:0]stan_top, stan_n;
    
    function [19:0]stanNaLiczby;
        input [4:0]stan_mm;
        begin
            case(stan_mm)
                `NIC:   stanNaLiczby = {1'b0,`W_0,1'b1,`W_0,1'b0,`W_0,1'b0,`W_0};
                `m050:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_0,1'b0,`W_5,1'b0,`W_0};
                `m100:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_1,1'b0,`W_0,1'b0,`W_0};
                `m150:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_1,1'b0,`W_5,1'b0,`W_0};
                `m200:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_2,1'b0,`W_0,1'b0,`W_0};
                `m250:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_2,1'b0,`W_5,1'b0,`W_0};
                `m300:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_3,1'b0,`W_0,1'b0,`W_0};
                `m350:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_3,1'b0,`W_5,1'b0,`W_0};
                `m400:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_4,1'b0,`W_0,1'b0,`W_0};
                `m450:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_4,1'b0,`W_5,1'b0,`W_0};
                `m500:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_5,1'b0,`W_0,1'b0,`W_0};
                `m550:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_5,1'b0,`W_5,1'b0,`W_0};
                `m600:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_6,1'b0,`W_0,1'b0,`W_0};
                `m650:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_6,1'b0,`W_5,1'b0,`W_0};
                `m700:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_7,1'b0,`W_0,1'b0,`W_0};
                `m750:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_7,1'b0,`W_5,1'b0,`W_0};
                `m800:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_8,1'b0,`W_0,1'b0,`W_0};
                `m850:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_8,1'b0,`W_5,1'b0,`W_0};
                `m900:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_9,1'b0,`W_0,1'b0,`W_0};
                `m950:  stanNaLiczby = {1'b0,`W_0,1'b1,`W_9,1'b0,`W_5,1'b0,`W_0};
                `m1000:  stanNaLiczby = {1'b0,`W_1,1'b1,`W_0,1'b0,`W_0,1'b0,`W_0};
            endcase
        end
    endfunction
    
    always @(panel_przyciskow_in)
        #1 begin
            if (panel_przyciskow_in == `CMD_RESET && cmd_in === 2'bXX) // automat nic nie robi - reset pocz�tkowy
                begin
                    // ustawienia poczatkowe
                    stan_top = 0;
                    stan_n = 0;
                    kubek = `STAN_ZEROWY;
                    woda = `STAN_ZEROWY;
                    kawa = `STAN_ZEROWY;
                    mleko = `STAN_ZEROWY;
                    cmd_out = `CMD_RESET;       // resetujemy modu� monet
                    licz_out = `LICZNIK_RESET;  // resetujemy licznik
                    // reset wyswietlacza
                    L_1 = 5'b00000;
                    L_2 = 5'b00000;
                    L_3 = 5'b00000;
                    L_4 = 5'b00000;
                end
            if (sprawnosc_in == 1'b0) begin     // sterowanie dost�pne tylko w przypadku sprawnej maszyny
                case (panel_przyciskow_in)
                    `CMD_OP1: // wci�ni�to przycisk wyboru opcji 1
                        if(cmd_in == `ODP_NIC)   // je�li modu� nic nie robi
                            begin
                                cmd_out = `CMD_OP1; // rozpoczynamy pob�r monet
                                stan_n = `POBIERAM;
                            end
                    `CMD_OP2: // wci�ni�to przycisk wyboru opcji 2
                        if(cmd_in == `ODP_NIC)   // je�li modu� nic nie robi
                            begin
                                cmd_out = `CMD_OP2; // rozpoczynamy pob�r monet
                                stan_n = `POBIERAM;
                            end
                    `CMD_OP3: // wci�ni�to przycisk wyboru opcji 3
                        if(cmd_in == `ODP_NIC)   // je�li modu� nic nie robi
                            begin
                                cmd_out = `CMD_OP3; // rozpoczynamy pob�r monet
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
            stan_top <= stan_n;
        end
        always @(posedge clk_div)  // g�owna cz��
            begin
                stan_n <= stan_top;
                case (stan_top)
                    `CZEKAM:     
                        begin // NIC SIE NIE DZIEJE - PUSTY WYSWIETLACZ
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b0,`W_NULL,1'b0,`W_NULL,1'b0,`W_NULL};
                        end
                    `POBIERAM:   // pobieram op�at�
                        begin
                            {L_1,L_2,L_3,L_4} <= stanNaLiczby(stan_mm);
                        end
                    `ZWRACAM:
                        begin
                            case (L_1) // WIRUJ�CE OKR�GI NA WY�WIETLACZU - ZWROT PIENI�DZY
                                default: {L_1,L_2,L_3,L_4} <= {1'b0,`W_UM,1'b0,`W_MM,1'b0,`W_UM,1'b0,`W_MM}; 
                                `W_UM: {L_1,L_2,L_3,L_4} <= {1'b0,`W_UL,1'b0,`W_UR,1'b0,`W_UL,1'b0,`W_UR};
                                `W_UL: {L_1,L_2,L_3,L_4} <= {1'b0,`W_MM,1'b0,`W_UM,1'b0,`W_MM,1'b0,`W_UM};
                                `W_MM: {L_1,L_2,L_3,L_4} <= {1'b0,`W_UR,1'b0,`W_UL,1'b0,`W_UR,1'b0,`W_UL};
                            endcase
                        end
                        
                endcase
            end
        always @(negedge clk_div)
            begin
                if ((cmd_out == `CMD_RESET || cmd_out == `CMD_RESET1 || cmd_out == `CMD_RESET2 || cmd_out == `CMD_RESET3) && cmd_in == `ODP_NIC) 
                    begin
                        cmd_out <= `CMD_NIC;        // zerowanie linii komend po wst�pnym resecie
                        licz_out <= `LICZNIK_NULL;  // zerowanie linii komend licznika po wstepnym resecie
                    end
                stan_top <= stan_n;
            end
endmodule