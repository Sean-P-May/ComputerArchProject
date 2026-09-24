#### Sean May

## Description of CPU
---
This project implements a 4-bit CPU with four registers and a 9-bit instruction format featuring a 3-bit opcode capable of encoding 8 distinct operations. The CPU is composed of five major components. First, a 9-bit instruction register that latches the current instruction on the clock edge. Second, a control unit that decodes the opcode and generates the appropriate ALU control signals and select line. Third, a 4x4 register file that stores four 4-bit registers and supports two simultaneous read ports and one write port. Fourth, a 4-bit ALU capable of performing eight operations returning a 4-bit result along with overflow and zero flags. Finally, a data write multiplexer that selects between writing the ALU result or an immediate value from the instruction code into the destination register.

 
# Instruction format and Operation Codes.
---
### Instruction Format:

| Bits  | 8-6    | 5-4    | 3-2    | 1-0    |
| ----- | ------ | ------ | ------ | ------ |
| Field | OP     | RS     | RT     | RD     |
| Size  | 3 bits | 2 bits | 2 bits | 2 bits |

#### Load Immediate Instruction

| Bits    | 8-6    | 5-2   | 1-0    |
| ------- | ------ | ----- | ------ |
| Field   | OP     | IMM   | RD     |
| Size    | 3 bits | 4bits | 2 bits |
| Example | 101    | 0111  | 00     |
The example would load 7 into register 0.
#### Opcode Table:

| OP   | Opcode | Operation                 | Description    |
| ---- | ------ | ------------------------- | -------------- |
| ADD  | 000    | R[RD] = R[RS] + R[RT]     | Add            |
| SUB  | 001    | R[RD] = R[RS] - R[RT]     | Subtract       |
| AND  | 010    | R[RD] = R[RS] & R[RT]     | Bitwise AND    |
| OR   | 011    | R[RD] = R[RS] \| R[RT]    | Bitwise OR     |
| SLT  | 100    | R[RD] = R[RS] < R[RT]     | Set Less Than  |
| LI   | 101    | R[RD] = IMM               | Load Immediate |
| NAND | 110    | R[RD] = ~(R[RS] & R[RT])  | Bitwise NAND   |
| NOR  | 111    | R[RD] = ~(R[RS] \| R[RT]) | Bitwise NOR    |

#### Arithmetic example with add

| Field | OP  | RS  | RT  | RD  |
| ----- | --- | --- | --- | --- |
| ADD   | 000 | 01  | 00  | 11  |
This instruction would add the value that's stored in register one and the value that's stored in register zero together and store the result in register three.

# Diagram of CPU
![[Pasted image 20260506202742.png]]



### Instruction register diagram.

![[Pasted image 20260506203040.png]]


### Data write Multiplexer Filled with two 2x1 multiplexers.
![[Pasted image 20260506203629.png]]

![[Pasted image 20260506203537.png]]


## Controller Diagram
![[Pasted image 20260506204423.png]]

|Op|OpCode|ALU (ALB,AL0,AL1)|S|
|---|---|---|---|
|ADD|000|010|1|
|SUB|001|110|1|
|AND|010|000|1|
|OR|011|001|1|
|SLT|100|111|1|
|LI|101|XXX|0|
|NAND|110|100|1|
|NOR|111|101|1|
**ALB:**

|OP2\OP1OP0|00|01|11|10|
|---|---|---|---|---|
|0|0|1|0|0|
|1|1|X|1|1|

ALB=OP2+(OP0⋅OP1′)

---

**AL0:**

|OP2\OP1OP0|00|01|11|10|
|---|---|---|---|---|
|0|1|1|0|0|
|1|1|X|0|0|

AL0 = OP1'.AL0=OP1′

---

**AL1:**

|OP2\OP1OP0|00|01|11|10|
|---|---|---|---|---|
|0|0|0|1|0|
|1|1|X|1|0|

AL1=(OP2⋅OP1′)+(OP1⋅OP0)

---

**S:**

|OP2\OP1OP0|00|01|11|10|
|---|---|---|---|---|
|0|1|1|1|1|
|1|1|0|1|1|

S=OP2′+OP1+OP0′

