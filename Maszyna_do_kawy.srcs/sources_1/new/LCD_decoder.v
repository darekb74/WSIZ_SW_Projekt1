`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2018 10:37:00
// Design Name: 
// Module Name: LCD_decoder
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


module LCD_decoder(
    input clk,
    input [7:0] in_data,
    output reg sprawnosc
    );
    
    // Stringi
    // uszkodzenia
    //string err = "Automat uszkodzony!";
    //string err_bk = "Brak kubkow!";
    reg [16*8:1] linia_1;
    reg [16*8:1] linia_2;
    always @(in_data) 
        begin
            // in_data < 10  -> b³¹d
            // in_data > 10  -> stan + 10
            // b³êdy
            case (in_data)
                1: begin
                    linia_1 = "Brak bilonu.    ";
                    linia_2 = "Przepraszamy.   ";
                end
                2: begin
                    linia_1 = "Brak mleka.     ";
                    linia_2 = "Przepraszamy.   ";
                end
                3: begin
                    linia_1 = "Brak kawy.      ";
                    linia_2 = "Przepraszamy.   ";
                end
                4: begin
                    linia_1 = "Brak wody.      ";
                    linia_2 = "Przepraszamy.   ";
                end
                5: begin
                    linia_1 = "Brak kubkow.    ";
                    linia_2 = "Przepraszamy.   ";
                end
                 
            endcase
            // stany
            case (in_data-10)
                `CZEKAM: begin
                    linia_1 = "Wybierz rodzaj  ";
                    linia_2 = "kawy.           ";
                 end
                `POBIERAM: begin
                    linia_1 = "Wrzuc wymagana  ";
                    linia_2 = "kwote.          ";
                 end                 
                `ZWRACAM: begin
                    linia_1 = "Anulowanie      ";
                    linia_2 = "zamowienia.     ";
                 end
                `PODSTAW_KUBEK: begin
                    linia_1 = "Podstawianie    ";
                    linia_2 = "kubek.          ";
                 end
                `ZMIEL_KAWE: begin
                    linia_1 = "Mielenie kawy.  ";
                    linia_2 = "                ";
                 end
                `DODAJ_WODE: begin
                    linia_1 = "Parzenie kawy.  ";
                    linia_2 = "                ";
                 end
                `SPIENIAJ_MLEKO: begin
                    linia_1 = "Spienianie      ";
                    linia_2 = "mleka.          ";
                 end
                `NAPELNIJ_PRZEWODY: begin
                    linia_1 = "Przygotowanie   ";
                    linia_2 = "urzadzenia.     ";
                 end
                `CZYSC_MASZYNE: begin
                    linia_1 = "Czyszczenie     ";
                    linia_2 = "urzadzenia.     ";
                 end
            endcase           
        end
    always @(clk)
        begin
            if (in_data < 10 )
                sprawnosc = 1'b0; // awaria
            else
                sprawnosc = 1'b1; // ok
        end
endmodule
