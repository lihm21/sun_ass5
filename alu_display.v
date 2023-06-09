1	//*************************************************************************
2	//   > 文件名: alu_display.v
3	//   > 描述  ：ALU显示模块，调用FPGA板上的IO接口和触摸屏
4	//   > 作者  : LOONGSON
5	//   > 日期  : 2016-04-14
6	//*************************************************************************
7	module alu_display(
8	    //时钟与复位信号
9	     input clk,
10	    input resetn,    //后缀"n"代表低电平有效
11	
12	    //拨码开关，用于选择输入数
13	    input [1:0] input_sel, //00:输入为控制信号(alu_control)
14	                           //10:输入为源操作数1(alu_src1)
15	                           //11:输入为源操作数2(alu_src2)
16	
17	    //触摸屏相关接口，不需要更改
18	    output lcd_rst,
19	    output lcd_cs,
20	    output lcd_rs,
21	    output lcd_wr,
22	    output lcd_rd,
23	    inout[15:0] lcd_data_io,
24	    output lcd_bl_ctr,
25	    inout ct_int,
26	    inout ct_sda,
27	    output ct_scl,
28	    output ct_rstn
29	    );
30	//-----{调用ALU模块}begin
31	    reg   [11:0] alu_control;  // ALU控制信号
32	    reg   [31:0] alu_src1;     // ALU操作数1
33	    reg   [31:0] alu_src2;     // ALU操作数2
34	    wire  [31:0] alu_result;   // ALU结果
35	    alu alu_module(
36	        .alu_control(alu_control),
37	        .alu_src1   (alu_src1   ),
38	        .alu_src2   (alu_src2   ),
39	        .alu_result (alu_result )
40	    );
41	//-----{调用ALU模块}end
42	
43	//---------------------{调用触摸屏模块}begin--------------------//
44	//-----{实例化触摸屏}begin
45	//此小节不需要更改
46	    reg         display_valid;
47	    reg  [39:0] display_name;
48	    reg  [31:0] display_value;
49	    wire [5 :0] display_number;
50	    wire        input_valid;
51	    wire [31:0] input_value;
52	
53	    lcd_module lcd_module(
54	        .clk            (clk           ),   //10Mhz
55	        .resetn         (resetn        ),
56	
57	        //调用触摸屏的接口
58	        .display_valid  (display_valid ),
59	        .display_name   (display_name  ),
60	        .display_value  (display_value ),
61	        .display_number (display_number),
62	        .input_valid    (input_valid   ),
63	        .input_value    (input_value   ),
64	
65	        //lcd触摸屏相关接口，不需要更改
66	        .lcd_rst        (lcd_rst       ),
67	        .lcd_cs         (lcd_cs        ),
68	        .lcd_rs         (lcd_rs        ),
69	        .lcd_wr         (lcd_wr        ),
70	        .lcd_rd         (lcd_rd        ),
71	        .lcd_data_io    (lcd_data_io   ),
72	        .lcd_bl_ctr     (lcd_bl_ctr    ),
73	        .ct_int         (ct_int        ),
74	        .ct_sda         (ct_sda        ),
75	        .ct_scl         (ct_scl        ),
76	        .ct_rstn        (ct_rstn       )
77	    ); 
78	//-----{实例化触摸屏}end
79	
80	//-----{从触摸屏获取输入}begin
81	//根据实际需要输入的数修改此小节，
82	//建议对每一个数的输入，编写单独一个always块
83	    //当input_sel为00时，表示输入数控制信号，即alu_control
84	    always @(posedge clk)
85	    begin
86	        if (!resetn)
87	        begin
88	            alu_control <= 12'd0;
89	        end
90	        else if (input_valid && input_sel==2'b00)
91	        begin
92	            alu_control <= input_value[11:0];
93	        end
94	    end
95	    
96	    //当input_sel为10时，表示输入数为源操作数1，即alu_src1
97	    always @(posedge clk)
98	    begin
99	        if (!resetn)
100	        begin
101	            alu_src1 <= 32'd0;
102	        end
103	        else if (input_valid && input_sel==2'b10)
104	        begin
105	            alu_src1 <= input_value;
106	        end
107	    end
108	
109	    //当input_sel为11时，表示输入数为源操作数2，即alu_src2
110	    always @(posedge clk)
111	    begin
112	        if (!resetn)
113	        begin
114	            alu_src2 <= 32'd0;
115	        end
116	        else if (input_valid && input_sel==2'b11)
117	        begin
118	            alu_src2 <= input_value;
119	        end
120	    end
121	//-----{从触摸屏获取输入}end
122	
123	//-----{输出到触摸屏显示}begin
124	//根据需要显示的数修改此小节，
125	//触摸屏上共有44块显示区域，可显示44组32位数据
126	//44块显示区域从1开始编号，编号为1~44，
127	    always @(posedge clk)
128	    begin
129	        case(display_number)
130	            6'd1 :
131	            begin
132	                display_valid <= 1'b1;
133	                display_name  <= "SRC_1";
134	                display_value <= alu_src1;
135	            end
136	            6'd2 :
137	            begin
138	                display_valid <= 1'b1;
139	                display_name  <= "SRC_2";
140	                display_value <= alu_src2;
141	            end
142	            6'd3 :
143	            begin
144	                display_valid <= 1'b1;
145	                display_name  <= "CONTR";
146	                display_value <={20'd0, alu_control};
147	            end
148	            6'd4 :
149	            begin
150	                display_valid <= 1'b1;
151	                display_name  <= "RESUL";
152	                display_value <= alu_result;
153	            end
154	            default :
155	            begin
156	                display_valid <= 1'b0;
157	                display_name  <= 40'd0;
158	                display_value <= 32'd0;
159	            end
160	        endcase
161	    end
162	//-----{输出到触摸屏显示}end
163	//----------------------{调用触摸屏模块}end---------------------//
164	endmodule
