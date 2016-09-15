// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Mon Jun 17 20:35:29 2013
// ============================================================================

`define ENABLE_HPS

module DE1_SOC_golden_top(


      ///////// CLOCKS /////////
      input              i_CLOCK2_50,
      input              i_CLOCK3_50,
      input              i_CLOCK4_50,
      input              i_CLOCK_50,



`ifdef ENABLE_HPS
      ///////// HPS /////////
      inout              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N,
      output             HPS_DDR3_CK_P,
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,
      output             HPS_ENET_GTX_CLK,
      inout              HPS_ENET_INT_N,
      output             HPS_ENET_MDC,
      inout              HPS_ENET_MDIO,
      input              HPS_ENET_RX_CLK,
      input       [3:0]  HPS_ENET_RX_DATA,
      input              HPS_ENET_RX_DV,
      output      [3:0]  HPS_ENET_TX_DATA,
      output             HPS_ENET_TX_EN,
      inout       [3:0]  HPS_FLASH_DATA,
      output             HPS_FLASH_DCLK,
      output             HPS_FLASH_NCSO,
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
      inout              HPS_I2C2_SCLK,
      inout              HPS_I2C2_SDAT,
      inout              HPS_I2C_CONTROL,
      inout              HPS_KEY,
      inout              HPS_LED,
      inout              HPS_LTC_GPIO,
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout       [3:0]  HPS_SD_DATA,
      output             HPS_SPIM_CLK,
      input              HPS_SPIM_MISO,
      output             HPS_SPIM_MOSI,
      inout              HPS_SPIM_SS,
      input              HPS_UART_RX,
      output             HPS_UART_TX,
      input              HPS_USB_CLKOUT,
      inout       [7:0]  HPS_USB_DATA,
      input              HPS_USB_DIR,
      input              HPS_USB_NXT,
      output             HPS_USB_STP,
