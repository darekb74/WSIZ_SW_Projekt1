`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Licznik robienia kawki
//////////////////////////////////////////////////////////////////////////////////

module counter(count_in, count_out, clk);

    input clk; 
    input [4:0] count_in;
    output reg count_out; 

    reg [31:0] count_to_0; //rejestr 32 bitowy
    // pozostaje przeliczyæ czasy
    // 1 s = 1 000 000 000 ns
    parameter tick_every = 20; // parametr co ile nastêpuje tick zegara (w ns)
    reg [31:0]mc = 1000000000/tick_every; // mno¿nik dla czasu w sekundach 
 
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
                        //count_out = `NIC_NIE_ODLICZAM; <- to by resetowa³o licznik - niepotrzebne
                    end
                `ODLICZ_KUBEK:      // maszyna podstawia kubek, ma na to 2 sek
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_KUBEK*mc;
                    end
                `ODLICZ_KAWA_OP1:   // maszyna mieli kawê dla opcji 1, ma na to 10 sek
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_KAWA_OPCJA1*mc;
                    end
                `ODLICZ_KAWA_OP2:   // maszyna mieli kawê dla opcji 2, ma na to 20 sek
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_KAWA_OPCJA2*mc;
                    end
                `ODLICZ_KAWA_OP3:   // maszyna mieli kawê dla opcji 3, ma na to 15 sek
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_KAWA_OPCJA3*mc;
                    end
                `ODLICZ_WODA_OP1:   // maszyna wlewa wrz¹tek dla opcji 1, ma na to 15 sek
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_WODA_OPCJA1*mc;                     
                    end
                `ODLICZ_WODA_OP2:   // maszyna wlewa wrz¹tek dla opcji 2, ma na to 30 sek
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_WODA_OPCJA2*mc;
                    end
                `ODLICZ_WODA_OP3:   // maszyna wlewa wrz¹tek dla opcji 3, ma na to 25 sek
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_WODA_OPCJA3*mc;
                    end
                `ODLICZ_MLEKO:      // maszyna spienia mleko, ma na to 30 sek
                    begin
                        count_out = `ODLICZAM;
                        count_to_0 = `CZAS_MLEKO*mc;
                    end 
            endcase;   
        end  
    
    always @(negedge clk) // odliczanie do 0
        begin
            if(count_out == 1 && count_to_0 > 0)
                count_to_0 <= count_to_0 - 1;
            else
                count_out <= `SKONCZYLEM_ODLICZAC; // skoñczyliœmy odliczaæ    
        end
        
endmodule