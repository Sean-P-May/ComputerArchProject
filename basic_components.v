// 2-to-1 multiplexer built from primitive logic gates.
// S = 0 selects i0, and S = 1 selects i1.
// Author: Sean May
module multiplexer2x1 (i0, i1, S, Out);

  input i0, i1, S;
  output Out;

  wire notS, i0_and_S, i1_and_S;

  // Generate both selection paths before combining them.
  not (notS, S);
  and (i0_and_S, i0, notS);
  and (i1_and_S, i1, S);
  or (Out, i0_and_S, i1_and_S);

endmodule


// 4-to-1 multiplexer constructed from three 2-to-1 multiplexers.
// s0 selects within each pair, while s1 selects between the two pairs.
// Author: Sean May
module multiplexer4x1 (i0, i1, i2, i3, s0, s1, Out);

  input i0, i1, i2, i3, s0, s1;
  output Out;

  wire out1, out2;

  multiplexer2x1 mux0 (i0, i1, s0, out1);
  multiplexer2x1 mux1 (i2, i3, s0, out2);
  multiplexer2x1 mux2 (out1, out2, s1, Out);

endmodule


// Level-sensitive D latch constructed from NAND gates.
// When C is high, Q follows D. When C is low, the stored value is held.
module D_latch (D, C, Q);

  input D, C;
  output Q;

  wire x, y, D1, Q1;

  not not1 (D1, D);
  nand nand1 (x, D, C), nand2 (y, D1, C);
  nand nand3 (Q, x, Q1), nand4 (Q1, y, Q);

endmodule


// Negative-edge-triggered D flip-flop built from two D latches.
module D_flip_flop (D, CLK, Q);

  input D, CLK;
  output Q;

  wire CLK1, Y;

  not not1 (CLK1, CLK);

  D_latch D1 (D, CLK, Y);
  D_latch D2 (Y, CLK1, Q);

endmodule

