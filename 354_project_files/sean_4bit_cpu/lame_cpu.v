#! /usr/bin/vvp
:ivl_version "13.0 (stable)" "(v13_0-dirty)";
:ivl_delay_selection "TYPICAL";
:vpi_time_precision + 0;
:vpi_module "/usr/lib/ivl/system.vpi";
:vpi_module "/usr/lib/ivl/vhdl_sys.vpi";
:vpi_module "/usr/lib/ivl/vhdl_textio.vpi";
:vpi_module "/usr/lib/ivl/v2005_math.vpi";
:vpi_module "/usr/lib/ivl/va_math.vpi";
S_0x5557ebd740a0 .scope module, "test_cpu" "test_cpu" 2 78;
 .timescale 0 0;
v0x5557ebd9b070_0 .var "CLK", 0 0;
v0x5557ebd9b110_0 .var "Instruction", 8 0;
v0x5557ebd9b220_0 .net "WriteData", 3 0, L_0x5557ebd9b3b0;  1 drivers
S_0x5557ebd74230 .scope module, "cpu1" "cpu" 2 82, 2 4 0, S_0x5557ebd740a0;
 .timescale 0 0;
    .port_info 0 /INPUT 9 "Instruction";
    .port_info 1 /OUTPUT 4 "WriteData";
    .port_info 2 /INPUT 1 "CLK";
v0x5557ebd9a740_0 .net "A", 3 0, L_0x5557ebd9b7a0;  1 drivers
v0x5557ebd9a820_0 .net "ALUctl", 2 0, v0x5557ebd989e0_0;  1 drivers
v0x5557ebd9a930_0 .net "B", 3 0, L_0x5557ebd9ba70;  1 drivers
v0x5557ebd9aa20_0 .net "CLK", 0 0, v0x5557ebd9b070_0;  1 drivers
v0x5557ebd9ab10_0 .net "IR", 8 0, v0x5557ebd98ff0_0;  1 drivers
v0x5557ebd9ac20_0 .net "Instruction", 8 0, v0x5557ebd9b110_0;  1 drivers
v0x5557ebd9acc0_0 .net "Result", 3 0, v0x5557ebd98260_0;  1 drivers
v0x5557ebd9adb0_0 .net "Sel", 0 0, v0x5557ebd98b80_0;  1 drivers
v0x5557ebd9aea0_0 .net "WriteData", 3 0, L_0x5557ebd9b3b0;  alias, 1 drivers
L_0x5557ebd9b2c0 .part v0x5557ebd98ff0_0, 6, 3;
L_0x5557ebd9b520 .part v0x5557ebd98ff0_0, 2, 4;
L_0x5557ebd9bb30 .part v0x5557ebd98ff0_0, 4, 2;
L_0x5557ebd9bcb0 .part v0x5557ebd98ff0_0, 2, 2;
L_0x5557ebd9bd80 .part v0x5557ebd98ff0_0, 0, 2;
S_0x5557ebd72ec0 .scope module, "alu" "ALU" 2 15, 2 63 0, S_0x5557ebd74230;
 .timescale 0 0;
    .port_info 0 /INPUT 3 "ALUctl";
    .port_info 1 /INPUT 4 "A";
    .port_info 2 /INPUT 4 "B";
    .port_info 3 /OUTPUT 4 "ALUOut";
v0x5557ebd66250_0 .net "A", 3 0, L_0x5557ebd9b7a0;  alias, 1 drivers
v0x5557ebd98260_0 .var "ALUOut", 3 0;
v0x5557ebd98340_0 .net "ALUctl", 2 0, v0x5557ebd989e0_0;  alias, 1 drivers
v0x5557ebd98400_0 .net "B", 3 0, L_0x5557ebd9ba70;  alias, 1 drivers
o0x7f0fced690d8 .functor BUFZ 1, c4<z>; HiZ drive
v0x5557ebd984e0_0 .net "Overflow", 0 0, o0x7f0fced690d8;  0 drivers
o0x7f0fced69108 .functor BUFZ 1, c4<z>; HiZ drive
v0x5557ebd985f0_0 .net "Zero", 0 0, o0x7f0fced69108;  0 drivers
E_0x5557ebd7ba50 .event anyedge, v0x5557ebd98400_0, v0x5557ebd66250_0, v0x5557ebd98340_0;
S_0x5557ebd98730 .scope module, "ctl" "control" 2 12, 2 27 0, S_0x5557ebd74230;
 .timescale 0 0;
    .port_info 0 /INPUT 3 "OP";
    .port_info 1 /OUTPUT 1 "Sel";
    .port_info 2 /OUTPUT 3 "ALUctl";
