library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Keyboard_driver is
    Port (  
        clk : IN STD_LOGIC;
        PS2Clk, PS2Data : IN STD_LOGIC;
        keyboard_out : OUT std_logic_vector(31 downto 0)
    );
end Keyboard_driver;
architecture Behavioral of Keyboard_driver is
    
    signal xxdata : std_logic_vector(10 downto 0);
    constant payload_length : positive := 11;
    signal xxcnt, xxcnt_next : unsigned(3 downto 0);
    
    signal xdata, data : std_logic_vector(10 downto 0);
    signal xcnt, cnt : unsigned(3 downto 0);
    signal scan_code : std_logic_vector(7 downto 0);
begin

    process(PS2Clk)
    begin
        if falling_edge(PS2Clk) then
            xxcnt <= xxcnt_next;
            xxdata <= PS2Data & xxdata(10 downto 1);
        end if;
    end process;
    
    process(all)
    begin
        if cnt = payload_length-1 then  
            xxcnt_next <= (others => '0');
        else
            xxcnt_next <= xxcnt+1;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            cnt <= xcnt;
            xcnt <= xxcnt;
            data <= xdata; 
            xdata <= xxdata;
            
            if cnt = "0000" then  
                scan_code <= data(8 downto 1);   
            end if; 
        end if;
    end process;

    keyboard_out <= x"000000" & scan_code;
end Behavioral;
