library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package cpu_constants is
    
    --Opcodes
    constant opcode_load :      std_logic_vector(6 downto 0) := "0000011";
    constant opcode_imm :       std_logic_vector(6 downto 0) := "0010011";
    constant opcode_store :     std_logic_vector(6 downto 0) := "0100011";
    constant opcode_r :         std_logic_vector(6 downto 0) := "0110011";
    constant opcode_branch :    std_logic_vector(6 downto 0) := "1100011";
    constant opcode_sys :       std_logic_vector(6 downto 0) := "1110011";
    
    constant opcode_auipc :     std_logic_vector(6 downto 0) := "0010111";
    constant opcode_lui :       std_logic_vector(6 downto 0) := "0110111";
    constant opcode_jalr :      std_logic_vector(6 downto 0) := "1100111";

    constant opcode_fence :     std_logic_vector(6 downto 0) := "0001111";
    constant opcode_jal :       std_logic_vector(6 downto 0) := "1101111";
    
    --PC
    constant PC_base :          std_logic_vector(31 downto 0) := x"00000000";
    
    --Memory
    -- Sizes are in registers of 32-bit
    constant memory_size :          integer := 2**10;
    
    constant memory_ROM_addr :      integer := 0;
    constant memory_ROM_size :      integer := 256;
    constant memory_BTN_addr :      integer := memory_ROM_addr + memory_ROM_size;
    constant memory_BTN_size :      integer := 1;
    constant memory_Keyboard_addr : integer := memory_BTN_addr + memory_BTN_size;
    constant memory_Keyboard_size : integer := 1;
    constant memory_UART_addr :     integer := memory_Keyboard_addr + memory_Keyboard_size;
    constant memory_UART_size :     integer := 2;
    constant memory_video_addr :    integer := memory_UART_addr + memory_UART_size;
    constant memory_video_size :    integer := 301;
    constant memory_LED_addr :      integer := memory_video_addr + memory_video_size;
    constant memory_LED_size :      integer := 1;
    constant memory_SEG7_addr :     integer := memory_LED_addr + memory_LED_size;
    constant memory_SEG7_size :     integer := 1;
    constant memory_data_addr :     integer := memory_SEG7_addr + memory_SEG7_size;
    constant memory_data_size :     integer := memory_size-memory_data_addr;
    
    -- Every rgister below UART out is READ ONLY
    constant memory_read_only :     integer := memory_UART_addr;

    
--    constant memory_Keyboard_addr :      std_logic_vector(31 downto 0) := x"00000184";
--    constant memory_UARTo_addr :      std_logic_vector(31 downto 0) := x"00000084";
--    constant memory_UARTi_addr :       std_logic_vector(31 downto 0) := x"00000088";
--    constant memory_video_addr :         std_logic_vector(31 downto 0) := x"0000008c";
--    constant memory_LED_addr :           std_logic_vector(31 downto 0) := x"00000184";
--    constant memory_SEG7_addr :          std_logic_vector(31 downto 0) := x"00000184";

    --Interfaces
    
    type interface_VGA is array (0 to memory_video_size-1) of STD_LOGIC_VECTOR (31 downto 0); --301 registers needed 10 x 4char x 30lines

end package cpu_constants;
