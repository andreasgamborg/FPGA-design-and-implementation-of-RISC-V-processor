library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity Memory is
    Port(
        clk:        IN STD_LOGIC;  
        -- READ PORT
        addrI_in :  IN STD_LOGIC_VECTOR(31 downto 0);
        dataI_out : OUT STD_LOGIC_VECTOR(31 downto 0);
        -- READ/WRITE PORT with byte access
        addrD_in :  IN STD_LOGIC_VECTOR(31 downto 0);
        dataD_in :  IN STD_LOGIC_VECTOR(31 downto 0);
        r_w_in :    IN STD_LOGIC;                               --0:read 1:write
        whb_in :    IN STD_LOGIC_VECTOR(1 downto 0);            -- word(11)/halfword(10)/byte(01)
        dataD_out : OUT STD_LOGIC_VECTOR(31 downto 0);
        --MMIO
        led_out:    OUT STD_LOGIC_VECTOR(31 downto 0);
        vga_addr_in:    IN STD_LOGIC_VECTOR(31 downto 0);
        vga_char_out:   OUT STD_LOGIC_VECTOR(7 downto 0);
        vga_color_out:   OUT STD_LOGIC_VECTOR(31 downto 0);
        uart_in :   IN STD_LOGIC_VECTOR(31 downto 0);
        uart_out :  OUT STD_LOGIC_VECTOR(31 downto 0);
        btn_in :    IN STD_LOGIC_VECTOR(31 downto 0);
        keyboard_in:IN STD_LOGIC_VECTOR(31 downto 0);
        seg7_out :  OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory;

architecture Behavioral of Memory is
    
    signal dataDi, dataDo : std_logic_vector(31 downto 0); 
    signal mask, mask_last : std_logic_vector(3 downto 0);     
    signal addrD, addrI, addrVGA : integer;
    signal addrD_last, addrI_last : integer;

    type RAM_type is array(memory_data_addr to memory_size-1) of STD_LOGIC_VECTOR(31 downto 0);
    signal RAM_ena, RAM_enb : std_logic;
    signal RAM_dib, RAM_doa, RAM_dob: std_logic_vector(31 downto 0);
    
    type IO_type is array(memory_BTN_addr to memory_data_addr-1) of STD_LOGIC_VECTOR(31 downto 0);
    signal IO_en : std_logic;
    signal IO_do, IO_di : std_logic_vector(31 downto 0);
    
    type ROM_type is array(0 to memory_BTN_addr-1) of STD_LOGIC_VECTOR(31 downto 0);
    signal ROM_en : std_logic;
    signal ROM_do : std_logic_vector(31 downto 0);    
    
    signal RAM : RAM_type;
    signal IO : IO_type;
    constant ROM : ROM_type := (
        x"41000293",x"0fff0337",x"00f30313",x"000013b7",x"8c438393",x"01aade37",x"f14e0e13",x"0062a023",
        x"0003a023",x"01c3a223",x"1d8000ef",x"00000413",x"000014b7",x"8cc48493",x"00001937",x"8c490913",
        x"0c0000ef",x"00a442b3",x"00050413",x"00a2f533",x"00050863",x"00b48023",x"00b90023",x"00148493",
        x"40000537",x"05c000ef",x"fc050ce3",x"00001337",x"8c830313",x"000012b7",x"8cc28293",x"00092023",
        x"00032023",x"24000093",x"00001137",x"00028067",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"40000293",x"0002a583",x"00b57533",x"00008067",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"40800e93",x"000ea583",x"00010337",x"0ff00393",x"0065f533",x"0075f5b3",x"00008067",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"ff810113",x"00112223",x"00050693",x"02800513",x"050000ef",x"41400293",x"00d50533",x"00550533",
        x"00c50023",x"00412083",x"00810113",x"00008067",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00100313",x"00000293",x"00157393",x"00639463",x"005582b3",x"00159593",x"00155513",x"fe0516e3",
        x"00028513",x"00008067",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"000015b7",x"8c458593",x"41400613",x"00062023",x"00460613",x"fec59ce3",x"00008067",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"20000537",x"e7dff0ef",x"fe050ce3",x"db5ff06f",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00051463",x"00008067",x"fff50513",x"00900293",x"fff28293",x"00000013",x"00000013",x"fe029ae3",
        x"00000013",x"00000013",x"00000013",x"00000013",x"fc051ce3",x"00008067",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"000013b7",x"8c838393",x"01aa5e37",x"555e0e13",x"01c3a023",x"f2dff06f",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
        x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000"
    );
    
    signal Memory_error_addrI_OutOfBound, Memory_error_addrD_OutOfBound : STD_LOGIC;
    signal Memory_error_addrD_ReadOnly: STD_LOGIC;

begin
    --Addresses
    addrI <= to_integer(unsigned(addrI_in(11 downto 2)));
    addrD <= to_integer(unsigned(addrD_in(11 downto 2)));
    addrVGA <= to_integer(unsigned(vga_addr_in(11 downto 2)))+memory_video_addr+1;
    process(clk)
    begin
        if rising_edge(clk) then
            addrI_last <= addrI;
            addrD_last <= addrD;
            mask_last <= mask;
        end if;
    end process;
    --Errors
    Memory_error_addrI_OutOfBound <= '0' when addrI_in(31 downto 12) = x"00000" else '1';
    Memory_error_addrD_OutOfBound <= '0' when addrD_in(31 downto 12) = x"00000" else '1';
    process(all)
    begin
        Memory_error_addrD_ReadOnly <= '0';                
        if (r_w_in = '1') and (Memory_error_addrD_OutOfBound = '0') then
            -- Every address below 'memory_read_only' is read only
            if addrD <= memory_read_only then
                Memory_error_addrD_ReadOnly <= '1';                
            end if;
        end if;
    end process;
    -- Generate mask and shift write data to correct address
    process(all)
    begin
        case whb_in is
            when "11" =>    
                mask <= "1111";
            when "10" =>    
                if(addrD_in(1) ='1') then
                    mask <= "1100";
                else
                    mask <= "0011";
                end if;
            when "01" =>    
                case addrD_in(1 downto 0) is 
                    when "00" => mask <= "0001";
                    when "01" => mask <= "0010";
                    when "10" => mask <= "0100";
                    when "11" => mask <= "1000";
                    when others => mask <= "0000";
                end case;
            when others =>  
                mask <= "0000";
        end case;
    end process;
    
    dataDi  <= std_logic_vector(shift_left(unsigned(dataD_in), 8*to_integer(unsigned(addrD_in(1 downto 0)))));

ROM_en <= '1' when addrI < memory_BTN_addr else '0';
IO_en <= '1' when (memory_BTN_addr <= addrD and addrD < memory_data_addr) else '0';
RAM_ena <= '1' when memory_data_addr <= addrI else '0';
RAM_enb <= '1' when memory_data_addr <= addrD and (whb_in /= "00") else '0';

-----------------------------ROM----------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if ROM_en = '1' and Memory_error_addrI_OutOfBound = '0' then
                ROM_do <= ROM(addrI);
            end if;
        end if;
    end process;
    
-----------------------------IO----------------------------------------
    IO_di   <= dataDi;
    process(clk)
    begin
        if rising_edge(clk) then
            if IO_en = '1' and Memory_error_addrD_OutOfBound = '0' then
                IO_do <=  IO(addrD);
                if r_w_in = '1' and Memory_error_addrD_ReadOnly = '0' then
                    for ii in 0 to 3 loop
                        if mask(ii)='1' then
                            IO(addrD)(8*ii+7 downto 8*ii) <= IO_di(8*ii+7 downto 8*ii);
                        end if;
                    end loop;
                end if;
            end if;
            IO(memory_uart_addr) <= uart_in;
            IO(memory_btn_addr) <= btn_in;
            IO(memory_keyboard_addr) <= keyboard_in;
        end if;
    end process;
     
    uart_out <= IO(memory_uart_addr+1);
    led_out <= IO(memory_LED_addr);
    seg7_out <= IO(memory_seg7_addr);
    vga_color_out <= IO(memory_video_addr);
    process(all)
    begin
        if(addrVGA < memory_LED_addr) then
            case vga_addr_in(1 downto 0) is
                when "00" => vga_char_out <= IO(addrVGA)(7 downto 0);
                when "01" => vga_char_out <= IO(addrVGA)(15 downto 8);
                when "10" => vga_char_out <= IO(addrVGA)(23 downto 16);
                when "11" => vga_char_out <= IO(addrVGA)(31 downto 24);
                when others => vga_char_out <= (others => '0');
            end case;
        else
            vga_char_out <= (others => '0');
        end if;
    end process;
-----------------------------RAM----------------------------------------
    --INPUT
    RAM_dib   <= dataDi;
    --RAM
    process(clk)
    begin
        if rising_edge(clk) then
            if RAM_ena = '1' and Memory_error_addrI_OutOfBound = '0' then
                RAM_doa <= RAM(addrI);
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if RAM_enb = '1' and Memory_error_addrD_OutOfBound = '0' then
                RAM_dob <= RAM(addrD);
                if r_w_in = '1' and Memory_error_addrD_ReadOnly = '0' then
                    for ii in 0 to 3 loop
                        if mask(ii)='1' then
                            RAM(addrD)(8*ii+7 downto 8*ii) <= RAM_dib(8*ii+7 downto 8*ii);
                        end if;
                    end loop;
                end if;
            end if;
        end if;
    end process;
    
    --OUTPUT
    -- I PORT
    process(all)
    begin
        if addrI_last < memory_BTN_addr then
            dataI_out <= ROM_do;
        elsif memory_data_addr <= addrI_last then
            dataI_out <= RAM_doa;  
        else
            dataI_out <= (others => '0');
        end if;
    end process;
    
    -- D port
    process(all)
    begin
        if memory_data_addr <= addrD_last then
            dataDo <= RAM_dob; 
        elsif memory_BTN_addr <= addrD_last then
            dataDo <= IO_do;
        else
            dataDo <= (others => '0');
        end if;
    end process;
    
    -- Swift data when lh, lb
    process(all)
    begin
        case mask_last is
            when "1111" =>
                dataD_out <= dataDo;
            when "1100" =>
                dataD_out <= x"0000" & dataDo(31 downto 16);
            when "0011" =>
                dataD_out <= x"0000" & dataDo(15 downto 0);
            when "1000" =>
                dataD_out <= x"000000" & dataDo(31 downto 24);
            when "0100" =>
                dataD_out <= x"000000" & dataDo(23 downto 16);
            when "0010" =>
                dataD_out <= x"000000" & dataDo(15 downto 8);
            when "0001" =>
                dataD_out <= x"000000" & dataDo(7 downto 0);
            when others =>
                dataD_out <= (others => '0');
        end case;
    end process;
end Behavioral;
