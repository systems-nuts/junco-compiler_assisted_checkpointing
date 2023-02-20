// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.2 (lin64) Build 3367213 Tue Oct 19 02:47:39 MDT 2021
// Date        : Wed Feb 15 16:40:06 2023
// Host        : mfrance-desktop running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bd_22c0_adder_check_gpio_0_sim_netlist.v
// Design      : bd_22c0_adder_check_gpio_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xcu50-fsvh2104-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_22c0_adder_check_gpio_0,c_addsub_v12_0_14,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_addsub_v12_0_14,Vivado 2021.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (A,
    S);
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [15:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 s_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME s_intf, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency bitwidth format long minimum {} maximum {}} value 16} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type generated dependency signed format bool minimum {} maximum {}} value FALSE}}}} DATA_WIDTH 16}" *) output [15:0]S;

  wire [15:0]A;
  wire [15:0]S;
  wire NLW_U0_C_OUT_UNCONNECTED;

  (* C_BORROW_LOW = "1" *) 
  (* C_CE_OVERRIDES_BYPASS = "1" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_IMPLEMENTATION = "0" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "virtexuplusHBM" *) 
  (* KEEP_HIERARCHY = "soft" *) 
  (* c_a_type = "1" *) 
  (* c_a_width = "16" *) 
  (* c_add_mode = "0" *) 
  (* c_ainit_val = "0" *) 
  (* c_b_constant = "1" *) 
  (* c_b_type = "1" *) 
  (* c_b_value = "0010010011100110" *) 
  (* c_b_width = "16" *) 
  (* c_bypass_low = "0" *) 
  (* c_has_bypass = "0" *) 
  (* c_has_c_in = "0" *) 
  (* c_has_c_out = "0" *) 
  (* c_has_ce = "0" *) 
  (* c_has_sclr = "0" *) 
  (* c_has_sinit = "0" *) 
  (* c_has_sset = "0" *) 
  (* c_latency = "0" *) 
  (* c_out_width = "16" *) 
  (* c_sinit_val = "0" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_addsub_v12_0_14 U0
       (.A(A),
        .ADD(1'b1),
        .B({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .BYPASS(1'b0),
        .CE(1'b1),
        .CLK(1'b0),
        .C_IN(1'b0),
        .C_OUT(NLW_U0_C_OUT_UNCONNECTED),
        .S(S),
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
iNiDb0ekPhRUbs/MzEotkv91aS3Hn7NpPOvNwhBA71ib54e/iuFgxDWsHQhG//uPFNOQcsw48NJ/
Jex9v3jJpOAvrsbpE1xtyr06RPHTtBrhLn5oy/JPLRnDikCjDL7pl2nz8/4NFppZ4IOdMQSsgZ6s
7cLy3ssFtw8YHgZpBBI=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
xMdWfJ9yC+dW7Z4tqvPOuJC1+I94TxwMeGVXcRxTpVQudL778iGxfViPG7+xFYupI1L28MxOHog5
8UcMSrFy49thnK0phUnIHj0aC6gyX5BTyX9O2yqRn+Tb0ViZwaw8RNb32PlwlnlwQ/6N6ZU9Y9aG
YFAdhmgN+2Xk4zUSzRuS4Fkh8aeMb+9XdKOXvagJC/n45GdxH8sqkEUbk/QiV8gGerqj5/G5/GwS
QvuOB3Sq1YSyUp1D7w4IQ4bJiFJESFOi5U2UE7u1h+1gzpJDnRrR1s84sELZRdUDynvMahqLleXZ
IWFY2+0qfSJmtHyzvV5D7u27zKevnVVSjKft+g==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
BXcxoAPS0tOe7iNiaiBkfnEQ6RK9h9ZdYl0ZQZ9gD+ivSxvHRqUQaNUJXADK+j/yHS3kFc9O9bHv
9apdYXON7IMZ9RLTfkh4tIbx4BGrm/PD1bNIEZES7Ggj/xNmgG+KoydQMFTsML7SQ21p7edBUfV2
az9eYYO2SbJM4Vnex/4=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PWOAiRdoP7UJP31mBYgem1wyfxKBGPCYYuy7qK1OPyroUHrsrRm0rZWFQbakJzsfCiqiBbes1Pdp
FoS53FX/0oO/nGzrbleR9IKNRGwjSKaUMfAwPhBe3I31YsUwdVUMEm0draA/0Bu0frhCP/0jFhKQ
HicTG99WiRHsLh+F6Xz6QXtxjRhNhWEmp7tK+Z+a7g+N8LWRI2JpIQ272d9VQ61BaLlYfCqHUkHw
ThTl6gfzihr1Ngg2QM5mtIXn8OB6+fq3s9W2CR6TBAvGrx17Z8ej+u3fxiXxC+hBvQjWJ6ri0Top
bA0fhxTpucHxWUd+X+DhmNLTh/f+O3HV2Qpcsw==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
botoKE8YfJkzZ/fegvRBoauY+UFblsqeTMPajI8WL2DBCRzCZJ9Qk/AYzzg+PUnrWUsoMrTJBGyn
gi8WNpzpMX8vvcpKlw8goBzVjdTNmI1s9S0E+VsI1yVv6BIJNCpUF+5EMLdX8/DiJlnuRanoMrvC
KGgBmcKqG7oRhK8xe5pzt7tMew5ocXeCa73sQSLmXuEgUF3UVgaIEpZcsxwiXmE2Av9Y6V+8CSvq
+Kfe/xfivs0EagmHnRhzTM0RvsI3OWHwM7UoosrQd3SFdhg0MFJga+3RHNAK/K7GDL4b3RHD5bQj
9a1gFdowA72kPKeFSBiYlgX6Vk9Uwm2F+V/kSg==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_01", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
lihXgVbpHCLec3zc0ec/06bvVG8syHdsLieKcT9rurQvsbFuEgs53hupuKiQVpUO75Rlflsu9Uv7
M1kUEvj0hLqSwp51FfBdIFyDn69Y/AR9B3nk5K135817Ii5ef0MMxeTSV36GglTaxPcxRJbXKlei
Nh0/cGeo0C8fqlrdb7l2aLKeeo9GaYgnzabE/VAGK3Kvr/UJbmK2eRfLlPygyEE2Hz4VYkVXisIZ
MLfZuqs0KBE7OdqwtqhW0cv/zMjRCl+Ton6KCq1NDbf5iAJGaVns2C8FlvsDnvW98hupBmOnntWx
+cSxLW5CnVkSSDuLYwSmB/VDFDZoKbAAPHcKWg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
bslnbMuzuE/h0dU1KUmyBtZ9YobdFoUvmIJOrSIMm1QHKHywokHfs/tstG3kbnleE5Ro3QbFvkee
MAslPB9/9GMe/K/9oy/NUwk7CdOKMDnWe6bjAzHdnN6rqGH8LyHfwibusv1+Ggl/dI+eT7fXvxNf
GalIV+qeXkw58Q8O8q/FoJMuwbuwcSGXWGWU+qSZ44Vj4aHHqMw6AvrJ3nWXG1Aa99MNUc7H9KAC
fL/xXWAYYUs0Aqqfj7hdBSkcTp8RLAb0NH2e/+ve6WJ5Y8lWNAyNlqNz/PW/FvxJwZvYCN5ALqAn
XPV0+dZ+1F6SjA2qB8uYqVSHe2sF4AgOSUb0Yg==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
KUnwEk0xEpdk2Q3CoTxn9CRe6h/F7eWo/AjrPR0pRlPkFpPN084BeB9Y0fdrjgkq+3HXC4zvjgDR
HGtLYulQ/DDCcVou7MBx+WsobjDsPw4aytnHFJhdPl1/gu90mG3irpFwUndHqHd5KOIno4hRyyVj
ntNaLqfhtx97ZFT7dzeS4sr9hR5umMXx8eagFMAL0SKuooqN5ma5Kn5yRTlFXeVZaOVeeodaDaTe
u+OLoCcbLeOyuraazX0w05ROt1RWuQhiAHJr5D+PdtFH6PTheFQIQp72F4YJVS/Xw+0kGSBAkqw0
FleW7Pxa+YHT/FS6kuvwJ5uAhLIHGM1453HF6YOB/1TCDOa2ntNezXMJIFtsfvAAHyaSJ2XMNrD3
feFFBLqTImohKBoaNkp7O7foRfLi5R/oAlMMzRg83P/99YLyjfIm3xkD3eia2CAK/2qk4ZtC2JQ3
4aJcd5YcoSYGjVfXix9p+pfKHaa/jbY+Vh5Z3dVT8Romtkzvu5jg+UbJ

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
P0U2cnGBY9QMyeqr0dOgxj1qNLQ9oatsneQM/zp8ImZGMa9l89mK7lP6/iTxsbrSbC19vRKLXHpw
FTJYNfqvgRZhS7DxQb5OwgYRsbNrhsqUkrU6fD4YcLCVJvUsq4FGf2GMp0SBEmXMlu0H57IA3Ycx
grGxw4dQSY2pM7fKezkaKsACbitFQrg/Q6XzNrg49L/dKrBnQzoDIcgA4wyQrdpLLWdScsi34/UM
96uXBX5B4OAKjIMOlIKwRQov3zD06mx28NQD4VizPa1T5UyqFMRb5eW6zlTHzEI6+x7KVH1IEyUn
4tcbk3Sz3i/RmX3lguEbJEV6kLotF8iEhuyTHw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
m+4AnpFJSR4MsB4FTDw9Sr0QkCP6hiKHcqTMal2x901VoujRW2k/8Z3mIITZD3mmCcCn7M70YakT
VSmOP37XH/csnoq9gZmYAJ3TGuKxb0XrfB/lbC8fiJKzxbXpi1Y0W31269mGERB57yPPNEp8+zBk
mCrmW0AW/D8nFFNvCw4f06RX9o7sO2ucvZzFp9vstVyD0Yh9ICUt/Ua2RugZMfrvewwmSTxquXbf
U7TeSyFhyInM3drkQ3/3xrjs7M4HbUXS+AwxVWszQ1VG6WgrM/dtw+sqkStnVpleaTNzNiP/g0fj
U04Y8UNfn6PbvOtXDjcNXRoJHBdMheqz0E//uQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DFIgg3KIG80o92WGm1st+q30tWuaXQVO6RhLmrkDwgBoCqD0m2MsvNUNUjKjfKFDCSYcA1CNZGwQ
NRBuC/pgQ5bbsRDi9GhK5CriR9QzO5wS42aBB4oNNb5DvJ8VeXb3hjgzy4BP/TjJhUlIUbv6PaRG
sdOh5g8LdQlUCpt7wevVT/EDCQxs7sbVBa29AiR2fBV2x5rFjv3nifFFiCHKccCx0G7+nq9crB3g
xTk4EVFMCJMsHgiwOn6xOAEfwBbLuYyHpt0bKmUsxw8ltMLPClPaZQ9o4Aipyr6ymjl94y+W8Clv
4BFaGxFWTUWs92/iR95o06ENRS35j+bZP+eK2A==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 8720)
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
