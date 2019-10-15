library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.cpu_constants.all;

entity RAM is
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
        uart_out : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end RAM;

architecture Behavioral of RAM is

    type RAM is array(0 to 2**10) of STD_LOGIC_VECTOR(31 downto 0);
    signal Dmem : RAM;
    
    signal addr : STD_LOGIC_VECTOR(11 downto 2);
    signal vga : interface_VGA;

begin
    ready_out <= '1';
    addr <= addr_in(11 downto 2);
    
    process(clk, reset)    -- Clocked signals
    begin
        if reset = '1' then
            --Dmem <= (others => (others => '0'));
        elsif rising_edge(clk) then
            Dmem(to_integer(unsigned(memory_uart_in(11 downto 2)))) <= uart_in;
            if (r_w_in = '1' and valid_in = '1') then
                if addr > memory_UART_out then
                    Dmem(to_integer(unsigned(addr))) <= data_in;
                end if;
            end if;
        end if;
    end process;
    
    process(all)     -- Data out
    begin
        if r_w_in = '0' and valid_in = '1' then
            data_out <= Dmem(to_integer(unsigned(addr)));
        else
            data_out <= (others => '0');
        end if;
    end process;
    
    uart_out <= Dmem(to_integer(unsigned(memory_uart_out(11 downto 2))));
    led_out <= Dmem(to_integer(unsigned(memory_LED(11 downto 2))));
--    vga(239 downto 0) <= Dmem(to_integer(unsigned(memory_video_high)) downto to_integer(unsigned(memory_video_low)));

end Behavioral;
