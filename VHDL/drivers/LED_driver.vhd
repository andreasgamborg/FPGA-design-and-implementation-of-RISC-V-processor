library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity LED_driver is
    Port (  
        led_in : IN STD_LOGIC_VECTOR(31 downto 0);
        led_out : OUT STD_LOGIC_VECTOR(15 downto 0)
    );
end LED_driver;

architecture Behavioral of LED_driver is
    
begin
   led_out <= led_in(15 downto 0);
end Behavioral;