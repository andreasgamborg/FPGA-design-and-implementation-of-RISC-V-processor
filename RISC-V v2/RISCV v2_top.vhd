library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity RISCV_top is
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
end RISCV_top;

architecture Behavioral of RISCV_top is
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
            clk :           IN STD_LOGIC;
            reset :         IN STD_LOGIC;
            --Imem interface
            Imem_addr_in:   OUT STD_LOGIC_VECTOR(31 downto 0);
            Imem_data_out:  IN STD_LOGIC_VECTOR(31 downto 0);
            --Dmem interface
            Dmem_addr_in:   OUT STD_LOGIC_VECTOR(31 downto 0);
            Dmem_data_in:   OUT STD_LOGIC_VECTOR(31 downto 0);
            Dmem_r_w_in:    OUT STD_LOGIC;
            Dmem_whb_in:    OUT STD_LOGIC_VECTOR(1 downto 0);
            Dmem_data_out:  IN STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
        
        signal Imem_addr_in:    STD_LOGIC_VECTOR(31 downto 0);
        signal Imem_data_out:   STD_LOGIC_VECTOR(31 downto 0);  
        
        signal Dmem_addr_in:    STD_LOGIC_VECTOR(31 downto 0);
        signal Dmem_data_in:    STD_LOGIC_VECTOR(31 downto 0);
        signal Dmem_r_w_in:     STD_LOGIC;                       --0:read 1:write
        signal Dmem_data_out:   STD_LOGIC_VECTOR(31 downto 0);
        signal Dmem_whb_in:     STD_LOGIC_VECTOR(1 downto 0);
    
    component Memory is
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
    end component;
    
        signal  led_out:      STD_LOGIC_VECTOR(31 downto 0);
        signal  vga_addr_in:  STD_LOGIC_VECTOR(31 downto 0);
        signal  vga_char_out: STD_LOGIC_VECTOR(7 downto 0);
        signal  vga_color_out:STD_LOGIC_VECTOR(31 downto 0);
        signal  uart_in :     STD_LOGIC_VECTOR(31 downto 0);
        signal  uart_out :    STD_LOGIC_VECTOR(31 downto 0);
        signal  btn_in :      STD_LOGIC_VECTOR(31 downto 0);
        signal  keyboard_in : STD_LOGIC_VECTOR(31 downto 0);
        signal  seg7_out :    STD_LOGIC_VECTOR(31 downto 0);
          
    component UART_driver is
        generic(
            clk_freq :      integer := 20e6; -- Hz
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
            clk_pixel :      in STD_LOGIC;
            ADDR_OUT :       out STD_LOGIC_VECTOR(31 downto 0);
            CHAR_IN :        in STD_LOGIC_VECTOR(7 downto 0);
            COLOR_IN :       in  STD_LOGIC_VECTOR(31 downto 0);
            VGA_HS_OUT :     out STD_LOGIC;
            VGA_VS_OUT :     out STD_LOGIC;
            VGA_RED_OUT :    out STD_LOGIC_VECTOR (3 downto 0);
            VGA_BLUE_OUT :   out STD_LOGIC_VECTOR (3 downto 0);
            VGA_GREEN_OUT :  out STD_LOGIC_VECTOR (3 downto 0)
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
     Generic(
        clk_freq :      integer := 20e6 -- Hz
    );
    Port (  
        clk :       IN STD_LOGIC;
        led_in : IN STD_LOGIC_VECTOR(31 downto 0);
        led_out : OUT STD_LOGIC_VECTOR(15 downto 0)
    );
    end component;
    
    component Btn_driver is
    Generic(
        clk_freq :          integer := 20e6;     -- Hz
        debounce_period :   integer := 10       -- ms
    );
    Port (
        clk :       IN STD_LOGIC;
        switch_in : IN STD_LOGIC_VECTOR(15 downto 0);
        btn_in :    IN STD_LOGIC_VECTOR(3 downto 0);
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
        clk20   => clk,
        clk_pixel => clk_pixel
    );
    
    CPU : Processor 
    port map(
    --  PORT            => SIGNAL
        clk             => clk,           
        reset           => reset, 
    --Imem        
        Imem_addr_in    => Imem_addr_in,
        Imem_data_out   => Imem_data_out, 
    --Dmem        
        Dmem_addr_in    => Dmem_addr_in,
        Dmem_data_in    => Dmem_data_in,
        Dmem_r_w_in     => Dmem_r_w_in,
        Dmem_whb_in     => Dmem_whb_in,
        Dmem_data_out   => Dmem_data_out
    );    
    
    Mem : Memory
    port map(
    --  PORT            => SIGNAL
        --CPU
        clk             => clk,       
        addrI_in        => Imem_addr_in,
        dataI_out       => Imem_data_out, 
        addrD_in        => Dmem_addr_in,
        dataD_in        => Dmem_data_in,
        r_w_in          => Dmem_r_w_in,
        whb_in          => Dmem_whb_in,
        dataD_out       => Dmem_data_out,
        --I/O
        led_out         => led_out,
        vga_addr_in     => vga_addr_in,
        vga_char_out    => vga_char_out,
        vga_color_out    => vga_color_out,
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
        addr_out        => vga_addr_in,
        char_in         => vga_char_out,
        color_in        => vga_color_out,
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
        clk             => clk,           
        led_in          => led_out,           
        led_out         => basys3_led 
    ); 
    BTN : BTN_driver
    port map(
    --  PORT            => SIGNAL
        clk             => clk,           
        switch_in       => basys3_switch, 
        btn_in          => basys3_btn(4 downto 1), 
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
