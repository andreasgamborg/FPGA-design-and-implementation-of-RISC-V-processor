library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.Display.all;

entity vga_ctrl is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           disp_char : in STD_LOGIC_VECTOR(5 downto 0);
           disp_pos_H : out STD_LOGIC_VECTOR(9 downto 0);
           disp_pos_V : out STD_LOGIC_VECTOR(9 downto 0);
           VGA_HS_OUT : out STD_LOGIC;
           VGA_VS_OUT : out STD_LOGIC;
           VGA_RED_OUT : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_BLUE_OUT : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_GREEN_OUT : out STD_LOGIC_VECTOR (3 downto 0)
    );
end vga_ctrl;

architecture Behavioral of vga_ctrl is

    signal count_pixel, count_pixel_next : unsigned(5 downto 0) := (others => '0');    
    signal count_H, count_H_next : unsigned(9 downto 0) := (others => '0');
    signal count_V, count_V_next : unsigned(9 downto 0) := (others => '0');

    signal flg_pixel_clk, HS, VS, HAct, VAct, Act, c_bit : std_logic;
    
begin
        
    flg_pixel_clk <= '1' when (count_pixel = "0011") else '0';
    
    process(all)
    begin
        if rising_edge(clk) then
            count_pixel <= count_pixel_next;
        end if;
        if flg_pixel_clk = '1' then
            count_pixel_next <= (others => '0');
        else 
            count_pixel_next <= count_pixel +1;
        end if;
    end process;

    process(all) -- Update
    begin
        if rising_edge(clk) then
            if flg_pixel_clk = '1' then
                count_H <= count_H_next;
                count_V <= count_V_next;
            end if;
        end if;
    end process;
    process(all) -- Next
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
    
    HS <= '0' when (DISP_WIDTH < count_H) and (count_H < DISP_WIDTH+H_FP) 
              else '1';
    VS <= '0' when (DISP_HEIGHT < count_V) and (count_V < DISP_HEIGHT+V_FP) 
              else '1';
    HAct <= '1' when (count_H < DISP_WIDTH)
              else '0';
    VAct <= '1' when (count_V < DISP_HEIGHT)
              else '0';
    Act  <= HAct and VAct;
    
    
--    c_char <= Frame(to_integer(count_V(9 downto 4)), to_integer(count_H(9 downto 4)));
    
    c_bit <= Char_ROM(to_integer(unsigned(disp_char(5 downto 4))&count_V(3 downto 0)), to_integer(unsigned(disp_char(3 downto 0))&count_H(3 downto 0)));
      
    
--    process(all)
--    begin
--        if rising_edge(clk) then
--            if (btn_s = '1') then
--                Frame(to_integer(c_ptr(8 downto 5)), to_integer(c_ptr(4 downto 0))) <= switch(5 downto 0);
--                c_ptr <= c_ptr+1;
--            end if;
--        end if;
--    end process;
    
    process(all) 
    begin
        if Act = '1' then
            if c_bit = '1' then
                VGA_RED_OUT <= DISP_FG(11 downto 8);
                VGA_GREEN_OUT <= DISP_FG(7 downto 4);
                VGA_BLUE_OUT <= DISP_FG(3 downto 0);  
            else                    
                VGA_RED_OUT <= DISP_BG(11 downto 8);
                VGA_GREEN_OUT <= DISP_BG(7 downto 4);
                VGA_BLUE_OUT <= DISP_BG(3 downto 0);  
            end if;
        else
            VGA_RED_OUT <= "0000";
            VGA_GREEN_OUT <= "0000";
            VGA_BLUE_OUT <= "0000";        
        end if;
    end process;
    VGA_HS_OUT <= HS;
    VGA_VS_OUT <= VS;
    disp_pos_H <= std_logic_vector(count_H);
    disp_pos_V <= std_logic_vector(count_V);
end Behavioral;