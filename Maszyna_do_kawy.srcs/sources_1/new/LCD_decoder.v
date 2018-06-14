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
    input CLK_250KHz,
    input [7:0] in_data,
    output reg sprawnosc,
    output reg [8:0] lcd_out,
    output wire WR
    );

    reg [16*8:1] linia_1 = "                ";
    reg [16*8:1] linia_2 = "                ";
    
    reg [4:0]znak = 5'd0;
    reg wiersz = 1'b0;
    reg [6:0]step = 7'd0;
    
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
            
            case (step)
                7'd0: begin //init
                    znak = 5'd0;
                    wiersz = 1'b0;
                    // czyœcimy lcd
                    lcd_out <= {1'b0, 8'h10};
                end 
                7'd1: begin //pierwszy wiersz
                    lcd_out <= {1'b0, 8'h80};
                end
                7'd2: begin //1-1
                    lcd_out <= {1'b1, linia_1[1*8 : (1*8)-7] };
                end
                7'd3: begin //2-1
                    lcd_out <= {1'b1, linia_1[2*8 : (2*8)-7] };
                end
                7'd4: begin //3-1
                    lcd_out <= {1'b1, linia_1[3*8 : (3*8)-7] };
                end
                7'd5: begin //4-1
                    lcd_out <= {1'b1, linia_1[4*8 : (4*8)-7] };
                end
                7'd6: begin //5-1
                    lcd_out <= {1'b1, linia_1[5*8 : (5*8)-7] };
                end
                7'd7: begin //6-1
                    lcd_out <= {1'b1, linia_1[6*8 : (6*8)-7] };
                end
                7'd8: begin //7-1
                    lcd_out <= {1'b1, linia_1[7*8 : (7*8)-7] };
                end
                7'd9: begin //8-1
                    lcd_out <= {1'b1, linia_1[8*8 : (8*8)-7] };
                end
                7'd10: begin //9-1
                    lcd_out <= {1'b1, linia_1[9*8 : (9*8)-7] };
                end
                7'd11: begin //10-1
                    lcd_out <= {1'b1, linia_1[10*8 : (10*8)-7] };
                end
                7'd12: begin //11-1
                    lcd_out <= {1'b1, linia_1[11*8 : (11*8)-7] };
                end
                7'd13: begin //12-1
                    lcd_out <= {1'b1, linia_1[12*8 : (12*8)-7] };
                end
                7'd14: begin //13-1
                    lcd_out <= {1'b1, linia_1[13*8 : (13*8)-7] };
                end
                7'd15: begin //14-1
                    lcd_out <= {1'b1, linia_1[14*8 : (14*8)-7] };
                end
                7'd16: begin //15-1
                    lcd_out <= {1'b1, linia_1[15*8 : (15*8)-7] };
                end
                7'd17: begin //16-1
                    lcd_out <= {1'b1, linia_1[16*8 : (16*8)-7] };
                end
                7'd18: begin //drugi wiersz
                    lcd_out <= {1'b0, 8'hC0};
                end
                7'd19: begin //1-1
                    lcd_out <= {1'b1, linia_2[1*8 : (1*8)-7] };
                end
                7'd20: begin //2-1
                    lcd_out <= {1'b1, linia_2[2*8 : (2*8)-7] };
                end
                7'd21: begin //3-1
                    lcd_out <= {1'b1, linia_2[3*8 : (3*8)-7] };
                end
                7'd22: begin //4-1
                    lcd_out <= {1'b1, linia_2[4*8 : (4*8)-7] };
                end
                7'd23: begin //5-1
                    lcd_out <= {1'b1, linia_2[5*8 : (5*8)-7] };
                end
                7'd24: begin //6-1
                    lcd_out <= {1'b1, linia_2[6*8 : (6*8)-7] };
                end
                7'd25: begin //7-1
                    lcd_out <= {1'b1, linia_2[7*8 : (7*8)-7] };
                end
                7'd26: begin //8-1
                    lcd_out <= {1'b1, linia_2[8*8 : (8*8)-7] };
                end
                7'd27: begin //9-1
                    lcd_out <= {1'b1, linia_2[9*8 : (9*8)-7] };
                end
                7'd28: begin //10-1
                    lcd_out <= {1'b1, linia_2[10*8 : (10*8)-7] };
                end
                7'd29: begin //11-1
                    lcd_out <= {1'b1, linia_2[11*8 : (11*8)-7] };
                end
                7'd30: begin //12-1
                    lcd_out <= {1'b1, linia_2[12*8 : (12*8)-7] };
                end
                7'd31: begin //13-1
                    lcd_out <= {1'b1, linia_2[13*8 : (13*8)-7] };
                end
                7'd32: begin //14-1
                    lcd_out <= {1'b1, linia_2[14*8 : (14*8)-7] };
                end
                7'd33: begin //15-1
                    lcd_out <= {1'b1, linia_2[15*8 : (15*8)-7] };
                end
                7'd34: begin //16-1
                    lcd_out <= {1'b1, linia_2[16*8 : (16*8)-7] };
                end

            endcase
            
                step <= (step == 34 ? 0 : step + 1);
        end
    // komendy lcd:
    // 01 - czyszczenie
    // 80 - pierwszy wiersz, pierwsza kolumna
    // C0 - drugi wiersz, pierwsza koluman
    assign WR = 1'b0; // write
endmodule
