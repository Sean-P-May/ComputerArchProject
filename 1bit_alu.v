module 1bitFullAdder(a,b,carry_in, sum, carry_out);
  input a, b, carry_in;
  output sum, carry_out;

  xor (a_xor_b, a,b);
  and (a_and_b, a,b);
  xor (sum, a_xor_b, a,b,);
  and (carry_and, a_xor_b, carry_in);
  or (carry_out, a_and_b, carry_and);

endmodule



module 1bitALU(a,b,carry_in, less, op, out, carry_out);
  input a, b, carry_in, less;
  input op[0:3]; // invert a, invert b, op0, op2
  output out, carry_out;

  wire logic_out[0:3]
  not(not_a,a);
  not(n0t_b,b);

  muilplexer2x1 negplex_a([a, nota], op[0], a_nota);
  muilplexer2x1 negplex_b([b,notbi], op[1], b_notb);
  
  and(logic_out[0], a_nota, b_notb);
  or(logic_out[1], a_nota, b_notb);

  1bitFullAdder full_adder(a_nota, b_notb, carry_in, logic_out[2], carry_out);

  buf(logic_out[3]);
  
  multiplexer4X1 (logic_out,op[2:3],output);

endmodule











