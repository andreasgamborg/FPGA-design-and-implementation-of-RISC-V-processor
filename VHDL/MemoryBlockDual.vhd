library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

library work;
use work.static.all;

--  Xilinx True Dual Port RAM Byte Write Read First Single Clock
--  This code implements a parameterizable true dual port memory (both ports can read and write).
--  The behavior of this RAM is when data is written, the prior memory contents at the write
--  address are presented on the output port.  If the output data is
--  not needed during writes or the last read value is desired to be retained,
--  it is suggested to use a no change RAM as it is more power efficient.
--  If a reset or enable is not necessary, it may be tied off or removed from the code.


--Insert the following in the architecture before the begin keyword
--  The following function calculates the address width based on specified RAM depth
entity Memory is
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
end Memory;

architecture Behavioral of Memory is
    
    signal dataDi, dataDo : std_logic_vector(31 downto 0); 
    signal mask : std_logic_vector(3 downto 0);     
    signal addrD, addrI : integer;
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
    
    signal Memory_error_addrI_OutOfBound, Memory_error_addrD_OutOfBound : STD_LOGIC;
    signal Memory_error_addrD_ReadOnly: STD_LOGIC;

begin
    --Addresses
    addrI <= to_integer(unsigned(addrI_in(11 downto 2)));
    addrD <= to_integer(unsigned(addrD_in(11 downto 2)));
    process(clk)
    begin
        if rising_edge(clk) then
            addrI_last <= addrI;
            addrD_last <= addrD;
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
        case whb is
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
RAM_enb <= '1' when memory_data_addr <= addrD else '0';

-----------------------------ROM----------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if ROM_en = '1' and Memory_error_addrI_OutOfBound = '0' then
                ROM_do <= ROM(addrI);
            else
                ROM_do <= (others => '0');
            end if;
        end if;
    end process;
    
-----------------------------IO----------------------------------------
    IO_di   <= dataDi;
    process(clk)
    begin
        if rising_edge(clk) then
            if IO_en = '1' and Memory_error_addrD_OutOfBound = '0' then
                if r_w_in = '1' and Memory_error_addrD_ReadOnly = '0' then
                    for ii in 0 to 3 loop
                        if mask(ii)='1' then
                            IO(addrD)(8*ii+7 downto 8*ii) <= IO_di(8*ii+7 downto 8*ii);
                        end if;
                    end loop;
                end if;
                if r_w_in = '0' then
                    IO_do <=  IO(addrD);
                else
                    IO_do <= (others => '0');
                end if;
            else
                IO_do <= (others => '0');
            end if;
            IO(memory_uart_addr) <= uart_in;
            IO(memory_btn_addr) <= btn_in;
            IO(memory_keyboard_addr) <= keyboard_in;
        end if;
    end process;
     
    uart_out <= IO(memory_uart_addr+1);
    led_out <= IO(memory_LED_addr);
    seg7_out <= IO(memory_seg7_addr);
    vga_out <= interface_vga(IO(memory_video_addr to memory_video_addr+memory_video_size-1));

-----------------------------RAM----------------------------------------
    --INPUT
    RAM_dib   <= dataDi;
    --RAM
    process(clk)
    begin
        if rising_edge(clk) then
            if RAM_ena = '1' and Memory_error_addrI_OutOfBound = '0' then
                RAM_doa <= RAM(addrI);
            else
                RAM_doa <= (others => '0');
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if RAM_enb = '1' and Memory_error_addrD_OutOfBound = '0' then
                if r_w_in = '1' and Memory_error_addrD_ReadOnly = '0' then
                    for ii in 0 to 3 loop
                        if mask(ii)='1' then
                            RAM(addrD)(8*ii+7 downto 8*ii) <= RAM_dib(8*ii+7 downto 8*ii);
                        end if;
                    end loop;
                end if;
                if r_w_in = '0' then
                    RAM_dob <= RAM(addrD);
                else
                    RAM_dob <= (others => '0');
                end if;
            else
                RAM_dob <= (others => '0');
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
        case mask is
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