v0x5557ebd989e0_0 .var "ALUctl", 2 0;
v0x5557ebd98ac0_0 .net "OP", 2 0, L_0x5557ebd9b2c0;  1 drivers
v0x5557ebd98b80_0 .var "Sel", 0 0;
E_0x5557ebd7be30 .event anyedge, v0x5557ebd98ac0_0;
S_0x5557ebd98ca0 .scope module, "instr" "instr_reg" 2 11, 2 18 0, S_0x5557ebd74230;
 .timescale 0 0;
    .port_info 0 /INPUT 9 "Instruction";
    .port_info 1 /OUTPUT 9 "IR";
    .port_info 2 /INPUT 1 "CLK";
v0x5557ebd98f10_0 .net "CLK", 0 0, v0x5557ebd9b070_0;  alias, 1 drivers
v0x5557ebd98ff0_0 .var "IR", 8 0;
v0x5557ebd990d0_0 .net "Instruction", 8 0, v0x5557ebd9b110_0;  alias, 1 drivers
E_0x5557ebd7b780 .event negedge, v0x5557ebd98f10_0;
S_0x5557ebd99210 .scope module, "mux" "quad2x1mux" 2 13, 2 42 0, S_0x5557ebd74230;
 .timescale 0 0;
    .port_info 0 /INPUT 4 "I0";
    .port_info 1 /INPUT 4 "I1";
    .port_info 2 /INPUT 1 "Sel";
    .port_info 3 /OUTPUT 4 "Out";
v0x5557ebd993f0_0 .net "I0", 3 0, L_0x5557ebd9b520;  1 drivers
v0x5557ebd994d0_0 .net "I1", 3 0, v0x5557ebd98260_0;  alias, 1 drivers
v0x5557ebd99590_0 .net "Out", 3 0, L_0x5557ebd9b3b0;  alias, 1 drivers
v0x5557ebd99630_0 .net "Sel", 0 0, v0x5557ebd98b80_0;  alias, 1 drivers
L_0x5557ebd9b3b0 .functor MUXZ 4, L_0x5557ebd9b520, v0x5557ebd98260_0, v0x5557ebd98b80_0, C4<>;
S_0x5557ebd99730 .scope module, "regs" "regfile" 2 14, 2 50 0, S_0x5557ebd74230;
 .timescale 0 0;
    .port_info 0 /INPUT 2 "ReadReg1";
    .port_info 1 /INPUT 2 "ReadReg2";
    .port_info 2 /INPUT 2 "WriteReg";
    .port_info 3 /INPUT 4 "WriteData";
    .port_info 4 /OUTPUT 4 "ReadData1";
    .port_info 5 /OUTPUT 4 "ReadData2";
    .port_info 6 /INPUT 1 "CLK";
L_0x5557ebd9b7a0 .functor BUFZ 4, L_0x5557ebd9b5c0, C4<0000>, C4<0000>, C4<0000>;
L_0x5557ebd9ba70 .functor BUFZ 4, L_0x5557ebd9b860, C4<0000>, C4<0000>, C4<0000>;
v0x5557ebd99a50_0 .net "CLK", 0 0, v0x5557ebd9b070_0;  alias, 1 drivers
v0x5557ebd99b10_0 .net "ReadData1", 3 0, L_0x5557ebd9b7a0;  alias, 1 drivers
v0x5557ebd99bb0_0 .net "ReadData2", 3 0, L_0x5557ebd9ba70;  alias, 1 drivers
v0x5557ebd99c80_0 .net "ReadReg1", 1 0, L_0x5557ebd9bb30;  1 drivers
v0x5557ebd99d20_0 .net "ReadReg2", 1 0, L_0x5557ebd9bcb0;  1 drivers
v0x5557ebd99e50 .array "Regs", 3 0, 3 0;
v0x5557ebd99f10_0 .net "WriteData", 3 0, L_0x5557ebd9b3b0;  alias, 1 drivers
v0x5557ebd99fd0_0 .net "WriteReg", 1 0, L_0x5557ebd9bd80;  1 drivers
v0x5557ebd9a090_0 .net *"_ivl_0", 3 0, L_0x5557ebd9b5c0;  1 drivers
v0x5557ebd9a200_0 .net *"_ivl_10", 3 0, L_0x5557ebd9b900;  1 drivers
L_0x7f0fced20060 .functor BUFT 1, C4<00>, C4<0>, C4<0>, C4<0>;
v0x5557ebd9a2e0_0 .net *"_ivl_13", 1 0, L_0x7f0fced20060;  1 drivers
v0x5557ebd9a3c0_0 .net *"_ivl_2", 3 0, L_0x5557ebd9b660;  1 drivers
L_0x7f0fced20018 .functor BUFT 1, C4<00>, C4<0>, C4<0>, C4<0>;
v0x5557ebd9a4a0_0 .net *"_ivl_5", 1 0, L_0x7f0fced20018;  1 drivers
v0x5557ebd9a580_0 .net *"_ivl_8", 3 0, L_0x5557ebd9b860;  1 drivers
L_0x5557ebd9b5c0 .array/port v0x5557ebd99e50, L_0x5557ebd9b660;
L_0x5557ebd9b660 .concat [ 2 2 0 0], L_0x5557ebd9bb30, L_0x7f0fced20018;
L_0x5557ebd9b860 .array/port v0x5557ebd99e50, L_0x5557ebd9b900;
L_0x5557ebd9b900 .concat [ 2 2 0 0], L_0x5557ebd9bcb0, L_0x7f0fced20060;
    .scope S_0x5557ebd98ca0;
