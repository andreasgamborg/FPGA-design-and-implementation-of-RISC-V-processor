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
    constant memory_ROM :       std_logic_vector(31 downto 0) := x"00000010";
    constant memory_keybord :   std_logic_vector(31 downto 0) := x"00000080";
    
    constant memory_UART_out :      std_logic_vector(31 downto 0) := x"00000084";
    constant memory_UART_in :       std_logic_vector(31 downto 0) := x"00000088";
    constant memory_video_low :     std_logic_vector(31 downto 0) := x"0000008c";
    constant memory_video_high :    std_logic_vector(31 downto 0) := x"00000180";
    constant memory_LED :           std_logic_vector(31 downto 0) := x"00000184";
    
    --Interfaces
    
    type interface_VGA is array (0 to 239) of STD_LOGIC_VECTOR (31 downto 0); --240 registers needed 8 x 5char x 30lines
    type interface_UART is array (0 to 2) of STD_LOGIC_VECTOR (31 downto 0);

end package cpu_constants;
