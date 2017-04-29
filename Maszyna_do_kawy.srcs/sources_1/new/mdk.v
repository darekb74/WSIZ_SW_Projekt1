`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: WSIZ Copernicus
// Engineer: Darek B.
// 
// Create Date: 25.04.2017 18:46:49
// Design Name:  
// Module Name: mdk
// Project Name: Maszyna do kawy 
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


module mdk_top(
    input wire rst,                     // reset
    input wire clk,                     // zegar
    // sygna³ z przycisków
    input wire [2:0]start,              // przyciski - wybór kawy 
	// czujniki sprawnoœci maszyny
	input wire kubki_t,                 // czujnik iloœci kubków
    input wire woda_t,                  // czujnik poziomu wody
    input wire kawa_t,                  // czuyjnik iloœci kawy
    input wire mleko_t,                 // czujnik iloœci mleka
    // sterowanie modu³em monet
    input wire[1:0]cmd_in,             // odpowiedz na koendê z modu³u odpowedzialnego za monety
    output reg [2:0]cmd_out,             // komenda do modu³u odpowedzialnego za monety
    // sterowanie poszczególnymi etapami parzenia kawy
	output reg kubek,                   // podstawienie kubka
    output reg woda,                    // w³¹czanie dozowania wody
    output reg kawa,                    // w³aczanie m³ynka do kawy
    output reg mleko                    // w³acznie dozowania mleka (spieniacz)
    );
    
    // ³¹czymy modu³y
    // pod³¹czamy modu³ monet
    modul_monet #(CENA_OP1, CENA_OP2, CENA_OP3) wrzut_zwrot(.clk(clk), .cmd_in(cmd_out), .cmd_out(cmd_in));

	reg [4:0]stan;
    
    // KOMENDY JEDNOBITOWE
    // kubek, kawa. woda, mleko
    localparam STAN_ZEROWY      = 1'b0;
    localparam PODSTAW_KUBEK    = 1'b1;
    localparam DODAJ_WODE       = 1'b1;
    localparam ZMIEL_KAWE       = 1'b1;
    localparam SPIENIAJ_MLEKO   = 1'b1;
    
    // KOMENDY DO MODU£U MONET (OBS£UGA PRZYCISKÓW)
    localparam [2:0]CMD_NIC     = 3'b000;
    localparam [2:0]CMD_OP1     = 3'b001;
    localparam [2:0]CMD_OP2     = 3'b010;
    localparam [2:0]CMD_OP3     = 3'b011;
    localparam [2:0]CMD_RESET   = 3'b100;
    // konieczne
    localparam [2:0] CMD_RESET1  = 3'b101;
    localparam [2:0] CMD_RESET2  = 3'b110;
    localparam [2:0] CMD_RESET3  = 3'b111;
    
    // ODPOWIEDZI OD MODU£U MONET
    localparam [1:0] ODP_NIC    = 2'b00;
    localparam [1:0] ODP_W_TOKU = 2'b01;
    localparam [1:0] ODP_ZWROT  = 2'b10;
    localparam [1:0] ODP_OK     = 2'b11;
    localparam [1:0] ODP_RESET  = 2'b11;
    
    localparam [4:0]m050  = 5'b00001;      // 50 groszy
    localparam [4:0]m100  = 5'b00010;      // 1 z³
    localparam [4:0]m150  = 5'b00011;      // 1.50 z³
    localparam [4:0]m200  = 5'b00100;      // 2 z³
    localparam [4:0]m250  = 5'b00101;      // 2.50 z³
    localparam [4:0]m300  = 5'b00110;      // 3 z³
    localparam [4:0]m350  = 5'b00111;      // 3.50 z³
    localparam [4:0]m400  = 5'b01001;      // 4 z³
    localparam [4:0]m450  = 5'b01010;      // 4.50 z³
    localparam [4:0]m500  = 5'b01011;      // 5 z³
    localparam [4:0]m550  = 5'b01100;      // 5.50 z³
    localparam [4:0]m600  = 5'b01101;      // 6 z³
    localparam [4:0]m650  = 5'b01110;      // 6.50 z³
    localparam [4:0]m700  = 5'b01111;      // 7.00 z³
    localparam [4:0]m750  = 5'b10000;      // 7.50 z³
    localparam [4:0]m800  = 5'b10001;      // 8.00 z³
    localparam [4:0]m850  = 5'b10010;      // 8.50 z³
    localparam [4:0]m900  = 5'b10011;      // 9.00 z³
    localparam [4:0]m950  = 5'b10100;      // 9.50 z³
    localparam [4:0]m1000 = 5'b10101;      // 10.00 z³
    
	parameter CENA_OP1 = m300;				// cena opcji 1 (3.00z³ - expresso)
	parameter CENA_OP2 = m500;				// cena opcji 2 (5.00z³ - expresso grande :P )
	parameter CENA_OP3 = m750;				// cena opcji 3 (7.50z³ - cappucino :P )
	
    initial
        begin
            kubek = STAN_ZEROWY;
            woda = STAN_ZEROWY;
            kawa = STAN_ZEROWY;
            mleko = STAN_ZEROWY;
			cmd_out = CMD_NIC;
        end
    always @(start)
        #1 begin
            case (start)
                //CMD_NIC:
                    //cmd_out = CMD_NIC;
                CMD_OP1: // wciœniêto przycisk wyboru opcji 1
                    if(cmd_in == ODP_NIC)   // jeœli modu³ nic nie robi
                        cmd_out = CMD_OP1; // rozpoczynamy pobór monet
                CMD_OP2: // wciœniêto przycisk wyboru opcji 2
                    if(cmd_in == ODP_NIC)   // jeœli modu³ nic nie robi
                        cmd_out = CMD_OP2; // rozpoczynamy pobór monet
                CMD_OP3: // wciœniêto przycisk wyboru opcji 3
                    if(cmd_in == ODP_NIC)   // jeœli modu³ nic nie robi
                        cmd_out = CMD_OP3; // rozpoczynamy pobór monet
                CMD_RESET:
                    case(cmd_out)
                        CMD_OP1:
                            cmd_out = CMD_RESET1;
                        CMD_OP2:
                            cmd_out = CMD_RESET2;
                        CMD_OP3:
                            cmd_out = CMD_RESET3;
                    endcase
            endcase
        end
endmodule
