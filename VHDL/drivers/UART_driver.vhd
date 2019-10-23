library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--Payload out
--31      23    15    7
--|status|valid|blank|package|

--Payload in
--|status|valid|blank|package|

entity UART_driver is
    generic(
        clk_freq :      integer := 100e6; -- Hz
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
end UART_driver;

architecture Behavioral of UART_driver is
    signal sRx, Rx: STD_LOGIC;
    --constant CNT_MAX : unsigned(13 downto 0) := d"10417";   --baud 9600 @ 100Hz
    --constant CNT_MAX : unsigned(10 downto 0) := d"1042";    --baud 9600 @ 10Hz
    constant CNT_MAX : integer := clk_freq/baud;

    signal enable_tick_cnt, enable_tick_cnt_next : unsigned(31 downto 0);
    signal enable_tick : std_logic;
    
    signal bit_cnt, bit_cnt_next : unsigned(3 downto 0);

    signal Rx_packet : std_logic_vector(9 downto 0);
    signal Rx_idle, Rx_packet_valid : std_logic;  
    
begin
    enable_tick <= '1' when (enable_tick_cnt = CNT_MAX) else '0';
    Rx_idle <= '1' when (Rx_packet = "1111111111") else '0';
    Rx_packet_valid <= '1' when  ((bit_cnt = packet_length-1) and (Rx_idle = '0')) else '0';
    
    process(all) -- Set Next
    begin
        if enable_tick = '1' then
            enable_tick_cnt_next <= (others => '0');
             if (Rx_packet_valid = '1' or Rx_idle = '1') then
                bit_cnt_next <= (others => '0');
            else
                bit_cnt_next <= bit_cnt+1;
            end if;
        else
            enable_tick_cnt_next <= enable_tick_cnt+1;
            bit_cnt_next <= bit_cnt;
        end if;
    end process;
    
    process(all) -- Update
    begin
        if reset = '1' then
            enable_tick_cnt <= (others => '0');
            bit_cnt <= (others => '0');
            Rx_packet <= (others => '1');
        elsif rising_edge(clk) then
            sRx <= RsRx;
            Rx <= sRx;
            enable_tick_cnt <= enable_tick_cnt_next;
            bit_cnt <= bit_cnt_next;
            if enable_tick = '1' then
                Rx_packet <= Rx & Rx_packet(9 downto 1);
            end if; 
        end if;
    end process;

    payload_out <= (31 downto 17 => '0')& Rx_packet_valid & (15 downto 8 => '0') & Rx_packet(8 downto 1);
    RsTx <= Rx;
end Behavioral;
