library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity Processor_bench is
end Processor_bench;

architecture Behavioral of Processor_bench is
    
    component Processor is
        generic(
            XLEN : integer := 32
        );
        Port(  
            clk :           IN STD_LOGIC;
            reset :         IN STD_LOGIC;
            Imem_addr_out:  OUT STD_LOGIC_VECTOR(31 downto 0);
            Imem_data_in:   IN STD_LOGIC_VECTOR(31 downto 0);
            Imem_valid_out: OUT STD_LOGIC;
            Imem_ready_in:  IN STD_LOGIC;
            Dmem_addr_out:  OUT STD_LOGIC_VECTOR(31 downto 0);
            Dmem_data_out:  OUT STD_LOGIC_VECTOR(31 downto 0);
            Dmem_r_w_out:   OUT STD_LOGIC;
            Dmem_data_in:   IN STD_LOGIC_VECTOR(31 downto 0);
            Dmem_valid_out: OUT STD_LOGIC;
            Dmem_ready_in:  IN STD_LOGIC;
            flg_error :     OUT STD_LOGIC
        );
    end component;
    
    
    signal   clk :            STD_LOGIC                        := '0';
    signal   reset :          STD_LOGIC                        := '1';
    
    signal   Imem_addr_out:   STD_LOGIC_VECTOR(31 downto 0);
    signal   Imem_data_in:    STD_LOGIC_VECTOR(31 downto 0);
    signal   Imem_valid_out:  STD_LOGIC;
    signal   Imem_ready_in:   STD_LOGIC;
    
    signal   Dmem_addr_out:   STD_LOGIC_VECTOR(31 downto 0);
    signal   Dmem_data_out:   STD_LOGIC_VECTOR(31 downto 0);
    signal   Dmem_r_w_out:    STD_LOGIC;
    signal   Dmem_data_in:    STD_LOGIC_VECTOR(31 downto 0);
    signal   Dmem_valid_out:  STD_LOGIC;
    signal   Dmem_ready_in:   STD_LOGIC;

begin
    CPU : Processor
        port map(
        --  PORT            => SIGNAL
            --CPU
            clk             => clk,           
            reset           => reset, 
            Imem_addr_out   => Imem_addr_out,
            Imem_data_in    => Imem_data_in, 
            Imem_valid_out  => Imem_valid_out,
            Imem_ready_in   => Imem_ready_in,
             
            Dmem_addr_out   => Dmem_addr_out,
            Dmem_data_out   => Dmem_data_out,
            Dmem_r_w_out    => Dmem_r_w_out,
            Dmem_data_in    => Dmem_data_in,
            Dmem_valid_out  => Dmem_valid_out,
            Dmem_ready_in   => Dmem_ready_in
        ); 
        
    clk <= not clk after 50 ns;
    
    process is
    begin
        wait for 200ns;
        reset <= '0';
        Imem_ready_in <= '1';
        Imem_data_in <= x"00000013";
        Dmem_data_in <= x"aaaaaaaa";
        Dmem_ready_in <= '1';
    end process;
    
end Behavioral;
