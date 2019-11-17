library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity LED_driver is
    Generic(
        clk_freq :      integer := 5e6 -- Hz
    );
    Port (
        clk:        IN STD_LOGIC;  
        led_in :    IN STD_LOGIC_VECTOR(31 downto 0);
        led_out :   OUT STD_LOGIC_VECTOR(15 downto 0)
    );
end LED_driver;

architecture Behavioral of LED_driver is

constant MAX_count : integer := clk_freq;
signal count, count_next : unsigned(31 downto 0);
signal led_blink, led_on, led: STD_LOGIC_VECTOR(15 downto 0);
signal blink : STD_LOGIC;

begin
    led_blink <= led_in(31 downto 16);
    led_on <= led_in(15 downto 0);
    blink <= '1' when count > clk_freq/2 else '0';

    process(all)
    begin
        if count=MAX_count then
            count_next <= (others => '0');
        else    
            count_next <= count+1;
        end if;
    end process;
        
    process(clk)
    begin
        if rising_edge(clk) then
            count <= count_next;
        end if;
    end process;

    led_out <= (led_blink and blink) or led_on;
    
end Behavioral;