`endif /*ENABLE_HPS*/



      ///////// VGA /////////
      output      [7:0]  VGA_B                   ,
      output             VGA_BLANK_N             ,
      output             VGA_CLK                 ,
      output      [7:0]  VGA_G                   ,
      output             VGA_HS                  ,
      output      [7:0]  VGA_R                   ,
      output             VGA_SYNC_N              ,
      output             VGA_VS                  ,
		
		
		
      /// Oscilloscope ADC and analog control /////
      input       [7:0]     i_AD9288A            ,
      input       [7:0]     i_AD9288B            ,
      output                o_AD9288_DFS         ,
      output                o_AD9288_S1          ,
      output                o_AD9288_S2          ,
      output    reg         o_AD9288_CLK_A       ,
      output    reg         o_AD9288_CLK_B       ,
	  output    reg         o_PWM_GAIN           ,  //PIN AK24
	  output    reg         o_ACDC_CTRL          ,  //PIN AK26
	  output    reg         o_RELY_GAIN             //PIN AJ25
);

assign o_AD9288_S1      =    1'b1;
assign o_AD9288_S2      =    1'b1;
assign o_AD9288_DFS     =    1'b0;


//=======================================================
//             REG/WIRE declarations
//=======================================================


wire underflow_from_the_alt_vip_itc_0;
wire vid_datavalid_from_the_alt_vip_itc_0;

//wire nios_td_reset_n;
wire reset_n                                                  ;


wire hps_fpga_reset_n                                         ;

// 9288 ADC Control
//wire                            clk_130                       ;    //9288clk generator
wire                            clk_200                       ;   

reg                             trigger_state                 ;      //  trigger_State 
reg                             sampling                 ;     //
reg           [9:0 ]            counter_post_trigger          ;
reg           [9:0 ]            counter_pre_trigger_en        ;
reg                             trigger_en                    ;
wire                            trigger_case                  ;
                            
reg           [9:0]             r1_i_AD9288B;
reg           [9:0]             r2_i_AD9288B;
reg                             r1_rdflg;
wire          [9:0 ]            rdadd                         ; 
wire          [15:0]            rddat                         ;
wire                            rdflg                         ;
reg           [9:0 ]            wradd                         ;    //write address counter
reg           [9:0 ]            rdadd_start_ofst              ;
wire          [9:0 ]            real_rdadd                    ;
                              
                              
                              
reg                             fliper                        ;    
wire           [7:0 ]            gain_pwm_set      ;
reg           [7:0 ]            gain_pwm_counter              ;

//=======================================================
//  Structural coding
//=======================================================



assign reset_n = 1'b1;

///////////////////////
// VGA


assign VGA_BLANK_N = 1'b1 ; 
assign VGA_SYNC_N  = 1'b0 ; 

assign real_rdadd = rdadd + rdadd_start_ofst;
assign trigger_case = (r2_i_AD9288B >= 8'd127 && r1_i_AD9288B>= 8'd127 && i_AD9288B<8'd127 ) & trigger_en & (~trigger_state);

///////////////////////

//generate output clock for ad9288
always @(posedge clk_200) begin 
	if(fliper) begin
		o_AD9288_CLK_A = 1'b1;
		o_AD9288_CLK_B = 1'b0;
	end else begin
		o_AD9288_CLK_A = 1'b0;
		o_AD9288_CLK_B = 1'b1;
	end
	fliper = ~fliper;
end



//generate Gain Control PWM
always @(posedge clk_200) begin 
	gain_pwm_counter = gain_pwm_counter + 8'b1;
	if(gain_pwm_counter < gain_pwm_set)
	    o_PWM_GAIN = 1'b1;
    else
	    o_PWM_GAIN = 1'b0;
end

//write address add
always @(posedge o_AD9288_CLK_B) begin 
	wradd <= wradd+10'b1;
end

//counter
always @(posedge o_AD9288_CLK_B) begin
    if(trigger_case) begin 
	
		counter_post_trigger <= 10'b0;
	end else if (trigger_state && sampling) begin
		counter_post_trigger <= counter_post_trigger + 10'b1;
	end
end

always @(posedge o_AD9288_CLK_B) begin

	if(r1_rdflg == 1'b1 && rdflg == 1'b0) begin
		sampling <= 1'b1;
	end else if(counter_post_trigger == 10'd512)begin
		sampling <= 1'b0;
	end
end

//delay registers
always @(posedge o_AD9288_CLK_B) begin

    r1_i_AD9288B <= i_AD9288B;
	r2_i_AD9288B <= r1_i_AD9288B;
    r1_rdflg <= rdflg;

end


always @(posedge o_AD9288_CLK_B) begin
    if(trigger_case) begin 
	    
		rdadd_start_ofst = wradd - 10'd512;
	end
end

//reset
always @(posedge o_AD9288_CLK_B) begin
    if(r1_rdflg == 1'b1 && rdflg == 1'b0) begin
	    trigger_state <= 1'b0;
	end else if(trigger_case) begin 
		trigger_state <= 1'b1;	
	end
end

//trigger enable
always @(posedge o_AD9288_CLK_B) begin
	if(r1_rdflg == 1'b1 && rdflg == 1'b0) begin
		trigger_en <= 1'b0;
	end else if(counter_pre_trigger_en >= 10'd512+10'd20 )begin
		trigger_en <= 1'b1;
	end
end

//counter 
always @(posedge o_AD9288_CLK_B) begin
    //reset
	if (r1_rdflg == 1'b1 && rdflg == 1'b0) begin
		counter_pre_trigger_en <= 10'b0;
	end else if(sampling && ~trigger_en)begin
		counter_pre_trigger_en = counter_pre_trigger_en + 10'b1;
	end

end

pll_adc (
	.refclk        (i_CLOCK_50),   //  refclk.clk
	.rst           (~(reset_n & hps_fpga_reset_n)),      //   reset.reset
	.outclk_0      (clk_200) // outclk0.clk
	);


waveform_ram ram1(
	.clock          (o_AD9288_CLK_B)                     ,
	.data           ({i_AD9288A,i_AD9288B})              ,
	.rdaddress      ({6'b0,real_rdadd[9:0]})             ,
	.wraddress      ({6'b0,wradd[9:0]})                  ,
	.wren           ( (~rdflg)&(sampling) )              ,
	.q              (rddat)              
	);




DE1_SoC_QSYS u0 (
	 
        .clk_50                                      (i_CLOCK_50),                             //                          clk_50_clk_in.clk
        .reset_n                                     (reset_n & hps_fpga_reset_n),             //                          clk_50_clk_in_reset.reset_n
		

		
        .clk_vga_clk                                 (VGA_CLK),                                //  Output to top                       altpll_0_c2.clk
		  // VGA
        .alt_vip_itc_0_clocked_video_vid_clk         (VGA_CLK ),                               //  Input to qsys       alt_vip_itc_0_clocked_video.vid_clk
        .alt_vip_itc_0_clocked_video_vid_data        ({VGA_R,VGA_G,VGA_B}),                    //                                    .vid_data
        .alt_vip_itc_0_clocked_video_underflow       (underflow_from_the_alt_vip_itc_0),       //                                    .underflow
        .alt_vip_itc_0_clocked_video_vid_datavalid   (vid_datavalid_from_the_alt_vip_itc_0),   //                                    .vid_datavalid
        .alt_vip_itc_0_clocked_video_vid_v_sync      (VGA_VS),                                 //                                    .vid_v_sync
        .alt_vip_itc_0_clocked_video_vid_h_sync      (VGA_HS),                                 //                                    .vid_h_sync
        .alt_vip_itc_0_clocked_video_vid_f           (),                                       //                                    .vid_f
        .alt_vip_itc_0_clocked_video_vid_h           (),                                       //                                    .vid_h
        .alt_vip_itc_0_clocked_video_vid_v           (),                                       //                                    .vid_v
		  

		//////////////////////////
		 // .ad9288a_external_connection_export  (i_AD9288A),
		 // .ad9288b_external_connection_export  (i_AD9288B),
		  
		  
		 .rdadd_export                               ({6'b0,rdadd[9:0]}),                  //                       rdadd.export
         .rddat_export                               (rddat),                              //                       rddat.export
         .rdflg_export                               (rdflg) ,
		 .analog_v_ctrl_export                       ({o_ACDC_CTRL, o_RELY_GAIN, gain_pwm_set[7:0], 6'bz}),        //16bit analog vertical control
 
         
		 
		// HPS
		
        .hps_0_h2f_reset_reset_n               ( hps_fpga_reset_n ),                //                hps_0_h2f_reset.reset_n
		  
        .memory_mem_a                          ( HPS_DDR3_ADDR),                          //          memory.mem_a
        .memory_mem_ba                         ( HPS_DDR3_BA),                         //                .mem_ba
        .memory_mem_ck                         ( HPS_DDR3_CK_P),                         //                .mem_ck
        .memory_mem_ck_n                       ( HPS_DDR3_CK_N),                       //                .mem_ck_n
        .memory_mem_cke                        ( HPS_DDR3_CKE),                        //                .mem_cke
        .memory_mem_cs_n                       ( HPS_DDR3_CS_N),                       //                .mem_cs_n
        .memory_mem_ras_n                      ( HPS_DDR3_RAS_N),                      //                .mem_ras_n
        .memory_mem_cas_n                      ( HPS_DDR3_CAS_N),                      //                .mem_cas_n
        .memory_mem_we_n                       ( HPS_DDR3_WE_N),                       //                .mem_we_n
        .memory_mem_reset_n                    ( HPS_DDR3_RESET_N),                    //                .mem_reset_n
        .memory_mem_dq                         ( HPS_DDR3_DQ),                         //                .mem_dq
        .memory_mem_dqs                        ( HPS_DDR3_DQS_P),                        //                .mem_dqs
        .memory_mem_dqs_n                      ( HPS_DDR3_DQS_N),                      //                .mem_dqs_n
        .memory_mem_odt                        ( HPS_DDR3_ODT),                        //                .mem_odt
        .memory_mem_dm                         ( HPS_DDR3_DM),                         //                .mem_dm
        .memory_oct_rzqin                      ( HPS_DDR3_RZQ),                      //                .oct_rzqin

		  
        .hps_io_hps_io_emac1_inst_TX_CLK       ( HPS_ENET_GTX_CLK), //                   hps_0_hps_io.hps_io_emac1_inst_TX_CLK
        .hps_io_hps_io_emac1_inst_TXD0         ( HPS_ENET_TX_DATA[0] ),   //                               .hps_io_emac1_inst_TXD0
        .hps_io_hps_io_emac1_inst_TXD1         ( HPS_ENET_TX_DATA[1] ),   //                               .hps_io_emac1_inst_TXD1
        .hps_io_hps_io_emac1_inst_TXD2         ( HPS_ENET_TX_DATA[2] ),   //                               .hps_io_emac1_inst_TXD2
        .hps_io_hps_io_emac1_inst_TXD3         ( HPS_ENET_TX_DATA[3] ),   //                               .hps_io_emac1_inst_TXD3
        .hps_io_hps_io_emac1_inst_RXD0         ( HPS_ENET_RX_DATA[0] ),   //                               .hps_io_emac1_inst_RXD0
        .hps_io_hps_io_emac1_inst_MDIO         ( HPS_ENET_MDIO ),   //                               .hps_io_emac1_inst_MDIO
        .hps_io_hps_io_emac1_inst_MDC          ( HPS_ENET_MDC  ),    //                               .hps_io_emac1_inst_MDC
        .hps_io_hps_io_emac1_inst_RX_CTL       ( HPS_ENET_RX_DV), //                               .hps_io_emac1_inst_RX_CTL
        .hps_io_hps_io_emac1_inst_TX_CTL       ( HPS_ENET_TX_EN), //                               .hps_io_emac1_inst_TX_CTL
        .hps_io_hps_io_emac1_inst_RX_CLK       ( HPS_ENET_RX_CLK), //                               .hps_io_emac1_inst_RX_CLK
        .hps_io_hps_io_emac1_inst_RXD1         ( HPS_ENET_RX_DATA[1] ),   //                               .hps_io_emac1_inst_RXD1
        .hps_io_hps_io_emac1_inst_RXD2         ( HPS_ENET_RX_DATA[2] ),   //                               .hps_io_emac1_inst_RXD2
        .hps_io_hps_io_emac1_inst_RXD3         ( HPS_ENET_RX_DATA[3] ),   //                               .hps_io_emac1_inst_RXD3
              
		        
        .hps_io_hps_io_qspi_inst_IO0           ( HPS_FLASH_DATA[0]    ),     //                               .hps_io_qspi_inst_IO0
        .hps_io_hps_io_qspi_inst_IO1           ( HPS_FLASH_DATA[1]    ),     //                               .hps_io_qspi_inst_IO1
        .hps_io_hps_io_qspi_inst_IO2           ( HPS_FLASH_DATA[2]    ),     //                               .hps_io_qspi_inst_IO2
        .hps_io_hps_io_qspi_inst_IO3           ( HPS_FLASH_DATA[3]    ),     //                               .hps_io_qspi_inst_IO3
        .hps_io_hps_io_qspi_inst_SS0           ( HPS_FLASH_NCSO    ),     //                               .hps_io_qspi_inst_SS0
        .hps_io_hps_io_qspi_inst_CLK           ( HPS_FLASH_DCLK    ),     //                               .hps_io_qspi_inst_CLK
              
        .hps_io_hps_io_sdio_inst_CMD           ( HPS_SD_CMD    ),     //                               .hps_io_sdio_inst_CMD
        .hps_io_hps_io_sdio_inst_D0            ( HPS_SD_DATA[0]     ),      //                               .hps_io_sdio_inst_D0
        .hps_io_hps_io_sdio_inst_D1            ( HPS_SD_DATA[1]     ),      //                               .hps_io_sdio_inst_D1
        .hps_io_hps_io_sdio_inst_CLK           ( HPS_SD_CLK   ),     //                               .hps_io_sdio_inst_CLK
        .hps_io_hps_io_sdio_inst_D2            ( HPS_SD_DATA[2]     ),      //                               .hps_io_sdio_inst_D2
        .hps_io_hps_io_sdio_inst_D3            ( HPS_SD_DATA[3]     ),      //                               .hps_io_sdio_inst_D3
        	      
        .hps_io_hps_io_usb1_inst_D0            ( HPS_USB_DATA[0]    ),      //                               .hps_io_usb1_inst_D0
        .hps_io_hps_io_usb1_inst_D1            ( HPS_USB_DATA[1]    ),      //                               .hps_io_usb1_inst_D1
        .hps_io_hps_io_usb1_inst_D2            ( HPS_USB_DATA[2]    ),      //                               .hps_io_usb1_inst_D2
        .hps_io_hps_io_usb1_inst_D3            ( HPS_USB_DATA[3]    ),      //                               .hps_io_usb1_inst_D3
        .hps_io_hps_io_usb1_inst_D4            ( HPS_USB_DATA[4]    ),      //                               .hps_io_usb1_inst_D4
        .hps_io_hps_io_usb1_inst_D5            ( HPS_USB_DATA[5]    ),      //                               .hps_io_usb1_inst_D5
        .hps_io_hps_io_usb1_inst_D6            ( HPS_USB_DATA[6]    ),      //                               .hps_io_usb1_inst_D6
        .hps_io_hps_io_usb1_inst_D7            ( HPS_USB_DATA[7]    ),      //                               .hps_io_usb1_inst_D7
        .hps_io_hps_io_usb1_inst_CLK           ( HPS_USB_CLKOUT    ),     //                               .hps_io_usb1_inst_CLK
        .hps_io_hps_io_usb1_inst_STP           ( HPS_USB_STP    ),     //                               .hps_io_usb1_inst_STP
        .hps_io_hps_io_usb1_inst_DIR           ( HPS_USB_DIR    ),     //                               .hps_io_usb1_inst_DIR
        .hps_io_hps_io_usb1_inst_NXT           ( HPS_USB_NXT    ),     //                               .hps_io_usb1_inst_NXT
        		        
        .hps_io_hps_io_spim1_inst_CLK          ( HPS_SPIM_CLK  ),    //                               .hps_io_spim1_inst_CLK
        .hps_io_hps_io_spim1_inst_MOSI         ( HPS_SPIM_MOSI ),   //                               .hps_io_spim1_inst_MOSI
        .hps_io_hps_io_spim1_inst_MISO         ( HPS_SPIM_MISO ),   //                               .hps_io_spim1_inst_MISO
        .hps_io_hps_io_spim1_inst_SS0          ( HPS_SPIM_SS ),    //                               .hps_io_spim1_inst_SS0
      	      
        .hps_io_hps_io_uart0_inst_RX           ( HPS_UART_RX    ),     //                               .hps_io_uart0_inst_RX
        .hps_io_hps_io_uart0_inst_TX           ( HPS_UART_TX    ),     //                               .hps_io_uart0_inst_TX
		      
        .hps_io_hps_io_i2c0_inst_SDA           ( HPS_I2C1_SDAT    ),     //                               .hps_io_i2c0_inst_SDA
        .hps_io_hps_io_i2c0_inst_SCL           ( HPS_I2C1_SCLK    ),     //                               .hps_io_i2c0_inst_SCL
		      
        .hps_io_hps_io_i2c1_inst_SDA           ( HPS_I2C2_SDAT    ),     //                               .hps_io_i2c1_inst_SDA
        .hps_io_hps_io_i2c1_inst_SCL           ( HPS_I2C2_SCLK    ),     //                               .hps_io_i2c1_inst_SCL
              
        .hps_io_hps_io_gpio_inst_GPIO09        ( HPS_CONV_USB_N),  //                               .hps_io_gpio_inst_GPIO09
        .hps_io_hps_io_gpio_inst_GPIO35        ( HPS_ENET_INT_N),  //                               .hps_io_gpio_inst_GPIO35
        .hps_io_hps_io_gpio_inst_GPIO40        ( HPS_LTC_GPIO),  //                               .hps_io_gpio_inst_GPIO40
         
        .hps_io_hps_io_gpio_inst_GPIO48        ( HPS_I2C_CONTROL),  //                               .hps_io_gpio_inst_GPIO48
        .hps_io_hps_io_gpio_inst_GPIO53        ( HPS_LED),  //                               .hps_io_gpio_inst_GPIO53
        .hps_io_hps_io_gpio_inst_GPIO54        ( HPS_KEY),  //                               .hps_io_gpio_inst_GPIO54
        .hps_io_hps_io_gpio_inst_GPIO61        ( HPS_GSENSOR_INT)  //                               .hps_io_gpio_inst_GPIO61
		  

    );

endmodule
