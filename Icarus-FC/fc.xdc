## This file is a specific .xdc for the AT1051 Flight Controller on Arty A7-100
## ----------------------------------------------------------------------------
## SYSTEM CLOCK & RESET
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk_100MHz }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk_100MHz }];

# Reset Button (Red Button on Board)
set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { reset_rtl_0 }];

# Allow Buffer-to-Buffer Clock Routing (Required for this specific clock tree)
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets AT1051_SoC_i/clk_wiz/inst/clk_out1]

## ----------------------------------------------------------------------------
## FLIGHT CONTROLLER PERIPHERALS
## ----------------------------------------------------------------------------

# --- PWM MOTORS (Mapped to Pmod JD for High Speed Output) ---
# Motors 1-4: Connect your ESC signal wires here (JD Top Row)
set_property -dict { PACKAGE_PIN D4  IOSTANDARD LVCMOS33 } [get_ports { pwm_0[0] }]; # JD[1]
set_property -dict { PACKAGE_PIN D3  IOSTANDARD LVCMOS33 } [get_ports { pwm_0[1] }]; # JD[2]
set_property -dict { PACKAGE_PIN F4  IOSTANDARD LVCMOS33 } [get_ports { pwm_0[2] }]; # JD[3]
set_property -dict { PACKAGE_PIN F3  IOSTANDARD LVCMOS33 } [get_ports { pwm_0[3] }]; # JD[4]

# Motors 5-8: Mapped to Onboard LEDs (Visual Throttle Indicator)
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports { pwm_0[4] }]; # LED 4
set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports { pwm_0[5] }]; # LED 5
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { pwm_0[6] }]; # LED 6
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { pwm_0[7] }]; # LED 7

# --- GPS UART (UART 0) -> Mapped to Pmod JA (Top Row) ---
set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS33 } [get_ports { uart_rtl_0_rxd }]; # JA[1]
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { uart_rtl_0_txd }]; # JA[2]

# --- TELEMETRY UART (UART 1) -> Mapped to Pmod JA (Bottom Row) ---
set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 } [get_ports { uart_rtl_1_rxd }]; # JA[7]
set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports { uart_rtl_1_txd }]; # JA[8]

# --- RC RECEIVER UART (UART 2) -> Mapped to Pmod JB (Top Row) ---
set_property -dict { PACKAGE_PIN E15 IOSTANDARD LVCMOS33 } [get_ports { uart_rtl_2_rxd }]; # JB[1]
set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS33 } [get_ports { uart_rtl_2_txd }]; # JB[2]

# --- I2C BUS (Magnetometer/Baro) -> Mapped to Dedicated ChipKit I2C ---
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { iic_rtl_0_scl_io }]; # CK_SCL
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports { iic_rtl_0_sda_io }]; # CK_SDA
set_property PULLUP true [get_ports { iic_rtl_0_scl_io }]
set_property PULLUP true [get_ports { iic_rtl_0_sda_io }]

# --- SPI 0 (IMU: Gyro/Accel) -> Mapped to Pmod JC ---
set_property -dict { PACKAGE_PIN U12 IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_0_ss_io[0] }]; # JC[1] (CS)
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_0_io0_io }];   # JC[2] (MOSI)
set_property -dict { PACKAGE_PIN V10 IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_0_io1_io }];   # JC[3] (MISO)
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_0_sck_io }];   # JC[4] (SCK)

# --- SPI 1 (Camera/Aux) -> Mapped to Standard ChipKit SPI Header ---
set_property -dict { PACKAGE_PIN C1  IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_1_ss_io[0] }]; # CK_SS
set_property -dict { PACKAGE_PIN H1  IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_1_io0_io }];   # CK_MOSI
set_property -dict { PACKAGE_PIN G1  IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_1_io1_io }];   # CK_MISO
set_property -dict { PACKAGE_PIN F1  IOSTANDARD LVCMOS33 } [get_ports { spi_rtl_1_sck_io }];   # CK_SCK


## ----------------------------------------------------------------------------
## SYSTEM STATUS & DEBUG
## ----------------------------------------------------------------------------
# Heartbeat LED (Mapped to RGB LED Blue Component)
set_property -dict { PACKAGE_PIN E1  IOSTANDARD LVCMOS33 } [get_ports { proc_heart_beat }]; 

# USB-UART (For Console/Printf Debugging)
set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [get_ports { sout }]; # USB UART TX
set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS33 } [get_ports { sin }];  # USB UART RX

# General GPIO (Optional - Mapped to Switches for Input, RGB LEDs for Output)
set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_io[0] }]; # SW0
set_property -dict { PACKAGE_PIN C11 IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_io[1] }]; # SW1
set_property -dict { PACKAGE_PIN C10 IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_io[2] }]; # SW2
set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_io[3] }]; # SW3
set_property -dict { PACKAGE_PIN F6  IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_io[4] }]; # LED0 Green
set_property -dict { PACKAGE_PIN J4  IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_io[5] }]; # LED1 Green
set_property -dict { PACKAGE_PIN J2  IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_io[6] }]; # LED2 Green
set_property -dict { PACKAGE_PIN H6  IOSTANDARD LVCMOS33 } [get_ports { gpio_rtl_0_tri_io[7] }]; # LED3 Green



