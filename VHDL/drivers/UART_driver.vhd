library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_driver is
    Port (  
        clk : IN STD_LOGIC;
        RsRx : IN STD_LOGIC;
        RsTx : OUT STD_LOGIC;
        done_flg : OUT STD_LOGIC;
        payload : OUT std_logic_vector(7 downto 0)
    );
end UART_driver;

architecture Behavioral of UART_driver is
    signal sRsRx : STD_LOGIC;
    constant CNT_MAX : unsigned(13 downto 0) := d"10417"; --baud 9600
    SIGNAL cnt, cnt_next : unsigned(13 downto 0);
    SIGNAL tick, done : std_logic;
    SIGNAL xdone : std_logic;

    type state_type is (Idle, Read);
    signal state, next_state : state_type;
    signal packet : std_logic_vector(9 downto 0);
    constant packet_length : unsigned(3 downto 0) := d"10";
    SIGNAL tick_cnt, tick_cnt_next : unsigned(3 downto 0);
    
begin
    done <= '1' when (tick_cnt = packet_length) else '0';
    tick <= '1' when (cnt = CNT_MAX) else '0';

    process(all) -- Set Next
    begin
        if tick = '1' then
            cnt_next <= (others => '0');
        else
            cnt_next <= cnt+1;
        end if;
        if done = '1' then
            tick_cnt_next <= (others => '0');
        elsif state = Read then
            tick_cnt_next <= tick_cnt+1;
        else
            tick_cnt_next <= tick_cnt;
        end if;
    end process;

    process(all) -- Update
    begin
        if rising_edge(clk) then
            sRsRx <= RsRx;
            cnt <= cnt_next;
            state <= next_state;
            if tick = '1' then
                tick_cnt <= tick_cnt_next;
            end if;
                     
            if state = Read then
                if tick = '1' then
                    packet <= sRsRx & packet(9 downto 1);
                end if;         
            end if;
            xdone <= done;
        end if;
    end process;
    
    process(all) -- State Logic
    begin
        case state is
            when Idle =>
                if sRsRx = '0' then
                    next_state <= Read;
                else
                    next_state <= Idle;
                end if;
            when Read =>
                if done = '1' then
                    next_state <= Idle;
                else
                    next_state <= Read;
                end if;
        end case;
    end process;
    
    done_flg <= done and (not xdone);
    payload <= packet(8 downto 1);
    RsTx <= sRsRx;
end Behavioral;
