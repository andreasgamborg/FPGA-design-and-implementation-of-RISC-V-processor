library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity Top_bench is
end Top_bench;


architecture Behavioral of Top_bench is
    
    component RISCV_top is
    Port (  
        basys3_clk : IN STD_LOGIC;
        basys3_switch : IN STD_LOGIC_VECTOR(15 downto 0);
        basys3_btn : IN STD_LOGIC_VECTOR(4 downto 0);
        basys3_pbtn : IN STD_LOGIC_VECTOR(3 downto 0);
        PS2Clk, PS2Data : IN STD_LOGIC;
        RsRx : IN STD_LOGIC;
        
        RsTx : OUT STD_LOGIC;
        basys3_led : OUT STD_LOGIC_VECTOR(15 downto 0);
        basys3_seg7 : OUT STD_LOGIC_VECTOR(7 downto 0);
        basys3_an : OUT STD_LOGIC_VECTOR(3 downto 0);
        VGA_HS_OUT : OUT STD_LOGIC;
        VGA_VS_OUT : OUT STD_LOGIC;
        VGA_RED_OUT : OUT STD_LOGIC_VECTOR (3 downto 0);
        VGA_BLUE_OUT : OUT STD_LOGIC_VECTOR (3 downto 0);
        VGA_GREEN_OUT : OUT STD_LOGIC_VECTOR (3 downto 0)
    );
    end component;
-- Signals
    signal basys3_clk : STD_LOGIC := '0';
    
    signal basys3_switch :  STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
    signal basys3_btn :     STD_LOGIC_VECTOR(4 downto 0):=(others => '0');
    signal basys3_pbtn :    STD_LOGIC_VECTOR(3 downto 0):=(others => '0');
    signal PS2Clk, PS2Data :STD_LOGIC;
    signal RsRx :           STD_LOGIC := '1';
    
    signal RsTx :           STD_LOGIC;
    signal basys3_led :     STD_LOGIC_VECTOR(15 downto 0);
    signal basys3_seg7 :    STD_LOGIC_VECTOR(7 downto 0);
    signal basys3_an :      STD_LOGIC_VECTOR(3 downto 0);
    signal VGA_HS_OUT :     STD_LOGIC;
    signal VGA_VS_OUT :     STD_LOGIC;
    signal VGA_RED_OUT :    STD_LOGIC_VECTOR (3 downto 0);
    signal VGA_BLUE_OUT :   STD_LOGIC_VECTOR (3 downto 0);
    signal VGA_GREEN_OUT :  STD_LOGIC_VECTOR (3 downto 0);
-- Procedures
    procedure UART_WRITE_BYTE (
    i_data_in       : in  std_logic_vector(7 downto 0);
    signal o_serial : out std_logic) is
    constant RX_period : time := 104166.6667 ns; --9600 baud
    begin
        -- Send Start Bit
        o_serial <= '0';
        wait for RX_period;
        
        -- Send Data Byte
        for ii in 0 to 7 loop
        o_serial <= i_data_in(ii);
        wait for RX_period;
        end loop;  -- ii
        
        -- Send Stop Bit
        o_serial <= '1';
        wait for RX_period;
    end UART_WRITE_BYTE;
begin
    Top : RISCV_top
    PORT MAP(
        basys3_clk => basys3_clk,
        basys3_switch => basys3_switch,
        basys3_btn  => basys3_btn,
        basys3_pbtn => basys3_pbtn,
        PS2Clk => PS2Clk,
        PS2Data => PS2Data,
        RsRx => RsRx,
        RsTx => RsTx,         
        basys3_led => basys3_led,
        basys3_seg7 => basys3_seg7,
        basys3_an    => basys3_an,
        VGA_HS_OUT   => VGA_HS_OUT,
        VGA_VS_OUT   => VGA_VS_OUT,
        VGA_RED_OUT  => VGA_RED_OUT, 
        VGA_BLUE_OUT  => VGA_BLUE_OUT, 
        VGA_GREEN_OUT => VGA_GREEN_OUT        
    );
    basys3_clk <= not basys3_clk after 5 ns;

    process is
    begin
        wait for 10 ms;
        
--        UART_WRITE_BYTE(X"13", RsRx);
--        UART_WRITE_BYTE(X"04", RsRx);
--        UART_WRITE_BYTE(X"00", RsRx);
--        UART_WRITE_BYTE(X"14", RsRx);

--        UART_WRITE_BYTE(X"13", RsRx);
--        UART_WRITE_BYTE(X"05", RsRx);
--        UART_WRITE_BYTE(X"30", RsRx);
--        UART_WRITE_BYTE(X"00", RsRx);
        
--        UART_WRITE_BYTE(X"93", RsRx);
--        UART_WRITE_BYTE(X"05", RsRx);
--        UART_WRITE_BYTE(X"30", RsRx);
--        UART_WRITE_BYTE(X"00", RsRx);

--        UART_WRITE_BYTE(X"13", RsRx);
--        UART_WRITE_BYTE(X"06", RsRx);
--        UART_WRITE_BYTE(X"30", RsRx);
--        UART_WRITE_BYTE(X"03", RsRx);
        
--        UART_WRITE_BYTE(X"e7", RsRx);
--        UART_WRITE_BYTE(X"00", RsRx);
--        UART_WRITE_BYTE(X"04", RsRx);
--        UART_WRITE_BYTE(X"00", RsRx);
        
--        wait for 500us;
--        basys3_btn <= "01000";
--        wait for 100us;

    end process;
    
end Behavioral;
