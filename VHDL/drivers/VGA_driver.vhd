library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.Display.all;
use work.cpu_constants.all;

entity VGA_driver is
    Port ( clk :            in STD_LOGIC;
           reset :          in STD_LOGIC;
--           disp_char :      in STD_LOGIC_VECTOR(5 downto 0);
--           disp_pos_H :     out STD_LOGIC_VECTOR(9 downto 0);
--           disp_pos_V :     out STD_LOGIC_VECTOR(9 downto 0);
           VGA_IN :         IN interface_VGA;
           VGA_HS_OUT :     out STD_LOGIC;
           VGA_VS_OUT :     out STD_LOGIC;
           VGA_RED_OUT :    out STD_LOGIC_VECTOR (3 downto 0);
           VGA_BLUE_OUT :   out STD_LOGIC_VECTOR (3 downto 0);
           VGA_GREEN_OUT :  out STD_LOGIC_VECTOR (3 downto 0)
    );
end VGA_driver;

architecture Behavioral of VGA_driver is

    signal count_pixel, count_pixel_next : unsigned(5 downto 0) := (others => '0');    
    signal count_H, count_H_next : unsigned(9 downto 0) := (others => '0');
    signal count_V, count_V_next : unsigned(9 downto 0) := (others => '0');

    signal flg_pixel_clk, HS, VS, HAct, VAct, Act, c_bit : std_logic;
    
    signal disp_char4 : STD_LOGIC_VECTOR(31 downto 0);
    signal disp_char : STD_LOGIC_VECTOR(7 downto 0);

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
        
    process(all)
    begin
        disp_char4 <= VGA_IN(to_integer(count_V(9 downto 4))*8+to_integer(count_H(9 downto 6)));
        case count_H(5 downto 4) is
            when "00" =>
                disp_char <= disp_char4(7 downto 0);
            when "01" =>
                disp_char <= disp_char4(15 downto 8);
            when "10" =>
                disp_char <= disp_char4(23 downto 16);
            when "11" =>
                disp_char <= disp_char4(31 downto 24);
        end case;
    end process;

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
end Behavioral;