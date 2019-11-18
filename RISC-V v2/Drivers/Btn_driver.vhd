library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Btn_driver is
    Generic(
        clk_freq :          integer := 5e6;     -- Hz
        debounce_period :   integer := 10       -- ms
    );
    Port(  
        clk :          IN STD_LOGIC;
        switch_in :    IN STD_LOGIC_VECTOR(15 downto 0);
        btn_in :       IN STD_LOGIC_VECTOR(4 downto 0);
        pbtn_in  :     IN STD_LOGIC_VECTOR(3 downto 0);
        btn_out :      OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end Btn_driver;

architecture Behavioral of Btn_driver is

    signal xxbtn, xbtn, btn, dbtn : STD_LOGIC_VECTOR(31 downto 0);
    
    constant cnt_max : integer := clk_freq*debounce_period/1000;
    signal cnt, cnt_next : unsigned(31 downto 0);
    
begin
    xxbtn <= btn_in & "000" & pbtn_in & "0000" & switch_in;
    --Syncronize inputs
    process(clk)
    begin
        if rising_edge(clk) then  
            dbtn <= btn;        
            btn <= xbtn;
            xbtn <= xxbtn;
        end if;
    end process;
    
    --Debounce
    process(all)
    begin
        if dbtn = btn then  
            cnt_next <= cnt+1;
        else
            cnt_next <= (others => '0');
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then  
            cnt <= cnt_next;
            if cnt = cnt_max then
                btn_out <= dbtn;
            end if;
        end if;
    end process;
    
end Behavioral;