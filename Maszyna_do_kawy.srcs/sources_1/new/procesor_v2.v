`include "defines.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2018 09:42:11
// Design Name: 
// Module Name: Procesor
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


module Procesor_v2(
    input clk,
    input reset,
    input [3:0] stan_data,
    input [7:0] interrupt_data,
    output reg [7:0] out_data
    );
    

    // kcpsm63 
    // input    
    reg interrupt;
    reg [7:0] in_port;
    wire [17:0]instruction ;
    wire [9:0] address ;
    wire [7:0]   out_port ;
    wire [7:0]   port_id ;
    wire        write_strobe ;
    wire        read_strobe ;
    wire        interrupt_ack ;
    
    kcpsm3 kcpsm3 (
        .address(address),
        .instruction(instruction),
        .port_id(port_id),
        .write_strobe(write_strobe),
        .out_port(out_port),
        .read_strobe(read_strobe),
        .in_port(in_port),
        .interrupt(interrupt),
        .interrupt_ack(interrupt_ack),
        .reset(reset),
        .clk(clk)
    );
    // program
   proc_d program (
        .address(address),
        .instruction(instruction),
        .clk(clk)
   );
    
    // inicjalizacja
    initial begin
        interrupt = 1'b0;
        
    end
    
    always @(interrupt_data) // zmiana w sprawnoœci
        begin
            interrupt <= 1'b1; // wyzwalamy przerwanie
        end

    always @(negedge interrupt_ack) // rozpoczeto wykonywanie przerwania
        begin
            interrupt <= 1'b0; // zerujemy liniê przerwania
        end
    
    always @(posedge read_strobe)
            begin
                case (port_id)
                    `ERROR_PORT:
                        begin
                            in_port = interrupt_data;
                        end
                     `STAN_PORT:
                        begin
                            in_port = {5'b00000,stan_data};
                        end
                endcase
            end

    always @(posedge write_strobe)
            begin
                case (port_id)
                    `WYSWIETLACZ_PORT:
                        begin
                            out_data = out_port;
                        end
                endcase
            end
   
endmodule