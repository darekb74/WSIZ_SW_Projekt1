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
// Revision 2.02 - wersja II - inne podejscie do problemu
// Additional Comments:
// 
/*
    ZASADY DZIA£ANIA MODU£U:
    AUTOMAT ROZPOCZYNA PRACÊ W STANIE 'NIC' - NA LINIECH WYJŒÆ MAMY:
     [LINIA]    [STAN]    
    CMD_OUT -> ODP_NIC (WYJŒCIE DO MODU£U G£ÓWNEGO)
    MON_OUT -> Z0G00   (WYJŒCIE DO WYRZUTNIKA BILONU)
    MODU£ CZEKA NA KOMEDNÊ Z MODU£U G£ÓWNEGO OZNAJMIAJ¥C¥ CO
    KLIENT WYBRA£ (JAK¥ OPCJÊ ZAKUPU). W TYM STANIE W PRZYPADKU
    OTRZYMANIA SYGNA£U Z WRZUTYNIKA BILONU MONETA ZWRACANA JEST
    AUTOMATYCZNIE DO WYRZYTNIKA.
    W PRZYPADKU OTRZYMANIA KOMENDY WYBORU OPCJI USTAWIANY JEST STAN
    ODPOWIADAJ¥CY CENIE WYBRANEJ OPCJI.
    KOMENDY WYBORU TO:
    CMD_OP1, CMD_OP2, CMD_OP3
    W TYM MOMENCIE USTAWIANY JEST TAK¯E SYGNA£ NA LINII CMD_OUT: ODP_W_TOKU.
    WRZUCANIE MONET GENERUJE SYGNALY NA LINII MON_IN, KTÓRE ZMNIEJSZAJ¥
    STAN AUTOMATU DO CZASU OSI¥GNIÊCIA STANU Z0G00 - NADWY¯KA ZOSTAJE
    ZWRÓCONA PRZEZ WYRZUTNIK BILONU
    ZAKOÑCZENIE PROCESU POBORU OP£ATY SYGNALIZOWANE JEST ZMIAN¥ SYGNA£U
    NA LINI CMD_OUT NA ODP_OK (PO CHWILI ZMIENIONY NA ODP_NIC)
    
    W DOWOLNYM MOMENCIE OTRZYMANIE SYGNALU NA LINI CMD_IN: CMD_RESET
    POWODUJE WYRZUCENIE WSZYSTKICH WRZUCONYCH (JEŒLI TAKIE S¥) MONET PRZEZ
    WYRZUTNIK BIOLONU, NA LINII CMD_OUT USTAWIANY JEST DO CZASU SKOÑCZENIA
    ZWRACANIA SYGNA£ ODP_ZWROT. PO ZAKOÑCZENIU SYGNA£ ZMIANIAMY NA ODP_RESET
    (PO CHWILI ZMIENIONY NA ODP_NIC) I USTAWIONY ZOSTAJE STAN
    POCZ¥TKOWY AUTOMATU 'NIC'.
 */ 
//////////////////////////////////////////////////////////////////////////////////


