library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Seg7_driver is
    Port(   clk :       IN STD_LOGIC;
            seg7_in:    IN STD_LOGIC_VECTOR(31 downto 0);
            seg7_out:   OUT STD_LOGIC_VECTOR(7 downto 0);
            an_out :    OUT STD_LOGIC_VECTOR(3 downto 0)
        );
end Seg7_driver;

architecture Behavioral of Seg7_driver is
constant CNT_MAX : unsigned(11 downto 0) := "111111111100";
SIGNAL cnt, cnt_next : unsigned(11 downto 0);
signal  xseg7:  STD_LOGIC_VECTOR(3 downto 0);
SIGNAL tick : std_logic;
    
type state_type is (A,B,C,D);
signal state_reg, next_state : state_type;

begin
    process(all)
    begin
        if cnt = CNT_MAX then
            tick <= '1';
            cnt_next <= (others => '0');
        else
            tick <= '0';
            cnt_next <= cnt+1;
        end if;
    end process;
    
    process(all)
    begin
        if rising_edge(clk) then
            cnt <= cnt_next;
            state_reg <= next_state;
        end if;
    end process;

    process(all) 
    begin
        next_state <= state_reg;
        case state_reg is
            when A =>
                xseg7 <= seg7_in(3 downto 0);
                an_out <= "1110";
                if tick = '1' then
                    next_state <= B;
                end if;
            when B =>
                xseg7 <= seg7_in(7 downto 4);
                an_out <= "1101";
                if tick = '1' then
                    next_state <= C;
                end if;
            when C =>
                xseg7 <= seg7_in(11 downto 8);
                an_out <= "1011";
                if tick = '1' then
                    next_state <= D;
                end if;
            when D =>
                xseg7 <= seg7_in(15 downto 12);
                an_out <= "0111";
                if tick = '1' then
                    next_state <= A;
                end if;
        end case;
    end process;
  
    process(all) 
    begin
        case xseg7 is
            when x"0" => seg7_out <= "00000011";
            when x"1" => seg7_out <= "10011111";
            when x"2" => seg7_out <= "00100101";
            when x"3" => seg7_out <= "00001101";
            when x"4" => seg7_out <= "10011001";
            when x"5" => seg7_out <= "01001001";
            when x"6" => seg7_out <= "01000001";
            when x"7" => seg7_out <= "00011111";
            when x"8" => seg7_out <= "00000001";
            when x"9" => seg7_out <= "00011001";
            when x"a" => seg7_out <= "00010001";
            when x"b" => seg7_out <= "11000001";
            when x"c" => seg7_out <= "11100101";
            when x"d" => seg7_out <= "10000101";
            when x"e" => seg7_out <= "01100001";
            when x"f" => seg7_out <= "01110001";
            when others => seg7_out <= "11111110";
        end case;
    end process;
end Behavioral;