### ALU Diagrams![[2026-04-25-181030_hyprshot.png]]

![[2026-04-25-180820_hyprshot.png]]


# Register File

---
![[Pasted image 20260506223921.png]]

The register file consists of four 4-bit registers, each built from four D flip-flops. It accepts a 4-bit data input which is written to the register selected by the 2-bit destination register address (RD). A select decoder takes RD and produces four one-hot outputs, each ANDed with the clock to ensure only the selected register is written to at the appropriate time. The register file supports two simultaneous read ports, outputting the contents of any two registers at once using the RS and RT address inputs respectively. Each read port is implemented with a 16-to-4 multiplexer, built from four 4-to-1 multiplexers, each of which is in turn built from two 2-to-1 multiplexers.
### Register
![[Pasted image 20260506223956.png]]


### Select Decoder

![[Pasted image 20260506224042.png]]

### Data Out Multiplexer

![[Pasted image 20260506224221.png]]


#  Verilog

### ALU.v

```Verilog
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


```
### reg_file.v
```verilog

module Mux4to1 (
    O,
    I,
    S
);
  input [0:3] I;
  input [0:1] S;
  output O;

  wire [0:1] W;

  MUX2to1 mux0 (
      W[0],
      {I[0], I[1]},
      S[1]
  );
  MUX2to1 mux1 (
      W[1],
      {I[2], I[3]},
      S[1]
  );
  MUX2to1 mux2 (
      O,
      {W[0], W[1]},
      S[0]
  );

endmodule
;

module DataOutMux16x4 (
    O,
    A,
    B,
    C,
    D,
    S
);
  input [0:3] A, B, C, D;
  input [0:1] S;
  output [0:3] O;

  // Each bit position gets its own 4-to-1 mux
  Mux4to1 m0 (
      O[0],
      {A[0], B[0], C[0], D[0]},
      S
  );
  Mux4to1 m1 (
      O[1],
      {A[1], B[1], C[1], D[1]},
      S
  );
  Mux4to1 m2 (
      O[2],
      {A[2], B[2], C[2], D[2]},
      S
  );
  Mux4to1 m3 (
      O[3],
      {A[3], B[3], C[3], D[3]},
      S
  );

endmodule
;

module Register (
    O,
    D,
    CLK
);

  input [0:3] D;
  input CLK;
  output [0:3] O;


  D_flip_flop FF0 (
      D[0],
      CLK,
      O[0]
  );
  D_flip_flop FF1 (
      D[1],
      CLK,
      O[1]
  );
  D_flip_flop FF2 (
      D[2],
      CLK,
      O[2]
  );
  D_flip_flop FF3 (
      D[3],
      CLK,
      O[3]
  );
endmodule
;


module Select_Decoder (
    w,
    s
);
  input [0:1] s;
  output [0:3] w;

  wire [0:1] not_s;

  not not0 (not_s[0], s[0]);
  not not1 (not_s[1], s[1]);

  and and0 (w[0], not_s[0], not_s[1]);
  and and1 (w[1], not_s[0], s[1]);
  and and2 (w[2], s[0], not_s[1]);
  and and3 (w[3], s[0], s[1]);

endmodule
;



module reg_file (
    A,
    B,
    D,
    _RD,
    _RS,
    _RT,
    CLK
);
  output [0:3] A, B;
  input [0:3] D;
  input [0:1] _RD, _RS, _RT;
  input CLK;

  wire [0:3] select_decoder_wire, 
              clk_and_select_decoder_wire,
              reg_out_a, 
              reg_out_b, 
              reg_out_c, 
              reg_out_d;
  Select_Decoder select_decoder (
      select_decoder_wire,
      _RD
  );


  and and0 (
      clk_and_select_decoder_wire[0], select_decoder_wire[0], CLK
  ), and1 (
      clk_and_select_decoder_wire[1], select_decoder_wire[1], CLK
  ), and2 (
      clk_and_select_decoder_wire[2], select_decoder_wire[2], CLK
  ), and3 (
      clk_and_select_decoder_wire[3], select_decoder_wire[3], CLK
  );


  Register reg_a (
      reg_out_a,
      D,
      clk_and_select_decoder_wire[0]
  );
  Register reg_b (
      reg_out_b,
      D,
      clk_and_select_decoder_wire[1]
  );
  Register reg_c (
      reg_out_c,
      D,
      clk_and_select_decoder_wire[2]
  );
  Register reg_d (
      reg_out_d,
      D,
      clk_and_select_decoder_wire[3]
  );

  DataOutMux16x4 dataOutMux16x4_0 (
      A,
      reg_out_a,
      reg_out_b,
      reg_out_c,
      reg_out_d,
      _RS
  );
  DataOutMux16x4 dataOutMux16x4_1 (
      B,
      reg_out_a,
      reg_out_b,
      reg_out_c,
      reg_out_d,
      _RT
  );

endmodule

```


