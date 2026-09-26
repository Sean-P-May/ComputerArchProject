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


module testALU;
   reg signed [15:0] a;
   reg signed [15:0] b;
   reg [3:0] op;
   reg [8*4:1] operation;

   wire signed [15:0] result;
   wire zero;

   ALU alu (op,a,b,result,zero);

   initial begin
    $display("operation op   a                      b                      result                 zero");
    $monitor ("%s      %b %b(%d) %b(%d) %b(%d) %b",
              operation,op,a,a,b,b,result,result,zero);

      operation = "AND "; op = 4'b0000; a = 16'b0000000000000111; b = 16'b0000000000000001;
	#1 operation = "OR  "; op = 4'b0001; a = 16'b0000000000000101; b = 16'b0000000000000010;
	#1 operation = "ADD "; op = 4'b0010; a = 16'b0000000000000100; b = 16'b0000000000000010;
	#1 operation = "ADD "; op = 4'b0010; a = 16'b0000000000000111; b = 16'b0000000000000001;
	#1 operation = "SUB "; op = 4'b0110; a = 16'b0000000000000101; b = 16'b0000000000000011;
	#1 operation = "SUB "; op = 4'b0110; a = 16'b0000000000001111; b = 16'b0000000000000001;
	#1 operation = "SLT "; op = 4'b0111; a = 16'b0000000000000101; b = 16'b0000000000000001;
	#1 operation = "SLT "; op = 4'b0111; a = 16'b1111111111111110; b = 16'b1111111111111111;
	#1 operation = "NOR "; op = 4'b1100; a = 16'b0000000000000101; b = 16'b0000000000000010;
	#1 operation = "NAND"; op = 4'b1101; a = 16'b0000000000000101; b = 16'b0000000000000010;
   end
endmodule
