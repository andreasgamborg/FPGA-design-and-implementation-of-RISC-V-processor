library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity Memory_sim is
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
end Memory_sim;

architecture Behavioral of Memory_sim is

    type RAM is array(memory_BTN_addr to memory_size) of STD_LOGIC_VECTOR(31 downto 0);
    signal Dmem : RAM;
    signal addr : integer;
    type ROM is array(0 to memory_BTN_addr-1) of STD_LOGIC_VECTOR(31 downto 0);
    
    signal Memory_error_OutOfBound, Memory_error_ReadOnly: STD_LOGIC;

    constant Imem : ROM := (
        x"41000d13",x"0fff0537",x"2f000ab7",x"00ad2023",x"00000413",x"00000493",x"00100913",x"00100993",
        x"00700513",x"00900593",x"000a8613",x"010000ef",x"00000013",x"0ac0006f",x"00000013",x"fe010113",
        x"00112e23",x"00812c23",x"00912a23",x"01212823",x"00050413",x"00058493",x"00060913",x"00a00513",
        x"fff48593",x"048000ef",x"00000013",x"00245593",x"00b50533",x"00300293",x"00251513",x"005475b3",
        x"00359593",x"00b95633",x"01a50533",x"00c52023",x"01c12083",x"01812403",x"01412483",x"01212823",
        x"02010113",x"00008067",x"00000013",x"00100313",x"00000293",x"00157393",x"00639663",x"00000013",
        x"005582b3",x"00159593",x"00155513",x"fe0514e3",x"00000013",x"00028513",x"00008067",x"00000013",
        x"00000013",x"00000013",x"00000013",x"ff5ff06f",x"00000013",x"00000013",x"00000013",x"00000013",
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
