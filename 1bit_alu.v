/*
 * Module: bitFullAdder
 * Author: Sean May
 * Description:
 *   Implements a 1-bit full adder using basic logic gates.
 *   Produces a sum and carry-out from inputs A, B, and carry-in.
 */
module bitFullAdder(a, b, carry_in, sum, carry_out);
  input a, b, carry_in;
  output sum, carry_out;

  wire a_xor_b;
  wire a_and_b;
  wire carry_and;

  xor (a_xor_b, a, b);
  and (a_and_b, a, b);
  xor (sum, a_xor_b, carry_in);
  and (carry_and, a_xor_b, carry_in);
  or (carry_out, a_and_b, carry_and);

endmodule


/*
 * Module: bitALU
 * Author: Sean May
 * Description:
 *   Implements a 1-bit ALU with support for AND, OR, addition,
 *   and set-less-than operations. Inputs A and B can also be
 *   inverted using the ALU control signals.
 */
module bitALU(a, b, carry_in, less, op, out, carry_out);
  input a, b, carry_in, less;
  input [0:3] op; // invert A, invert B, operation select
  output out, carry_out;

  wire [0:3] logic_out;
  wire not_a;
  wire not_b;
  wire a_nota;
  wire b_notb;

  // Generate inverted versions of A and B
  not (not_a, a);
  not (not_b, b);

  // Select normal or inverted inputs
  multiplexer2x1 negplex_a(a, not_a, op[0], a_nota);
  multiplexer2x1 negplex_b(b, not_b, op[1], b_notb);

  // AND operation
  and (logic_out[0], a_nota, b_notb);

  // OR operation
  or (logic_out[1], a_nota, b_notb);

  // ADD operation
  bitFullAdder full_adder(
    a_nota,
    b_notb,
    carry_in,
    logic_out[2],
    carry_out
  );

  // Set-less-than result
  buf (logic_out[3], less);

  // Select final ALU result
  multiplexer4X1 result_mux(
    logic_out,
    op[2:3],
    out
  );

endmodule







