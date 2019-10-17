----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.10.2019 13:29:20
-- Design Name: 
-- Module Name: Memory_driver - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

library work;
use work.cpu_constants.all;

entity Memory_driver is
    Port(
        --Dmem
        Dmem_addr_in: IN STD_LOGIC_VECTOR(31 downto 0);
        Dmem_data_in: IN STD_LOGIC_VECTOR(31 downto 0);
        Dmem_r_w_in: IN STD_LOGIC;                       --0:read 1:write
        Dmem_data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        Dmem_valid_in: IN STD_LOGIC;
        Dmem_ready_out: OUT STD_LOGIC;
        --Imem
        Imem_addr_in: IN STD_LOGIC_VECTOR(31 downto 0);
        Imem_data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        Imem_valid_in: IN STD_LOGIC;
        Imem_ready_out: OUT STD_LOGIC;
        -- MMIO
        mem_addr_in: OUT STD_LOGIC_VECTOR(31 downto 0);
        mem_data_in: OUT STD_LOGIC_VECTOR(31 downto 0);
        mem_r_w_in: OUT STD_LOGIC;                       --0:read 1:write
        mem_data_out: IN STD_LOGIC_VECTOR(31 downto 0);
        mem_valid_in: OUT STD_LOGIC;
        mem_ready_out: IN STD_LOGIC
    );
end Memory_driver;

architecture Behavioral of Memory_driver is

begin
    
    process(all)
    begin
        mem_addr_in <= (others => '0');
        mem_data_in <= (others => '0');
        mem_r_w_in <= '0';
        
        Imem_ready_out <= mem_ready_out;
        Imem_data_out <= mem_data_out;

        Dmem_ready_out <= mem_ready_out;
        Dmem_data_out <= mem_data_out;

        if Dmem_valid_in = '1' then
            mem_addr_in <= Dmem_addr_in;
            mem_data_in <= Dmem_data_in;
            mem_r_w_in <=  Dmem_r_w_in;
            mem_valid_in <= '1';
            Imem_ready_out <= '0';
        elsif Dmem_valid_in = '1' then
            mem_addr_in <= Imem_addr_in;
            mem_valid_in <= '1';
        else
            mem_valid_in <= '0';
        end if;
    end process;

end Behavioral;
