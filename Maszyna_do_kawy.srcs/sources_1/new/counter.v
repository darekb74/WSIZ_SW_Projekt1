`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Licznik robienia kawki
//////////////////////////////////////////////////////////////////////////////////

module counter(clk, count_in, count_out, count_secs);

    input clk; 
    input [4:0] count_in;
    output reg count_out;
    output wire [6:0]count_secs; // przekazanie pozosta�ego czasu (w sekundach) do modu�u g�ownego
                                 // potrzebna do wy�wietlacza - 7 bit = max 127 sek (wystarczy)

    reg [22:0] count_to_0 = 0;           //rejestr 23 bitowy, przy zegarze 50kHz wystarczy na odliczanie od 167 sekund
    // pozostaje przeliczy� czasy
    // 1 s = 1 000 000 000 ns
    // 1 s = 1 000 000 us
    parameter tick_every = 20;       // parametr co ile nast�puje tick zegara (w us)
    integer mc = 1000000/tick_every; // mno�nik dla czasu w sekundach (cz�stotliwo�� w Hz)
    
    // wysy�amy pozosta�y czas do modu�u top (w sekundach)
    assign count_secs = count_to_0/mc;
 
    always @(count_in) 
        begin 
            if(count_in == `LICZNIK_RESET)  // reset licznika
                begin
                    count_out <= `NIC_NIE_ODLICZAM;
                    count_to_0 <= 0;
                end
            case (count_in)
                `LICZNIK_NULL: // stan zerowy, wyjscie 0
                    begin
                        //count_out = `NIC_NIE_ODLICZAM; <- to by resetowa�o licznik - niepotrzebne
                    end
                `ODLICZ_KUBEK:      // maszyna podstawia kubek
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_KUBEK*mc;
                    end
                `ODLICZ_KAWA_OP1:   // maszyna mieli kaw� dla opcji 1
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_KAWA_OPCJA1*mc;
                    end
                `ODLICZ_KAWA_OP2:   // maszyna mieli kaw� dla opcji 2
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_KAWA_OPCJA2*mc;
                    end
                `ODLICZ_KAWA_OP3:   // maszyna mieli kaw� dla opcji 3
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_KAWA_OPCJA3*mc;
                    end
                `ODLICZ_WODA_OP1:   // maszyna wlewa wrz�tek dla opcji 1
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_WODA_OPCJA1*mc;                     
                    end
                `ODLICZ_WODA_OP2:   // maszyna wlewa wrz�tek dla opcji 2
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_WODA_OPCJA2*mc;
                    end
                `ODLICZ_WODA_OP3:   // maszyna wlewa wrz�tek dla opcji 3
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_WODA_OPCJA3*mc;
                    end
                `ODLICZ_MLEKO:      // maszyna spienia mleko
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_MLEKO*mc;
                    end
                `ODLICZ_NAPELN:     // maszyna wype�nia przewody wod�         
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_NAPELN*mc;
                    end
                `ODLICZ_CZYSC:      // maszyna usuwa zu�yt� kaw�, czy�ci instalacj�, usuwa wod� z przewod�w 
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_CZYSC*mc;
                    end
                  
            endcase;   
        end  
    
    always @(negedge clk) // odliczanie do 0
        begin
            if(count_out == 1 && count_to_0 > 0)
                count_to_0 <= count_to_0 - 1;
            else
                count_out <= `SKONCZYLEM_ODLICZAC; // sko�czyli�my odlicza�    
        end
        
endmodule