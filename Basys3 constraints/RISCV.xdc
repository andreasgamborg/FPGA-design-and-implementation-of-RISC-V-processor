## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

set_property IOSTANDARD LVCMOS33 [get_ports *]


## Clock signal
set_property PACKAGE_PIN W5 [get_ports basys3_clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports basys3_clk]

## Switches
set_property PACKAGE_PIN V17 [get_ports {basys3_switch[0]}]
set_property PACKAGE_PIN V16 [get_ports {basys3_switch[1]}]
set_property PACKAGE_PIN W16 [get_ports {basys3_switch[2]}]
set_property PACKAGE_PIN W17 [get_ports {basys3_switch[3]}]
set_property PACKAGE_PIN W15 [get_ports {basys3_switch[4]}]
set_property PACKAGE_PIN V15 [get_ports {basys3_switch[5]}]
set_property PACKAGE_PIN W14 [get_ports {basys3_switch[6]}]
set_property PACKAGE_PIN W13 [get_ports {basys3_switch[7]}]
set_property PACKAGE_PIN V2 [get_ports {basys3_switch[8]}]
set_property PACKAGE_PIN T3 [get_ports {basys3_switch[9]}]
set_property PACKAGE_PIN T2 [get_ports {basys3_switch[10]}]
set_property PACKAGE_PIN R3 [get_ports {basys3_switch[11]}]
set_property PACKAGE_PIN W2 [get_ports {basys3_switch[12]}]
set_property PACKAGE_PIN U1 [get_ports {basys3_switch[13]}]
set_property PACKAGE_PIN T1 [get_ports {basys3_switch[14]}]
set_property PACKAGE_PIN R2 [get_ports {basys3_switch[15]}]


## LEDs
set_property PACKAGE_PIN U16 [get_ports {basys3_led[0]}]
set_property PACKAGE_PIN E19 [get_ports {basys3_led[1]}]
set_property PACKAGE_PIN U19 [get_ports {basys3_led[2]}]
set_property PACKAGE_PIN V19 [get_ports {basys3_led[3]}]
set_property PACKAGE_PIN W18 [get_ports {basys3_led[4]}]
set_property PACKAGE_PIN U15 [get_ports {basys3_led[5]}]
set_property PACKAGE_PIN U14 [get_ports {basys3_led[6]}]
set_property PACKAGE_PIN V14 [get_ports {basys3_led[7]}]
set_property PACKAGE_PIN V13 [get_ports {basys3_led[8]}]
set_property PACKAGE_PIN V3 [get_ports {basys3_led[9]}]
set_property PACKAGE_PIN W3 [get_ports {basys3_led[10]}]
set_property PACKAGE_PIN U3 [get_ports {basys3_led[11]}]
set_property PACKAGE_PIN P3 [get_ports {basys3_led[12]}]
set_property PACKAGE_PIN N3 [get_ports {basys3_led[13]}]
set_property PACKAGE_PIN P1 [get_ports {basys3_led[14]}]
set_property PACKAGE_PIN L1 [get_ports {basys3_led[15]}]


##Buttons
set_property PACKAGE_PIN T18 [get_ports {basys3_btn[4]}]
set_property PACKAGE_PIN U17 [get_ports {basys3_btn[3]}]
set_property PACKAGE_PIN W19 [get_ports {basys3_btn[2]}]
set_property PACKAGE_PIN T17 [get_ports {basys3_btn[1]}]
set_property PACKAGE_PIN U18 [get_ports {basys3_btn[0]}]

#set_property PACKAGE_PIN U18 [get_ports btnC]
#set_property PACKAGE_PIN T18 [get_ports btnU]
#set_property PACKAGE_PIN W19 [get_ports btnL]
#set_property PACKAGE_PIN T17 [get_ports btnR]
#set_property PACKAGE_PIN U17 [get_ports btnD]

##7 segment display
set_property PACKAGE_PIN W7 [get_ports {basys3_seg7[7]}]
set_property PACKAGE_PIN W6 [get_ports {basys3_seg7[6]}]
set_property PACKAGE_PIN U8 [get_ports {basys3_seg7[5]}]
set_property PACKAGE_PIN V8 [get_ports {basys3_seg7[4]}]
set_property PACKAGE_PIN U5 [get_ports {basys3_seg7[3]}]
set_property PACKAGE_PIN V5 [get_ports {basys3_seg7[2]}]
set_property PACKAGE_PIN U7 [get_ports {basys3_seg7[1]}]
set_property PACKAGE_PIN V7 [get_ports {basys3_seg7[0]}]
set_property PACKAGE_PIN U2 [get_ports {basys3_an[0]}]
set_property PACKAGE_PIN U4 [get_ports {basys3_an[1]}]
set_property PACKAGE_PIN V4 [get_ports {basys3_an[2]}]
set_property PACKAGE_PIN W4 [get_ports {basys3_an[3]}]


