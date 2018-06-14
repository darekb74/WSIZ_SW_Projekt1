`include "defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: WSIZ Copernicus
// Engineer: Rafa� B., Szymon S., Darek B.
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
    STAN AUTOMATU DO CZASU OSI�GNI�CIA STANU 'NIC' - NADWY�KA ZOSTAJE
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
    input wire [2:0] cmd_in,            // komenda: 0-nic,  1- zakup opcja1, 2- zakup opcja2, 3-zakup opcja3, 4-reset (pe�en zwrot)
    output reg [1:0] cmd_out,           // odpowied� na komend�
    output wire [4:0] stan_mm           // przekazujemy stan - potrzebne do obs�ugi wy�wietlacza
    );
    
  
    parameter CENA_OP1 = `m300;			   // cena opcji 1 (3.00z� - expresso)
    parameter CENA_OP2 = `m500;             // cena opcji 2 (5.00z� - expresso grande :P )
    parameter CENA_OP3 = `m750;             // cena opcji 3 (7.50z� - cappuccino :P )

    reg [4:0]stan;                         // aktualny stan    
    reg [4:0]n_stan;                       // nast�pny stan
    reg [4:0]tmp;                          // zmienna tymczasowa potrzebna do oblicze�

    assign stan_mm = stan;
    
    reg [2:0]cmd_sig = 3'b000;
    
    reg [2:0] out_FIFO [0:10]; // kolejka fifo na 10 monet
    reg [2:0] rcount_FIFO = 3'b000; // marker odczytu
    reg [2:0] wcount_FIFO = 3'b000; // marker zapisu

    task add_FIFO;
        input [2:0] moneta;
        begin
            out_FIFO[wcount_FIFO] = moneta;
            wcount_FIFO = wcount_FIFO+1;
            if (wcount_FIFO > 10)
                wcount_FIFO = 0;
        end
    endtask
    
    function [2:0]get_FIFO;
        input whatever; // (O_o)/ mo�e task by�by lepszy ?
        begin
            if (rcount_FIFO != wcount_FIFO) begin
                get_FIFO = out_FIFO[rcount_FIFO];
                rcount_FIFO = rcount_FIFO+1;
                if (rcount_FIFO > 10)
                    rcount_FIFO = 0;
            end
            else
            begin
                get_FIFO = `z0g00;
            end
        end
    endfunction
    
    reg [2:0]i;
    task fill_FIFO;
        input [4:0] do_zwrotu;
        begin   //max 10 miejsc -> max kwota 36,50 z�
            for (i = 0; i<6; i=i+1) begin 
                if (do_zwrotu>=`m500) begin
                    add_FIFO(`z5g00);
                    do_zwrotu = do_zwrotu - `m500;
                end
            end
            if (do_zwrotu>=`m200) begin
                add_FIFO(`z2g00);
                do_zwrotu = do_zwrotu - `m200;
            end
            if (do_zwrotu>=`m200) begin
                add_FIFO(`z2g00);
                do_zwrotu = do_zwrotu - `m200;
            end
            if (do_zwrotu>=`m100) begin
                add_FIFO(`z1g00);
                do_zwrotu = do_zwrotu - `m100;
            end
            if (do_zwrotu>=`m050) begin
                add_FIFO(`z0g50);
                do_zwrotu = do_zwrotu - `m050;
            end
        end
    endtask
        
    always @(clk or cmd_in)
        begin
            // cmd_in
            if (cmd_sig != cmd_in) // otrzymali�my komend�
                begin
                    n_stan = stan;  // przepisujemy stan do n_stan - potrzebne w przypadku, gdyby stan nie uleg� zmianie (p�telka)
                    case (cmd_in)
                    `CMD_OP1:
                        begin
                            n_stan <= CENA_OP1;             // stan na cen� zakupou opcji 1
                            cmd_out <= `ODP_W_TOKU;
                        end
                    `CMD_OP2:
                        begin
                            n_stan <= CENA_OP2;             // stan na cen� zakupou opcji 2
                            cmd_out <= `ODP_W_TOKU;
                        end
                    `CMD_OP3:
                        begin
                            n_stan <= CENA_OP3;             // stan na cen� zakupou opcji 3
                            cmd_out <= `ODP_W_TOKU;
                        end
                    `CMD_RESET1:                             // rezygnujemy z zakupu opcji 3
                        if (cmd_out == `ODP_W_TOKU)          // je�li wybrali�my juz opcj�
                            begin
                                cmd_out <= `ODP_ZWROT;       // rozpoczynamy zwrot
                                //n_stan <= CENA_OP1-stan;
                                fill_FIFO(CENA_OP1-stan);    // monety do zwrotu
                            end
                    `CMD_RESET2:                             // rezygnujemy z zakupu opcji 2
                        if (cmd_out == `ODP_W_TOKU)          // je�li wybrali�my juz opcj�
                            begin
                                cmd_out <= `ODP_ZWROT;       // rozpoczynamy zwrot
                                //n_stan <= CENA_OP2-stan;
                                fill_FIFO(CENA_OP2-stan);    // monety do zwrotu
                            end
                    `CMD_RESET3:                             // rezygnujemy z zakupu opcji 3
                        if (cmd_out == `ODP_W_TOKU)          // je�li wybrali�my juz opcj�
                            begin
                                cmd_out <= `ODP_ZWROT;       // rozpoczynamy zwrot
                                //n_stan <= CENA_OP3-stan;
                                fill_FIFO(CENA_OP3-stan);    // monety do zwrotu
                            end
                    `CMD_RESET:                         // reset pocz�tkowy
                        if (cmd_out === 2'bxx)          // je�li automat nie zosta� zresetowany wcze�niej
                            begin
                                stan <= `NIC;
                                n_stan <= `NIC;
                                cmd_out <= 2'b00;
                                mon_out <= 3'b000;
                                tmp = `NIC;
                            end
                    endcase
                    cmd_sig = cmd_in;
                end
            // org
            if (rcount_FIFO!=wcount_FIFO && mon_out == `z0g00)
                begin
                    mon_out <= get_FIFO(0);    // oprozniamy bufor (monete)
                end
            case (cmd_out)
                `ODP_ZWROT:                              // jeste�my w trybie zwrotu
                    if (mon_in != `z0g00)                // zwracamy monety, a kto� wrzuci� dodatkow� monet�
                        begin
                            n_stan <= stan;              // stan bez zmian
                            add_FIFO(mon_in);          // dodaj do kolejki zwrotu
                        end
                    else begin
                        if (stan>`NIC) // wypelnimy kolejk� zwrotu
                        begin
                            stan = `NIC;
                            cmd_out <= `ODP_OK;
                        end
                    end
                `ODP_W_TOKU:                             // jeste�my w trybie op�aty za opcj�
                    begin
                        case (mon_in)                   // jak� monet� wrzucono ?
                            default:  tmp = `NIC;        // zerujemy w ka�dym innym przypadku
                            `z0g50: tmp = `m050;          // 50 groszy
                            `z1g00: tmp = `m100;          // 1 z�
                            `z2g00: tmp = `m200;          // 2 z�
                            `z5g00: tmp = `m500;          // 5z�
                        endcase
                        if (stan > tmp)                 // moneta to za ma�o aby zako�czy� pob�r op�aty
                            n_stan <= stan - tmp;       // ustawiamy nast�pny stan  
                        else if (stan == tmp)           // moneta wystarczy aby zako�czyc pob�r op�aty
                            begin
                                n_stan <= `NIC;          // ustawiamy nast�pny stan
                                cmd_out <= `ODP_OK;      // informujemy MG, �e wszystko ok
                            end
                        else                            // moneta to za du�o - trzeba zwr�ci� reszt�
                            begin
                                //n_stan <= tmp - stan;   // ustawiamy nast�pny stan
                                fill_FIFO(tmp - stan);  // reszta do zwrotu
                                cmd_out <= `ODP_ZWROT;   // ustawiamy tryb na zwrot;  
                            end
                    end
                `ODP_NIC:
                    if (mon_in != `z0g00)                // modu� nic nie robi a wrzucono monet�
                        begin
                            n_stan <= stan;             // stan bez zmian
                            add_FIFO(mon_in);         // dodajemy do kolejki zwrotu
                            //mon_out <= mon_in;          // zwracamy monet�
                        end
            endcase 
        end
 
    always @(clk)
        begin
            if (cmd_out == `ODP_OK) cmd_out <= `ODP_NIC;  // koniec wrzutu lub zwrotu - modu� w stanie zero
            if (mon_out != `z0g00) mon_out <= `z0g00;     // po 10ns zerujemy sygna� zwrotu monety
        end
    always @(*)
        #1 begin
            stan = n_stan;                                  // ustawiamy nast�pny stan
        end 
endmodule
