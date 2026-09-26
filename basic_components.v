
/*
 * Module: multiplexer2x1
 * Author: Sean May
 * Description:
 *   Implements a 2-to-1 multiplexer using primitive logic gates.
 *   S = 0 selects i[0], and S = 1 selects i[1].
 */
module multiplexer2x1 (
    i,
    S,
    Out
);

  input [1:0] i;
  input S;
  output Out;

  wire notS, i0_and_S, i1_and_S;

  not (notS, S);
  and (i0_and_S, i[0], notS);
  and (i1_and_S, i[1], S);
  or (Out, i0_and_S, i1_and_S);

endmodule


/*
 * Module: multiplexer4x1
 * Author: Sean May
 * Description:
 *   Implements a 4-to-1 multiplexer using three 2-to-1 multiplexers.
 *   s[0] selects within each input pair, while s[1] selects
 *   between the two pairs.
 */
module multiplexer4x1 (
    i,
    s,
    Out
);

  input [3:0] i;
  input [1:0] s;
  output Out;

  wire out1, out2;

  // Select between i[0]/i[1] and i[2]/i[3]
  multiplexer2x1 mux0 (
      i[1:0],
      s[0],
      out1
  );
  multiplexer2x1 mux1 (
      i[3:2],
      s[0],
      out2
  );

  // Select between the results of the first two multiplexers
  multiplexer2x1 mux2 (
      {out2, out1},
      s[1],
      Out
  );

endmodule



// Level-sensitive D latch constructed from NAND gates.
// When C is high, Q follows D. When C is low, the stored value is held.
module D_latch (
    D,
    C,
    Q
);

  input D, C;
  output Q;

  wire x, y, D1, Q1;

  not not1 (D1, D);
  nand nand1 (x, D, C), nand2 (y, D1, C);
  nand nand3 (Q, x, Q1), nand4 (Q1, y, Q);

endmodule


// Negative-edge-triggered D flip-flop built from two D latches.
module D_flip_flop (
    D,
    CLK,
    Q
);

  input D, CLK;
  output Q;

  wire CLK1, Y;

  not not1 (CLK1, CLK);

  D_latch D1 (
      D,
      CLK,
      Y
  );
  D_latch D2 (
      Y,
      CLK1,
      Q
  );

endmodule
