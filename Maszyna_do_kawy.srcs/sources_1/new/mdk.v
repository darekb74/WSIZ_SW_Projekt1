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
    input wire [6:0] count_secs,            // potrzebne do wy�wietlacza - ilo�� pozosta�ych sekund                    
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
    output reg [2:0]urzadzenia              // sterowanie urz�dzeniami
                                            // 000 - nic nie pracuje
    //output reg kubek,                     // 001 - podstawienie kubka
    //output reg woda,                      // 010 - w��czanie dozowania wody
    //output reg kawa,                      // 011 - w��czanie m�ynka do kawy
    //output reg mleko                      // 100 - w��czanie dozowania mleka (spieniacz)
    );
    
    
    parameter CENA_OP1 = `m300;				// cena opcji 1 (3.00z� - expresso)
    parameter CENA_OP2 = `m500;				// cena opcji 2 (5.00z� - expresso grande :P )
    parameter CENA_OP3 = `m750;				// cena opcji 3 (7.50z� - cappucino :P )
    
    parameter tick_every = 20;              // pozwoli dostosowa� czasy do zegaru (oraz przyspieszy� symulacj� ;] )

    // ��czymy modu�y
    // pod��czamy modu� monet
    modul_monet #(.CENA_OP1(CENA_OP1), .CENA_OP2(CENA_OP2), .CENA_OP3(CENA_OP3)) wrzut_zwrot(.clk(clk_div), .cmd_in(cmd_out), .cmd_out(cmd_in), .stan_mm(stan_mm));
    // pod��czamy modu� sprawnosci
    sprawnosc spr_test(.signal_s(sprawnosc_in));
    // pod��czamy modu� licznika
    counter #(.tick_every(tick_every)) licznik(.clk(clk_div), .count_out(licz_in), .count_in(licz_out), .count_secs(count_secs));
    // pod��czamy modu� wy�wietlacza
    wyswietlacz_4x7seg wys_pan(.clk(clk), .L_1(L_1), .L_2(L_2), .L_3(L_3), .L_4(L_4));
    // pod��czamy dzielnik cz�stotliwo�ci
    divider #(1) div(.clk(clk), .clk_div(clk_div));

    reg [5:0]stan_top, stan_n;              // stan i nast�pny stan modu�u g��wnego
    
    function [9:0]licznikNaLiczby;
        input reg [6:0] count_secs;
        integer a,b;
        begin
            b = count_secs / 10;
            a = count_secs - (b*10);
            licznikNaLiczby = {b[4:0],a[4:0]};
            $strobe("strobe  count_secs:%b(%0d) a:%b(%0d) b:%b(%0d) @ %0t", count_secs, count_secs, b[4:0], b[4:0], a[4:0], a[4:0], $time);
        end
    endfunction 
    
    
    always @(panel_przyciskow_in)
        #1 begin
            if (panel_przyciskow_in == `CMD_RESET && cmd_in === 2'bXX) // automat nic nie robi - reset pocz�tkowy
                begin
                    // ustawienia poczatkowe
                    stan_top = 0;
                    stan_n = 0;
                    urzadzenia = `NIC;
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
        always @(licz_in)
            begin
                if (licz_in == `SKONCZYLEM_ODLICZAC)
                    begin
                        case (stan_top)
                            `NAPELNIJ_PRZEWODY: begin stan_n = `PODSTAW_KUBEK; licz_out <= `ODLICZ_KUBEK; urzadzenia <= `CMD_PODSTAW_KUBEK; end
                            `PODSTAW_KUBEK: 
                                begin
                                    stan_n = `ZMIEL_KAWE;
                                    case(cmd_out)
                                        `CMD_OP1: begin licz_out <= `ODLICZ_KAWA_OP1; end
                                        `CMD_OP2: begin licz_out <= `ODLICZ_KAWA_OP2; end
                                        `CMD_OP3: begin licz_out <= `ODLICZ_KAWA_OP3; end
                                    endcase
                                    urzadzenia <= `CMD_ZMIEL_KAWE;
                                end
                            `ZMIEL_KAWE:
                                begin
                                    stan_n = `DODAJ_WODE;
                                    case(cmd_out)
                                        `CMD_OP1: begin licz_out <= `ODLICZ_WODA_OP1; end
                                        `CMD_OP2: begin licz_out <= `ODLICZ_WODA_OP2; end
                                        `CMD_OP3: begin licz_out <= `ODLICZ_WODA_OP3; end
                                    endcase
                                    urzadzenia <= `CMD_DODAJ_WODE;
                                end
                            `DODAJ_WODE:
                                begin
                                    case(cmd_out)
                                        `CMD_OP1: begin stan_n = `CZYSC_MASZYNE; licz_out <= `ODLICZ_CZYSC; urzadzenia <= `CMD_CZYSC_MASZYNE; end
                                        `CMD_OP2: begin stan_n = `CZYSC_MASZYNE; licz_out <= `ODLICZ_CZYSC; urzadzenia <= `CMD_CZYSC_MASZYNE; end
                                        `CMD_OP3: begin stan_n = `SPIENIAJ_MLEKO; licz_out <= `ODLICZ_MLEKO; urzadzenia <= `CMD_SPIENIAJ_MLEKO; end
                                    endcase
                                end
                            `SPIENIAJ_MLEKO:
                                begin
                                    stan_n = `CZYSC_MASZYNE;
                                    licz_out <= `ODLICZ_CZYSC;
                                    urzadzenia <= `CMD_CZYSC_MASZYNE;
                                end
                            `CZYSC_MASZYNE:
                                begin
                                    stan_n = `CZEKAM;
                                    licz_out <= `LICZNIK_NULL;
                                    urzadzenia <= `CMD_ZERO;
                                end
                        endcase
                    end
                stan_top <= stan_n;       
            end
        always @(cmd_in) // odpowied� z modu�u monet
            begin
                stan_n = stan_top;
                case (stan_top)
                    `POBIERAM:
                        begin
                            if ( cmd_in == `ODP_OK) // zko�czono pob�r op�aty gdy brak resetu
                                begin 
                                    stan_n <= `NAPELNIJ_PRZEWODY;
                                    licz_out <= `ODLICZ_NAPELN;
                                    urzadzenia <= `CMD_NAPELNIJ_PRZEWODY;
                                end
                        end
                endcase
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
                            case(stan_mm)
                                `NIC:   {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_0,1'b0,`W_0,1'b0,`W_0};
                                `m050:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_0,1'b0,`W_5,1'b0,`W_0};
                                `m100:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_1,1'b0,`W_0,1'b0,`W_0};
                                `m150:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_1,1'b0,`W_5,1'b0,`W_0};
                                `m200:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_2,1'b0,`W_0,1'b0,`W_0};
                                `m250:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_2,1'b0,`W_5,1'b0,`W_0};
                                `m300:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_3,1'b0,`W_0,1'b0,`W_0};
                                `m350:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_3,1'b0,`W_5,1'b0,`W_0};
                                `m400:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_4,1'b0,`W_0,1'b0,`W_0};
                                `m450:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_4,1'b0,`W_5,1'b0,`W_0};
                                `m500:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_5,1'b0,`W_0,1'b0,`W_0};
                                `m550:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_5,1'b0,`W_5,1'b0,`W_0};
                                `m600:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_6,1'b0,`W_0,1'b0,`W_0};
                                `m650:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_6,1'b0,`W_5,1'b0,`W_0};
                                `m700:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_7,1'b0,`W_0,1'b0,`W_0};
                                `m750:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_7,1'b0,`W_5,1'b0,`W_0};
                                `m800:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_8,1'b0,`W_0,1'b0,`W_0};
                                `m850:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_8,1'b0,`W_5,1'b0,`W_0};
                                `m900:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_9,1'b0,`W_0,1'b0,`W_0};
                                `m950:  {L_1,L_2,L_3,L_4} <= {1'b0,`W_NULL,1'b1,`W_9,1'b0,`W_5,1'b0,`W_0};
                                `m1000: {L_1,L_2,L_3,L_4} <= {1'b0,`W_1,1'b1,`W_0,1'b0,`W_0,1'b0,`W_0};
                            endcase
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
                    `NAPELNIJ_PRZEWODY:     // wype�nianie przewod�w wod�
                        begin
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_MM,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end
                    `PODSTAW_KUBEK:         // podtsawienie kubka
                        begin
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_1,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end
                    `ZMIEL_KAWE:            // mielenie kawy
                        begin
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_2,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end
                    `DODAJ_WODE:            // podgrzewanie wody (parzenie kawy)
                        begin
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_3,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end
                    `SPIENIAJ_MLEKO:        // spienianie mleka
                        begin
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_4,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end
                    `CZYSC_MASZYNE:         // usuwanie zu�ytej kawy, p�ukanie instalacji i usuni�cie z przewod�w wody
                        begin
                            {L_1,L_2,L_3,L_4} <= {1'b0,`W_MM,1'b0,`W_MM,licznikNaLiczby(count_secs)};
                        end
                endcase
            end
        always @(negedge clk_div)
            begin
                if ((cmd_out == `CMD_RESET || cmd_out == `CMD_RESET1 || cmd_out == `CMD_RESET2 || cmd_out == `CMD_RESET3) && cmd_in == `ODP_NIC) 
                    begin
                        cmd_out <= `CMD_NIC;        // zerowanie linii komend po wst�pnym resecie
                        licz_out <= `LICZNIK_NULL;  // zerowanie linii komend licznika po wstepnym resecie
                        stan_n = `CZEKAM;          // zerowanie stanu maszyny
                    end
                if (cmd_out == `CMD_NIC && stan_top != `CZEKAM) 
                    stan_n = `CZEKAM; 
                stan_top <= stan_n;
            end
endmodule