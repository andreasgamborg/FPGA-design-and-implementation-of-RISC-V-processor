library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.cpu_constants.all;

entity Memory_bench is
end Memory_bench;

architecture Behavioral of Memory_bench is
    
    component RAM is
        Port(
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            addr_in: IN STD_LOGIC_VECTOR(31 downto 0);
            data_in: IN STD_LOGIC_VECTOR(31 downto 0);
            r_w_in: IN STD_LOGIC;                       --0:read 1:write
            data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
            valid_in: IN STD_LOGIC;
            ready_out: OUT STD_LOGIC;
            -- MMIO
            led_out: OUT STD_LOGIC_VECTOR(31 downto 0);
            vga_out: OUT interface_VGA;
            uart_in : IN STD_LOGIC_VECTOR(31 downto 0);
            uart_out : OUT STD_LOGIC_VECTOR(31 downto 0);
            btn_in : IN STD_LOGIC_VECTOR(31 downto 0);
            keyboard_in : IN STD_LOGIC_VECTOR(31 downto 0);
            seg7_out : OUT STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    signal   clk         : STD_LOGIC                        := '0';
    signal   reset       : STD_LOGIC                        := '1';
    signal   addr_in     : STD_LOGIC_VECTOR(31 downto 0);
    signal   data_in     : STD_LOGIC_VECTOR(31 downto 0);
    signal   r_w_in      : STD_LOGIC;
    signal   data_out    : STD_LOGIC_VECTOR(31 downto 0);
    signal   valid_in    : STD_LOGIC                        := '1';
    signal   ready_out   : STD_LOGIC;
    signal   led_out     : STD_LOGIC_VECTOR(31 downto 0);
    signal   vga_out     : interface_VGA;
    signal   uart_in     : STD_LOGIC_VECTOR(31 downto 0);
    signal   uart_out    : STD_LOGIC_VECTOR(31 downto 0);
    signal   btn_in      : STD_LOGIC_VECTOR(31 downto 0);
    signal   keyboard_in : STD_LOGIC_VECTOR(31 downto 0);
    signal   seg7_out    : STD_LOGIC_VECTOR(31 downto 0);
begin
    Mem : RAM
        port map(
        --  PORT            => SIGNAL
            --CPU
            clk             => clk,           
            reset           => reset, 
            addr_in         => addr_in,
            data_in         => data_in, 
            r_w_in          => r_w_in,
            data_out        => data_out, 
            valid_in        => valid_in,
            ready_out       => ready_out,
            --I/O
            led_out         => led_out,
            vga_out         => vga_out,
            uart_in         => uart_in,
            uart_out        => uart_out,
            btn_in          => btn_in,
            keyboard_in     => keyboard_in,
            seg7_out        => seg7_out
        ); 
        
clk <= not clk after 50 ns;

process is
begin
    wait for 200ns;
    reset <= '0';
    r_w_in <= '1';
    data_in <= x"11100111";
    
    --Write
    wait until rising_edge(clk);
    for ii in 0 to 2**10 loop
       addr_in <= std_logic_vector(to_unsigned(memory_ROM_addr+ii*4,32));
       wait until rising_edge(clk);
    end loop;  -- ii  
    
--    addr_in <= std_logic_vector(to_unsigned(memory_Btn_addr,32));
--    wait until rising_edge(clk);

--    addr_in <= std_logic_vector(to_unsigned(memory_Keyboard_addr,32));
--    wait until rising_edge(clk);

--    addr_in <= std_logic_vector(to_unsigned(memory_UART_addr,32));
--    wait until rising_edge(clk);

--    for ii in 0 to 5 loop
--        addr_in <= std_logic_vector(to_unsigned(memory_Video_addr+ii,32));
--        wait until rising_edge(clk);
--    end loop;  -- ii  

--    addr_in <= std_logic_vector(to_unsigned(memory_LED_addr,32));
--    wait until rising_edge(clk);

--    addr_in <= std_logic_vector(to_unsigned(memory_SEG7_addr,32));
--    wait until rising_edge(clk);
    
    
    --READ
    wait until rising_edge(clk);
    r_w_in <= '0';
    for ii in 0 to 5 loop
       addr_in <= std_logic_vector(to_unsigned(memory_ROM_addr+ii*4,32));
       wait until rising_edge(clk);
    end loop;  -- ii    

    addr_in <= std_logic_vector(to_unsigned(memory_Btn_addr*4,32));
    wait until rising_edge(clk);

    addr_in <= std_logic_vector(to_unsigned(memory_Keyboard_addr*4,32));
    wait until rising_edge(clk);

    addr_in <= std_logic_vector(to_unsigned(memory_UART_addr*4,32));
    wait until rising_edge(clk);

     for ii in 0 to 5 loop
        addr_in <= std_logic_vector(to_unsigned(memory_Video_addr*4+ii*4,32));
        wait until rising_edge(clk);
    end loop;  -- ii  

    addr_in <= std_logic_vector(to_unsigned(memory_LED_addr*4,32));
    wait until rising_edge(clk);

    addr_in <= std_logic_vector(to_unsigned(memory_SEG7_addr*4,32));
    wait until rising_edge(clk);
end process;


end Behavioral;
