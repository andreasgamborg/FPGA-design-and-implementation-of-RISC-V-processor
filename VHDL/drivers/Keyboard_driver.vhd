library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Keyboard_driver is
    Port (  
        clk, reset : IN STD_LOGIC;
        PS2Clk, PS2Data : IN STD_LOGIC;
        keyboard_out : OUT std_logic_vector(31 downto 0)
    );
end Keyboard_driver;
architecture Behavioral of Keyboard_driver is
    
    signal data : std_logic_vector(10 downto 0);
    signal scan_code : std_logic_vector(7 downto 0);
    
begin
    
    process(PS2Clk)
    begin
        if reset = '1' then
            data <= (others => '0');
        elsif falling_edge(PS2Clk) then
            data <= PS2Data & data(10 downto 1);
        end if;
    end process;
    
    scan_code <= data(8 downto 1);
    keyboard_out <= x"000000" & scan_code;
end Behavioral;
