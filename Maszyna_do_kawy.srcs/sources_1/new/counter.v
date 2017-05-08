`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Licznik robienia kawki
//////////////////////////////////////////////////////////////////////////////////

module counter(count_in, count_out, clk);

    input clk; 
    input [4:0] count_in;
    output reg count_out; 
    
    reg [31:0] count_to_0; //rejestr 32 bitowy
 
    always @(count_in) 
        begin 
            if(count_in == 'COUNTER_RESET)
                begin
                    count_out <= 0;
                    count_in <= 0;
                end
            case (count_in)
                `STAN_ZEROWY: // stan zerowy, wyjscie 0
                    begin
                        count_out = 1'b0;
                    end
                `PODSTAW_KUBEK:  // maszyna podstawia kubek, ma na to 5ns
                    begin
                        count_out = 1'b1;
                        count_to_0 = 5'b00101;
                    end
                `DODAJ_WODE: // maszyna wlewa wrzątek, ma na to 3ns
                    begin
                        count_out = 1'b1;
                        count_to_0 = 5'b00011;                     
                    end
                `ZMIEL_KAWE: // maszyna mieli kawe, ma na to 7ns
                    begin
                        count_out = 1'b1;
                        count_to_0 = 5'b00111;
                    end
                `SPIENIAJ_MLEKO: // maszyna spienia mleko, ma na to 2ns
                    begin
                        count_out = 1'b1;
                        count_to_0 = 5'b00010;
                    end 
            endcase;   
        end  
    
    always @(negedge clk) // odliczanie do 0
        begin
            if(cout_out == 1 && count_to_0 > 0)
                count_to_0 <= count_to_0 - 1;
            else
                count_to_0 <= 0;    
        end
        
endmodule