##VGA Connector
set_property PACKAGE_PIN G19 [get_ports {VGA_RED_OUT[0]}]
set_property PACKAGE_PIN H19 [get_ports {VGA_RED_OUT[1]}]
set_property PACKAGE_PIN J19 [get_ports {VGA_RED_OUT[2]}]
set_property PACKAGE_PIN N19 [get_ports {VGA_RED_OUT[3]}]
set_property PACKAGE_PIN N18 [get_ports {VGA_BLUE_OUT[0]}]
set_property PACKAGE_PIN L18 [get_ports {VGA_BLUE_OUT[1]}]
set_property PACKAGE_PIN K18 [get_ports {VGA_BLUE_OUT[2]}]
set_property PACKAGE_PIN J18 [get_ports {VGA_BLUE_OUT[3]}]
set_property PACKAGE_PIN J17 [get_ports {VGA_GREEN_OUT[0]}]
set_property PACKAGE_PIN H17 [get_ports {VGA_GREEN_OUT[1]}]
set_property PACKAGE_PIN G17 [get_ports {VGA_GREEN_OUT[2]}]
set_property PACKAGE_PIN D17 [get_ports {VGA_GREEN_OUT[3]}]
set_property PACKAGE_PIN P19 [get_ports VGA_HS_OUT]
set_property PACKAGE_PIN R19 [get_ports VGA_VS_OUT]


##USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports RsRx]
set_property PACKAGE_PIN A18 [get_ports RsTx]


##USB HID (PS/2)
set_property PACKAGE_PIN C17 [get_ports PS2Clk]
set_property PULLUP true [get_ports PS2Clk]
create_clock -period 40000 -name keyboard_clk_pin -waveform {0 20000} -add [get_ports PS2Clk]

set_property PACKAGE_PIN B17 [get_ports PS2Data]
set_property PULLUP true [get_ports PS2Data]


##Pmod Header JA
#set_property PACKAGE_PIN J1 [get_ports {JA[0]}]
#set_property PACKAGE_PIN L2 [get_ports {JA[1]}]
#set_property PACKAGE_PIN J2 [get_ports {JA[2]}]
#set_property PACKAGE_PIN G2 [get_ports {JA[3]}]
#set_property PACKAGE_PIN H1 [get_ports {JA[4]}]
#set_property PACKAGE_PIN K2 [get_ports {JA[5]}]
#set_property PACKAGE_PIN H2 [get_ports {JA[6]}]
#set_property PACKAGE_PIN G3 [get_ports {JA[7]}]


##Pmod Header JB
#set_property PACKAGE_PIN A14 [get_ports {JB[0]}]
#set_property PACKAGE_PIN A16 [get_ports {JB[1]}]
#set_property PACKAGE_PIN B15 [get_ports {JB[2]}]
#set_property PACKAGE_PIN B16 [get_ports {JB[3]}]

## Pmod in lower row
# BTN0
#set_property PACKAGE_PIN A15 [get_ports {JB[4]}]
# BTN1
#set_property PACKAGE_PIN A17 [get_ports {JB[5]}]
# BTN2
#set_property PACKAGE_PIN C15 [get_ports {JB[6]}]
# BTN3 - use as manual clock
#set_property PACKAGE_PIN C16 [get_ports {JB[7]}]


##Pmod Header JC
set_property PACKAGE_PIN K17 [get_ports {basys3_pbtn[0]}]
set_property PACKAGE_PIN M18 [get_ports {basys3_pbtn[1]}]
set_property PACKAGE_PIN N17 [get_ports {basys3_pbtn[2]}]
set_property PACKAGE_PIN P18 [get_ports {basys3_pbtn[3]}]
#set_property PACKAGE_PIN L17 [get_ports {JC[4]}]
#set_property PACKAGE_PIN M19 [get_ports {JC[5]}]
#set_property PACKAGE_PIN P17 [get_ports {JC[6]}]
#set_property PACKAGE_PIN R18 [get_ports {JC[7]}]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

