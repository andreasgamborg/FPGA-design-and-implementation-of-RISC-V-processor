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
    Port (  addr : IN STD_LOGIC_VECTOR(63 downto 0);
            inst : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end ROM;

architecture Behavioral of ROM is

begin
    process(addr)
    begin
        case addr is
            when x"0000000000000000" =>
                inst <= x"00a00513";
            when x"0000000000000004" =>
                inst <= x"01400593";
            when x"0000000000000008" =>
                inst <= x"02b50063";
            when x"000000000000000c" =>
                inst <= x"00b54863";
            when x"0000000000000010" =>
                inst <= x"00300513";
            when x"0000000000000014" =>
                inst <= x"00400593";
            when x"0000000000000018" =>
                inst <= x"00b54c63";
            when x"000000000000001c" =>
                inst <= x"00b54463";
            when x"0000000000000020" =>
                inst <= x"feb548e3";
            when x"0000000000000024" =>
                inst <= x"feb54ee3";
            when x"0000000000000028" =>
                inst <= x"00100513";
            when x"000000000000002c" =>
                inst <= x"00200593";
            when x"0000000000000030" =>
                inst <= x"00050613";
            when x"0000000000000034" =>
                inst <= x"00a00513";
            when x"0000000000000038" =>
                inst <= x"00000073";
            when x"000000000000003c" =>
                inst <= x"00000013";
            when others => 
                inst <= x"00000013";
        end case;
    end process;
end Behavioral;
