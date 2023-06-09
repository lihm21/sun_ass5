1	`timescale 1ns / 1ps
2	//****************************************************************
3	//   > 文件名: data_mem.v
4	//   > 描述  ：异步数据存储器模块，采用寄存器搭建而成，类似寄存器堆
5	//   >         同步写，异步读
6	//   > 作者  : LOONGSON
7	//   > 日期  : 2016-04-14
8	//****************************************************************
9	module data_ram(
10	    input         clk,         // 时钟
11	    input  [3:0]  wen,         // 字节写使能
12	    input  [4:0] addr,        // 地址
13	    input  [31:0] wdata,       // 写数据
14	    output reg [31:0] rdata,       // 读数据
15	    
16	    //调试端口，用于读出数据显示
17	    input  [4 :0] test_addr,
18	    output reg [31:0] test_data
19	);
20	    reg [31:0] DM[31:0];//数据存储器，字节地址7'b000_0000~7'b111_1111
21	
22	    //写数据
23	    always @(posedge clk)    // 当写控制信号为1，数据写入内存
24	    begin
25	        if (wen[3])
26	        begin
27	            DM[addr][31:24] <= wdata[31:24];
28	        end
29	    end
30	    always @(posedge clk)
31	    begin
32	        if (wen[2])
33	        begin
34	            DM[addr][23:16] <= wdata[23:16];
35	        end
36	    end
37	    always @(posedge clk)
38	    begin
39	        if (wen[1])
40	        begin
41	            DM[addr][15: 8] <= wdata[15: 8];
42	        end
43	    end
44	    always @(posedge clk)
45	    begin
46	        if (wen[0])
47	        begin
48	            DM[addr][7 : 0] <= wdata[7 : 0];
49	        end
50	    end
51	    
52	    //读数据,取4字节
53	    always @(*)
54	    begin
55	        case (addr)
56	            5'd0 : rdata <= DM[0 ];
57	            5'd1 : rdata <= DM[1 ];
58	            5'd2 : rdata <= DM[2 ];
59	            5'd3 : rdata <= DM[3 ];
60	            5'd4 : rdata <= DM[4 ];
61	            5'd5 : rdata <= DM[5 ];
62	            5'd6 : rdata <= DM[6 ];
63	            5'd7 : rdata <= DM[7 ];
64	            5'd8 : rdata <= DM[8 ];
65	            5'd9 : rdata <= DM[9 ];
66	            5'd10: rdata <= DM[10];
67	            5'd11: rdata <= DM[11];
68	            5'd12: rdata <= DM[12];
69	            5'd13: rdata <= DM[13];
70	            5'd14: rdata <= DM[14];
71	            5'd15: rdata <= DM[15];
72	            5'd16: rdata <= DM[16];
73	            5'd17: rdata <= DM[17];
74	            5'd18: rdata <= DM[18];
75	            5'd19: rdata <= DM[19];
76	            5'd20: rdata <= DM[20];
77	            5'd21: rdata <= DM[21];
78	            5'd22: rdata <= DM[22];
79	            5'd23: rdata <= DM[23];
80	            5'd24: rdata <= DM[24];
81	            5'd25: rdata <= DM[25];
82	            5'd26: rdata <= DM[26];
83	            5'd27: rdata <= DM[27];
84	            5'd28: rdata <= DM[28];
85	            5'd29: rdata <= DM[29];
86	            5'd30: rdata <= DM[30];
87	            5'd31: rdata <= DM[31];
88	        endcase
89	    end
90	    //调试端口，读出特定内存的数据
91	    always @(*)
92	    begin
93	        case (test_addr)
94	            5'd0 : test_data <= DM[0 ];
95	            5'd1 : test_data <= DM[1 ];
96	            5'd2 : test_data <= DM[2 ];
97	            5'd3 : test_data <= DM[3 ];
98	            5'd4 : test_data <= DM[4 ];
99	            5'd5 : test_data <= DM[5 ];
100	            5'd6 : test_data <= DM[6 ];
101	            5'd7 : test_data <= DM[7 ];
102	            5'd8 : test_data <= DM[8 ];
103	            5'd9 : test_data <= DM[9 ];
104	            5'd10: test_data <= DM[10];
105	            5'd11: test_data <= DM[11];
106	            5'd12: test_data <= DM[12];
107	            5'd13: test_data <= DM[13];
108	            5'd14: test_data <= DM[14];
109	            5'd15: test_data <= DM[15];
110	            5'd16: test_data <= DM[16];
111	            5'd17: test_data <= DM[17];
112	            5'd18: test_data <= DM[18];
113	            5'd19: test_data <= DM[19];
114	            5'd20: test_data <= DM[20];
115	            5'd21: test_data <= DM[21];
116	            5'd22: test_data <= DM[22];
117	            5'd23: test_data <= DM[23];
118	            5'd24: test_data <= DM[24];
119	            5'd25: test_data <= DM[25];
120	            5'd26: test_data <= DM[26];
121	            5'd27: test_data <= DM[27];
122	            5'd28: test_data <= DM[28];
123	            5'd29: test_data <= DM[29];
124	            5'd30: test_data <= DM[30];
125	            5'd31: test_data <= DM[31];
126	        endcase
127	    end
128	endmodule
