library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Single_cycle_top is
    Port (  
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC
    );
end Single_cycle_top;

architecture Behavioral of Single_cycle_top is
    component Processor is
        Port(  
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            --Imem interface
            Imem_addr_out: OUT STD_LOGIC_VECTOR(31 downto 0);
            --Imem_data_out: IN STD_LOGIC_VECTOR(31 downto 0);
            --Imem_r_w_out: OUT STD_LOGIC;
            Imem_data_in: IN STD_LOGIC_VECTOR(31 downto 0);
            --Imem_valid_out: OUT STD_LOGIC;
            --Imem_ready_in: IN STD_LOGIC;
            --Dmem interface
            Dmem_addr_out: OUT STD_LOGIC_VECTOR(31 downto 0);
            Dmem_data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
            Dmem_r_w_out: OUT STD_LOGIC;
            Dmem_data_in: IN STD_LOGIC_VECTOR(31 downto 0);
            Dmem_valid_out: OUT STD_LOGIC;
            Dmem_ready_in: IN STD_LOGIC;
            --flags
            flg_error : OUT STD_LOGIC
        );
    end component;
    
    component ROM is
        Port (  addr : IN STD_LOGIC_VECTOR(31 downto 0);
                inst : OUT STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    signal Imem_addr : STD_LOGIC_VECTOR(31 downto 0);
    signal CPU_inst : STD_LOGIC_VECTOR(31 downto 0);
    
    component RAM is
    Port(
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        addr_in: IN STD_LOGIC_VECTOR(31 downto 0);
        data_in: IN STD_LOGIC_VECTOR(31 downto 0);
        r_w_in: IN STD_LOGIC;                       --0:read 1:write
        data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        valid_in: IN STD_LOGIC;
        ready_out: OUT STD_LOGIC;
        led_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        --vga_out: OUT interface_VGA;
        uart_in : IN STD_LOGIC_VECTOR(31 downto 0);
        uart_out : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;
    
    signal Dmem_addr:  STD_LOGIC_VECTOR(31 downto 0);
    signal Dmem_data:  STD_LOGIC_VECTOR(31 downto 0);
    signal Dmem_r_w:  STD_LOGIC;                       --0:read 1:write
    signal CPU_data:  STD_LOGIC_VECTOR(31 downto 0);
    signal Dmem_valid:  STD_LOGIC;
    signal CPU_ready:  STD_LOGIC;
    signal Dmem_UART:  STD_LOGIC_VECTOR(31 downto 0);

    
begin

    CPU : Processor 
    port map(
        clk => clk,           
        reset => reset, 
        Imem_addr_out => Imem_addr,
        Imem_data_in => CPU_inst,
        Dmem_addr_out => Dmem_addr,
        Dmem_data_out => Dmem_data,
        Dmem_r_w_out => Dmem_r_w,
        Dmem_data_in => CPU_data,
        Dmem_valid_out => Dmem_valid,
        Dmem_ready_in => CPU_ready
    ); 
    Imem : ROM 
    port map(
        addr => Imem_addr,
        inst => CPU_inst
    ); 
    Dmem : RAM 
    port map(
        clk => clk,           
        reset => reset, 
        addr_in => Dmem_addr,
        data_in => Dmem_data,
        r_w_in => Dmem_r_w,        
        data_out => CPU_data,
        valid_in => Dmem_valid,
        ready_out => CPU_ready,
        uart_in => Dmem_UART
    ); 

end Behavioral;
