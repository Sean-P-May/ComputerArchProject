module adder (
    S,
    Cout,
    A,
    B,
    Cin
);
  input A, B, Cin;
  output S, Cout;

  xor (a_xor_b, A, B);
  and (a_and_b, A, B);
  xor (S, a_xor_b, Cin);
  and (carry_and, a_xor_b, Cin);
  or (Cout, a_and_b, carry_and);

endmodule



module multiplexer2x1 (
    Out,
    i0,
    i1,
    S
);
  input i0, i1, S;
  output Out;

  not (notS, S);
  and (i0_and_S, i0, notS);
  and (i1_and_S, i1, S);
  or (Out, i0_and_S, i1_and_S);

endmodule


module multiplexer4x1 (
    Out,
    i0,
    i1,
    i2,
    i3,
    s0,
    s1
);

  input i0, i1, i2, i3, s0, s1;
  output Out;

  wire out1, out2;

  multiplexer2x1 mux0 (
      out1,
      i0,
      i1,
      s0
  );
  multiplexer2x1 mux1 (
      out2,
      i2,
      i3,
      s0
  );
  multiplexer2x1 mux2 (
      Out,
      out1,
      out2,
      s1
  );

endmodule

module decoder (
    binvert_out,

    Op0_out,
    binvert,
    Op0
);

  input binvert, Op0;
  output binvert_out, Op0_out;

  wire notOp0;

  not (notOp0, Op0);
  and (binvert_out, binvert, Op0);
  and (Op0_out, binvert, notOp0);

endmodule


module alubit (
    Result,
    CarryOut,
    Binvert,
    Op0,
    Op1,
    Ain,
    Bin,
    less,
    CarryIn
);

  input Binvert, Op0, Op1, Ain, Bin, less, CarryIn;
  output Result, CarryOut;

  wire B_invert_decoded, Op0_decoded;
  wire notB, B;
  wire A_and_B, A_or_B;
  wire S;
  wire result_raw, not_result;

  decoder OpCodeDecoder (
      B_invert_decoded,
      Op0_decoded,
      Binvert,
      Op0
  );

  not (notB, Bin);

  multiplexer2x1 invert_b_mux (
      B,
      Bin,
      notB,
      B_invert_decoded
  );

  and (A_and_B, Ain, B);
  or (A_or_B, Ain, B);

  adder full_adder (
      S,
      CarryOut,
      Ain,
      B,
      CarryIn
  );

  multiplexer4x1 OperationMultiplexer (
      result_raw,
      A_and_B,
      A_or_B,
      S,
      less,
      Op1,
      Op0

  );

  not (not_result, result_raw);

  multiplexer2x1 resultInvert (
      Result,
      result_raw,
      not_result,
      Op0_decoded
  );

endmodule

module alubit3 (
    Result,
    CarryOut,
    Set,
    Binvert,
    Op0,
    Op1,
    Ain,
    Bin,
    less,
    CarryIn
);

  input Binvert, Op0, Op1, Ain, Bin, less, CarryIn;
  output Result, CarryOut, Set;

  wire B_invert_decoded, Op0_decoded;
  wire notB, B;
  wire A_and_B, A_or_B;
  wire S;
  wire result_raw, not_result;

  decoder OpCodeDecoder (
      B_invert_decoded,
      Op0_decoded,
      Binvert,
      Op0
  );

  not (notB, Bin);

  multiplexer2x1 invert_b_mux (
      B,
      Bin,
      notB,
      B_invert_decoded
  );

  and (A_and_B, Ain, B);
  or (A_or_B, Ain, B);

  adder full_adder (
      S,
      CarryOut,
      Ain,
      B,
      CarryIn
  );

  buf (Set, S);

  multiplexer4x1 OperationMultiplexer (
      result_raw,
      A_and_B,
      A_or_B,
      S,
      less,
      Op1,

      Op0
  );

  not (not_result, result_raw);

  multiplexer2x1 resultInvert (
      Result,
      result_raw,
      not_result,
      Op0_decoded
  );

