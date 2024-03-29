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
        x"41000293",x"0fff0337",x"00f30313",x"000013b7",x"8c838393",x"80000e37",x"0062a023",x"01c3a023",
        x"084000ef",x"00000413",x"00000493",x"00001937",x"8cc90913",x"09c000ef",x"00a442b3",x"00050413",
        x"00a2f533",x"02050863",x"01859593",x"0084d493",x"00b4e4b3",x"00300293",x"0122f333",x"00629a63",
        x"000013b7",x"8c438393",x"00992023",x"0093a023",x"00190913",x"00100537",x"048000ef",x"fa050ce3",
        x"000013b7",x"8c838393",x"00001337",x"8c430313",x"000012b7",x"8cc28293",x"0003a023",x"00032023",
        x"00028067",x"000015b7",x"8c458593",x"41400613",x"00062023",x"00460613",x"fec59ce3",x"00008067",
        x"40000293",x"0002a583",x"00b57533",x"00008067",x"40800e93",x"000ea583",x"00010337",x"0ff00393",
        x"0065f533",x"0075f5b3",x"00008067",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"fe010113",x"00112e23",x"00812c23",x"00912a23",x"01212823",x"00050413",x"00058493",x"00060913",
        x"00a00513",x"09c000ef",x"00245593",x"00b50533",x"00251513",x"41400293",x"00550533",x"00300293",
        x"005475b3",x"00359593",x"00b95633",x"00c52023",x"01c12083",x"01812403",x"01412483",x"01012903",
        x"02010113",x"00008067",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00100313",x"00000293",x"00157393",x"00639463",x"005582b3",x"00159593",x"00155513",x"fe0516e3",
        x"00028513",x"00008067",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",x"00000013",
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
        if r_w_in = '0' and valid_in = '1' and Memory_error_OutOfBound = '0' then
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
