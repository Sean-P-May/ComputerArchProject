// Behavioral model of MIPS, 3-stage pipeline for R-types and addi only
// Implements forwarding
module reg_file (RR1,RR2,WR,WD,RegWrite,RD1,RD2,clock);

  input [1:0] RR1,RR2,WR;
  input [15:0] WD;
  input RegWrite,clock;
  output [15:0] RD1,RD2; //16 bit output

  reg [15:0] Regs[0:3]; //4 Registers

  assign RD1 = Regs[RR1];
  assign RD2 = Regs[RR2];

  initial Regs[0] = 0; //reg 0 always zero

  always @(negedge clock)
    if (RegWrite==1 & WR!=0) //only write when enabled and never write to reg zero 
	Regs[WR] <= WD;

endmodule

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

/*
 * Module: multiplexers4x2
 * Author: Sean May
 * Description:
 *   Implements a 4-to-2 multiplexer using two 2-to-1 multiplexers.
 *   The select input s determines whether the upper or lower
 *   pair of input bits is passed to the output.
 */
module multiplexers4x2 (i,s,out);

  input [3:0] i;
  input s;
  output [1:0] out;

  // Select between i[1] and i[3] for the upper output bit
  multiplexer2x1 mux0 ({i[3], i[1]},s ,out[1]);

  // Select between i[0] and i[2] for the lower output bit
  multiplexer2x1 mux1 ({i[2], i[0]},s ,out[0]);

endmodule

/*
 * Module: multiplexer32x16
 * Author: Sean May
 * Description:
 *   Implements a 32-to-16 multiplexer using sixteen 2-to-1 multiplexers.
 *   The select input s determines whether the lower 16 bits or upper
 *   16 bits of the input are passed to the output.
 */
module multiplexer32x16 (
    i,
    s,
    out
);

  input [31:0] i;
  input s;
  output [15:0] out;

  // Select between corresponding bits of the lower and upper 16-bit halves
  multiplexer2x1 mux0  ({i[16], i[0]},  s, out[0]);
  multiplexer2x1 mux1  ({i[17], i[1]},  s, out[1]);
  multiplexer2x1 mux2  ({i[18], i[2]},  s, out[2]);
  multiplexer2x1 mux3  ({i[19], i[3]},  s, out[3]);
  multiplexer2x1 mux4  ({i[20], i[4]},  s, out[4]);
  multiplexer2x1 mux5  ({i[21], i[5]},  s, out[5]);
  multiplexer2x1 mux6  ({i[22], i[6]},  s, out[6]);
  multiplexer2x1 mux7  ({i[23], i[7]},  s, out[7]);
  multiplexer2x1 mux8  ({i[24], i[8]},  s, out[8]);
  multiplexer2x1 mux9  ({i[25], i[9]},  s, out[9]);
  multiplexer2x1 mux10 ({i[26], i[10]}, s, out[10]);
  multiplexer2x1 mux11 ({i[27], i[11]}, s, out[11]);
  multiplexer2x1 mux12 ({i[28], i[12]}, s, out[12]);
  multiplexer2x1 mux13 ({i[29], i[13]}, s, out[13]);
  multiplexer2x1 mux14 ({i[30], i[14]}, s, out[14]);
  multiplexer2x1 mux15 ({i[31], i[15]}, s, out[15]);

endmodule
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

/*
 * Module: ALU
 * Author: Sean May
 * Description:
 *   Implements a 16-bit ALU using sixteen 1-bit ALU slices.
 *   Supports AND, OR, addition, subtraction, set-less-than,
 *   NOR, and NAND operations. Carry signals ripple between
 *   each bit. The most significant bit generates the SET
 *   signal used by the SLT operation. The zero output is
 *   asserted when the entire result is zero.
 *
 *   ALU Control Format:
 *
 *   op[3]   = Ainvert
 *   op[2]   = Bnegate
 *   op[1:0] = Operation
 *
 *   Ainvert   Bnegate   Operation   Instruction   Opcode
 *      0         0         00          AND         0000
 *      0         0         01          OR          0001
 *      0         0         10          ADD         0010
 *      0         1         10          SUB         0110
 *      0         1         11          SLT         0111
 *      1         1         00          NOR         1100
 *      1         1         01          NAND        1101
 */
