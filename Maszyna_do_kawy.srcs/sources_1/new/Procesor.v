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


module Procesor(
    input clk,
    input reset,
    input [3:0] stan_data,
    input [7:0] interrupt_data,
    output reg [7:0] out_data
    );
    
    // kcpsm6 
    // input    
    reg interrupt;
    reg [7:0] in_port;
    wire  [17:0]instruction ;
    wire sleep ;
    assign sleep = 1'b0; // nieu¿ywany
    // output
    wire        bram_enable ;
    wire [11:0] address ;
    wire [7:0]   out_port ;
    wire [7:0]   port_id ;
    wire        write_strobe ;
    wire        k_write_strobe ;
    wire        read_strobe ;
    wire        interrupt_ack ;
    
    kcpsm6 kcpsm6(
        // in
        .clk(clk),
        .reset(reset),
        .in_port(in_port),
        .interrupt(interrupt),
        .instruction(instruction),
        .sleep(sleep),
        //out
        .bram_enable(bram_enable),
        .address(address),
        .out_port(out_port),
        .port_id(port_id),
        .write_strobe(write_strobe),
        .k_write_strobe(k_write_strobe),
        .read_strobe(read_strobe),
        .interrupt_ack(interrupt_ack)        
    );
    // program
    proc_data  
      /*
      #(
      .C_FAMILY           ("S6"),       //Family 'S6' or 'V6'
      .C_RAM_SIZE_KWORDS    (1),      //Program size '1', '2' or '4'
      .C_JTAG_LOADER_ENABLE    (0))      //Include JTAG Loader when set to '1'
      */ 
    program(
        // in
        .address(address),
        .enable(bram_enable),
        .clk(clk),
        // out
        .instruction(instruction)
    );
    
    // inicjalizacja
    initial begin
        interrupt = 1'b0;
        zmiana = 8'b00000000;
        iack_edge = 1'b0;
    end

    reg [7:0]zmiana;
    reg iack_edge;

    always @(clk)
        begin
            if (interrupt_data != zmiana) begin // zmiana w sprawnoœci
                interrupt <= 1'b1; // start przerwania
            end 
            if (interrupt_ack == 1'b1 && interrupt == 1'b1) begin
                iack_edge = 1'b1;
            end
            if (interrupt_ack == 1'b0 && interrupt == 1'b1 && iack_edge == 1'b1) begin // rozpoczeto wykonywanie przerwania
                interrupt = 1'b0; // zerujemy liniê przerwania
                iack_edge = 1'b0;
            end
            zmiana <= interrupt_data; 
            
            if(read_strobe)
            begin
                case (port_id)
                    `ERROR_PORT:
                        begin
                            in_port <= interrupt_data;
                        end
                     `STAN_PORT:
                        begin
                            in_port <= {4'b0000,stan_data};
                        end
                endcase
            end
            if (write_strobe)
            begin
                case (port_id)
                    `WYSWIETLACZ_PORT:
                        begin
                            out_data <= out_port;
                        end
                endcase
            end
         end
    
endmodule
