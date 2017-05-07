`include "defines.v"

module sprawnosc(c_k, p_w, i_k, i_m, p_b, signal_s);

// c_k - czujnik ilo�ci kubk�w
// p_w - pod��czenie wody
// i_k - ilo�� kawy
// i_m - ilo�� mleka
// p_b - posiadany bilon na wydanie reszty
// signal_s - wyj�ciowy sygna�

output signal_s;
input c_k, p_w, i_k, i_m, p_b;
//powy�ej zadeklarowa�em porty

assign signal_s = c_k | p_w | i_k | i_m | p_b;

endmodule
