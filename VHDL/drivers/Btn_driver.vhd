library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Btn_driver is
    Port (  
        clk :          IN STD_LOGIC;
        switch_in :    IN STD_LOGIC_VECTOR(15 downto 0);
        btn_in :       IN STD_LOGIC_VECTOR(4 downto 0);
        pbtn_in  :     IN STD_LOGIC_VECTOR(3 downto 0);
        btn_out :      OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end Btn_driver;

architecture Behavioral of Btn_driver is

    signal xbtn, btn : STD_LOGIC_VECTOR(31 downto 0);
    
begin
    xbtn <= btn_in & "000" & pbtn_in & "0000" & switch_in;
    process(all)
    begin
        if rising_edge(clk) then          
            btn_out <= btn;
            btn <= xbtn;      
        end if;
    end process;
end Behavioral;