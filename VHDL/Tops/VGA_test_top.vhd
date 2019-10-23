library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity VGA_test_top is
    Port (  
        basys3_clk : IN STD_LOGIC;
        basys3_switch : IN STD_LOGIC_VECTOR(5 downto 0);

        VGA_HS_OUT : OUT STD_LOGIC;
        VGA_VS_OUT : OUT STD_LOGIC;
        VGA_RED_OUT : OUT STD_LOGIC_VECTOR (3 downto 0);
        VGA_BLUE_OUT : OUT STD_LOGIC_VECTOR (3 downto 0);
        VGA_GREEN_OUT : OUT STD_LOGIC_VECTOR (3 downto 0)
    );
end VGA_test_top;

architecture Behavioral of VGA_test_top is
    
    component Clock_gen is
      port (
        clk20 :     out STD_LOGIC;
        clk10 :     out STD_LOGIC;
        clk5 :      out STD_LOGIC;
        clk_pixel : out STD_LOGIC;
        clksys :    in STD_LOGIC
      );
    end component;
    
    component VGA_driver is
        Port ( 
            clk_pixel : in STD_LOGIC;
            reset : in STD_LOGIC;
            VGA_IN :         IN interface_VGA;
            VGA_HS_OUT : out STD_LOGIC;
            VGA_VS_OUT : out STD_LOGIC;
            VGA_RED_OUT : out STD_LOGIC_VECTOR (3 downto 0);
            VGA_BLUE_OUT : out STD_LOGIC_VECTOR (3 downto 0);
            VGA_GREEN_OUT : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;
    
    signal clk_pixel :  STD_LOGIC;
    signal VGA_IN :     interface_VGA;
    signal char : STD_LOGIC_VECTOR (7 downto 0);
    signal char4 : STD_LOGIC_VECTOR (31 downto 0);

begin
    Clock : clock_gen 
    port map(
        clksys => basys3_clk,
        clk_pixel => clk_pixel
    );
    VGA : VGA_driver
    port map(
    --  PORT            => SIGNAL
        clk_pixel       => clk_pixel,           
        reset           => '0', 
        VGA_IN          => VGA_IN,
        VGA_HS_OUT      => VGA_HS_OUT,
        VGA_VS_OUT      => VGA_VS_OUT,  
        VGA_RED_OUT     => VGA_RED_OUT,  
        VGA_BLUE_OUT    => VGA_BLUE_OUT, 
        VGA_GREEN_OUT   => VGA_GREEN_OUT
    ); 
   
    char <= "00"&basys3_switch;
    char4 <= char&char&char&char;
    VGA_IN <= (0 => x"0f0f00ff", others => char4);
    
end Behavioral;
