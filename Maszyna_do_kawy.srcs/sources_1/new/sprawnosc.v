`include "defines.v"

module sprawnosc(c_k, p_w, i_k, i_m, p_b, signal_s);

// c_k - czujnik iloœci kubków
// p_w - pod³¹czenie wody
// i_k - iloœæ kawy
// i_m - iloœæ mleka
// p_b - posiadany bilon na wydanie reszty
// signal_s - wyjœciowy sygna³

output signal_s;
input c_k, p_w, i_k, i_m, p_b;
//powy¿ej zadeklarowa³em porty

assign signal_s = c_k | p_w | i_k | i_m | p_b;

endmodule
