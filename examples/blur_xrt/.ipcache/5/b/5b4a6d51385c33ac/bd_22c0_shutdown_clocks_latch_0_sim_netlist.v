// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.2 (lin64) Build 3367213 Tue Oct 19 02:47:39 MDT 2021
// Date        : Wed Feb 15 16:40:17 2023
// Host        : mfrance-desktop running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bd_22c0_shutdown_clocks_latch_0_sim_netlist.v
// Design      : bd_22c0_shutdown_clocks_latch_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xcu50-fsvh2104-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_22c0_shutdown_clocks_latch_0,c_shift_ram_v12_0_14,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_shift_ram_v12_0_14,Vivado 2021.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (D,
    CLK,
    CE,
    Q);
  (* x_interface_info = "xilinx.com:signal:data:1.0 d_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME d_intf, LAYERED_METADATA undef" *) input [0:0]D;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:sinit_intf:sset_intf:d_intf:a_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 50000000, FREQ_TOLERANCE_HZ 0, PHASE 0, CLK_DOMAIN cd_ctrl_00, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:clockenable:1.0 ce_intf CE" *) (* x_interface_parameter = "XIL_INTERFACENAME ce_intf, POLARITY ACTIVE_HIGH" *) input CE;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency data_bitwidth format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} DATA_WIDTH 1}" *) output [0:0]Q;

  wire CE;
  wire CLK;
  wire [0:0]D;
  wire [0:0]Q;

  (* C_AINIT_VAL = "0" *) 
  (* C_HAS_CE = "1" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_SYNC_ENABLE = "0" *) 
  (* C_SYNC_PRIORITY = "1" *) 
  (* C_WIDTH = "1" *) 
  (* c_addr_width = "4" *) 
  (* c_default_data = "0" *) 
  (* c_depth = "1" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_a = "0" *) 
  (* c_mem_init_file = "no_coe_file_loaded" *) 
  (* c_opt_goal = "0" *) 
  (* c_parser_type = "0" *) 
  (* c_read_mif = "0" *) 
  (* c_reg_last_bit = "1" *) 
  (* c_shift_type = "0" *) 
  (* c_verbosity = "0" *) 
  (* c_xdevicefamily = "virtexuplusHBM" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_shift_ram_v12_0_14 U0
       (.A({1'b0,1'b0,1'b0,1'b0}),
        .CE(CE),
        .CLK(CLK),
        .D(D),
        .Q(Q),
        .SCLR(1'b0),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2021.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
jG2v9T49tdQSj574iPMluJEMXDDBLjZG2zNs0knuFEWnAaqdikWpECT7idbm6x5qJDGEr9gLczib
BMlJXPjZqnu8LKErXhHN4zQPdW/UyjPdO0+zXLYvmV3+WFLktZAub8fBcb1jkCpceHkVN/L47DJm
0NqTdD1/nSudhZT07x4=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
omahqO8erRajfMFm0CRLhUI+R/ENUIUELpzH+ZyfLsy2pO7X1skXaARvTRzro4Sia2qXbjr8QNb3
MViAT9Vt2JD1wNUIqIRmv+eR7f/YVh6bRoQsbWpOXpQl1juOVD9g+tAx1bZ56jeC7mVwOZeJAaa8
IxNWjmTu0oRtqqAJMdxIcG9OtNntBPODFtkmL1NCgAarTRy9jpe7a2w0My8DJ0uNhTThmoHEEIBo
bjixlKZWJWWjP5wcniMkdJTG5Z3iZgC7gMNUZAeKvdqtju2nicAfNnznUi0W5VL3cX6/FdEAcH+G
Ys4c+etN4i0ZBUiXiGEZYj/w9cNKCBsY7P+SZg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
BGMOv1hIfDXZClH2jp8n3C6zubbI31BJ+kwrJGaaZztKwljIuMW1xBJPpe0MJPPYFMkaV53/NhII
gZsWlMS+0xb+lpZvbabVEp1zVXDkJVlKVyMkCJq6vhJEmbr18QOApnY7ZdxA3jVRmGCFi2bEYf1Z
kFoyZUIhjfxwXvvyEuU=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
RFhMMeHCwF0EBiEVTGToaq7uMNuVhKGBODUna6RhJBlQpi7lEkx19iDGQX3XNWrESsnLrwLfV9im
A3I4KpK+bFFTGE6gd8ITj1j3mlic4zumdZlzEVBoNZZ+SSJwwodEM66lJxJdnQrJinMM1xZHA1a5
0YcrjWjMz7xVm8Ua4GI9wU3Me6E0Ynj9p/dqrSjz/XXXKAX6M906EHwodmgeURgBdSXeizA6viDw
w3/naDGVX5ft95xZIl0/A7HhFWQJ+yCWbdjATsAMq7imhgEeOUeylx6emOXNT9NIYVbcC2XkSScr
sHgVYnOh78bBLsBi0Y6hO8rB/id49SIHRxLMWA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
MdduHUbZpyR3cdxehChW5dF4A5+wRD2Ou4kjhjkNeYucmxhrYKruLxKwIXq2QCxoCidI7Xgns81Q
6i7XKLxu0z01H10d7qtFwwJLfiE6TMbKHI3c8VOd5EtHAfUvRLcIzSwjcH7d4SZKDKkxBxyyUydV
8OdLG5Xk2ObtxWeLNChWwA/TDni5GPHWUu9yFQpCmzwYwYRbzc7Hz5WjhWFdZrtho5+Q7YqEG60J
pkhbQd6+C6mzowXWylqaK/68+04Of8FTEcnhpRPAF8jiTftidlU6IA8raaPlmH9c0vrvm3hRjxKZ
lXlU8sKGJVELhJQUvKyCUuLmaVthLgyj2gE/iQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_01", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GzreOmqw+ToJkUwbUv9qMljwWejCepyirklLAf4Fq41jkLx6zX77fgq6OSLRXS7XGx8z/EsfPhy9
+1EMooqQ4AG4AI0U62jylpi5Rn6ZtBEuqQIqO38cA3l82QBDrD1IT2doIszkRhdUK+FHSgiFaQXj
P2afjajqS7mh8virHcSQ6+SjctNL1rrh+mf6yHBzCfn0mHqbNowj5sTE8yTXTo9E34KTsGdI4Ahc
CEixVBaQ4+WcVfvdqnHkNQUaOGqPBg+dj+BtYcrw0Rs0qG9xf4NN3QJxRAPE3pWU+/fPLKN/T7Jk
0rp/c+B/3k3JDNv0KVCpF8vblZ+c9ic6DM0rcQ==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
IPSD6xR9Fms++sJcBWt5QBDsLb48uh9dp81Y2M19lsza0rYoP6qTo3vr7u38hyzy+SjbAgcHdMWZ
y6cOLdDdOLnwuoZbFicsOPsFneuQTyS2/q+da8ieW5934Y8B8ommWY6chhhcfZFksS+9SkhYpjN5
0kW0XlP/kr7CDRGzoGpmyQkUrOKqk5lu7FGa7ugd00ikvuK1pNIUpVHyiu/50kelTBNZqmBBbF/o
JLgPglue85L1btjSw+C+LtX23P7KLU9VFPo/qupZVpBhJkfFPEcQAh/H8/c+rXQT6BZLqighSpHX
x3Fz0VeyyG758nO4sKlC5VQy/VJUaCfkHLIXfw==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
K7I8bdi0/qD7rf66atUchc8ZKFGrl0PQYAxgRIlLf8znkzNfTAlaHo4O/4bBxrFeBFJIJfxRLnIu
KHaPEZi2L6rFNI/HK97kU1Jc5OyaTDvlIHjVACoQNDqdp5c/WL9hNvDfutzrxwQlait3Fith5Gc8
wn9x/V+PqJzKaqEl3DZkVkWH2RBcw4goDMjI8D49qbCTDD85NpFnFuFb5L2LkFJhgPBwjSxTU4Aq
+ZRqyedj7C5g1Ad5/NJCCE4BlxELcwUDTsAraGsBHURJHM5hH+AQqNiOBdUTt6WpuoSCSaUgDCnR
sZ98jiIuQPnhXgLTzu5DQMadsZoqjky+pFX2rKGbl/RE/EdlbKLYGwyg1a6glipvHrCaORwDKN+U
IVhrGxyQc0UfKpn1DMxpcE6DZKLa4xWCkxcqdcyFc75Xj/xeq0+KqpHtpWDRC8iK9LTJ76+VXksa
hX/CEj61mK/LvJYd54UaztQ4bw9azmt3z2HgDvr3DgybxcoFYU7LkJmg

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
RS5eHe/zrf1NaRRw6+oIutWaSmDK69iMgcW/v0c0jAXkK6Gfn9oUcneOYMuU29zSKn7WGl6NJQnq
rVqlhdJEdRIbbss7IM0WZof3LerrQoWBwNSBUuK/NZ7p/RzoiC1bSUh2LAin7gaspBvAHXr1rvKx
OOwD527zrdbhnPOu4uEWGvTwfI9ImNTCS/aMTdHCC6ZqGXuGhtpS9hyDih3a0JoaAF7irmu2GA35
My5/Y2Xwtc3WZ7SgvhS4KtEKavOO9H1WAWgS2u7IUDyJ0YbyfMpIWSa6xjACUk9l5HFYF0UE+Glp
lJJewBk6oeCeXVBfe37oSeo8ZwzHMvpzK7dUGA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
RqbHGjpC1K87CKlp5Cv3BAVsJgaDxF9D43+tpA/c85q+Ql3Y/mlLRLvbitvJOx9U6F5VGj8KjEKC
GewU9z/UFiuU5X4nNWd6DNLaaKD/eAp0mHEGuohfgoDLEZyJgkL5wCCGLqCLmnkrtRB83Rk+OCeA
B99cPJnYkPI5AMkzJNZlpWUba73IeGO2Y7AczsmjIfW52yKHZS3kHPwD8qA8QzczS/o8NO4VZqC+
OnPTvOaaF/UOp1H1VALkfMpyS3yM3Cs3erM1sLSg0V56lVVeY0N79XRK14FYoaU3dSVp37sY6bgq
Bd2I+ioaL2Ju2C2J9nEDbE3WzQ/hrXEgcuyB9Q==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
5rJGQovBN4mjWgRWexckMLeDNOcqQ+wtDaOJKWLXaWzBkpveZvwUEdLoZL1bbcvyBvbbdrAd2Fa6
M2rVjREY9I6GqtaJhVn8F+fWBoMRhvGhvMsvcO1GGIBH+ilKR/PvZpZ0fslYY1GUU0HVx2xqbCi8
GVifLq/LF71EKPTLiu5u131Um0Ni+gZL2WybL3G9G5idnufzLrfQywzOvsTmJfltM+s8go2/LJM3
4/obhjqBLMBUafIRfRqi0WJk2xp6XT5eAvm+z/eTzkKJz+JmygUw0zJXwzCpWgp3S11CmtNwJsvQ
AkGaalKxM+TMkEjfk15BFUiR9GkBbZzjPiQ26w==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 6816)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
