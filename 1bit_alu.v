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
 *   Implements a standard 1-bit ALU with support for AND, OR,
 *   addition, and set-less-than operations.
 *   Inputs A and B may also be inverted using the ALU control bits.
 */
module bitALU(a, b, carry_in, less, op, out, carry_out);

  input a, b, carry_in, less;
  input [3:0] op; // op[3] = Ainvert, op[2] = Bnegate, op[1:0] = Operation

  output out, carry_out;

  wire [3:0] logic_out;

  wire not_a;
  wire not_b;

  wire a_nota;
  wire b_notb;

  // Generate inverted versions of A and B
  not (not_a, a);
  not (not_b, b);

  // Select normal or inverted A
  multiplexer2x1 negplex_a(
    {not_a, a},
    op[3],
    a_nota
  );

  // Select normal or inverted B
  multiplexer2x1 negplex_b(
    {not_b, b},
    op[2],
    b_notb
  );

  // AND operation
  and (
    logic_out[0],
    a_nota,
    b_notb
  );

  // OR operation
  or (
    logic_out[1],
    a_nota,
    b_notb
  );

  // ADD operation
  bitFullAdder full_adder(
    a_nota,
    b_notb,
    carry_in,
    logic_out[2],
    carry_out
  );

  // Set-less-than operation
  buf (
    logic_out[3],
    less
  );

  // Select final ALU result
  multiplexer4x1 result_mux(
    logic_out,
    op[1:0],
    out
  );

endmodule


/*
 * Module: Overflow_detection
 * Author: Sean May
 * Description:
 *   Implements gate-level signed overflow detection.
 *
 *   Overflow occurs when both processed inputs have the same sign,
 *   but the resulting sum has a different sign.
 *
 *   Formula:
 *   overflow = (A_sign == B_sign) && (Sum_sign != A_sign)
 */
module Overflow_detection(a_processed, b_processed, sum, overflow);

  input a_processed, b_processed, sum;
  output overflow;

  wire signs_match;
  wire sign_changed;

  // Check if both processed input signs are the same
  xnor (
    signs_match,
    a_processed,
    b_processed
  );

  // Check if the resulting sum sign differs from A
  xor (
    sign_changed,
    sum,
    a_processed
  );

  // Overflow occurs only when both conditions are true
  and (
    overflow,
    signs_match,
    sign_changed
  );

endmodule


/*
 * Module: bit15ALU
 * Author: Sean May
 * Description:
 *   Implements the most significant bit of a 16-bit ALU.
 *   Supports AND, OR, addition, and set-less-than operations.
 *   Also generates the SET signal and detects signed overflow.
 */
module bit15ALU(
  a,
  b,
  carry_in,
  less,
  op,
  out,
  carry_out,
  set,
  overflow
);

  input a, b, carry_in, less;
  input [3:0] op; // op[3] = Ainvert, op[2] = Bnegate, op[1:0] = Operation
  output out;
  output carry_out;
  output set;
  output overflow;

  wire [3:0] logic_out;

  wire not_a;
  wire not_b;

  wire a_nota;
  wire b_notb;

  // Generate inverted versions of A and B
  not (not_a, a);
  not (not_b, b);

  // Select normal or inverted A
  multiplexer2x1 negplex_a(
    {not_a, a},
    op[3],
    a_nota
  );

  // Select normal or inverted B
  multiplexer2x1 negplex_b(
    {not_b, b},
    op[2],
    b_notb
  );

  // AND operation
  and (
    logic_out[0],
    a_nota,
    b_notb
  );

  // OR operation
  or (
    logic_out[1],
    a_nota,
    b_notb
  );

  // ADD operation
  bitFullAdder full_adder(
    a_nota,
    b_notb,
    carry_in,
    logic_out[2],
    carry_out
  );

  // Set-less-than input
  buf (
    logic_out[3],
    less
  );

  // Select final ALU result
  multiplexer4x1 result_mux(
    logic_out,
    op[1:0],
    out
  );

  // Detect signed arithmetic overflow
  Overflow_detection overflow_detection(
    a_nota,
    b_notb,
    logic_out[2],
    overflow
  );

 // Correct signed set-less-than value
 xor (set, logic_out[2], overflow);

endmodule