endmodule

module alu_unit (
    Result,
    Overflow,
    Zero,
    A,
    B,
    OpCode
);

  input [3:0] A, B;
  input [2:0] OpCode;
  output [3:0] Result;
  output Overflow, Zero;

  wire [3:0] CarryOut;
  wire Binvert, Op0, Op1, CarryIn;
  wire Set, less;
  wire OverflowXor;
  wire anyResult;

  // Decode control bits with gates only
  buf (Binvert, OpCode[2]);
  buf (Op0, OpCode[1]);
  buf (Op1, OpCode[0]);
  buf (CarryIn, Binvert);

  // SLT feedback
  buf (less, Set);

  alubit alu0 (
      Result[0],
      CarryOut[0],
      Binvert,
      Op0,
      Op1,
      A[0],
      B[0],
      less,
      CarryIn
  );
  alubit alu1 (
      Result[1],
      CarryOut[1],
      Binvert,
      Op0,
      Op1,
      A[1],
      B[1],
      1'b0,
      CarryOut[0]
  );
  alubit alu2 (
      Result[2],
      CarryOut[2],
      Binvert,
      Op0,
      Op1,
      A[2],
      B[2],
      1'b0,
      CarryOut[1]
  );

  alubit3 alu3 (
      Result[3],
      CarryOut[3],
      Set,
      Binvert,
      Op0,
      Op1,
      A[3],
      B[3],
      1'b0,
      CarryOut[2]
  );

  // Overflow
  xor (OverflowXor, CarryOut[3], CarryOut[2]);
  and (Overflow, OverflowXor, Op0);

  // Zero detect
  nor (Zero, Result[0], Result[1], Result[2], Result[3]);


endmodule
//
// module testALU;
//   reg signed [3:0] a;
//   reg signed [3:0] b;
//   reg [2:0] op;
//   wire signed [3:0] result;
//   wire zero, overflow;
//   alu_unit alu (
//       result,
//       overflow,
//       zero,
//       a,
//       b,
//       op
//   );
//   initial begin
//     $display("op   a        b        result   zero overflow");
//     $monitor("%b %b(%d) %b(%d) %b(%d) %b    %b", op, a, a, b, b, result, result, zero, overflow);
//     op = 3'b000;
//     a  = 4'b0111;
//     b  = 4'b0010;  // AND
//     #1 op = 3'b001;
//     a = 4'b0101;
//     b = 4'b0010;  // OR
//     #1 op = 3'b010;
//     a = 4'b0101;
//     b = 4'b0001;  // ADD
//     #1 op = 3'b010;
//     a = 4'b0111;
//     b = 4'b0001;  // ADD overflow (8+1=-8)
//     #1 op = 3'b110;
//     a = 4'b0101;
//     b = 4'b0001;  // SUB
//     #1 op = 3'b110;
//     a = 4'b1111;
//     b = 4'b0001;  // SUB
//     #1 op = 3'b110;
//     a = 4'b1111;
//     b = 4'b1000;  // SUB no overflow (-1-(-8)=7)
//     #1 op = 3'b110;
//     a = 4'b1110;
//     b = 4'b0111;  // SUB overflow (-2-7=7)
//     #1 op = 3'b111;
//     a = 4'b0101;
//     b = 4'b0001;  // SLT
//     #1 op = 3'b111;
//     a = 4'b0001;
//     b = 4'b0011;  // SLT
//     #1 op = 3'b111;
//     a = 4'b1101;
//     b = 4'b0110;  // SLT overflow (-3-6=7 => SLT=0)
//     #1 op = 3'b100;
//     a = 4'b0101;
//     b = 4'b0011;  // NAND
//
//     #1 op = 3'b101;
//     a = 4'b0101;
//     b = 4'b0011;  // NOR
//   end
// endmodule
