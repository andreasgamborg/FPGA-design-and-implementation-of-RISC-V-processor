library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity Pipe3_top is
    Port (  
        basys3_clk : IN STD_LOGIC;
        basys3_switch : IN STD_LOGIC_VECTOR(15 downto 0);
        basys3_btn : IN STD_LOGIC_VECTOR(4 downto 0);
        basys3_pbtn : IN STD_LOGIC_VECTOR(3 downto 0);
        PS2Clk, PS2Data : IN STD_LOGIC;
        RsRx : IN STD_LOGIC;
        
        RsTx : OUT STD_LOGIC;
        basys3_led : OUT STD_LOGIC_VECTOR(15 downto 0);
        basys3_seg7 : OUT STD_LOGIC_VECTOR(7 downto 0);
        basys3_an : OUT STD_LOGIC_VECTOR(3 downto 0);
        VGA_HS_OUT : OUT STD_LOGIC;
        VGA_VS_OUT : OUT STD_LOGIC;
        VGA_RED_OUT : OUT STD_LOGIC_VECTOR (3 downto 0);
        VGA_BLUE_OUT : OUT STD_LOGIC_VECTOR (3 downto 0);
        VGA_GREEN_OUT : OUT STD_LOGIC_VECTOR (3 downto 0)
    );
end Pipe3_top;

