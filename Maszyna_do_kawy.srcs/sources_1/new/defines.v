`ifndef MY_DEFINES_SV
`define MY_DEFINES_SV
    `timescale 1ns / 1ps
    // stany (pootrzebne do ustalenia CEN)
    `define NIC    5'b00000      // bezczynnosc
    `define m050   5'b00001      // 50 groszy
    `define m100   5'b00010      // 1 z³
    `define m150   5'b00011      // 1.50 z³
    `define m200   5'b00100      // 2 z³
    `define m250   5'b00101      // 2.50 z³
    `define m300   5'b00110      // 3 z³
    `define m350   5'b00111      // 3.50 z³
    `define m400   5'b01000      // 4 z³
    `define m450   5'b01001      // 4.50 z³
    `define m500   5'b01010      // 5 z³
    `define m550   5'b01011      // 5.50 z³
    `define m600   5'b01100      // 6 z³
    `define m650   5'b01101      // 6.50 z³
    `define m700   5'b01110      // 7.00 z³
    `define m750   5'b01111      // 7.50 z³
    `define m800   5'b10000      // 8.00 z³
    `define m850   5'b10001      // 8.50 z³
    `define m900   5'b10010      // 9.00 z³
    `define m950   5'b10011      // 9.50 z³
    `define m1000  5'b10100      // 10.00 z³
    
    // KOMENDY JEDNOBITOWE
    // kubek, kawa. woda, mleko - do zmiany
    `define STAN_ZEROWY       1'b0
    `define PODSTAW_KUBEK     1'b1
    `define DODAJ_WODE        1'b1
    `define ZMIEL_KAWE        1'b1
    `define SPIENIAJ_MLEKO    1'b1
        
    // KOMENDY DO MODU£U MONET (OBS£UGA PRZYCISKÓW)
    `define CMD_NIC      3'b000
    `define CMD_OP1      3'b001
    `define CMD_OP2      3'b010
    `define CMD_OP3      3'b011
    `define CMD_RESET    3'b100
    // konieczne
    `define  CMD_RESET1   3'b101
    `define  CMD_RESET2   3'b110
    `define  CMD_RESET3   3'b111
        
    // ODPOWIEDZI OD MODU£U MONET
    `define  ODP_NIC     2'b00
    `define  ODP_W_TOKU  2'b01
    `define  ODP_ZWROT   2'b10
    `define  ODP_OK      2'b11
    `define  ODP_RESET   2'b11
    
    // typy monet
    `define z0g00  3'b000        // brak monety - stan zerowy
    `define z0g50  3'b001        // 50 groszy
    `define z1g00  3'b010        // 1 z³
    `define z2g00  3'b011        // 2 z³
    `define z5g00  3'b100        // 5 z³
`endif