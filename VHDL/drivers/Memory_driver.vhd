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
        -- CPU
        addr_in: IN STD_LOGIC_VECTOR(31 downto 0);
        data_in: IN STD_LOGIC_VECTOR(31 downto 0);
        r_w_in: IN STD_LOGIC;                       --0:read 1:write
        valid_in: IN STD_LOGIC;
        data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        ready_out: OUT STD_LOGIC;
        -- Dmem
        dmem_addr_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        dmem_data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        dmem_r_w_out: OUT STD_LOGIC;                       --0:read 1:write
        dmem_valid_out: OUT STD_LOGIC;
        dmem_data_in: IN STD_LOGIC_VECTOR(31 downto 0);
        dmem_ready_in: IN STD_LOGIC;
        
        led_addr_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        led_data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        led_r_w_out: OUT STD_LOGIC;                       --0:read 1:write
        led_valid_out: OUT STD_LOGIC;
        led_data_in: IN STD_LOGIC_VECTOR(31 downto 0);
        led_ready_in: IN STD_LOGIC
    );
end Memory_driver;

architecture Behavioral of Memory_driver is

begin

    process(all)
    begin
        
    end process;

end Behavioral;