## cpu.v

```verilog
module D_flip_flop (
    D,
    CLK,
    Q
);
  input D, CLK;
  output Q;
  wire CLK1, Y;
  not not1 (CLK1, CLK);
  D_latch
      D1 (
          D,
          CLK,
          Y
      ),
      D2 (
          Y,
          CLK1,
          Q
      );
endmodule


module D_latch (
    D,
    C,
    Q
);
  input D, C;
  output Q;
  wire x, y, D1, Q1;
  nand nand1 (x, D, C), nand2 (y, D1, C), nand3 (Q, x, Q1), nand4 (Q1, y, Q);
  not not1 (D1, D);
endmodule


module instr_reg (
    Instruction,
    IR,
    CLK
);
  input [8:0] Instruction;
  input CLK;
  output [8:0] IR;

  D_flip_flop ff0 (
      Instruction[0],
      CLK,
      IR[0]
  );
  D_flip_flop ff1 (
      Instruction[1],
      CLK,
      IR[1]
  );
  D_flip_flop ff2 (
      Instruction[2],
      CLK,
      IR[2]
  );
  D_flip_flop ff3 (
      Instruction[3],
      CLK,
      IR[3]
  );
  D_flip_flop ff4 (
      Instruction[4],
      CLK,
      IR[4]
  );
  D_flip_flop ff5 (
      Instruction[5],
      CLK,
      IR[5]
  );
  D_flip_flop ff6 (
      Instruction[6],
      CLK,
      IR[6]
  );
  D_flip_flop ff7 (
      Instruction[7],
      CLK,
      IR[7]
  );
  D_flip_flop ff8 (
      Instruction[8],
      CLK,
      IR[8]
  );

endmodule

module MUX2to1 (
    O,
    I,
    S
);
  input [0:1] I;
  input S;
  output O;

  wire [0:1] IandS;
  wire not_S;

  not not_ (not_S, S);

  and and0 (IandS[0], I[0], not_S), and1 (IandS[1], I[1], S);

  or or_ (O, IandS[0], IandS[1]);

endmodule
;



module DataWriteMUX (
    W,
    IR,
    D,
    S
);
  input S;
  input [0:3] IR, D;
  output [0:3] W;
  MUX2to1 mux0 (
      W[0],
      {IR[0], D[0]},
      S
  );
  MUX2to1 mux1 (
      W[1],
      {IR[1], D[1]},
      S
  );
  MUX2to1 mux2 (
      W[2],
      {IR[2], D[2]},
      S
  );
  MUX2to1 mux3 (
      W[3],
      {IR[3], D[3]},
      S
  );
endmodule

module control (
    ALU_OP,
    OP,
    S
);
  input [2:0] OP;
  output [2:0] ALU_OP;
  output S;

  wire [2:0] not_OP;
  wire [3:0] and_out_wires;

  not not0 (not_OP[0], OP[0]), not1 (not_OP[1], OP[1]), not2 (not_OP[2], OP[2]);

  // AL0 = ~OP1
  buf buf0 (ALU_OP[1], not_OP[1]);

  // S = ~OP0 + OP1 + ~OP2
  or or_ (S, not_OP[0], OP[1], not_OP[2]);

  // ALB = OP2 + (OP0 & ~OP1)
  and and0 (and_out_wires[0], OP[0], not_OP[1]);
  or or0 (ALU_OP[2], OP[2], and_out_wires[0]);

  // AL1 = (OP2 & ~OP1) + (OP1 & OP0)
  and and2 (and_out_wires[2], OP[2], not_OP[1]), and3 (and_out_wires[3], OP[1], OP[0]);
  or or1 (ALU_OP[0], and_out_wires[2], and_out_wires[3]);

endmodule
module cpu (
    Instruction,
    WriteData,
    CLK
);
  input [8:0] Instruction;
  input CLK;
  output [3:0] WriteData;

  wire [8:0] IR;
  wire [3:0] A, B, D, Result;
  wire [2:0] ALUctl;
  wire S, OverFlow, Zero;

  instr_reg instr (
      Instruction,
      IR,
      CLK
  );

  // IR[8:6] = OP2,OP1,OP0
  // OP is IR[0:2] (big-endian)
  control ctl (
      ALUctl,
      IR[8:6],
      S
  );

  // RT=IR[3:4], RS=IR[5:6], RD=IR[7:8]
  DataWriteMUX datawriteMUX (
      D,
      IR[5:2],
      Result,
      S
  );

  reg_file reg_file_ (
      A,
      B,
      D,
      IR[1:0],  // _RD
      IR[5:4],  // _RS
      IR[3:2],  // _RT
      CLK
  );

  alu_unit alu (
      Result,
      OverFlow,
      Zero,
      A,
      B,
      ALUctl
  );

  assign WriteData = D;
endmodule

module test_cpu;
  reg [8:0] Instruction;
  reg CLK;
  wire [3:0] WriteData;
  cpu cpu1 (
      Instruction,
      WriteData,
      CLK
  );
  initial begin
    $display("\nCLK Instruction WriteData\n-------------------------");
    $monitor("%b   %b   %d (%b)", CLK, Instruction, WriteData, WriteData);
    ;
    #1 Instruction = 9'b101_0111_01;  // li $t1, 7
    CLK = 1;
    #1 CLK = 0;

    #1 Instruction = 9'b101_0101_10;  // li $t2, 5
    CLK = 1;
    #1 CLK = 0;

    #1 Instruction = 9'b001_01_10_11;  // sub $t3, $t1, $t2 # 7-5=2
    CLK = 1;
    #1 CLK = 0;

    #1 Instruction = 9'b101_1010_11;  // li $t3, 10
    CLK = 1;
    #1 CLK = 0;

    #1 Instruction = 9'b011_10_11_10;  // or $t2, $t2, $t3 # 5|10=15
    CLK = 1;
    #1 CLK = 0;

    #1 Instruction = 9'b010_10_11_11;  // and $t3, $t2, $t3 # 15&10=10
    CLK = 1;
    #1 CLK = 0;

    #1 Instruction = 9'b100_11_10_10;  // slt $t2, $t3, $t2 # 10<15=1
    CLK = 1;
    #1 CLK = 0;

    #1 Instruction = 9'b000_11_10_10;  // add $t2, $t3, $t2 # 10+1=11
    CLK = 1;
    #1 CLK = 0;

    #1 Instruction = 9'b000_01_10_11;  // add $t3, $t1, $t2 # 7+(-5)=2
    CLK = 1;
    #1 CLK = 0;

    #1 Instruction = 9'b100_10_11_01;  // slt $t1, $t2, $t3 # -5<2=1
    CLK = 1;
    #1 CLK = 0;
  end
endmodule

```

## Output:
```
CLK Instruction WriteData
-------------------------
x   xxxxxxxxx    x (xxxx)
1   101011101    x (xxxx)
0   101011101    7 (0111)
1   101010110    7 (0111)
0   101010110    5 (0101)
1   001011011    5 (0101)
0   001011011    2 (0010)
1   101101011    2 (0010)
0   101101011   10 (1010)
1   011101110   10 (1010)
0   011101110   15 (1111)
1   010101111   15 (1111)
0   010101111   10 (1010)
1   100111010   10 (1010)
0   100111010    1 (0001)
1   000111010    1 (0001)
0   000111010   11 (1011)
1   000011011   11 (1011)
0   000011011    2 (0010)
1   100101101    2 (0010)
0   100101101    1 (0001)```