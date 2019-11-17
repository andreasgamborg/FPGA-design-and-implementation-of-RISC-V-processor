library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity Memory_bench is
end Memory_bench;

architecture Behavioral of Memory_bench is
    
    component Memory is
        Port(
            clk :       IN STD_LOGIC;
            -- READ PORT
            addrI_in :  IN STD_LOGIC_VECTOR(31 downto 0);
            dataI_out : OUT STD_LOGIC_VECTOR(31 downto 0);
            -- READ/WRITE PORT with byte access
            addrD_in :  IN STD_LOGIC_VECTOR(31 downto 0);
            dataD_in :   IN STD_LOGIC_VECTOR(31 downto 0);
            r_w_in :    IN STD_LOGIC;                               --0:read 1:write
            whb :       IN STD_LOGIC_VECTOR(1 downto 0);            -- word(11)/halfword(10)/byte(01)
            dataD_out : OUT STD_LOGIC_VECTOR(31 downto 0);
            --MMIO
            led_out: OUT STD_LOGIC_VECTOR(31 downto 0);
            vga_out: OUT interface_VGA;
            uart_in : IN STD_LOGIC_VECTOR(31 downto 0);
            uart_out : OUT STD_LOGIC_VECTOR(31 downto 0);
            btn_in : IN STD_LOGIC_VECTOR(31 downto 0);
            keyboard_in : IN STD_LOGIC_VECTOR(31 downto 0);
            seg7_out : OUT STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
        signal clk :        STD_LOGIC := '0';
        signal addrI_in :   STD_LOGIC_VECTOR(31 downto 0);
        signal dataI_out :  STD_LOGIC_VECTOR(31 downto 0);

        signal addrD_in :   STD_LOGIC_VECTOR(31 downto 0);
        signal dataD_in :    STD_LOGIC_VECTOR(31 downto 0) := x"03020100";
        signal r_w_in :     STD_LOGIC;      
        signal whb :        STD_LOGIC_VECTOR(1 downto 0) := "11";           
        signal dataD_out :  STD_LOGIC_VECTOR(31 downto 0);
        signal led_out:     STD_LOGIC_VECTOR(31 downto 0);
        signal vga_out:     interface_VGA;
        signal uart_in :    STD_LOGIC_VECTOR(31 downto 0);
        signal uart_out :   STD_LOGIC_VECTOR(31 downto 0);
        signal btn_in :     STD_LOGIC_VECTOR(31 downto 0);
        signal keyboard_in: STD_LOGIC_VECTOR(31 downto 0);
        signal seg7_out :   STD_LOGIC_VECTOR(31 downto 0);
        
        signal count : unsigned(31 downto 0) := x"01010101";
        
begin
    Mem : Memory
        port map(
        --  PORT        => SIGNAL
            clk         => clk,      
            addrI_in    => addrI_in,
            dataI_out   => dataI_out,
            addrD_in    => addrD_in, 
            dataD_in     => dataD_in,  
            r_w_in      => r_w_in,         
            whb         => whb,  
            dataD_out   => dataD_out,
            led_out     => led_out,       
            vga_out     => vga_out,    
            uart_in     => uart_in,    
            uart_out    => uart_out,   
            btn_in      => btn_in,     
            keyboard_in => keyboard_in,
            seg7_out    => seg7_out
        ); 
        
clk <= not clk after 50 ns;

process is
begin
    
    wait until rising_edge(clk);
    for ii in 0 to 255 loop
        addrI_in <= std_logic_vector(to_unsigned(ii*4,32));
        wait until rising_edge(clk);
    end loop;
    
    wait until rising_edge(clk);
    for ii in memory_data_addr-10 to memory_data_addr+10 loop
        addrI_in <= std_logic_vector(to_unsigned(ii*4,32));
        wait until rising_edge(clk);
    end loop;
    
end process;

process is
begin
    r_w_in <= '1';
    whb <= "10";
    wait for 200ns;
    
    --Write
    wait until rising_edge(clk);
    for ii in 200 to memory_data_addr+10 loop
        addrD_in <= std_logic_vector(to_unsigned(ii*4+2,32));
        dataD_in <= std_logic_vector(unsigned(dataD_in) + count);
        wait until rising_edge(clk);
    end loop;  -- ii 
     
    r_w_in <= '0';
    whb <= "01";
    wait until rising_edge(clk);
    for ii in 200 to memory_data_addr+10 loop
        addrD_in <= std_logic_vector(to_unsigned(ii*4+3,32));
        wait until rising_edge(clk);
    end loop;  -- ii 
    
end process;

end Behavioral;
