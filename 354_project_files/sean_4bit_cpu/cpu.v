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