module modul_monet(
    input wire clk,                     // zegar
    input wire [2:0] mon_in,            // wrzut monet
    output reg [2:0] mon_out,           // zwrot monet
    input wire [2:0] cmd_in,            // komenda: 0-nic,  1- zakup opcja1, 2- zakup opcja2, 3-zakup opcja3, 4-reset (pe³en zwrot)
    output reg [1:0] cmd_out            // odpowiedŸ na komendê
    );
    
    // sygna³y
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
    localparam [4:0]NIC   = 5'b00000;      // bezczynnoœæ
    localparam [4:0]m050  = 5'b00001;      // 50 groszy
    localparam [4:0]m100  = 5'b00010;      // 1 z³
    localparam [4:0]m150  = 5'b00011;      // 1.50 z³
    localparam [4:0]m200  = 5'b00100;      // 2 z³
    localparam [4:0]m250  = 5'b00101;      // 2.50 z³
    localparam [4:0]m300  = 5'b00110;      // 3 z³
    localparam [4:0]m350  = 5'b00111;      // 3.50 z³
    localparam [4:0]m400  = 5'b01000;      // 4 z³
    localparam [4:0]m450  = 5'b01001;      // 4.50 z³
    localparam [4:0]m500  = 5'b01010;      // 5 z³
    localparam [4:0]m550  = 5'b01011;      // 5.50 z³
    localparam [4:0]m600  = 5'b01100;      // 6 z³
    localparam [4:0]m650  = 5'b01101;      // 6.50 z³
    localparam [4:0]m700  = 5'b01110;      // 7 z³
    localparam [4:0]m750  = 5'b01111;      // 7.50 z³
    localparam [4:0]m800  = 5'b10000;      // 8 z³
    localparam [4:0]m850  = 5'b10001;      // 8.50 z³
    localparam [4:0]m900  = 5'b10010;      // 9 z³
    localparam [4:0]m950  = 5'b10011;      // 9.50 z³
    localparam [4:0]m1000 = 5'b10100;      // 10 z³    
    
    parameter CENA_OP1 = m300;			   // cena opcji 1 (3.00z³ - expresso)
    parameter CENA_OP2 = m500;             // cena opcji 2 (5.00z³ - expresso grande :P )
    parameter CENA_OP3 = m750;             // cena opcji 3 (7.50z³ - cappuccino :P )

    reg [4:0]stan;                         // aktualny stan    
    reg [4:0]n_stan;                       // nastêpny stan
    reg [4:0]tmp;                          // zmienna tymczasowa potrzebna do obliczeñ
   
    // typy monet
    localparam [2:0]z0g00 = 3'b000;        // brak monety - stan zerowy
    localparam [2:0]z0g50 = 3'b001;        // 50 groszy
    localparam [2:0]z1g00 = 3'b010;        // 1 z³
    localparam [2:0]z2g00 = 3'b011;        // 2 z³
    localparam [2:0]z5g00 = 3'b100;        // 5 z³
    
    initial
        begin // zerujemy
            stan = NIC;
            n_stan = NIC;
            cmd_out = 2'b00;
            mon_out = 3'b000;
            tmp = NIC;
        end

    always @(cmd_in) // otrzymaliœmy komendê
        begin
            n_stan = stan;  // przepisujemy stan do n_stan - potrzebne w przypadku, gdyby stan nie uleg³ zmianie (pêtelka)
            case (cmd_in)
                CMD_OP1:
                    begin
                        n_stan <= CENA_OP1;             // stan na cenê zakupou opcji 1
                        cmd_out <= ODP_W_TOKU;
                    end
                CMD_OP2:
                    begin
                        n_stan <= CENA_OP2;             // stan na cenê zakupou opcji 2
                        cmd_out <= ODP_W_TOKU;
                    end
                CMD_OP3:
                    begin
                        n_stan <= CENA_OP3;             // stan na cenê zakupou opcji 3
                        cmd_out <= ODP_W_TOKU;
                    end
                CMD_RESET1:                             // rezygnujemy z zakupu opcji 3
                    if (cmd_out == ODP_W_TOKU)          // jeœli wybraliœmy juz opcjê
                        begin
                            cmd_out <= ODP_ZWROT;       // rozpoczynamy zwrot
                            n_stan <= CENA_OP1-stan;
                        end
                CMD_RESET2:                             // rezygnujemy z zakupu opcji 2
                    if (cmd_out == ODP_W_TOKU)          // jeœli wybraliœmy juz opcjê
                        begin
                            cmd_out <= ODP_ZWROT;       // rozpoczynamy zwrot
                            n_stan <= CENA_OP2-stan;
                        end
                CMD_RESET3:                             // rezygnujemy z zakupu opcji 3
                    if (cmd_out == ODP_W_TOKU)          // jeœli wybraliœmy juz opcjê
                        begin
                            cmd_out <= ODP_ZWROT;       // rozpoczynamy zwrot
                            n_stan <= CENA_OP3-stan;
                        end
           endcase
        end
    always @(posedge clk)
        begin
            case (cmd_out)
                ODP_ZWROT:                              // jesteœmy w trybie zwrotu
                    if (mon_in != z0g00)                // zwracamy monety, a ktoœ wrzuci³ dodatkow¹ monetê
                        begin
                            n_stan <= stan;             // stan bez zmian
                            mon_out <= mon_in;          // zwracamy monetê
                        end
                    else begin                          // w innym przypadku kontynuujemy zwrot monet 
                        if (stan>m200) begin            // ponad 2 z³ do zwrotu
                            mon_out <= z2g00;           // zwracamy 2 z³
                            n_stan <= stan - m200;      // ustawiamy nastêpny stan
                            end
                        else if (stan == m200) begin    // dok³adnie 2 z³ do zwrotu
                            mon_out <= z2g00;           // zwracamy 2 z³
                            n_stan <= NIC;              // ustawiamy nastêpny stan
                            cmd_out <= ODP_OK;          // informujemy MG, ¿e wszystko OK
                            end
                        else if (stan == m150) begin    // pozosta³o 1,50 do zwrotu
                            mon_out <= z1g00;           // zwracamy 1 z³
                            n_stan <= m050;             // ustawiamy nastêpny stan
                            end
                        else begin
                            case (stan)
                                m050:  mon_out <= z0g50;// pozosta³o 50 gr do zwrotu - zwracamy
                                m100:  mon_out <= z1g00;// pozosta³o 1 z³ do zwrotu - zwracamy
                            endcase
                            n_stan <= NIC;              // ustawiamy nastêpny stan
                            cmd_out <= ODP_OK;          // informujemy MG, ¿e wszystko OK
                            end 
                    end
                ODP_W_TOKU:                             // jesteœmy w trybie op³aty za opcjê
                    begin
                        case (mon_in)                   // jak¹ monetê wrzucono ?
                            default:  tmp = NIC;        // zerujemy w ka¿dym innym przypadku
                            z0g50: tmp = m050;          // 50 groszy
                            z1g00: tmp = m100;          // 1 z³
                            z2g00: tmp = m200;          // 2 z³
                            z5g00: tmp = m500;          // 5z³
                        endcase
                        if (stan > tmp)                 // moneta to za ma³o aby zakoñczyæ pobór op³aty
                            n_stan <= stan - tmp;       // ustawiamy nastêpny stan  
                        else if (stan == tmp)           // moneta wystarczy aby zakoñczyc pobór op³aty
                            begin
                                n_stan <= NIC;          // ustawiamy nastêpny stan
                                cmd_out <= ODP_OK;      // informujemy MG, ¿e wszystko ok
                            end
                        else                            // moneta to za du¿o - trzeba zwróciæ resztê
                            begin
                                n_stan <= tmp - stan;   // ustawiamy nastêpny stan
                                cmd_out <= ODP_ZWROT;   // ustawiamy tryb na zwrot;  
                            end
                    end
                ODP_NIC:
                    if (mon_in != z0g00)                // modu³ nic nie robi a wrzucono monetê
                        begin
                            n_stan <= stan;             // stan bez zmian
                            mon_out <= mon_in;          // zwracamy monetê
                        end
            endcase 
        end
 
    always @(negedge clk)
        begin
            #10 begin
                if (cmd_out == ODP_OK) cmd_out <= ODP_NIC;  // koniec wrzutu lub zwrotu - modu³ w stanie zero
                if (mon_out != z0g00) mon_out <= z0g00;     // po 10ns zerujemy sygna³ zwrotu monety
            end
        end
    always @(*)
        #1 begin
            stan = n_stan;                                  // ustawiamy nastêpny stan
        end 
endmodule
