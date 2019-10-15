library unisim;

use unisim.vcomponents.all;

--


--

-----------------------------------------------------------------------------------------

-- Create 50MHz clock from 200MHz differential clock

-----------------------------------------------------------------------------------------

--
diff_clk_buffer: IBUFGDS

port map ( I => clk200_p,

IB => clk200_n,

O => clk200);

--

-- BUFR used to divide by 4 and create a regional clock

--


clock_divide: BUFR

generic map ( BUFR_DIVIDE => "4",

SIM_DEVICE=> "7SERIES")

port map ( I => clk200,

O => clk50,

CE => '1',

CLR => '0');
