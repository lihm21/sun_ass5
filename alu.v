1	`timescale 1ns / 1ps
2	//**************************************************************
3	//   > 文件名: alu.v
4	//   > 描述  ：ALU模块，可做12种操作
5	//   > 作者  : LOONGSON
6	//   > 日期  : 2016-04-14
7	//**************************************************************
8	module alu(
9	    input  [11:0] alu_control,  // ALU控制信号
10	    input  [31:0] alu_src1,     // ALU操作数1,为补码
11	    input  [31:0] alu_src2,     // ALU操作数2，为补码
12	    output [31:0] alu_result    // ALU结果
13	    );
14	　
15	    // ALU控制信号，独热码
16	    wire alu_add;   //加法操作
17	    wire alu_sub;   //减法操作
18	    wire alu_slt;   //有符号比较，小于置位，复用加法器做减法
19	    wire alu_sltu;  //无符号比较，小于置位，复用加法器做减法
20	    wire alu_and;   //按位与
21	    wire alu_nor;   //按位或非
22	    wire alu_or;    //按位或
23	    wire alu_xor;   //按位异或
24	    wire alu_sll;   //逻辑左移
25	    wire alu_srl;   //逻辑右移
26	    wire alu_sra;   //算术右移
27	    wire alu_lui;   //高位加载
28	　
29	    assign alu_add  = alu_control[11];
30	    assign alu_sub  = alu_control[10];
31	    assign alu_slt  = alu_control[ 9];
32	    assign alu_sltu = alu_control[ 8];
33	    assign alu_and  = alu_control[ 7];
34	    assign alu_nor  = alu_control[ 6];
35	    assign alu_or   = alu_control[ 5];
36	    assign alu_xor  = alu_control[ 4];
37	    assign alu_sll  = alu_control[ 3];
38	    assign alu_srl  = alu_control[ 2];
39	    assign alu_sra  = alu_control[ 1];
40	    assign alu_lui  = alu_control[ 0];
41	　
42	    wire [31:0] add_sub_result;
43	    wire [31:0] slt_result;
44	    wire [31:0] sltu_result;
45	    wire [31:0] and_result;
46	    wire [31:0] nor_result;
47	    wire [31:0] or_result;
48	    wire [31:0] xor_result;
49	    wire [31:0] sll_result;
50	    wire [31:0] srl_result;
51	    wire [31:0] sra_result;
52	    wire [31:0] lui_result;
53	　
54	    assign and_result = alu_src1 & alu_src2;  //与结果为两数按位与
55	    assign or_result  = alu_src1 | alu_src2;  //或结果为两数按位或
56	    assign nor_result = ~or_result;           //或非结果为或结果取反
57	    assign xor_result = alu_src1 ^ alu_src2;//异或结果为两数按位异或
58	        assign lui_result    = {alu_src2[15:0], 16'd0};//src2低16位装载至高16位
59	　
60	//-----{加法器}begin
61	//add,sub,slt,sltu均使用该模块
62	    wire [31:0] adder_operand1;
63	    wire [31:0] adder_operand2;
64	    wire        adder_cin     ;
65	    wire [31:0] adder_result  ;
66	    wire        adder_cout    ;
67	    assign adder_operand1 = alu_src1; 
68	    assign adder_operand2 = alu_add ? alu_src2 : ~alu_src2; 
69	    assign adder_cin      = ~alu_add; //减法需要cin 
70	    adder adder_module(
71	    .operand1(adder_operand1),
72	    .operand2(adder_operand2),
73	    .cin     (adder_cin     ),
74	    .result  (adder_result  ),
75	    .cout    (adder_cout    )
76	    );
77	　
78	    //加减结果
79	    assign add_sub_result = adder_result;
80	　
81	        //slt结果
82	        //adder_src1[31] adder_src2[31] adder_result[31]
83	        //       0             1           X(0或1)      "正-负"，显然小于不成立
84	        //       0             0             1           相减为负，说明小于
85	        //       0             0             0           相减为正，说明不小于
86	        //       1             1             1           相减为负，说明小于
87	        //       1             1             0           相减为正，说明不小于
88	        //       1             0           X(0或1)      "负-正"，显然小于成立
89	    assign slt_result[31:1] = 31'd0;
90	    assign slt_result[0]=(alu_src1[31] & ~alu_src2[31]) | 
91	(~(alu_src1[31]^alu_src2[31]) & adder_result[31]);
92	　
93	    //sltu结果
94	    //对于32位无符号数比较，最高位前填0作为符号位，可转为
95	//33位有符号数（{1'b0,src1}和{1'b0,src2}）的比较
96	//故，33位正数相减，需要对{1'b0,src2}取反,
97	//即需要{1'b0,src1}+{1'b1,~src2}+cin
98	    //但此处用的为32位加法器，只做了运算: src1 + ~src2 + cin
99	    //32位加法的结果为{adder_cout,adder_result},
100	//则33位加法结果应该为{adder_cout+1'b1,adder_result}
101	    //对比slt结果注释，知道，此时判断大小属于第二三种情况，
102	//即源操作数1符号位为0，源操作数2符号位为0
103	    //结果的符号位为1，说明小于，即adder_cout+1'b1为2'b01，
104	//即adder_cout为0
105	    assign sltu_result = {31'd0, ~adder_cout};
106	//-----{加法器}end
107	　
108	//-----{移位器}begin
109	    // 移位分三步进行，
110	    // 第一步根据移位量低2位即[1:0]位做第一次移位，
111	    // 第二步在第一次移位基础上根据移位量[3:2]位做第二次移位，
112	    // 第三步在第二次移位基础上根据移位量[4]位做第三次移位。
113	    wire [4:0] shf;
114	    assign shf = alu_src1[4:0];
115	    wire [1:0] shf_1_0;
116	    wire [1:0] shf_3_2;
117	    assign shf_1_0 = shf[1:0];
118	    assign shf_3_2 = shf[3:2];
119	    
120	    // 逻辑左移
121	    wire [31:0] sll_step1;
122	    wire [31:0] sll_step2;
123	// 依据shf[1:0],左移0、1、2、3位
124	    assign sll_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                   
125	              | {32{shf_1_0 == 2'b01}} & {alu_src2[30:0], 1'd0}     
126	              | {32{shf_1_0 == 2'b10}} & {alu_src2[29:0], 2'd0}     
127	              | {32{shf_1_0 == 2'b11}} & {alu_src2[28:0], 3'd0};    
128	// 依据shf[3:2],将第一次移位结果左移0、4、8、12位
129	    assign sll_step2 = {32{shf_3_2 == 2'b00}} & sll_step1                  
130	            | {32{shf_3_2 == 2'b01}} & {sll_step1[27:0], 4'd0}    
131	            | {32{shf_3_2 == 2'b10}} & {sll_step1[23:0], 8'd0}    
132	            | {32{shf_3_2 == 2'b11}} & {sll_step1[19:0], 12'd0};  
133	// 依据shf[4],将第二次移位结果左移0、16位
134	    assign sll_result = shf[4] ? {sll_step2[15:0], 16'd0} : sll_step2;     
135	　
136	    // 逻辑右移
137	    wire [31:0] srl_step1;
138	    wire [31:0] srl_step2;
139	// 依据shf[1:0],右移0、1、2、3位，高位补0
140	    assign srl_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                    
141	              | {32{shf_1_0 == 2'b01}} & {1'd0, alu_src2[31:1]}     
142	              | {32{shf_1_0 == 2'b10}} & {2'd0, alu_src2[31:2]}     
143	              | {32{shf_1_0 == 2'b11}} & {3'd0, alu_src2[31:3]};    
144	// 依据shf[3:2],将第一次移位结果右移0、4、8、12位，高位补0
145	    assign srl_step2 = {32{shf_3_2 == 2'b00}} & srl_step1                  
146	           | {32{shf_3_2 == 2'b01}} & {4'd0, srl_step1[31:4]}    
147	           | {32{shf_3_2 == 2'b10}} & {8'd0, srl_step1[31:8]}    
148	           | {32{shf_3_2 == 2'b11}} & {12'd0, srl_step1[31:12]}; 
149	// 依据shf[4],将第二次移位结果右移0、16位，高位补0
150	    assign srl_result = shf[4] ? {16'd0, srl_step2[31:16]} : srl_step2;    
151	 
152	    // 算术右移
153	    wire [31:0] sra_step1;
154	    wire [31:0] sra_step2;
155	// 依据shf[1:0],右移0、1、2、3位，高位补符号位
156	    assign sra_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                                 
157	 | {32{shf_1_0 == 2'b01}} & {alu_src2[31], alu_src2[31:1]} 
158	| {32{shf_1_0 == 2'b10}} & {{2{alu_src2[31]}}, alu_src2[31:2]}      
159	 | {32{shf_1_0 == 2'b11}} & {{3{alu_src2[31]}}, alu_src2[31:3]}; 
160	// 依据shf[3:2],将第一次移位结果右移0、4、8、12位，高位补符号位
161	    assign sra_step2 = {32{shf_3_2 == 2'b00}} & sra_step1                                
162	| {32{shf_3_2 == 2'b01}} & {{4{sra_step1[31]}}, sra_step1[31:4]} 
163	 | {32{shf_3_2 == 2'b10}} & {{8{sra_step1[31]}}, sra_step1[31:8]} 
164	 | {32{shf_3_2 == 2'b11}} & {{12{sra_step1[31]}}, sra_step1[31:12]}; 
165	// 依据shf[4],将第二次移位结果右移0、16位，高位补符号位
166	    assign sra_result = shf[4] ? {{16{sra_step2[31]}}, sra_step2[31:16]} : 
167	sra_step2;
168	//-----{移位器}end
169	    // 选择相应结果输出
170	    assign alu_result = (alu_add|alu_sub) ? add_sub_result[31:0] : 
171	                        alu_slt         ? slt_result :
172	                        alu_sltu        ? sltu_result :
173	                        alu_and         ? and_result :
174	                        alu_nor         ? nor_result :
175	                        alu_or          ? or_result  :
176	                        alu_xor         ? xor_result :
177	                        alu_sll         ? sll_result :
178	                        alu_srl         ? srl_result :
179	                        alu_sra         ? sra_result :
180	                        alu_lui         ? lui_result :
181	                        32'd0;
182	endmodule
