library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity Memory is
    Port(
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        addr_in: IN STD_LOGIC_VECTOR(31 downto 0);
        data_in: IN STD_LOGIC_VECTOR(31 downto 0);
        r_w_in: IN STD_LOGIC;                       --0:read 1:write
        data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        valid_in: IN STD_LOGIC;
        ready_out: OUT STD_LOGIC
        -- MMIO
--        led_out: OUT STD_LOGIC_VECTOR(31 downto 0);
--        vga_out: OUT interface_VGA;
--        uart_in : IN STD_LOGIC_VECTOR(31 downto 0);
--        uart_out : OUT STD_LOGIC_VECTOR(31 downto 0);
--        btn_in : IN STD_LOGIC_VECTOR(31 downto 0);
--        keyboard_in : IN STD_LOGIC_VECTOR(31 downto 0);
--        seg7_out : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory;

architecture Behavioral of Memory is

    type RAM is array(0 to 2**12) of STD_LOGIC_VECTOR(31 downto 0);
    signal Dmem : RAM;
    signal addr : integer;
    
    signal Memory_error_OutOfBound, Memory_error_ReadOnly: STD_LOGIC;

begin
    ready_out <= '1';
    addr <= to_integer(unsigned(addr_in(13 downto 2)));
    
    process(all) --Errors
    begin
        -- Attempting to write to a read only address
        if (r_w_in = '1' and valid_in = '1' and (addr <= memory_read_only)) then
            -- Every address below 'memory_read_only' is read only
            Memory_error_ReadOnly <= '1';
        else
            Memory_error_ReadOnly <= '0';
        end if;
        
        -- Attempting to access a illegit address
        if addr_in(31 downto 14) = "000000000000000000" then
            --legit address
            Memory_error_OutOfBound <= '0';
        else
            --illegit address
            Memory_error_OutOfBound <= '1';
        end if;
    end process;
    
    process(clk)    -- Read/write
    begin
        if rising_edge(clk) then
--            Dmem(memory_uart_addr) <= uart_in;
--            Dmem(memory_btn_addr) <= btn_in;
--            Dmem(memory_keyboard_addr) <= keyboard_in;
            if (valid_in = '1') and (Memory_error_OutOfBound = '0') then
                if (r_w_in = '1') then
                    if (Memory_error_ReadOnly = '0') then  
                        -- Write only if addr is a legit write address
                        Dmem(addr) <= data_in;
                    end if;
                else
                        data_out <= Dmem(addr);
                end if;
            end if;
        end if;
    end process;
    
--    uart_out <= Dmem(memory_uart_addr+1);
--    led_out <= Dmem(memory_LED_addr);
--    seg7_out <= Dmem(memory_seg7_addr);
--    vga_out <= interface_vga(Dmem(memory_video_addr to memory_video_addr+memory_video_size-1));

end Behavioral;
