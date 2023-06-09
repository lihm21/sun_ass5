1	`timescale 1ns / 1ps
2	//****************************************************************
3	//   > 文件名: data_ram_display.v
4	//   > 描述  ：数据存储器模块显示模块，调用FPGA板上的IO接口和触摸屏
5	//   > 作者  : LOONGSON
6	//   > 日期  : 2016-04-14
7	//****************************************************************
8	module data_ram_display(
9	    //时钟与复位信号
10	     input clk,
11	    input resetn,    //后缀"n"代表低电平有效
12	
13	    //拨码开关，用于产生写使能和选择输入数
14	    input [3:0] wen,
15	    input [1:0] input_sel,
16	
17	    //led灯，用于指示写使能信号，和正在输入什么数据
18	    output [3:0] led_wen,
19	    output led_addr,      //指示输入读写地址
20	    output led_wdata,     //指示输入写数据
21	    output led_test_addr, //指示输入test地址
22	
23	    //触摸屏相关接口，不需要更改
24	    output lcd_rst,
25	    output lcd_cs,
26	    output lcd_rs,
27	    output lcd_wr,
28	    output lcd_rd,
29	    inout[15:0] lcd_data_io,
30	    output lcd_bl_ctr,
31	    inout ct_int,
32	    inout ct_sda,
33	    output ct_scl,
34	    output ct_rstn
35	    );
36	//-----{LED显示}begin
37	    assign led_wen       = wen;
38	    assign led_addr      = (input_sel==2'd0);
39	    assign led_wdata     = (input_sel==2'd1);
40	    assign led_test_addr = (input_sel==2'd2);
41	//-----{LED显示}end
42	//-----{调用数据储存器模块}begin
43	    //数据存储器多增加一个读端口，用于读出特定内存地址显示在触摸屏上
44	    reg  [31:0] addr;
45	    reg  [31:0] wdata;
46	    wire [31:0] rdata;
47	    reg  [31:0] test_addr;
48	    wire [31:0] test_data;  
49	
50	    data_ram data_ram_module(
51	        .clk   (clk   ),
52	        .wen   (wen   ),
53	        .addr  (addr[6:2]),
54	        .wdata (wdata ),
55	        .rdata (rdata ),
56	        .test_addr(test_addr[6:2]),
57	        .test_data(test_data)
58	    );
59	//-----{调用寄存器堆模块}end
60	
61	//---------------------{调用触摸屏模块}begin--------------------//
62	//-----{实例化触摸屏}begin
63	//此小节不需要更改
64	    reg         display_valid;
65	    reg  [39:0] display_name;
66	    reg  [31:0] display_value;
67	    wire [5 :0] display_number;
68	    wire        input_valid;
69	    wire [31:0] input_value;
70	
71	    lcd_module lcd_module(
72	        .clk            (clk           ),   //10Mhz
73	        .resetn         (resetn        ),
74	
75	        //调用触摸屏的接口
76	        .display_valid  (display_valid ),
77	        .display_name   (display_name  ),
78	        .display_value  (display_value ),
79	        .display_number (display_number),
80	        .input_valid    (input_valid   ),
81	        .input_value    (input_value   ),
82	
83	        //lcd触摸屏相关接口，不需要更改
84	        .lcd_rst        (lcd_rst       ),
85	        .lcd_cs         (lcd_cs        ),
86	        .lcd_rs         (lcd_rs        ),
87	        .lcd_wr         (lcd_wr        ),
88	        .lcd_rd         (lcd_rd        ),
89	        .lcd_data_io    (lcd_data_io   ),
90	        .lcd_bl_ctr     (lcd_bl_ctr    ),
91	        .ct_int         (ct_int        ),
92	        .ct_sda         (ct_sda        ),
93	        .ct_scl         (ct_scl        ),
94	        .ct_rstn        (ct_rstn       )
95	    ); 
96	//-----{实例化触摸屏}end
97	
98	//-----{从触摸屏获取输入}begin
99	//根据实际需要输入的数修改此小节，
100	//建议对每一个数的输入，编写单独一个always块
101	    //当input_sel为2'b00时，表示输入数为读写地址，即addr
102	    always @(posedge clk)
103	    begin
104	        if (!resetn)
105	        begin
106	            addr <= 32'd0;
107	        end
108	        else if (input_valid && input_sel==2'd0)
109	        begin
110	            addr[31:2] <= input_value[31:2];
111	        end
112	    end
113	    
114	    //当input_sel为2'b01时，表示输入数为写数据，即wdata
115	    always @(posedge clk)
116	    begin
117	        if (!resetn)
118	        begin
119	            wdata <= 32'd0;
120	        end
121	        else if (input_valid && input_sel==2'd1)
122	        begin
123	            wdata <= input_value;
124	        end
125	    end
126	    
127	    //当input_sel为2'b10时，表示输入数为test地址，即test_addr
128	    always @(posedge clk)
129	    begin
130	        if (!resetn)
131	        begin
132	            test_addr  <= 32'd0;
133	        end
134	        else if (input_valid && input_sel==2'd2)
135	        begin
136	            test_addr[31:2] <= input_value[31:2];
137	        end
138	    end
139	//-----{从触摸屏获取输入}end
140	
141	//-----{输出到触摸屏显示}begin
142	//根据需要显示的数修改此小节，
143	//触摸屏上共有44块显示区域，可显示44组32位数据
144	//44块显示区域从1开始编号，编号为1~44，
145	    always @(posedge clk)
146	    begin
147	       case(display_number)
148	           6'd1:
149	           begin
150	               display_valid <= 1'b1;
151	               display_name  <= "ADDR ";
152	               display_value <= addr;
153	           end
154	           6'd2: 
155	           begin
156	               display_valid <= 1'b1;
157	               display_name  <= "WDATA";
158	               display_value <= wdata;
159	           end
160	           6'd3: 
161	           begin
162	               display_valid <= 1'b1;
163	               display_name  <= "RDATA";
164	               display_value <= rdata;
165	           end
166	           6'd5: 
167	           begin
168	               display_valid <= 1'b1;
169	               display_name  <= "T_ADD";
170	               display_value <= test_addr;
171	           end
172	           6'd6: 
173	           begin
174	               display_valid <= 1'b1;
175	               display_name  <= "T_DAT";
176	               display_value <= test_data;
177	           end
178	           default :
179	           begin
180	               display_valid <= 1'b0;
181	               display_name  <= 40'd0;
182	               display_value <= 32'd0;
183	           end
184	       endcase
185	    end
186	//-----{输出到触摸屏显示}end
187	//----------------------{调用触摸屏模块}end---------------------//
188	endmodule