T_0 ;
    %wait E_0x5557ebd7b780;
    %load/vec4 v0x5557ebd990d0_0;
    %store/vec4 v0x5557ebd98ff0_0, 0, 9;
    %jmp T_0;
    .thread T_0;
    .scope S_0x5557ebd98730;
T_1 ;
    %wait E_0x5557ebd7be30;
    %load/vec4 v0x5557ebd98ac0_0;
    %dup/vec4;
    %pushi/vec4 0, 0, 3;
    %cmp/u;
    %jmp/1 T_1.0, 6;
    %dup/vec4;
    %pushi/vec4 1, 0, 3;
    %cmp/u;
    %jmp/1 T_1.1, 6;
    %dup/vec4;
    %pushi/vec4 2, 0, 3;
    %cmp/u;
    %jmp/1 T_1.2, 6;
    %dup/vec4;
    %pushi/vec4 3, 0, 3;
    %cmp/u;
    %jmp/1 T_1.3, 6;
    %dup/vec4;
    %pushi/vec4 4, 0, 3;
    %cmp/u;
    %jmp/1 T_1.4, 6;
    %dup/vec4;
    %pushi/vec4 5, 0, 3;
    %cmp/u;
    %jmp/1 T_1.5, 6;
    %jmp T_1.6;
T_1.0 ;
    %pushi/vec4 10, 0, 4;
    %split/vec4 3;
    %store/vec4 v0x5557ebd989e0_0, 0, 3;
    %store/vec4 v0x5557ebd98b80_0, 0, 1;
    %jmp T_1.6;
T_1.1 ;
    %pushi/vec4 14, 0, 4;
    %split/vec4 3;
    %store/vec4 v0x5557ebd989e0_0, 0, 3;
    %store/vec4 v0x5557ebd98b80_0, 0, 1;
    %jmp T_1.6;
T_1.2 ;
    %pushi/vec4 8, 0, 4;
    %split/vec4 3;
    %store/vec4 v0x5557ebd989e0_0, 0, 3;
    %store/vec4 v0x5557ebd98b80_0, 0, 1;
    %jmp T_1.6;
T_1.3 ;
    %pushi/vec4 9, 0, 4;
    %split/vec4 3;
    %store/vec4 v0x5557ebd989e0_0, 0, 3;
    %store/vec4 v0x5557ebd98b80_0, 0, 1;
    %jmp T_1.6;
T_1.4 ;
    %pushi/vec4 15, 0, 4;
    %split/vec4 3;
    %store/vec4 v0x5557ebd989e0_0, 0, 3;
    %store/vec4 v0x5557ebd98b80_0, 0, 1;
    %jmp T_1.6;
T_1.5 ;
    %pushi/vec4 0, 0, 4;
    %split/vec4 3;
    %store/vec4 v0x5557ebd989e0_0, 0, 3;
    %store/vec4 v0x5557ebd98b80_0, 0, 1;
    %jmp T_1.6;
T_1.6 ;
    %pop/vec4 1;
    %jmp T_1;
    .thread T_1, $push;
    .scope S_0x5557ebd99730;
T_2 ;
    %pushi/vec4 0, 0, 4;
    %ix/load 4, 0, 0;
    %flag_set/imm 4, 0;
    %store/vec4a v0x5557ebd99e50, 4, 0;
    %end;
    .thread T_2;
    .scope S_0x5557ebd99730;