architecture Behavioral of Pipe3_top is
    signal reset, clk : STD_LOGIC;
    
    component Clock_gen is
      port (
        clk20 :     out STD_LOGIC;
        clk10 :     out STD_LOGIC;
        clk5 :      out STD_LOGIC;
        clk_pixel : out STD_LOGIC;
        clksys :    in STD_LOGIC
      );
    end component;
    
    component Processor is
        Port(  
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            --Imem interface
            Imem_addr_out: OUT STD_LOGIC_VECTOR(31 downto 0);
            Imem_data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
            Imem_r_w_out: OUT STD_LOGIC;
            Imem_data_in: IN STD_LOGIC_VECTOR(31 downto 0);
            Imem_valid_out: OUT STD_LOGIC;
            Imem_ready_in: IN STD_LOGIC;
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
    
        signal Dmem_addr:       STD_LOGIC_VECTOR(31 downto 0);
        signal Dmem_data_in:    STD_LOGIC_VECTOR(31 downto 0);
        signal Dmem_r_w:        STD_LOGIC;                       --0:read 1:write
        signal Dmem_data_out:   STD_LOGIC_VECTOR(31 downto 0);
        signal Dmem_valid:      STD_LOGIC;
        signal Dmem_ready:      STD_LOGIC;
            
        signal Imem_addr:       STD_LOGIC_VECTOR(31 downto 0);
        signal Imem_data_in:    STD_LOGIC_VECTOR(31 downto 0);
        signal Imem_r_w:        STD_LOGIC;
        signal Imem_data_out:   STD_LOGIC_VECTOR(31 downto 0);
        signal Imem_valid:      STD_LOGIC;
        signal Imem_ready:      STD_LOGIC;
    
    component Memory_driver is
        Port(
            --Dmem
            Dmem_addr_in: IN STD_LOGIC_VECTOR(31 downto 0);
            Dmem_data_in: IN STD_LOGIC_VECTOR(31 downto 0);
            Dmem_r_w_in: IN STD_LOGIC;                       --0:read 1:write
            Dmem_data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
            Dmem_valid_in: IN STD_LOGIC;
            Dmem_ready_out: OUT STD_LOGIC;
            --Imem
            Imem_addr_in:   IN STD_LOGIC_VECTOR(31 downto 0);
            Imem_data_in:   IN STD_LOGIC_VECTOR(31 downto 0);
            Imem_r_w_in:    IN STD_LOGIC;
            Imem_data_out:  OUT STD_LOGIC_VECTOR(31 downto 0);
            Imem_valid_in:  IN STD_LOGIC;
            Imem_ready_out: OUT STD_LOGIC;
            -- MMIO
            mem_addr_in: OUT STD_LOGIC_VECTOR(31 downto 0);
            mem_data_in: OUT STD_LOGIC_VECTOR(31 downto 0);
            mem_r_w_in: OUT STD_LOGIC;                       --0:read 1:write
            mem_data_out: IN STD_LOGIC_VECTOR(31 downto 0);
            mem_valid_in: OUT STD_LOGIC;
            mem_ready_out: IN STD_LOGIC
        );
    end component;
    
       signal mem_addr_in:      STD_LOGIC_VECTOR(31 downto 0);
       signal mem_data_in:      STD_LOGIC_VECTOR(31 downto 0);
       signal mem_r_w_in:       STD_LOGIC;                       --0:read 1:write
       signal mem_data_out:     STD_LOGIC_VECTOR(31 downto 0);
       signal mem_valid_in:     STD_LOGIC;
       signal mem_ready_out:    STD_LOGIC;
       
    component Memory is
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
            led_out:        OUT STD_LOGIC_VECTOR(31 downto 0);
            vga_out:        OUT interface_VGA;
            uart_in :       IN STD_LOGIC_VECTOR(31 downto 0);
            uart_out :      OUT STD_LOGIC_VECTOR(31 downto 0);
            btn_in :        IN STD_LOGIC_VECTOR(31 downto 0);
            keyboard_in :   IN STD_LOGIC_VECTOR(31 downto 0);
            seg7_out :      OUT STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
          signal  led_out:      STD_LOGIC_VECTOR(31 downto 0);
          signal  vga_out:      interface_VGA;
          signal  uart_in :     STD_LOGIC_VECTOR(31 downto 0);
          signal  uart_out :    STD_LOGIC_VECTOR(31 downto 0);
          signal  btn_in :      STD_LOGIC_VECTOR(31 downto 0);
          signal  keyboard_in : STD_LOGIC_VECTOR(31 downto 0);
          signal  seg7_out :    STD_LOGIC_VECTOR(31 downto 0);
          
    component UART_driver is
        generic(
            clk_freq :      integer := 5e6; -- Hz
            baud :          integer := 9600; -- bits per sec
            packet_length : integer := 10   -- bits
        );
        Port (  
            clk : IN STD_LOGIC;
            reset :IN STD_LOGIC;
            RsRx : IN STD_LOGIC;
            RsTx : OUT STD_LOGIC;
            payload_in : IN std_logic_vector(31 downto 0);
            payload_out : OUT std_logic_vector(31 downto 0)
        );
    end component;
    
    
    component VGA_driver is
        Port ( 
            clk_pixel : in STD_LOGIC;
            reset : in STD_LOGIC;
            VGA_IN :         IN interface_VGA;
            VGA_HS_OUT : out STD_LOGIC;
            VGA_VS_OUT : out STD_LOGIC;
            VGA_RED_OUT : out STD_LOGIC_VECTOR (3 downto 0);
            VGA_BLUE_OUT : out STD_LOGIC_VECTOR (3 downto 0);
            VGA_GREEN_OUT : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;
    signal clk_pixel : STD_LOGIC;

    
    component Keyboard_driver is
    Port (  
        clk, reset :        IN STD_LOGIC;
        PS2Clk, PS2Data :   IN STD_LOGIC;
        keyboard_out :      OUT std_logic_vector(31 downto 0)
    );
    end component;
    
    component LED_driver is
    Port (  
        led_in : IN STD_LOGIC_VECTOR(31 downto 0);
        led_out : OUT STD_LOGIC_VECTOR(15 downto 0)
    );
    end component;
    
    component Btn_driver is
    Port (
        clk :       IN STD_LOGIC;
        switch_in : IN STD_LOGIC_VECTOR(15 downto 0);
        btn_in :    IN STD_LOGIC_VECTOR(4 downto 0);
        pbtn_in :   IN STD_LOGIC_VECTOR(3 downto 0);
        btn_out :   OUT STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;
    
    component Seg7_driver is
    Port(   
        clk :       IN STD_LOGIC;
        seg7_in:    IN STD_LOGIC_VECTOR(31 downto 0);
        seg7_out:   OUT STD_LOGIC_VECTOR(7 downto 0);
        an_out :    OUT STD_LOGIC_VECTOR(3 downto 0)
    );
    end component;
          
begin
    reset <= basys3_btn(0);
    Clock : clock_gen 
    port map(
        clksys => basys3_clk,
        clk5   => clk,
        clk_pixel => clk_pixel
    );
    CPU : Processor 
    port map(
    --  PORT            => SIGNAL
        clk             => clk,           
        reset           => reset, 
    --Imem        
        Imem_addr_out   => Imem_addr,
        Imem_data_out   => Imem_data_in, 
        Imem_r_w_out    => Imem_r_w,
        Imem_data_in    => Imem_data_out,
        Imem_valid_out  => Imem_valid,
        Imem_ready_in   => Imem_ready,
    --Dmem        
        Dmem_addr_out   => Dmem_addr,
        Dmem_data_out   => Dmem_data_in,
        Dmem_r_w_out    => Dmem_r_w,
        Dmem_data_in    => Dmem_data_out,
        Dmem_valid_out  => Dmem_valid,
        Dmem_ready_in   => Dmem_ready
    );    
    
    Mem_d : Memory_driver
    port map(
    --  PORT            => SIGNAL
    --Dmem        
        Dmem_addr_in    =>  Dmem_addr,   
        Dmem_data_in    =>  Dmem_data_in,  
        Dmem_r_w_in     =>  Dmem_r_w,   
        Dmem_data_out   =>  Dmem_data_out, 
        Dmem_valid_in   =>  Dmem_valid, 
        Dmem_ready_out  =>  Dmem_ready,
    --Imem        
        Imem_addr_in    =>  Imem_addr,  
        Imem_data_in    =>  Imem_data_in,
        Imem_r_w_in     =>  Imem_r_w, 
        Imem_data_out   =>  Imem_data_out,
        Imem_valid_in   =>  Imem_valid, 
        Imem_ready_out  =>  Imem_ready,
    -- mem
        mem_addr_in     =>  mem_addr_in,
        mem_data_in     =>  mem_data_in, 
        mem_r_w_in      =>  mem_r_w_in,
        mem_data_out    =>  mem_data_out, 
        mem_valid_in    =>  mem_valid_in,
        mem_ready_out   =>  mem_ready_out
    );
    Mem : Memory
    port map(
    --  PORT            => SIGNAL
        --CPU
        clk             => clk,           
        reset           => reset, 
        addr_in         => mem_addr_in,
        data_in         => mem_data_in, 
        r_w_in          => mem_r_w_in,
        data_out        => mem_data_out, 
        valid_in        => mem_valid_in,
        ready_out       => mem_ready_out,
        --I/O
        led_out         => led_out,
        vga_out         => vga_out,
        uart_in         => uart_in,
        uart_out        => uart_out,
        btn_in          => btn_in,
        keyboard_in     => keyboard_in,
        seg7_out        => seg7_out
    ); 
    
    UART : UART_driver
    port map(
    --  PORT            => SIGNAL
        clk             => clk,           
        reset           => reset, 
        RsRX            => RsRX,
        RsTX            => RsTX,
        payload_in      => uart_out,
        payload_out     => uart_in
    ); 
    VGA : VGA_driver
    port map(
    --  PORT            => SIGNAL
        clk_pixel       => clk_pixel,           
        reset           => reset, 
        VGA_IN          => vga_out,
        VGA_HS_OUT      => VGA_HS_OUT,
        VGA_VS_OUT      => VGA_VS_OUT,  
        VGA_RED_OUT     => VGA_RED_OUT,  
        VGA_BLUE_OUT    => VGA_BLUE_OUT, 
        VGA_GREEN_OUT   => VGA_GREEN_OUT
    ); 
    Keyboard : Keyboard_driver
    port map(
    --  PORT            => SIGNAL
        clk             => clk,           
        reset           => reset, 
        PS2Clk          => PS2Clk,
        PS2Data         => PS2Data,
        keyboard_out    => keyboard_in
    ); 
    LED : LED_driver
    port map(
    --  PORT            => SIGNAL
        led_in          => led_out,           
        led_out         => basys3_led 
    ); 
    BTN : BTN_driver
    port map(
    --  PORT            => SIGNAL
        clk             => clk,           
        switch_in       => basys3_switch, 
        btn_in          => basys3_btn, 
        pbtn_in         => basys3_pbtn, 
        btn_out         => btn_in
    ); 
    SEG7 : SEG7_driver
    port map(
    --  PORT            => SIGNAL
        clk             => clk,           
        seg7_in         => seg7_out, 
        seg7_out        => basys3_seg7, 
        an_out          => basys3_an
    ); 

end Behavioral;
