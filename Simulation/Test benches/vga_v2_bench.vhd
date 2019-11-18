library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity vga_v2_bench is
end vga_v2_bench;

architecture Behavioral of vga_v2_bench is
    component VGA_driver is
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
    end component;

    signal clk_pixel :      STD_LOGIC := '0';
    signal ADDR_OUT :       STD_LOGIC_VECTOR(31 downto 0);
    signal CHAR_IN :        STD_LOGIC_VECTOR(7 downto 0) := x"00";
    signal COLOR_IN :       STD_LOGIC_VECTOR(31 downto 0);
    signal VGA_HS_OUT :     STD_LOGIC;
    signal VGA_VS_OUT :     STD_LOGIC;
    signal VGA_RED_OUT :    STD_LOGIC_VECTOR (3 downto 0);
    signal VGA_BLUE_OUT :   STD_LOGIC_VECTOR (3 downto 0);
    signal VGA_GREEN_OUT :  STD_LOGIC_VECTOR (3 downto 0);

begin
    VGA : VGA_driver
    port map(
    --  PORT            => SIGNAL
        clk_pixel       => clk_pixel,           
        addr_out        => addr_out,
        char_in         => char_in,
        color_in        => COLOR_IN,
        VGA_HS_OUT      => VGA_HS_OUT,
        VGA_VS_OUT      => VGA_VS_OUT,  
        VGA_RED_OUT     => VGA_RED_OUT,  
        VGA_BLUE_OUT    => VGA_BLUE_OUT, 
        VGA_GREEN_OUT   => VGA_GREEN_OUT
    ); 
    
    clk_pixel <= not clk_pixel after 5 ns;

    process is
    begin
        wait for 20ns;
        CHAR_IN <= std_logic_vector(unsigned(CHAR_IN)+1);
    end process;
    
end Behavioral;
