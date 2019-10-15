----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.09.2019 19:26:54
-- Design Name: 
-- Module Name: ROM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ROM is
    Port (  addr : IN STD_LOGIC_VECTOR(31 downto 0);
            inst : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end ROM;

architecture Behavioral of ROM is
    signal addr_ext : STD_LOGIC_VECTOR(63 downto 0);
begin
    addr_ext <= ((63 downto 32 => '0') & addr); 
    process(addr_ext)
    begin
        case addr_ext is
           when x"0000000000000000" =>
                inst <= x"fe010113";
            when x"0000000000000004" =>
                inst <= x"00112e23";
            when x"0000000000000008" =>
                inst <= x"00000813";
            when x"000000000000000c" =>
                inst <= x"00812c23";
            when x"0000000000000010" =>
                inst <= x"02010413";
            when x"0000000000000014" =>
                inst <= x"08800293";
            when x"0000000000000018" =>
                inst <= x"0002a503";
            when x"000000000000001c" =>
                inst <= x"000015b7";
            when x"0000000000000020" =>
                inst <= x"00a5f5b3";
            when x"0000000000000024" =>
                inst <= x"00b00a63";
            when x"0000000000000028" =>
                inst <= x"0ff57613";
            when x"000000000000002c" =>
                inst <= x"00c80023";
            when x"0000000000000030" =>
                inst <= x"00180813";
            when x"0000000000000034" =>
                inst <= x"fe5ff06f";
            when x"0000000000000038" =>
                inst <= x"00000013";
            when x"000000000000003c" =>
                inst <= x"fddff06f";
            when others => 
                inst <= x"00000013";
        end case;
    end process;
end Behavioral;
