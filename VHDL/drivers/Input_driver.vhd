library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Input_driver is
    Port (  
        clk : IN STD_LOGIC;
        btn_run : IN STD_LOGIC;
        btn_stop : IN STD_LOGIC;
        btn_reset : IN STD_LOGIC;
        btn_load : IN STD_LOGIC;
        sbtn_run : OUT STD_LOGIC;
        sbtn_stop : OUT STD_LOGIC;
        sbtn_reset : OUT STD_LOGIC;
        sbtn_load : OUT STD_LOGIC
    );
end Input_driver;

architecture Behavioral of Input_driver is

    signal xrun, xstop, xreset, xload : STD_LOGIC;
    signal xxrun, xxstop, xxreset, xxload : STD_LOGIC;
        
begin
    process(all)
    begin
        if rising_edge(clk) then          
            xxrun   <= xrun;  
            xxstop  <= xstop; 
            xxreset <= xreset;
            xxload  <= xload;
            xrun   <= btn_run;  
            xstop  <= btn_stop; 
            xreset <= btn_reset;
            xload  <= btn_load;       
        end if;
    end process;
    sbtn_run   <= (not xxrun) and xrun;  
    sbtn_stop  <= (not xxstop) and xstop; 
    sbtn_reset <= (not xxreset) and xreset;
    sbtn_load  <= (not xxload) and xload;
end Behavioral;