T_3 ;
    %wait E_0x5557ebd7b780;
    %load/vec4 v0x5557ebd99f10_0;
    %load/vec4 v0x5557ebd99fd0_0;
    %pad/u 4;
    %ix/vec4 4;
    %store/vec4a v0x5557ebd99e50, 4, 0;
    %jmp T_3;
    .thread T_3;
    .scope S_0x5557ebd72ec0;
T_4 ;
    %wait E_0x5557ebd7ba50;
    %load/vec4 v0x5557ebd98340_0;
    %dup/vec4;
    %pushi/vec4 0, 0, 3;
    %cmp/u;
    %jmp/1 T_4.0, 6;
    %dup/vec4;
    %pushi/vec4 1, 0, 3;
    %cmp/u;
    %jmp/1 T_4.1, 6;
    %dup/vec4;
    %pushi/vec4 2, 0, 3;
    %cmp/u;
    %jmp/1 T_4.2, 6;
    %dup/vec4;
    %pushi/vec4 6, 0, 3;
    %cmp/u;
    %jmp/1 T_4.3, 6;
    %dup/vec4;
    %pushi/vec4 7, 0, 3;
    %cmp/u;
    %jmp/1 T_4.4, 6;
    %jmp T_4.5;
T_4.0 ;
    %load/vec4 v0x5557ebd66250_0;
    %load/vec4 v0x5557ebd98400_0;
    %and;
    %assign/vec4 v0x5557ebd98260_0, 0;
    %jmp T_4.5;
T_4.1 ;
    %load/vec4 v0x5557ebd66250_0;
    %load/vec4 v0x5557ebd98400_0;
    %or;
    %assign/vec4 v0x5557ebd98260_0, 0;
    %jmp T_4.5;
T_4.2 ;
    %load/vec4 v0x5557ebd66250_0;
    %load/vec4 v0x5557ebd98400_0;
    %add;
    %assign/vec4 v0x5557ebd98260_0, 0;
    %jmp T_4.5;
T_4.3 ;
    %load/vec4 v0x5557ebd66250_0;
    %load/vec4 v0x5557ebd98400_0;
    %sub;
    %assign/vec4 v0x5557ebd98260_0, 0;
    %jmp T_4.5;
T_4.4 ;
    %load/vec4 v0x5557ebd66250_0;
    %load/vec4 v0x5557ebd98400_0;
    %cmp/u;
    %flag_mov 8, 5;
    %jmp/0 T_4.6, 8;
    %pushi/vec4 1, 0, 4;
    %jmp/1 T_4.7, 8;
T_4.6 ; End of true expr.
    %pushi/vec4 0, 0, 4;
    %jmp/0 T_4.7, 8;
 ; End of false expr.
    %blend;
T_4.7;
    %assign/vec4 v0x5557ebd98260_0, 0;
    %jmp T_4.5;
T_4.5 ;
    %pop/vec4 1;
    %jmp T_4;
    .thread T_4, $push;
    .scope S_0x5557ebd740a0;
T_5 ;
    %vpi_call 2 85 "$display", "\012CLK Instruction WriteData\012-------------------------" {0 0 0};
    %vpi_call 2 86 "$monitor", "%b   %b   %d (%b)", v0x5557ebd9b070_0, v0x5557ebd9b110_0, v0x5557ebd9b220_0, v0x5557ebd9b220_0 {0 0 0};
    %delay 1, 0;
    %pushi/vec4 349, 0, 9;
    %store/vec4 v0x5557ebd9b110_0, 0, 9;
    %pushi/vec4 1, 0, 1;
    %store/vec4 v0x5557ebd9b070_0, 0, 1;
    %delay 1, 0;
    %pushi/vec4 0, 0, 1;
    %store/vec4 v0x5557ebd9b070_0, 0, 1;
    %delay 1, 0;
    %pushi/vec4 342, 0, 9;
    %store/vec4 v0x5557ebd9b110_0, 0, 9;
    %pushi/vec4 1, 0, 1;
    %store/vec4 v0x5557ebd9b070_0, 0, 1;
    %delay 1, 0;
    %pushi/vec4 0, 0, 1;
    %store/vec4 v0x5557ebd9b070_0, 0, 1;
    %delay 1, 0;
    %pushi/vec4 91, 0, 9;
    %store/vec4 v0x5557ebd9b110_0, 0, 9;
    %pushi/vec4 1, 0, 1;
    %store/vec4 v0x5557ebd9b070_0, 0, 1;
    %delay 1, 0;
    %pushi/vec4 0, 0, 1;
    %store/vec4 v0x5557ebd9b070_0, 0, 1;
    %end;
    .thread T_5;
# The file index is used to find the file name in the following table.
:file_names 3;
    "N/A";
    "<interactive>";
    "lame_cpu.v";
