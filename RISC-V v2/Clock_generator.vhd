library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity Clock_gen is
  port (
    clk20 : out STD_LOGIC;      --20 MHz
    clk10 : out STD_LOGIC;      --10 MHz
    clk5 : out STD_LOGIC;       --5 MHz
    clk_pixel : out STD_LOGIC;  --25.175 (25.2) MHz
    clksys : in STD_LOGIC
  );
end Clock_gen;

architecture STRUCTURE of Clock_gen is
    signal clk10_clk_wiz_0 : STD_LOGIC;
    signal clk20_clk_wiz_0 : STD_LOGIC;
    signal clk5_clk_wiz_0 : STD_LOGIC;
    signal clk_pixel_clk_wiz_0 : STD_LOGIC;
    signal clkfbout_clk_wiz_0 : STD_LOGIC;
    signal clksys_clk_wiz_0 : STD_LOGIC;
    attribute BOX_TYPE : string;
    attribute BOX_TYPE of clkin1_ibufg : label is "PRIMITIVE";
    attribute CAPACITANCE : string;
    attribute CAPACITANCE of clkin1_ibufg : label is "DONT_CARE";
    attribute IBUF_DELAY_VALUE : string;
    attribute IBUF_DELAY_VALUE of clkin1_ibufg : label is "0";
    attribute IFD_DELAY_VALUE : string;
    attribute IFD_DELAY_VALUE of clkin1_ibufg : label is "AUTO";
    attribute BOX_TYPE of clkout1_buf : label is "PRIMITIVE";
    attribute BOX_TYPE of clkout2_buf : label is "PRIMITIVE";
    attribute BOX_TYPE of clkout3_buf : label is "PRIMITIVE";
    attribute BOX_TYPE of mmcm_adv_inst : label is "PRIMITIVE";
begin
clkin1_ibufg: unisim.vcomponents.IBUF
    generic map(
      IOSTANDARD => "DEFAULT"
    )
        port map (
      I => clksys,
      O => clksys_clk_wiz_0
    );
clkout1_buf: unisim.vcomponents.BUFG
     port map (
      I => clk20_clk_wiz_0,
      O => clk20
    );
clkout2_buf: unisim.vcomponents.BUFG
     port map (
      I => clk10_clk_wiz_0,
      O => clk10
    );
clkout3_buf: unisim.vcomponents.BUFG
     port map (
      I => clk5_clk_wiz_0,
      O => clk5
    );
clkout4_buf: unisim.vcomponents.BUFG
     port map (
      I => clk_pixel_clk_wiz_0,
      O => clk_pixel
    );
mmcm_adv_inst: unisim.vcomponents.MMCME2_ADV
    generic map(
      BANDWIDTH => "OPTIMIZED",
      CLKFBOUT_MULT_F => 31.500000,
      CLKFBOUT_PHASE => 0.000000,
      CLKFBOUT_USE_FINE_PS => false,
      CLKIN1_PERIOD => 10.000000,
      CLKIN2_PERIOD => 0.000000,
      CLKOUT0_DIVIDE_F => 31.500000,
      CLKOUT0_DUTY_CYCLE => 0.500000,
      CLKOUT0_PHASE => 0.000000,
      CLKOUT0_USE_FINE_PS => false,
      CLKOUT1_DIVIDE => 63,
      CLKOUT1_DUTY_CYCLE => 0.500000,
      CLKOUT1_PHASE => 0.000000,
      CLKOUT1_USE_FINE_PS => false,
      CLKOUT2_DIVIDE => 126,
      CLKOUT2_DUTY_CYCLE => 0.500000,
      CLKOUT2_PHASE => 0.000000,
      CLKOUT2_USE_FINE_PS => false,
      CLKOUT3_DIVIDE => 25,
      CLKOUT3_DUTY_CYCLE => 0.500000,
      CLKOUT3_PHASE => 0.000000,
      CLKOUT3_USE_FINE_PS => false,
      CLKOUT4_CASCADE => false,
      CLKOUT4_DIVIDE => 1,
      CLKOUT4_DUTY_CYCLE => 0.500000,
      CLKOUT4_PHASE => 0.000000,
      CLKOUT4_USE_FINE_PS => false,
      CLKOUT5_DIVIDE => 1,
      CLKOUT5_DUTY_CYCLE => 0.500000,
      CLKOUT5_PHASE => 0.000000,
      CLKOUT5_USE_FINE_PS => false,
      CLKOUT6_DIVIDE => 1,
      CLKOUT6_DUTY_CYCLE => 0.500000,
      CLKOUT6_PHASE => 0.000000,
      CLKOUT6_USE_FINE_PS => false,
      COMPENSATION => "INTERNAL",
      DIVCLK_DIVIDE => 5,
      IS_CLKINSEL_INVERTED => '0',
      IS_PSEN_INVERTED => '0',
      IS_PSINCDEC_INVERTED => '0',
      IS_PWRDWN_INVERTED => '0',
      IS_RST_INVERTED => '0',
      REF_JITTER1 => 0.010000,
      REF_JITTER2 => 0.010000,
      SS_EN => "FALSE",
      SS_MODE => "CENTER_HIGH",
      SS_MOD_PERIOD => 10000,
      STARTUP_WAIT => false
    )
        port map (
      CLKFBIN => clkfbout_clk_wiz_0,
      CLKFBOUT => clkfbout_clk_wiz_0,
      CLKIN1 => clksys_clk_wiz_0,
      CLKIN2 => '0',
      CLKINSEL => '1',
      CLKOUT0 => clk20_clk_wiz_0,
      CLKOUT1 => clk10_clk_wiz_0,
      CLKOUT2 => clk5_clk_wiz_0,
      CLKOUT3 => clk_pixel_clk_wiz_0,
      DADDR(6 downto 0) => B"0000000",
      DCLK => '0',
      DEN => '0',
      DI(15 downto 0) => B"0000000000000000",
      DWE => '0',
      PSCLK => '0',
      PSEN => '0',
      PSINCDEC => '0',
      PWRDWN => '0',
      RST => '0'
    );
end STRUCTURE;
