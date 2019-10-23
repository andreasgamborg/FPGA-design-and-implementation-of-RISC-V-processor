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
end Memory;

architecture Behavioral of Memory is

    type RAM is array(memory_BTN_addr to memory_size) of STD_LOGIC_VECTOR(31 downto 0);
    signal Dmem : RAM;
    signal addr : integer;
    type ROM is array(0 to memory_BTN_addr-1) of STD_LOGIC_VECTOR(31 downto 0);
    
    signal Memory_error_OutOfBound, Memory_error_ReadOnly: STD_LOGIC;

    constant Imem : ROM := (
        x"00001fb7",x"8c8f8f93",x"41000e93",x"40800293",x"00001337",x"8c430313",x"000013b7",x"8c838393",
        x"40000e13",x"00fff5b7",x"00f58593",x"00bea023",x"000f8813",x"004e8613",x"00062023",x"00460613",
        x"fe661ce3",x"00000013",x"00f005b7",x"000e2503",x"00a5f5b3",x"06059263",x"00000013",x"000105b7",
        x"0002a503",x"00a5f5b3",x"fe0580e3",x"00000013",x"00c51513",x"00865613",x"00c51513",x"00300593",
        x"00180813",x"00c56633",x"0105f5b3",x"00059863",x"00000013",x"00c82023",x"00c32023",x"000105b7",
        x"0002a503",x"00a5f5b3",x"fe059ae3",x"00000013",x"f99ff06f",x"00000013",x"000f8067",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
        x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013"
    );
        
begin
    ready_out <= '1';
    addr <= to_integer(unsigned(addr_in(11 downto 2)));
    
    process(all) --Errors
    begin
        Memory_error_ReadOnly <= '0';
        Memory_error_OutOfBound <= '0';
        -- Attempting to access a illegit address
        if addr_in(31 downto 12) = x"00000" then
        -- legit address
            -- Attempting to write to a read only address
            if (r_w_in = '1' and valid_in = '1' and (addr <= memory_read_only)) then
            -- Every address below 'memory_read_only' is read only
                    Memory_error_ReadOnly <= '1';                
            end if;
        else
        -- illegit address
            Memory_error_OutOfBound <= '1';
        end if;
    end process;
    
    process(all)    -- Clocked signals
    begin
        if reset = '1' then
            --Dmem <= (others => (others => '0'));
        elsif rising_edge(clk) then
            Dmem(memory_uart_addr) <= uart_in;
            Dmem(memory_btn_addr) <= btn_in;
            Dmem(memory_keyboard_addr) <= keyboard_in;
            if (r_w_in = '1' and valid_in = '1') then
                if (Memory_error_ReadOnly = '0' and Memory_error_OutOfBound = '0') then  
                    -- Write only if addr is a legit write address
                    Dmem(addr) <= data_in;
                end if;
            end if;
        end if;
    end process;
    
    process(all)     -- Data out
    begin
        if r_w_in = '0' and valid_in = '1' then
            if addr >= memory_BTN_addr then
                data_out <= Dmem(addr);
            else
                data_out <= Imem(addr);
            end if;
        else
            data_out <= (others => '0');
        end if;
    end process;
    
    uart_out <= Dmem(memory_uart_addr+1);
    led_out <= Dmem(memory_LED_addr);
    seg7_out <= Dmem(memory_seg7_addr);
    vga_out <= interface_vga(Dmem(memory_video_addr to memory_video_addr+memory_video_size-1));

end Behavioral;
