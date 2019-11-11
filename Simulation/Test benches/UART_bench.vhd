----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.10.2019 16:18:24
-- Design Name: 
-- Module Name: UART_bench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_bench is
end UART_bench;

architecture Behavioral of UART_bench is
    component UART_driver is
        generic(
            clk_freq :      integer := 20e6; -- Hz
            baud :          integer := 9600; -- bits per sec
            packet_length : integer := 10   -- bits
        );
        Port (  
            clk : IN STD_LOGIC;
            reset :IN STD_LOGIC;
            RsRx : IN STD_LOGIC;
            RsTx : OUT STD_LOGIC;
            payload_in : IN std_logic_vector(31 downto 0);
            payload_out : OUT std_logic_vector(31 downto 0)
        );
    end component;
        signal clk : STD_LOGIC := '0';
        signal reset : STD_LOGIC := '1';
        signal RsRx : STD_LOGIC := '1';
        signal RsTx : STD_LOGIC;
        signal payload_in : std_logic_vector(31 downto 0);
        signal payload_out : std_logic_vector(31 downto 0);
        
    constant RX_period : time := 104166.6667 ns; --9600 baud

    
    procedure UART_WRITE_BYTE (
    i_data_in       : in  std_logic_vector(7 downto 0);
    signal o_serial : out std_logic) is
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
    UART : UART_driver
        port map(
        --  PORT            => SIGNAL
            --CPU
            clk             => clk,           
            reset           => reset, 
            RsRx            => RsRx,
            RsTx            => RsTx, 
            payload_in      => payload_in,
            payload_out     => payload_out
        ); 
        
    clk <= not clk after 25 ns;
    payload_in <= x"00000000";
    
    process is
    begin
        wait for 1us;
        reset <= '0';
        wait for 50us;

    for ii in 0 to 400 loop
        UART_WRITE_BYTE(X"13", RsRx);
        UART_WRITE_BYTE(X"23", RsRx);
        UART_WRITE_BYTE(X"43", RsRx);
        UART_WRITE_BYTE(X"c3", RsRx);
    end loop;  -- ii 
    
    end process;
    
end Behavioral;
