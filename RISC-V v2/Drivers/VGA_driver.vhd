library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.display.all;
use work.static.all;

entity VGA_driver is
    Port ( clk_pixel :      in STD_LOGIC;
           ADDR_OUT :       out STD_LOGIC_VECTOR(31 downto 0);
           CHAR_IN :        in STD_LOGIC_VECTOR(7 downto 0);
           COLOR_IN :       in  STD_LOGIC_VECTOR(31 downto 0);
           VGA_HS_OUT :     out STD_LOGIC;
           VGA_VS_OUT :     out STD_LOGIC;
           VGA_RED_OUT :    out STD_LOGIC_VECTOR (3 downto 0);
           VGA_BLUE_OUT :   out STD_LOGIC_VECTOR (3 downto 0);
           VGA_GREEN_OUT :  out STD_LOGIC_VECTOR (3 downto 0)
    );
end VGA_driver;

architecture Behavioral of VGA_driver is

    signal count_H, count_H_next : UNSIGNED(9 downto 0) := (others => '0');
    signal count_V, count_V_next : UNSIGNED(9 downto 0) := (others => '0');

    signal HS, VS, HAct, VAct, Act, c_bit : STD_LOGIC;
    
    signal addr :       UNSIGNED(31 downto 0);
    signal disp_char4 : STD_LOGIC_VECTOR(31 downto 0);
    signal disp_char :  STD_LOGIC_VECTOR(7 downto 0);
    signal color_FG :   STD_LOGIC_VECTOR(15 downto 0);
    signal color_BG :   STD_LOGIC_VECTOR(15 downto 0);
begin
    process(clk_pixel) -- Update counters
    begin
        if rising_edge(clk_pixel) then
            count_H <= count_H_next;
            count_V <= count_V_next;
        end if;
    end process;
    
    process(all) -- Next count
    begin
        -- Horizontal count
        if (count_H = H_PER - 1) then
            count_H_next <= (others => '0');
        else 
            count_H_next <= count_H + 1;
        end if;
        -- Vertical count
        if (count_V = V_PER - 1) then
            count_V_next <= (others => '0');
        elsif (count_H = H_PER - 1) then
            count_V_next <= count_V + 1;
        else
            count_V_next <= count_V;
        end if;
    end process;
    
    HS <= '0' when (DISP_WIDTH+H_FP < count_H) and (count_H < DISP_WIDTH+H_FP+H_SW+1) 
              else '1';
    VS <= '0' when (DISP_HEIGHT+V_FP < count_V) and (count_V < DISP_HEIGHT+V_FP+V_SW+1) 
              else '1';
    HAct <= '1' when (count_H < DISP_WIDTH)
              else '0';
    VAct <= '1' when (count_V < DISP_HEIGHT)
              else '0';
    Act  <= HAct and VAct;

    Color_BG <= COLOR_IN(15 downto 0);
    Color_FG <= COLOR_IN(31 downto 16);
    addr <= to_unsigned(to_integer(count_V(9 downto 4))*40 + to_integer(count_H(9 downto 4)),32);     
    c_bit <= Char_ROM(to_integer(unsigned(CHAR_IN(5 downto 4))&count_V(3 downto 0)), to_integer(unsigned(CHAR_IN(3 downto 0))&count_H(3 downto 0)));

    process(all) 
    begin
        if Act = '1' then
            if c_bit = '1' then
                VGA_RED_OUT <= Color_FG(11 downto 8);
                VGA_GREEN_OUT <= Color_FG(7 downto 4);
                VGA_BLUE_OUT <= Color_FG(3 downto 0);  
            else                    
                VGA_RED_OUT <= Color_BG(11 downto 8);
                VGA_GREEN_OUT <= Color_BG(7 downto 4);
                VGA_BLUE_OUT <= Color_BG(3 downto 0);  
            end if;
        else
            VGA_RED_OUT <= "0000";
            VGA_GREEN_OUT <= "0000";
            VGA_BLUE_OUT <= "0000";        
        end if;
    end process;
    
    ADDR_OUT <= std_logic_vector(addr + to_unsigned(memory_video_addr*4,32)+4);
    VGA_HS_OUT <= HS;
    VGA_VS_OUT <= VS;
end Behavioral;