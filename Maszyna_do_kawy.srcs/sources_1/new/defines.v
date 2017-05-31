`ifndef MY_DEFINES_SV
`define MY_DEFINES_SV
    `timescale 1us / 1ns
    // stany (pootrzebne do ustalenia CEN)
    `define NIC    5'b00000      // bezczynnosc
    `define m050   5'b00001      // 50 groszy
    `define m100   5'b00010      // 1 z�
    `define m150   5'b00011      // 1.50 z�
    `define m200   5'b00100      // 2 z�
    `define m250   5'b00101      // 2.50 z�
    `define m300   5'b00110      // 3 z�
    `define m350   5'b00111      // 3.50 z�
    `define m400   5'b01000      // 4 z�
    `define m450   5'b01001      // 4.50 z�
    `define m500   5'b01010      // 5 z�
    `define m550   5'b01011      // 5.50 z�
    `define m600   5'b01100      // 6 z�
    `define m650   5'b01101      // 6.50 z�
    `define m700   5'b01110      // 7.00 z�
    `define m750   5'b01111      // 7.50 z�
    `define m800   5'b10000      // 8.00 z�
    `define m850   5'b10001      // 8.50 z�
    `define m900   5'b10010      // 9.00 z�
    `define m950   5'b10011      // 9.50 z�
    `define m1000  5'b10100      // 10.00 z�
    
    // kubek, kawa. woda, mleko - do zmiany
    `define STAN_ZEROWY       5'b00000
    `define PODSTAW_KUBEK     5'b00011
    `define DODAJ_WODE        5'b00101
    `define ZMIEL_KAWE        5'b01100
    `define SPIENIAJ_MLEKO    5'b00110
    
    // MODU� TOP - STANY
    `define CZEKAM              5'b00000
    `define POBIERAM            5'b00001
    `define ZWRACAM             5'b00010
    
        
    // KOMENDY DO MODU�U MONET (OBS�UGA PRZYCISK�W)
    `define CMD_NIC      3'b000
    `define CMD_OP1      3'b001
    `define CMD_OP2      3'b010
    `define CMD_OP3      3'b011
    `define CMD_RESET    3'b100
    // konieczne
    `define  CMD_RESET1   3'b101
    `define  CMD_RESET2   3'b110
    `define  CMD_RESET3   3'b111
        
    // ODPOWIEDZI OD MODU�U MONET
    `define  ODP_NIC     2'b00
    `define  ODP_W_TOKU  2'b01
    `define  ODP_ZWROT   2'b10
    `define  ODP_OK      2'b11
    `define  ODP_RESET   2'b11
    
    // typy monet
    `define z0g00  3'b000        // brak monety - stan zerowy
    `define z0g50  3'b001        // 50 groszy
    `define z1g00  3'b010        // 1 z�
    `define z2g00  3'b011        // 2 z�
    `define z5g00  3'b100        // 5 z�
	
	// KOMENDY LICZNIKA
    `define LICZNIK_NULL        5'b00000
    `define ODLICZ_KUBEK        5'b00001
    `define ODLICZ_KAWA_OP1     5'b00010
    `define ODLICZ_KAWA_OP2     5'b00011
    `define ODLICZ_KAWA_OP3     5'b00100
    `define ODLICZ_WODA_OP1     5'b00101
    `define ODLICZ_WODA_OP2     5'b00110
    `define ODLICZ_WODA_OP3     5'b00111
    `define ODLICZ_MLEKO        5'b01000
    `define LICZNIK_RESET       5'b11111
    
    // ODPOWIEDZI LICZNIKA
    `define NIC_NIE_ODLICZAM    1'b0
    `define SKONCZYLEM_ODLICZAC 1'b0
    `define ODLICZAM            1'b1
    
    // CZASY DLA POSZCZEG�LNYCH OPCJI (w sekundach)
    // MODU� PRZELICZY TO NA ODPOWIEDNI� LICZB�
    // UWZGL�DNIAJ�C CZ�STOTLIWO�� ZEGARA
    `define CZAS_KUBEK          2
    `define CZAS_KAWA_OPCJA1    4
    `define CZAS_KAWA_OPCJA2    6
    `define CZAS_KAWA_OPCJA3    3
    `define CZAS_WODA_OPCJA1    15
    `define CZAS_WODA_OPCJA2    30
    `define CZAS_WODA_OPCJA3    25
    `define CZAS_MLEKO          30
    
    `define W_0             4'b0000 // 0
    `define W_1             4'b0001 // 1
    `define W_2             4'b0010 // 2
    `define W_3             4'b0011 // 3
    `define W_4             4'b0100 // 4
    `define W_5             4'b0101 // 5
    `define W_6             4'b0110 // 6
    `define W_7             4'b0111 // 7
    `define W_8             4'b1000 // 8
    `define W_9             4'b1001 // 9
                    
    `define W_MM            4'b1010 // mm
    `define W_UM            4'b1011 // um
    `define W_UR            4'b1100 // ur
    `define W_UL            4'b1101 // ul
    `define W_DM            4'b1110 // dm
    `define W_NULL          4'b1111 // nic
    
    
`endif