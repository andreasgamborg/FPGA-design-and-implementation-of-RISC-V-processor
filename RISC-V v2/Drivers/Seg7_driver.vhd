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
signal  xseg7:  STD_LOGIC_VECTOR(7 downto 0);
SIGNAL tick, mode : std_logic;
    
type state_type is (A,B,C,D);
signal state_reg, next_state : state_type;

begin

    tick <= '1' when cnt = CNT_MAX else '0';
    mode <= seg7_in(24);
    
    process(all)
    begin
        if tick = '1' then
            cnt_next <= (others => '0');
        else
            cnt_next <= cnt+1;
        end if;
    end process;
    
    process(clk)
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
                xseg7 <= "0000"&seg7_in(3 downto 0);
                if mode = '1' then
                    xseg7(6 downto 5) <= seg7_in(17 downto 16);
                end if;
                an_out <= "1110";
                if tick = '1' then
                    next_state <= B;
                end if;
            when B =>
                xseg7 <= "0000"&seg7_in(7 downto 4);
                if mode = '1' then
                    xseg7(6 downto 5) <= seg7_in(19 downto 18);
                end if;             
                an_out <= "1101";
                if tick = '1' then
                    next_state <= C;
                end if;
            when C =>
                xseg7 <= "0000"&seg7_in(11 downto 8);
                if mode = '1' then
                    xseg7(6 downto 5) <= seg7_in(21 downto 20);
                end if;              
                an_out <= "1011";
                if tick = '1' then
                    next_state <= D;
                end if;
            when D =>
                xseg7 <= "0000"&seg7_in(15 downto 12);
                if mode = '1' then
                    xseg7(6 downto 5) <= seg7_in(23 downto 22);
                end if;
                an_out <= "0111";
                if tick = '1' then
                    next_state <= A;
                end if;
        end case;
    end process;
  
    process(all) 
    begin
            case xseg7 is
                when x"00" => seg7_out <= "00000011";--0
                when x"01" => seg7_out <= "10011111";--1
                when x"02" => seg7_out <= "00100101";--2
                when x"03" => seg7_out <= "00001101";--3
                when x"04" => seg7_out <= "10011001";--4
                when x"05" => seg7_out <= "01001001";--5
                when x"06" => seg7_out <= "01000001";--6
                when x"07" => seg7_out <= "00011111";--7
                when x"08" => seg7_out <= "00000001";--8
                when x"09" => seg7_out <= "00011001";--9
                when x"0a" => seg7_out <= "00010001";--A
                when x"0b" => seg7_out <= "11000001";--B
                when x"0c" => seg7_out <= "11100101";--C
                when x"0d" => seg7_out <= "10000101";--D
                when x"0e" => seg7_out <= "01100001";--E
                when x"0f" => seg7_out <= "01110001";--F
                                
                when x"10" => seg7_out <= "00000011";--0
                when x"11" => seg7_out <= "10011111";--1
                when x"12" => seg7_out <= "00100101";--2
                when x"13" => seg7_out <= "00001101";--3
                when x"14" => seg7_out <= "10011001";--4
                when x"15" => seg7_out <= "01001001";--5
                when x"16" => seg7_out <= "01000001";--6
                when x"17" => seg7_out <= "00011111";--7
                when x"18" => seg7_out <= "00000001";--8
                when x"19" => seg7_out <= "00011001";--9
                
                when x"21" => seg7_out <= "00010001";--A
                when x"22" => seg7_out <= "11000001";--B
                when x"23" => seg7_out <= "11100101";--C
                when x"24" => seg7_out <= "10000101";--D
                when x"25" => seg7_out <= "01100001";--E
                when x"26" => seg7_out <= "01110001";--F
                when x"28" => seg7_out <= "10010001";--H
                when x"29" => seg7_out <= "11110011";--I
                when x"2a" => seg7_out <= "10000111";--J
                when x"2c" => seg7_out <= "11100011";--L
                when x"2f" => seg7_out <= "11000101";--O
                
                when x"30" => seg7_out <= "00110001";--P
                when x"33" => seg7_out <= "01001001";--S
                when x"35" => seg7_out <= "10000011";--U
                when x"36" => seg7_out <= "10000010";--V
                when x"38" => seg7_out <= "10010000";--X
                when x"3a" => seg7_out <= "00100100";--Z
                when others => seg7_out <= "11111110";
            end case;
    end process;
end Behavioral;


