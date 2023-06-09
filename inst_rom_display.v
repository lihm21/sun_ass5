1	`timescale 1ns / 1ps
2	//***************************************************************
3	//   > 文件名: inst_rom_display.v
4	//   > 描述  ：异步指令存储器显示模块，调用FPGA板上的IO接口和触摸屏
5	//   > 作者  : LOONGSON
6	//   > 日期  : 2016-04-14
7	//***************************************************************
8	module inst_rom_display(
9	    //时钟与复位信号
10	    input clk,
11	    input resetn,    //后缀"n"代表低电平有效
12	
13	    //触摸屏相关接口，不需要更改
14	    output lcd_rst,
15	    output lcd_cs,
16	    output lcd_rs,
17	    output lcd_wr,
18	    output lcd_rd,
19	    inout[15:0] lcd_data_io,
20	    output lcd_bl_ctr,
21	    inout ct_int,
22	    inout ct_sda,
23	    output ct_scl,
24	    output ct_rstn
25	    );
26	//-----{调用数据储存器模块}begin
27	    //数据存储器多增加一个读端口，用于读出特定内存地址显示在触摸屏上
28	    reg  [31:0] addr;
29	    wire [31:0] inst;
30	
31	    inst_rom inst_rom_module(
32	        .clka   (clk       ),
33	        .addra  (addr[9:2] ),
34	        .douta  (inst      )
35	    );
36	//-----{调用寄存器堆模块}end
37	
38	//---------------------{调用触摸屏模块}begin--------------------//
39	//-----{实例化触摸屏}begin
40	//此小节不需要更改
41	    reg         display_valid;
42	    reg  [39:0] display_name;
43	    reg  [31:0] display_value;
44	    wire [5 :0] display_number;
45	    wire        input_valid;
46	    wire [31:0] input_value;
47	
48	    lcd_module lcd_module(
49	        .clk            (clk           ),   //10Mhz
50	        .resetn         (resetn        ),
51	
52	        //调用触摸屏的接口
53	        .display_valid  (display_valid ),
54	        .display_name   (display_name  ),
55	        .display_value  (display_value ),
56	        .display_number (display_number),
57	        .input_valid    (input_valid   ),
58	        .input_value    (input_value   ),
59	
60	        //lcd触摸屏相关接口，不需要更改
61	        .lcd_rst        (lcd_rst       ),
62	        .lcd_cs         (lcd_cs        ),
63	        .lcd_rs         (lcd_rs        ),
64	        .lcd_wr         (lcd_wr        ),
65	        .lcd_rd         (lcd_rd        ),
66	        .lcd_data_io    (lcd_data_io   ),
67	        .lcd_bl_ctr     (lcd_bl_ctr    ),
68	        .ct_int         (ct_int        ),
69	        .ct_sda         (ct_sda        ),
70	        .ct_scl         (ct_scl        ),
71	        .ct_rstn        (ct_rstn       )
72	    ); 
73	//-----{实例化触摸屏}end
74	
75	//-----{从触摸屏获取输入}begin
76	//根据实际需要输入的数修改此小节，
77	//建议对每一个数的输入，编写单独一个always块
78	    always @(posedge clk)
79	    begin
80	        if (!resetn)
81	        begin
82	            addr <= 32'd0;
83	        end
84	        else if (input_valid)
85	        begin
86	            addr[31:2] <= input_value[31:2];
87	        end
88	    end
89	//-----{从触摸屏获取输入}end
90	
91	//-----{输出到触摸屏显示}begin
92	//根据需要显示的数修改此小节，
93	//触摸屏上共有44块显示区域，可显示44组32位数据
94	//44块显示区域从1开始编号，编号为1~44，
95	    always @(posedge clk)
96	    begin
97	       case(display_number)
98	           6'd1:
99	           begin
100	               display_valid <= 1'b1;
101	               display_name  <= "ADDR ";
102	               display_value <= addr;
103	           end
104	           6'd2: 
105	           begin
106	               display_valid <= 1'b1;
107	               display_name  <= "INST ";
108	               display_value <= inst;
109	           end
110	           default :
111	           begin
112	               display_valid <= 1'b0;
113	               display_name  <= 40'd0;
114	               display_value <= 32'd0;
115	           end
116	       endcase
117	    end
118	//-----{输出到触摸屏显示}end
119	//----------------------{调用触摸屏模块}end---------------------//
120	endmodule
