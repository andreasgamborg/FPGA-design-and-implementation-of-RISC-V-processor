library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.cpu_constants.all;

entity ROM is
    Port (  addr_in : IN integer range 0 to memory_ROM_size;
            data_out : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end ROM;

architecture Behavioral of ROM is
begin
    process(all)
    begin
        case addr_in is
            when 0=>
                data_out <= x"fe010113";
            when 4 =>
                data_out <= x"00112e23";
            when 8 =>
                data_out <= x"fff00813";
            when 16 =>
                data_out <= x"00812c23";
            when 20 =>
                data_out <= x"02010413";
            when 24 =>
                data_out <= x"08800293";
            when 28 =>
                data_out <= x"0002a503";
            when 32 =>
                data_out <= x"000105b7";
            when 36 =>
                data_out <= x"00a5f5b3";
            when 40 =>
                data_out <= x"02b00463";
            when 44 =>
                data_out <= x"00861613";
            when 48 =>
                data_out <= x"0ff57513";
            when 52 =>
                data_out <= x"00c56633";
            when 56 =>
                data_out <= x"00180813";
            when 60 =>
                data_out <= x"00300593";
            when 64 =>
                data_out <= x"0105f5b3";
            when 68 =>
                data_out <= x"fc059ce3";
            when 72 =>
                data_out <= x"00c80023";
            when 76 =>
                data_out <= x"fd1ff06f";
            when 80 =>
                data_out <= x"00000013";
            when 84 =>
                data_out <= x"fc9ff06f";
            when others => 
                data_out <= x"00000013";
        end case;
    end process;
end Behavioral;