module ALU(op, a, b, result, zero);

   input [15:0] a;
   input [15:0] b;
   input [3:0] op;

   output [15:0] result;
   output zero;

   wire set_wire;
   wire overflow;
   wire initial_carry;
   wire [15:0] carryout;

   // Bnegate is also the initial carry-in for subtraction
   buf (initial_carry, op[2]);

   bitALU bit0ALU(a[0], b[0], initial_carry, set_wire, op, result[0], carryout[0]);
   bitALU bit1ALU(a[1], b[1], carryout[0], 1'b0, op, result[1], carryout[1]);
   bitALU bit2ALU(a[2], b[2], carryout[1], 1'b0, op, result[2], carryout[2]);
   bitALU bit3ALU(a[3], b[3], carryout[2], 1'b0, op, result[3], carryout[3]);
   bitALU bit4ALU(a[4], b[4], carryout[3], 1'b0, op, result[4], carryout[4]);
   bitALU bit5ALU(a[5], b[5], carryout[4], 1'b0, op, result[5], carryout[5]);
   bitALU bit6ALU(a[6], b[6], carryout[5], 1'b0, op, result[6], carryout[6]);
   bitALU bit7ALU(a[7], b[7], carryout[6], 1'b0, op, result[7], carryout[7]);
   bitALU bit8ALU(a[8], b[8], carryout[7], 1'b0, op, result[8], carryout[8]);
   bitALU bit9ALU(a[9], b[9], carryout[8], 1'b0, op, result[9], carryout[9]);
   bitALU bit10ALU(a[10], b[10], carryout[9], 1'b0, op, result[10], carryout[10]);
   bitALU bit11ALU(a[11], b[11], carryout[10], 1'b0, op, result[11], carryout[11]);
   bitALU bit12ALU(a[12], b[12], carryout[11], 1'b0, op, result[12], carryout[12]);
   bitALU bit13ALU(a[13], b[13], carryout[12], 1'b0, op, result[13], carryout[13]);
   bitALU bit14ALU(a[14], b[14], carryout[13], 1'b0, op, result[14], carryout[14]);

   bit15ALU bit15ALU(a[15], b[15], carryout[14], 1'b0, op, result[15], carryout[15], set_wire, overflow);

   // Zero is 1 only when all result bits are 0
   nor (zero,
        result[0], result[1], result[2], result[3],
        result[4], result[5], result[6], result[7],
        result[8], result[9], result[10], result[11],
        result[12], result[13], result[14], result[15]);

endmodule

module MainControl (Op, ALUctl, ALUSrc, RegWrite, RegDst); 
  input [3:0] Op;

  output reg [3:0] ALUctl;
  output reg ALUSrc, RegWrite, RegDst;

  // Control bits: RegDst, ALUSrc, RegWrite, ALUctl
  always @(Op) begin
    case (Op)

      4'b0000: begin // add
        ALUctl   <= 4'b0010;
        RegWrite <= 1'b1;
        RegDst   <= 1'b0;
        ALUSrc   <= 1'b0;
      end

      4'b0001: begin //sub
      ALUctl   <= 4'b0110;
      RegWrite <= 1'b1;
      RegDst   <= 1'b0;
      ALUSrc   <= 1'b0;
      end

      4'b0010: begin // and
      ALUctl   <= 4'b0000;
      RegWrite <= 1'b1;
      RegDst   <= 1'b0;
      ALUSrc   <= 1'b0;
      end

      4'b0011: begin //OR
      ALUctl   <= 4'b0001;
      RegWrite <= 1'b1;
      RegDst   <= 1'b0;
      ALUSrc   <= 1'b0;
      end

     4'b0100: begin //NOR
     ALUctl   <= 4'b1100;
     RegWrite <= 1'b1;
     RegDst   <= 1'b0;
     ALUSrc   <= 1'b0;
      end
    
    4'b0101: begin //nand
    ALUctl   <= 4'b1101;
    RegWrite <= 1'b1;
    RegDst   <= 1'b0;
    ALUSrc   <= 1'b0;
    end

    4'b0110: begin //slt
    ALUctl   <= 4'b0111;
    RegWrite <= 1'b1;
    RegDst   <= 1'b0;
    ALUSrc   <= 1'b0;
    end
    
      // R-type
      4'b0111: begin // addi
        ALUctl <= 4'b0010;
        RegWrite <= 1'b1;
        RegDst <= 1'b1;
        ALUSrc <= 1'b1;
      end

      

    endcase
  end

endmodule

module CPU (clock,PC,IFID_IR,IDEX_IR,WD);
  input clock;
  output [15:0] PC,IFID_IR,IDEX_IR,WD;
  reg[15:0] PC, IMemory[0:1023];
  /*initial begin
  
// Program with nop's - no hazards
    IMemory[0]  = 16'b0111_00_01_00001111;  // addi $t1, $0,  15   ($t1=15)
    IMemory[1]  = 16'b0111_00_10_00000111;  // addi $t2, $0,  7    ($t2= 7)
    IMemory[2]  = 16'b0000_0000_0000_0000;  // nop (split into four subfields for better readability)
    IMemory[3]  = 16'b0010_01_10_11_000000;  // and  $t3, $t1, $t2  ($t3= 7)
    IMemory[4]  = 16'b0000_0000_0000_0000;  // nop
    IMemory[5]  = 16'b0001_01_11_10_000000;  // sub  $t2, $t1, $t3  ($t2= 8)
    IMemory[6]  = 16'b0000_0000_0000_0000;  // nop
    IMemory[7]  = 16'b0011_10_11_10_000000;  // or   $t2, $t2, $t3  ($t2=15)
    IMemory[8]  = 16'b0000_0000_0000_0000;  // nop
    IMemory[9]  = 16'b0000_10_11_11_000000;  // add  $t3, $t2, $t3  ($t3=22)
    IMemory[10] = 16'b0000_0000_0000_0000;  // nop
    IMemory[11] = 16'b0100_10_11_01_000000;  // nor  $t1, $t2, $t3  ($t1=-32)
    IMemory[12] = 16'b0110_11_10_01_000000;  // slt  $t1, $t3, $t2  ($t1= 0)
    IMemory[13] = 16'b0110_10_11_01_000000;  // slt  $t1, $t2, $t3  ($t1= 1)
  end*/

  initial begin 
// Program without nop's - wrong results due to data hazards (same as Project 1's test)
    IMemory[0]  = 16'b0111_00_01_00001111;  // addi $t1, $0,  15   ($t1=15)
    IMemory[1]  = 16'b0111_00_10_00000111;  // addi $t2, $0,  7    ($t2= 7)
    IMemory[2]  = 16'b0010_01_10_11_000000;  // and  $t3, $t1, $t2  ($t3= 7)
    IMemory[3]  = 16'b0001_01_11_10_000000;  // sub  $t2, $t1, $t3  ($t2= 8)
    IMemory[4]  = 16'b0011_10_11_10_000000;  // or   $t2, $t2, $t3  ($t2=15)
    IMemory[5]  = 16'b0000_10_11_11_000000;  // add  $t3, $t2, $t3  ($t3=22)
    IMemory[6] = 16'b0100_10_11_01_000000;  // nor  $t1, $t2, $t3  ($t1=-32)
    IMemory[7] = 16'b0110_11_10_01_000000;  // slt  $t1, $t3, $t2  ($t1= 0)
    IMemory[8] = 16'b0110_10_11_01_000000;  // slt  $t1, $t2, $t3  ($t1= 1)
  end

//====== PIPELINE ====== 
//=== IF STAGE ===
   wire [15:0] NextPC;
   wire Unused, Zero;
   // reg[15:0] PC, IMemory[0:1023];
//--------------------------------
   reg[15:0] IFID_IR;
//--------------------------------
   ALU fetch (4'b0010,PC,16'd2,NextPC,Unused);

//=== ID STAGE ===
   wire [6:0] Control;
   wire [15:0] RD1,RD2,SignExtend,WD;
   wire [15:0] FWD_RD1,FWD_RD2; // Outputs of the forwarding muxes
   reg [15:0] IDEX_IR; // For monitoring the pipeline
   reg IDEX_RegWrite,IDEX_ALUSrc,IDEX_RegDst;
   reg [3:0]  IDEX_ALUctl;
   reg [15:0] IDEX_RD1,IDEX_RD2,IDEX_SignExt;
   reg [1:0]  IDEX_rt,IDEX_rd;
   wire [1:0] WR;
   reg_file rf (IFID_IR[11:10],IFID_IR[9:8],WR,WD,IDEX_RegWrite,RD1,RD2,clock); 
   MainControl MainCtr (
    .Op(IFID_IR[15:12]),
    .ALUctl(Control[3:0]),
    .ALUSrc(Control[5]),
    .RegWrite(Control[4]),
    .RegDst(Control[6])
); 
   assign SignExtend = {{8{IFID_IR[7]}},IFID_IR[7:0]}; 

//=== EXE STAGE ===
   wire [15:0] B,ALUOut;
   ALU ex (IDEX_ALUctl, IDEX_RD1, B, ALUOut, Zero);
   

  multiplexer32x16 ALUSrcMux (
      {IDEX_SignExt, IDEX_RD2},
      IDEX_ALUSrc,
      B
  );

  multiplexers4x2 RegDstMux (
      {IDEX_rt, IDEX_rd},
      IDEX_RegDst,
      WR
  );
      // RegDst Mux 
   assign WD = ALUOut;

// Forwarding multiplexers
   assign FWD_RD1 = (IDEX_RegWrite && WR==IFID_IR[11:10]) ? ALUOut: RD1;
   assign FWD_RD2 = (IDEX_RegWrite && WR==IFID_IR[9:0]) ? ALUOut: RD2;

   initial begin //running the pipeline
    PC = 0;
    IFID_IR = 0; // clear pipeline register to avoid forwarding from empty pipeline
    IDEX_RegWrite = 0; 
   end

// Running the pipeline
   always @(negedge clock) begin

// Stage 1 - IF
    PC <= NextPC;
    IFID_IR <= IMemory[PC>>1];

// Stage 2 - ID
    IDEX_IR <= IFID_IR; // For monitoring the pipeline
    {IDEX_RegDst,IDEX_ALUSrc,IDEX_RegWrite,IDEX_ALUctl} <= Control;    

//  No Forwarding
    IDEX_RD1 <= RD1; 
    IDEX_RD2 <= RD2;

//  Forwarding
//  IDEX_RD1 <= FWD_RD1; 
//  IDEX_RD2 <= FWD_RD2;

    IDEX_SignExt <= SignExtend; 
    IDEX_rt <= IFID_IR[9:8];
    IDEX_rd <= IFID_IR[7:6];

// Stage 3 - EX
// No transfers needed here - on negedge WD is written into register WR
  end
endmodule

module test ();
  reg clock;
  wire signed [15:0] PC,IFID_IR,IDEX_IR,WD;
  CPU test_cpu(clock,PC,IFID_IR,IDEX_IR,WD);
  always #1 clock = ~clock;
  initial begin
    $display ("PC  IFID_IR   IDEX_IR   WD");
    $monitor ("%2d  %h      %h     %2d",PC,IFID_IR,IDEX_IR,WD);
    clock = 1;
    #30 $finish;
  end
endmodule

/* Output
Program with nop's
---------------------------
 PC  IFID_IR   IDEX_IR   WD
 0  00000000  xxxxxxxx   x
 4  2009000f  00000000   x
 8  200a0007  2009000f  15
12  00000000  200a0007   7
16  012a5824  00000000   0
20  00000000  012a5824   7
24  012b5022  00000000   0
28  00000000  012b5022   8
32  014b5025  00000000   0
36  00000000  014b5025  15
40  014b5820  00000000   0
44  00000000  014b5820  22
48  014b4827  00000000   0
52  016a482a  014b4827  -32
56  014b482a  016a482a   0
60  xxxxxxxx  014b482a   1

Program without nop's
--------------------------
PC  IFID_IR   IDEX_IR   WD
 0  00000000  xxxxxxxx   x
 4  2009000f  00000000   x
 8  200a0007  2009000f  15
12  012a5824  200a0007   7
16  012b5022  012a5824   X
20  014b5025  012b5022   x
24  014b5820  014b5025   X
28  014b4827  014b5820   x
32  016a482a  014b4827   X
36  014b482a  016a482a   X
40  xxxxxxxx  014b482a   X
44  xxxxxxxx  xxxxxxxx   X
48  xxxxxxxx  xxxxxxxx   X
52  xxxxxxxx  xxxxxxxx   X
56  xxxxxxxx  xxxxxxxx   X
60  xxxxxxxx  xxxxxxxx   X
*/