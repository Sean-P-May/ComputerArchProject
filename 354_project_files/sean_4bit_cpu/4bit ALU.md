#### Sean May
---
This project implements a 4-bit Arithmetic Logic Unit, or ALU, using gate-level Verilog modeling. The ALU takes two 4-bit inputs, `A` and `B`, and a 3-bit control input, `OpCode`. Based on the control value, the ALU performs one of 7 operations: bitwise AND, bitwise OR, bitwise NAND, bitwise NOR, addition, subtraction, and set-on-less-than.

The ALU produces a 4-bit output called `Result`. It also produces two status outputs: `Zero` and `Overflow`. The `Zero` output is set to `1` when the final result is `0000`; otherwise, it is `0`. The `Overflow` output is set to `1` when overflow occurs during arithmetic operations such as ADD, SUB, or SLT.

## Instructions
---
### Instruction Code Format

| Op Code | Binvert | Op0 | Op1 |
| ------- | ------- | --- | --- |
| nor     | 1       | 0   | 1   |

### Instruction Set

| Operation | Op code |
| --------- | ------- |
| and       | 000     |
| or        | 001     |
| add       | 010     |
| sub       | 110     |
| slt       | 111     |
| nand      | 100     |
| nor       | 101     |
note: For instruction  nand and nor Binvert does not invert input B but inverts the output this is done thru a simple encoder.

$Binvert.Op0 = Op0Out$
$Binvert.Op0' = BinvertOut$

![[Pasted image 20260429132820.png]]



## ALU Design

![[2026-04-25-180820_hyprshot.png]]

### Module Description

The design is hierarchical, built with 4 1-bit ALU module, bits 0 through 2 are identical while bit 3 contains an extra output set for use `slt` operations. These 1 bit module contains logic gates for AND and OR operations, a full adder for arithmetic, and multiplexers to select the correct output based on the operation code. `nand` and `nor` are implemented uses a decoder that will invert the result using a 2x1 multiplexer.   

A separate 1-bit ALU module is used for bit 3, the most significant bit. This module is similar to the lower-bit ALU, but it also outputs a `Set` signal. The `Set` signal is used by the `slt `operation to determine whether `A` is less than `B`.

The top-level 4-bit ALU module connects four 1-bit ALU slices together. The carry output from each bit is connected to the carry input of the next bit, forming a ripple-carry structure. The final carry signals are used to detect overflow.

## Zero and Overflow

The `Zero` output is generated using a NOR gate across all four bits of `Result`. If every bit of `Result` is `0`, then `Zero` becomes `1`.

Overflow is detected by comparing the carry out of the most significant bit. If these carry values are different during an arithmetic operation, overflow has occurred. For this ALU, the overflow signal is only enabled for arithmetic operations. This happens outside of the one bit ALUs.

$Overflow = (Carry2 \oplus Carry3).Op0$


# 1 bit ALU 0-2
---
![[2026-04-25-181030_hyprshot.png]]

# 1 bit ALU 3

![[2026-04-25-181030_hyprshot.png]]



# Verilog

```verilog
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

module testALU;
  reg signed [3:0] a;
  reg signed [3:0] b;
  reg [2:0] op;
  wire signed [3:0] result;
  wire zero, overflow;
  alu_unit alu (
      result,
      overflow,
      zero,
      a,
      b,
      op
  );
  initial begin
    $display("op   a        b        result   zero overflow");
    $monitor("%b %b(%d) %b(%d) %b(%d) %b    %b", op, a, a, b, b, result, result, zero, overflow);
    op = 3'b000;
    a  = 4'b0111;
    b  = 4'b0010;  // AND
    #1 op = 3'b001;
    a = 4'b0101;
    b = 4'b0010;  // OR
    #1 op = 3'b010;
    a = 4'b0101;
    b = 4'b0001;  // ADD
    #1 op = 3'b010;
    a = 4'b0111;
    b = 4'b0001;  // ADD overflow (8+1=-8)
    #1 op = 3'b110;
    a = 4'b0101;
    b = 4'b0001;  // SUB
    #1 op = 3'b110;
    a = 4'b1111;
    b = 4'b0001;  // SUB
    #1 op = 3'b110;
    a = 4'b1111;
    b = 4'b1000;  // SUB no overflow (-1-(-8)=7)
    #1 op = 3'b110;
    a = 4'b1110;
    b = 4'b0111;  // SUB overflow (-2-7=7)
    #1 op = 3'b111;
    a = 4'b0101;
    b = 4'b0001;  // SLT
    #1 op = 3'b111;
    a = 4'b0001;
    b = 4'b0011;  // SLT
    #1 op = 3'b111;
    a = 4'b1101;
    b = 4'b0110;  // SLT overflow (-3-6=7 => SLT=0)
    #1 op = 3'b100;
    a = 4'b0101;
    b = 4'b0011;  // NAND

    #1 op = 3'b101;
    a = 4'b0101;
    b = 4'b0011;  // NOR
  end
endmodule


```

# Output

```
op   a        b        result   zero overflow
000 0111( 7) 0010( 2) 0010( 2) 0    0
001 0101( 5) 0010( 2) 0111( 7) 0    0
010 0101( 5) 0001( 1) 0110( 6) 0    0
010 0111( 7) 0001( 1) 1000(-8) 0    1
110 0101( 5) 0001( 1) 0100( 4) 0    0
110 1111(-1) 0001( 1) 1110(-2) 0    0
110 1111(-1) 1000(-8) 0111( 7) 0    0
110 1110(-2) 0111( 7) 0111( 7) 0    1
111 0101( 5) 0001( 1) 0000( 0) 1    0
111 0001( 1) 0011( 3) 0001( 1) 0    0
111 1101(-3) 0110( 6) 0000( 0) 1    1
100 0101( 5) 0011( 3) 1110(-2) 0    0
101 0101( 5) 0011( 3) 1000(-8) 0    0


```