################## DDR3 ##################
set_property PACKAGE_PIN K6 [get_ports {ddr3_reset_n}]
set_property PACKAGE_PIN L1 [get_ports {ddr3_dm[0]}]
set_property PACKAGE_PIN U1 [get_ports {ddr3_dm[1]}]
set_property PACKAGE_PIN K5 [get_ports {ddr3_dq[0]}]
set_property PACKAGE_PIN L3 [get_ports {ddr3_dq[1]}]
set_property PACKAGE_PIN K3 [get_ports {ddr3_dq[2]}]
set_property PACKAGE_PIN L6 [get_ports {ddr3_dq[3]}]
set_property PACKAGE_PIN M3 [get_ports {ddr3_dq[4]}]
set_property PACKAGE_PIN M1 [get_ports {ddr3_dq[5]}]
set_property PACKAGE_PIN L4 [get_ports {ddr3_dq[6]}]
set_property PACKAGE_PIN M2 [get_ports {ddr3_dq[7]}]
set_property PACKAGE_PIN V4 [get_ports {ddr3_dq[8]}]
set_property PACKAGE_PIN T5 [get_ports {ddr3_dq[9]}]
set_property PACKAGE_PIN U4 [get_ports {ddr3_dq[10]}]
set_property PACKAGE_PIN V5 [get_ports {ddr3_dq[11]}]
set_property PACKAGE_PIN V1 [get_ports {ddr3_dq[12]}]
set_property PACKAGE_PIN T3 [get_ports {ddr3_dq[13]}]
set_property PACKAGE_PIN U3 [get_ports {ddr3_dq[14]}]
set_property PACKAGE_PIN R3 [get_ports {ddr3_dq[15]}]
set_property PACKAGE_PIN N2 [get_ports {ddr3_dqs_p[0]}]
set_property PACKAGE_PIN U2 [get_ports {ddr3_dqs_p[1]}]
set_property PACKAGE_PIN N1 [get_ports {ddr3_dqs_n[0]}]
set_property PACKAGE_PIN V2 [get_ports {ddr3_dqs_n[1]}]
set_property PACKAGE_PIN R5 [get_ports {ddr3_odt[0]}]
set_property PACKAGE_PIN R2 [get_ports {ddr3_addr[0]}]
set_property PACKAGE_PIN M6 [get_ports {ddr3_addr[1]}]
set_property PACKAGE_PIN N4 [get_ports {ddr3_addr[2]}]
set_property PACKAGE_PIN T1 [get_ports {ddr3_addr[3]}]
set_property PACKAGE_PIN N6 [get_ports {ddr3_addr[4]}]
set_property PACKAGE_PIN R7 [get_ports {ddr3_addr[5]}]
set_property PACKAGE_PIN V6 [get_ports {ddr3_addr[6]}]
set_property PACKAGE_PIN U7 [get_ports {ddr3_addr[7]}]
set_property PACKAGE_PIN R8 [get_ports {ddr3_addr[8]}]
set_property PACKAGE_PIN V7 [get_ports {ddr3_addr[9]}]
set_property PACKAGE_PIN R6 [get_ports {ddr3_addr[10]}]
set_property PACKAGE_PIN U6 [get_ports {ddr3_addr[11]}]
set_property PACKAGE_PIN T6 [get_ports {ddr3_addr[12]}]
set_property PACKAGE_PIN T8 [get_ports {ddr3_addr[13]}]
set_property PACKAGE_PIN R1 [get_ports {ddr3_ba[0]}]
set_property PACKAGE_PIN P4 [get_ports {ddr3_ba[1]}]
set_property PACKAGE_PIN P2 [get_ports {ddr3_ba[2]}]
set_property PACKAGE_PIN U9 [get_ports {ddr3_ck_p[0]}]
set_property PACKAGE_PIN V9 [get_ports {ddr3_ck_n[0]}]
set_property PACKAGE_PIN N5 [get_ports {ddr3_cke[0]}]
set_property PACKAGE_PIN U8 [get_ports {ddr3_cs_n[0]}]
set_property PACKAGE_PIN P3 [get_ports {ddr3_ras_n}]
set_property PACKAGE_PIN M4 [get_ports {ddr3_cas_n}]
set_property PACKAGE_PIN P5 [get_ports {ddr3_we_n}]



################## MAC ##################
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports eth_rstn]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {rxd[0]}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {rxd[1]}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {rxd[2]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {rxd[3]}]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports rx_dv]
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports rx_err]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports rx_mac_clk]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports {txd[0]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {txd[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {txd[2]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {txd[3]}]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports tx_en]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports tx_mac_clk]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports mii_mdi]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports mii_clk]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports crs]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports col]

set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports eth_ref_clk]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets AT1051_SOC_i/clk_wiz/inst/clk_out1]