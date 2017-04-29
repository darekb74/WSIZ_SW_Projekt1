`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Darek B.
// 
// Create Date: 27.04.2017 18:45:34
// Design Name: 
// Module Name: modul_monet
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 2.01 - wersja II - inne podejscie do problemu 
// Additional Comments:
// 
/*
    ZASADY DZIA�ANIA MODU�U:
    AUTOMAT ROZPOCZYNA PRAC� W STANIE 'NIC' - NA LINIECH WYJ�� MAMY:
     [LINIA]    [STAN]    
    CMD_OUT -> ODP_NIC (WYJ�CIE DO MODU�U G��WNEGO)
    MON_OUT -> Z0G00   (WYJ�CIE DO WYRZUTNIKA BILONU)
    MODU� CZEKA NA KOMEDN� Z MODU�U G��WNEGO OZNAJMIAJ�C� CO
    KLIENT WYBRA� (JAK� OPCJ� ZAKUPU). W TYM STANIE W PRZYPADKU
    OTRZYMANIA SYGNA�U Z WRZUTYNIKA BILONU MONETA ZWRACANA JEST
    AUTOMATYCZNIE DO WYRZYTNIKA.
    W PRZYPADKU OTRZYMANIA KOMENDY WYBORU OPCJI USTAWIANY JEST STAN
    ODPOWIADAJ�CY CENIE WYBRANEJ OPCJI.
    KOMENDY WYBORU TO:
    CMD_OP1, CMD_OP2, CMD_OP3
    W TYM MOMENCIE USTAWIANY JEST TAK�E SYGNA� NA LINII CMD_OUT: ODP_W_TOKU.
    WRZUCANIE MONET GENERUJE SYGNALY NA LINII MON_IN, KT�RE ZMNIEJSZAJ�
    STAN AUTOMATU DO CZASU OSI�GNI�CIA STANU Z0G00 - NADWY�KA ZOSTAJE
    ZWR�CONA PRZEZ WYRZUTNIK BILONU
    ZAKO�CZENIE PROCESU POBORU OP�ATY SYGNALIZOWANE JEST ZMIAN� SYGNA�U
    NA LINI CMD_OUT NA ODP_OK (PO CHWILI ZMIENIONY NA ODP_NIC)
    
    W DOWOLNYM MOMENCIE OTRZYMANIE SYGNALU NA LINI CMD_IN: CMD_RESET
    POWODUJE WYRZUCENIE WSZYSTKICH WRZUCONYCH (JE�LI TAKIE S�) MONET PRZEZ
    WYRZUTNIK BIOLONU, NA LINII CMD_OUT USTAWIANY JEST DO CZASU SKO�CZENIA
    ZWRACANIA SYGNA� ODP_ZWROT. PO ZAKO�CZENIU SYGNA� ZMIANIAMY NA ODP_RESET
    (PO CHWILI ZMIENIONY NA ODP_NIC) I USTAWIONY ZOSTAJE STAN
    POCZ�TKOWY AUTOMATU 'NIC'.
 */ 
//////////////////////////////////////////////////////////////////////////////////


module modul_monet(
    input wire clk,                     // zegar
    input wire [2:0] mon_in,            // wrzut monet
    output reg [2:0] mon_out,           // zwrot monet
    input wire [2:0] cmd_in,            // komenda: 0-nic,  1- zakup opcja1, 2- zakup opcja2, 3-zakup opcja3, 4-reset (pelen zwrot)
    output reg [1:0] cmd_out//,            // odpowiedz na komend�
    //output reg [4:0] stan // debug
    );
    
    reg [4:0] stan;
    // sygna�y
    localparam [1:0] ODP_NIC    = 2'b00;
    localparam [1:0] ODP_W_TOKU = 2'b01;
    localparam [1:0] ODP_ZWROT  = 2'b10;
    localparam [1:0] ODP_OK     = 2'b11;
    localparam [1:0] ODP_RESET  = 2'b11;

    localparam [2:0] CMD_NIC    = 3'b000;
    localparam [2:0] CMD_OP1    = 3'b001;
    localparam [2:0] CMD_OP2    = 3'b010;
    localparam [2:0] CMD_OP3    = 3'b011;
    localparam [2:0] CMD_RESET  = 3'b100;
    // konieczne
    localparam [2:0] CMD_RESET1  = 3'b101;
    localparam [2:0] CMD_RESET2  = 3'b110;
    localparam [2:0] CMD_RESET3  = 3'b111;    

    // stany
    localparam [4:0]NIC   = 5'b00000;      // bezczynnosc
    localparam [4:0]m050  = 5'b00001;      // 50 groszy
    localparam [4:0]m100  = 5'b00010;      // 1 z�
    localparam [4:0]m150  = 5'b00011;      // 1.50 z�
    localparam [4:0]m200  = 5'b00100;      // 2 z�
    localparam [4:0]m250  = 5'b00101;      // 2.50 z�
    localparam [4:0]m300  = 5'b00110;      // 3 z�
    localparam [4:0]m350  = 5'b00111;      // 3.50 z�
    localparam [4:0]m400  = 5'b01000;      // 4 z�
    localparam [4:0]m450  = 5'b01001;      // 4.50 z�
    localparam [4:0]m500  = 5'b01010;      // 5 z�
    localparam [4:0]m550  = 5'b01011;      // 5.50 z�
    localparam [4:0]m600  = 5'b01100;      // 6 z�
    localparam [4:0]m650  = 5'b01101;      // 6.50 z�
    localparam [4:0]m700  = 5'b01110;      // 7.00 z�
    localparam [4:0]m750  = 5'b01111;      // 7.50 z�
    localparam [4:0]m800  = 5'b10000;      // 8.00 z�
    localparam [4:0]m850  = 5'b10001;      // 8.50 z�
    localparam [4:0]m900  = 5'b10010;      // 9.00 z�
    localparam [4:0]m950  = 5'b10011;      // 9.50 z�
    localparam [4:0]m1000 = 5'b10100;      // 10.00 z�    
    
	parameter CENA_OP1 = m300;				// cena opcji 1 (3.00z� - expresso)
    parameter CENA_OP2 = m500;              // cena opcji 2 (5.00z� - expresso grande :P )
    parameter CENA_OP3 = m750;              // cena opcji 3 (7.50z� - cappucino :P )
    
    reg [4:0]n_stan;        // nast�pny stan - ZMIENNA TYMCZASOWA
   
    // typy monet
    localparam [2:0]z0g00 = 3'b000;      // brak monety - stan zerowy
    localparam [2:0]z0g50 = 3'b001;      // 50 groszy
    localparam [2:0]z1g00 = 3'b010;      // 1 z�
    localparam [2:0]z2g00 = 3'b011;      // 2 z�
    localparam [2:0]z5g00 = 3'b100;      // 5 z�
    
    initial
        begin // zerujemy
            stan = NIC;
            n_stan = NIC;
            cmd_out = 2'b00;
            mon_out = 3'b000;
        end

    always @(cmd_in) // otrzymali�my komend�
       begin
                n_stan = stan;  // ustawiamy nast�pny stan na starty gdyby stan nie uleg� zmianie (p�telka)
                    case (cmd_in)
                        CMD_OP1:
                            begin
                                n_stan = CENA_OP1; // stan na cen� zakupou opcji 1
                                cmd_out = ODP_W_TOKU;
                                // $display("[disp:op1] stan:%5b, cmd_out:%5b @ %0t", stan, cmd_out, $time);
                            end
                        CMD_OP2:
                            begin
                                n_stan = CENA_OP2; // stan na cen� zakupou opcji 2
                                cmd_out = ODP_W_TOKU;
                            end
                        CMD_OP3:
                            begin
                                n_stan = CENA_OP3; // stan na cen� zakupou opcji 3
                                cmd_out = ODP_W_TOKU;
                            end
                        CMD_RESET1:  // rezygnujemy z zakupu opcji 3
                            if (cmd_out == ODP_W_TOKU)  // je�li wybrali�my juz opcj�
                                begin
                                    cmd_out = ODP_ZWROT;    // rozpoczynamy zwrot
                                    n_stan = CENA_OP1-stan;
                                end
                        CMD_RESET2:  // rezygnujemy z zakupu opcji 2
                             if (cmd_out == ODP_W_TOKU)  // je�li wybrali�my juz opcj�
                                begin
                                    cmd_out = ODP_ZWROT;    // rozpoczynamy zwrot
                                    n_stan = CENA_OP2-stan;
                                end
                        CMD_RESET3:  // rezygnujemy z zakupu opcji 3
                             if (cmd_out == ODP_W_TOKU)  // je�li wybrali�my juz opcj�
                                begin
                                    cmd_out = ODP_ZWROT;    // rozpoczynamy zwrot
                                    n_stan = CENA_OP3-stan;
                                end
                    endcase
                    stan = n_stan;  // zminiamy stan
                end
                
    always @(mon_in != z0g00)
        #1 begin
            case (stan)
                NIC:
                    begin
                        //wrzucono monet� ale jestesmy w stanie pocz�tkowym albo ju� nie trzeba nic wrzuca�
                         mon_out <= mon_in; // zwracamy monet�
                         n_stan <= NIC;  // stan nie ulega zmianie
                    end
                 m050:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 50 groszy
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        begin
                                            n_stan <= NIC; // wrzucono 50 groszy i tyle brakowa�o
                                            cmd_out <= ODP_OK; // informujemy MG, �e wszystko ok
                                        end
                                    z1g00:
                                        begin
                                            n_stan <= m050; // wrzucono 1 z�, brakowa�o 50 groszy
                                            mon_out <= z0g50; // zwrot 50 groszy
                                            cmd_out <= ODP_OK; // informujemy MG, �e wszystko ok
                                        end                                        
                                    z2g00:
                                        begin
                                            n_stan <= m050; // wrzucono 2 z�, brakowa�o 50 groszy
                                            mon_out <= z1g00; // zwrot 1.00 z�
                                            cmd_out <= ODP_ZWROT; // informujemy MG, �e pozosta�o co� do zwrotu
                                        end                                        
                                    z5g00:
                                        begin
                                            n_stan <= m250; // wrzucono 5 z�, brakowa�o 50 groszy
                                            mon_out <= z2g00; // zwrot 2.00 z�
                                            cmd_out <= ODP_ZWROT; // informujemy MG, �e pozosta�o co� do zwrotu
                                        end                                        
                                endcase
                          endcase
                    end
                 m100:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 1 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan <= stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                         n_stan <= m050; // wrzucono 50 groszy 
                                    z1g00:
                                        begin
                                            n_stan <= NIC; // wrzucono 1 z� i tyle brakowa�o
                                            cmd_out <= ODP_OK; // informujemy MG, �e wszystko ok
                                        end                                        
                                    z2g00:
                                        begin
                                            n_stan <= NIC; // wrzucono 2 z�, brakowa�o 1 z�
                                            mon_out <= z1g00; // zwrot 1.00 z�
                                            cmd_out <= ODP_OK; // informujemy MG, �e wszyswtko ok
                                        end                                        
                                    z5g00:
                                        begin
                                            n_stan <= m200; // wrzucono 5 z�, brakowa�o 1 z�
                                            mon_out <= z2g00; // zwrot 2.00 z�
                                            cmd_out <= ODP_ZWROT; // informujemy MG, �e pozosta�o co� do zwrotu
                                        end                                        
                                endcase
                          endcase
                    end
                 m150:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan = stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 1.50 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m100; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m050; // wrzucono 1 z�, brakowa�o 1,50 z�
                                    z2g00:
                                        begin
                                            n_stan <= NIC; // wrzucono 2 z�, brakowa�o 1.50 z�
                                            mon_out <= z0g50; // zwrot 50 groszy
                                            cmd_out <= ODP_OK; // informujemy MG, �e wszyswtko ok
                                        end                                        
                                    z5g00:
                                        begin
                                            n_stan <= m150; // wrzucono 5 z�, brakowa�o 1.50 z�
                                            mon_out <= z2g00; // zwrot 2.00 z�
                                            cmd_out <= ODP_ZWROT; // informujemy MG, �e pozosta�o co� do zwrotu
                                        end                                        
                                endcase
                          endcase
                    end
                 m200:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 2 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m150; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m100; // wrzucono 1 z� i tyle brakowa�o
                                    z2g00:
                                        begin
                                            n_stan <= NIC; // wrzucono 2 z� i tyle brakowa�o
                                            cmd_out <= ODP_OK; // informujemy MG, �e wszyswtko ok
                                        end                                        
                                    z5g00:
                                        begin
                                            n_stan <= m100; // wrzucono 5 z�, brakowa�o 2 z�
                                            mon_out <= z2g00; // zwrot 2.00 z�
                                            cmd_out <= ODP_ZWROT; // informujemy MG, �e wszystko OK
                                        end                                        
                                endcase
                          endcase
                    end
                 m250:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 2,50 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m200; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m150; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m050; // wrzucono 2 z� 
                                    z5g00:
                                        begin
                                            n_stan <= m050; // wrzucono 5 z�, brakowa�o 2,50 z�
                                            mon_out <= z2g00; // zwrot 2.00 z�
                                            cmd_out <= ODP_ZWROT; // informujemy MG, �e pozosta�o co� do zwrotu
                                        end                                        
                                endcase
                          endcase
                    end
                 m300:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 3 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m250; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m200; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m100; // wrzucono 2 z� 
                                    z5g00:
                                        begin
                                            n_stan <= NIC; // wrzucono 5 z�, brakowa�o 3,00 z�
                                            mon_out <= z2g00; // zwrot 2.00 z�
                                            cmd_out <= ODP_OK; // informujemy MG, �e wszystko ok
                                        end                                        
                                endcase
                          endcase
                    end
                 m350:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 3,50 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m300; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m250; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m150; // wrzucono 2 z� 
                                    z5g00:
                                        begin
                                            n_stan <= m050; // wrzucono 5 z�, brakowa�o 3,50 z�
                                            mon_out <= z1g00; // zwrot 1.00 z�
                                            cmd_out <= ODP_ZWROT; // informujemy MG, �e pozosta�o co� do zwrotu
                                        end                                        
                                endcase
                          endcase
                    end
                 m400:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 4 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m350; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m300; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m200; // wrzucono 2 z� 
                                    z5g00:
                                        begin
                                            n_stan <= NIC; // wrzucono 5 z�, brakowa�o 4 z�
                                            mon_out <= z1g00; // zwrot 1.00 z�
                                            cmd_out <= ODP_OK; // informujemy MG, �e wszystko ok
                                        end                                        
                                endcase
                          endcase
                    end
                 m450:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan = stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 4,50 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m400; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m350; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m250; // wrzucono 2 z� 
                                    z5g00:
                                        begin
                                            n_stan <= NIC; // wrzucono 5 z�, brakowa�o 4,50 z�
                                            mon_out <= z0g50; // zwrot0,50 z�
                                            cmd_out <= ODP_OK; // informujemy MG, �e wszystko ok
                                        end                                        
                                endcase
                          endcase
                    end
                 m500:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 5 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m450; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m400; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m300; // wrzucono 2 z� 
                                    z5g00:
                                        begin
                                            n_stan <= NIC; // wrzucono 5 z�, brakowa�o 4 z�
                                            cmd_out <= ODP_OK; // informujemy MG, �e wszystko ok
                                        end                                        
                                endcase
                          endcase
                    end
                 m550:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 5,50 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m500; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m450; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m350; // wrzucono 2 z� 
                                    z5g00:
                                        n_stan <= m050; // wrzucono 5 z�
                                endcase
                          endcase
                    end
                 m600:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 6 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m550; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m500; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m400; // wrzucono 2 z� 
                                    z5g00:
                                        n_stan <= m100; // wrzucono 5 z�
                                endcase
                          endcase
                    end
                 m650:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 6,50 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m600; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m550; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m450; // wrzucono 2 z� 
                                    z5g00:
                                        n_stan <= m150; // wrzucono 5 z�
                                endcase
                          endcase
                    end
                 m700:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 7 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m650; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m600; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m500; // wrzucono 2 z� 
                                    z5g00:
                                        n_stan <= m200; // wrzucono 5 z�
                                endcase
                          endcase
                    end
                 m750:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 7,50 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m700; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m650; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m550; // wrzucono 2 z� 
                                    z5g00:
                                        n_stan <= m250; // wrzucono 5 z�
                                endcase
                          endcase
                    end
                 m800:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 8 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m750; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m700; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m600; // wrzucono 2 z� 
                                    z5g00:
                                        n_stan <= m300; // wrzucono 5 z�
                                endcase
                          endcase
                    end
                 m850:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 8,50 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m800; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m750; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m650; // wrzucono 2 z� 
                                    z5g00:
                                        n_stan <= m350; // wrzucono 5 z�
                                endcase
                          endcase
                    end
                 m900:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 9 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m850; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m800; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m700; // wrzucono 2 z� 
                                    z5g00:
                                        n_stan <= m400; // wrzucono 5 z�
                                endcase
                          endcase
                    end
                 m950:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy jeszce 9,50 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m900; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m850; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m750; // wrzucono 2 z� 
                                    z5g00:
                                        n_stan <= m450; // wrzucono 5 z�
                                endcase
                          endcase
                    end
                 m1000:
                    begin
                        case(cmd_out)
                            ODP_ZWROT:  // sytuacja, w kt�rej zwracamy pieni�dze, a ktos wrzuci� nast�pn� monet�
                                begin
                                    mon_out <= mon_in;  // zwracamy monet�
                                    n_stan <= stan;      // stan pozostaje bez zmian.
                                end
                            ODP_W_TOKU: // potrzebujemy 10 z�
                                case (mon_in)
                                    z0g00:
                                        n_stan<=stan; // wrzucono 0 groszy O_o - nic nie robimy
                                    z0g50:
                                        n_stan <= m950; // wrzucono 50 groszy 
                                    z1g00:
                                        n_stan <= m900; // wrzucono 1 z� 
                                    z2g00:
                                        n_stan <= m800; // wrzucono 2 z� 
                                    z5g00:
                                        n_stan <= m500; // wrzucono 5 z�
                                endcase
                          endcase
                    end
             endcase
        end
        always @(clk)
           #2 begin
                if (cmd_out == ODP_ZWROT && mon_in == z0g00 && mon_out == z0g00) begin // tutaj zwracamuy pieni�dze
                    case (stan)
                        NIC:
                            cmd_out <= ODP_OK; // tak na wszelki wypadek - do p�niej usuni�cia
                        m450:   // 450 do zwrotu (maksumalna ilo��)
                            begin
                                mon_out <= z2g00;   // zwracamy 2 z�
                                n_stan <= m250;     // pozosta�o 2,50 z� do zwrotu
                            end
                        m400:
                            begin
                                mon_out <= z2g00;   // zwracamy 2 z�
                                n_stan <= m200;     // pozosta�o 2 z� do zwrotu
                            end
                        m350:
                            begin
                                mon_out <= z2g00;   // zwracamy 2 z�
                                n_stan <= m150;     // pozosta�o 1,50 z� do zwrotu
                            end
                        m300:
                            begin
                                mon_out <= z2g00;   // zwracamy 2 z�
                                n_stan <= m100;     // pozosta�o 1 z� do zwrotu
                            end
                        m250:
                            begin
                                mon_out <= z2g00;   // zwracamy 2 z�
                                n_stan <= m050;     // pozosta�o 50 gr do zwrotu
                            end
                        m200:
                            begin
                                n_stan <= NIC;      // stan zerowy - koniec zwrotu
                                mon_out <= z2g00;   // zwracamy 2 z�
                                cmd_out <= ODP_OK;  // koniec zwrotu - informujemy mod� g��wny
                            end
                        m150:
                            begin
                                n_stan <= m050;
                                mon_out <= z1g00;   // zwracamy 1 z�
                            end
                        m100:
                            begin
                                n_stan <= NIC;      // stan zerowy - koniec zwrotu
                                mon_out <= z1g00;   // zwracamy 1 z�
                                cmd_out <= ODP_OK;  // koniec zwrotu - informujemy mod� g��wny
                            end
                        m050:
                            begin
                                n_stan <= NIC;      // stan zerowy - koniec zwrotu
                                mon_out <= z0g50;   // zwracamy 50 gr
                                cmd_out <= ODP_OK;  // koniec zwrotu - informujemy mod� g��wny
                            end
                    endcase
                end
                #10 if (cmd_out == ODP_OK) cmd_out = ODP_NIC; // koniec wrzutu lub zwrotu - mod� w stanie zero
                #11 if (mon_out != z0g00) mon_out = z0g00; // po 10ns zerujemy sygna� zwrotu monety
                
            end

    always @(*)
        #3 begin
            stan = n_stan;      // ustawiamy nast�pny stan
        end      
endmodule
