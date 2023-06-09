1	`timescale 1ns / 1ps
2	//***************************************************************
3	//   > 文件名: data_ram_display.v
4	//   > 描述  ：数据存储器模块显示模块，调用FPGA板上的IO接口和触摸屏
5	//   > 作者  : LOONGSON
6	//   > 日期  : 2016-04-14
7	//***************************************************************
8	module data_ram_display(
9	    //时钟与复位信号
10	    input clk,
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
51	        .clka  (clk           ),
52	        .wea   (wen           ),
53	        .addra (addr[9:2]     ),
54	        .dina  (wdata         ),
55	        .douta (rdata         ),
56	        .clkb  (clk           ),
57	        .web   (4'd0          ),
58	        .addrb (test_addr[9:2]),
59	        .doutb (test_data     ),
60	        .dinb  (32'd0         )
61	    );
62	//-----{调用寄存器堆模块}end
63	
64	//---------------------{调用触摸屏模块}begin--------------------//
65	//-----{实例化触摸屏}begin
66	//此小节不需要更改
67	    reg         display_valid;
68	    reg  [39:0] display_name;
69	    reg  [31:0] display_value;
70	    wire [5 :0] display_number;
71	    wire        input_valid;
72	    wire [31:0] input_value;
73	
74	    lcd_module lcd_module(
75	        .clk            (clk           ),   //10Mhz
76	        .resetn         (resetn        ),
77	
78	        //调用触摸屏的接口
79	        .display_valid  (display_valid ),
80	        .display_name   (display_name  ),
81	        .display_value  (display_value ),
82	        .display_number (display_number),
83	        .input_valid    (input_valid   ),
84	        .input_value    (input_value   ),
85	
86	        //lcd触摸屏相关接口，不需要更改
87	        .lcd_rst        (lcd_rst       ),
88	        .lcd_cs         (lcd_cs        ),
89	        .lcd_rs         (lcd_rs        ),
90	        .lcd_wr         (lcd_wr        ),
91	        .lcd_rd         (lcd_rd        ),
92	        .lcd_data_io    (lcd_data_io   ),
93	        .lcd_bl_ctr     (lcd_bl_ctr    ),
94	        .ct_int         (ct_int        ),
95	        .ct_sda         (ct_sda        ),
96	        .ct_scl         (ct_scl        ),
97	        .ct_rstn        (ct_rstn       )
98	    ); 
99	//-----{实例化触摸屏}end
100	
101	//-----{从触摸屏获取输入}begin
102	//根据实际需要输入的数修改此小节，
103	//建议对每一个数的输入，编写单独一个always块
104	    //当input_sel为2'b00时，表示输入数为读写地址，即addr
105	    always @(posedge clk)
106	    begin
107	        if (!resetn)
108	        begin
109	            addr <= 32'd0;
110	        end
111	        else if (input_valid &&  input_sel==2'd0)
112	        begin
113	            addr[31:2] <= input_value[31:2];
114	        end
115	    end
116	    
117	    //当input_sel为2'b01时，表示输入数为写数据，即wdata
118	    always @(posedge clk)
119	    begin
120	        if (!resetn)
121	        begin
122	            wdata <= 32'd0;
123	        end
124	        else if (input_valid && input_sel==2'd1)
125	        begin
126	            wdata <= input_value;
127	        end
128	    end
129	    
130	    //当input_sel为2'b10时，表示输入数为test地址，即test_addr
131	    always @(posedge clk)
132	    begin
133	        if (!resetn)
134	        begin
135	            test_addr  <= 32'd0;
136	        end
137	        else if (input_valid && input_sel==2'd2)
138	        begin
139	            test_addr[31:2] <= input_value[31:2];
140	        end
141	    end
142	//-----{从触摸屏获取输入}end
143	
144	//-----{输出到触摸屏显示}begin
145	//根据需要显示的数修改此小节，
146	//触摸屏上共有44块显示区域，可显示44组32位数据
147	//44块显示区域从1开始编号，编号为1~44，
148	    always @(posedge clk)
149	    begin
150	       case(display_number)
151	           6'd1:
152	           begin
153	               display_valid <= 1'b1;
154	               display_name  <= "ADDR ";
155	               display_value <= addr;
156	           end
157	           6'd2: 
158	           begin
159	               display_valid <= 1'b1;
160	               display_name  <= "WDATA";
161	               display_value <= wdata;
162	           end
163	           6'd3: 
164	           begin
165	               display_valid <= 1'b1;
166	               display_name  <= "RDATA";
167	               display_value <= rdata;
168	           end
169	           6'd5: 
170	           begin
171	               display_valid <= 1'b1;
172	               display_name  <= "T_ADD";
173	               display_value <= test_addr;
174	           end
175	           6'd6: 
176	           begin
177	               display_valid <= 1'b1;
178	               display_name  <= "T_DAT";
179	               display_value <= test_data;
180	           end
181	           default :
182	           begin
183	               display_valid <= 1'b0;
184	               display_name  <= 40'd0;
185	               display_value <= 32'd0;
186	           end
187	       endcase
188	    end
189	//-----{输出到触摸屏显示}end
190	//----------------------{调用触摸屏模块}end---------------------//
191	endmodule
