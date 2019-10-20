library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity Processor is
    generic(
        XLEN : integer := 32
    );
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
end Processor;

architecture Behavioral of Processor is

-- CPU State
    signal PC_I, PC_E : STD_LOGIC_VECTOR(XLEN-1 downto 0);
    signal PC4_I, PC4_E, PC4_D : STD_LOGIC_VECTOR(XLEN-1 downto 0);
    signal PC_next, PC_branch : STD_LOGIC_VECTOR(XLEN-1 downto 0);

    type registerFile is array(0 to 31) of STD_LOGIC_VECTOR(XLEN-1 downto 0);
    signal registers : registerFile;
-- Instrucion
    signal inst_I, inst_E : STD_LOGIC_VECTOR(31 downto 0);
    signal opcode, func7 : STD_LOGIC_VECTOR(6 downto 0);
    signal rd_E, rd_D, rs1, rs2 : STD_LOGIC_VECTOR(4 downto 0);
    signal func3 : STD_LOGIC_VECTOR(2 downto 0);
-- Control
    --ALU
    signal ctrl_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal ctrl_alu_src_a_sel, ctrl_alu_src_b_sel : STD_LOGIC;
    --Register
    signal ctrl_rd_w_en_E, ctrl_rd_w_en_D : STD_LOGIC;
    signal ctrl_rd_data_sel_E, ctrl_rd_data_sel_D : STD_LOGIC_VECTOR(1 downto 0);
    --Branch/Jump
    signal ctrl_branch, ctrl_jump, ctrl_sys : STD_LOGIC;
    signal ctrl_pc_next_sel : STD_LOGIC_VECTOR(1 downto 0);
    --Data memory
    signal ctrl_mem_w_D, ctrl_mem_w_E: STD_LOGIC;
    signal ctrl_mem_r_D, ctrl_mem_r_E: STD_LOGIC;
-- Data lines
    signal rs1_data, rs2_data_D, rs2_data_E, rd_data, mem_data: STD_LOGIC_VECTOR(XLEN-1 downto 0);
    signal imm_E, imm_D : STD_LOGIC_VECTOR(XLEN-1 downto 0);
-- Misc
    --ALU
    signal alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_result_E, alu_result_D : STD_LOGIC_VECTOR(XLEN-1 downto 0);
    signal alu_src_a,alu_src_b : STD_LOGIC_VECTOR(XLEN-1 downto 0);
    --branch/jump
    signal pc_branch_sel : STD_LOGIC;
    
-- Flags
    signal flg_error_branch : STD_LOGIC;
    signal flg_error_alu : STD_LOGIC;
    signal flg_error_ctrl : STD_LOGIC;
    signal flg_error_imm : STD_LOGIC;
    signal flg_alu_zero : STD_LOGIC;
    signal flg_stall : STD_LOGIC;


  begin
    flg_error <= flg_error_alu or flg_error_ctrl or flg_error_imm or flg_error_branch;
    PC4_I <= std_logic_vector(unsigned(PC_I) + 4);
    flg_stall <= not Imem_ready_in;
    
    process(all)     -- Instruction fetch or STALL
    begin
        Imem_addr_out <= PC_I;
        Imem_valid_out <= '1';
        --Imem_data_out <= 
        Imem_r_w_out <= '0';
        if flg_stall = '1' then
            inst_I <= x"00000013";
        else
            inst_I <= Imem_data_in;
        end if;
    end process;
    
    
    process(clk, reset)     -- PC and registerfile
    begin
        if reset = '1' then
            PC_I <= pc_base;
            registers(2) <= x"000003ff";
        elsif rising_edge(clk) then
            PC_I <= PC_next;
            if ctrl_rd_w_en_D = '1' then
                registers(to_integer(unsigned(rd_D))) <= rd_data;
            end if;
        end if;
        registers(0) <= (others => '0');
    end process;
    
    process(clk, reset)     -- Pipe registers
    begin
        if reset = '1' then
        --Control
            ctrl_rd_data_sel_D <= "00";
            ctrl_rd_w_en_D <= '0';
            ctrl_mem_w_D <= '0';
            ctrl_mem_r_D <= '0';
        --Data
            PC4_D <= (others => '0');
            alu_result_D <= (others => '0');
            rs2_data_D <= (others => '0');
            imm_D <= (others => '0');
            rd_D <= (others => '0');
            -- E/I
            PC_E <= (others => '0');
            inst_E <= (others => '0');
            PC4_E <= (others => '0');
        elsif rising_edge(clk) then
        --Control
            -- D/E
            ctrl_rd_data_sel_D <= ctrl_rd_data_sel_E;
            ctrl_rd_w_en_D <= ctrl_rd_w_en_E;
            ctrl_mem_w_D <= ctrl_mem_w_E;
            ctrl_mem_r_D <= ctrl_mem_r_E;
        --Data
            -- D/E
            PC4_D <= PC4_E;
            alu_result_D <= alu_result_E;
            rs2_data_D <= rs2_data_E;
            imm_D <= imm_E;
            rd_D <= rd_E;
            -- E/I
            PC_E <= PC_I;
            inst_E <= inst_I;
            PC4_E <= PC4_I;
        end if;
    end process;
    
    process(all) -- PC next multiplexer
    begin
        if flg_stall = '1' then
            PC_next <= PC_I;
        else
            case ctrl_pc_next_sel is
                when "00" =>
                    PC_next <= PC4_I;
                when "01" =>
                    PC_next <= PC_branch;
                when "10" =>
                    PC_next <= alu_result_E;  
                when "11" =>
                    PC_next <= PC_base;
                when others =>
                    PC_next <= PC_base;
            end case;
        end if;
    end process;
    
    process(all)    -- Cutting up instruction
    begin
        opcode <= inst_E(6 downto 0);
        func7 <= inst_E(31 downto 25);
        rd_E <=  inst_E(11 downto 7);
        rs1 <= inst_E(19 downto 15);
        rs2 <= inst_E(24 downto 20);
        func3 <= inst_E(14 downto 12);
    end process;
    
    process(all)        --Branch control
    begin
        flg_error_branch <= '0';
        pc_branch_sel <= '0';
        if ctrl_branch = '1' then
            case func3 is
                when "000" => -- beq
                    pc_branch_sel <= flg_alu_zero;
                when "001" => --bne
                    pc_branch_sel <= not flg_alu_zero;
                when "100" => --blt
                    pc_branch_sel <= alu_result_E(XLEN-1);  
                when "101" => --bge
                    pc_branch_sel <= not alu_result_E(XLEN-1);
                when "110" => --bltu
                    pc_branch_sel <= (alu_src_a(XLEN-1) xor alu_src_b(XLEN-1)) xor alu_result_E(XLEN-1);
                when "111" => --bgeu
                    pc_branch_sel <= not((alu_src_a(XLEN-1) xor alu_src_b(XLEN-1)) xor alu_result_E(XLEN-1));      
                when others =>
                    flg_error_branch <= '1';
            end case;
        end if;
        if pc_branch_sel = '1' then
            PC_branch <= std_logic_vector(signed(PC_E) + signed(imm_E));
        else
            PC_branch <= PC4_E;
        end if;
    end process;
    
    process(opcode)    -- Control
    begin
    ctrl_alu_src_a_sel <= '0';
    ctrl_alu_src_b_sel <= '0';
    ctrl_alu_op <= "00";

    ctrl_rd_w_en_E <= '0';
    ctrl_rd_data_sel_E <= "00";

    ctrl_mem_w_E <= '0';
    ctrl_mem_r_E <= '0';

    ctrl_branch <= '0';
    ctrl_jump <= '0';
    ctrl_sys <= '0';
    flg_error_ctrl <= '0';
        case opcode is 
            when opcode_load =>         -- Load
                ctrl_alu_src_b_sel <= '1';
                ctrl_rd_w_en_E <= '1';
                ctrl_mem_r_E <= '1';
                ctrl_rd_data_sel_E <= "01";
            when opcode_imm =>          -- I-type
                ctrl_alu_src_b_sel <= '1';
                ctrl_alu_op <= "11";
                ctrl_rd_w_en_E <= '1';
            when opcode_store =>        -- Store
                ctrl_alu_src_b_sel <= '1';
                ctrl_mem_w_E <= '1';
            when opcode_r =>            -- R-type
                ctrl_alu_op <= "10";
                ctrl_rd_w_en_E <= '1';
            when opcode_branch =>       -- Branch
                ctrl_alu_op <= "01";
                ctrl_branch <= '1';       
            when opcode_sys =>          -- ecall
                ctrl_sys <= '1';
            when opcode_auipc =>        -- auipc
                ctrl_alu_src_a_sel <= '1';
                ctrl_alu_src_b_sel <= '1';
                ctrl_rd_w_en_E <= '1';
            when opcode_lui =>          -- lui
                ctrl_rd_w_en_E <= '1';
                ctrl_rd_data_sel_E <= "11";
            when opcode_jalr =>         -- jalr
                ctrl_alu_src_b_sel <= '1';
                ctrl_rd_w_en_E <= '1';
                ctrl_rd_data_sel_E <= "10";
                ctrl_jump <= '1';
            when opcode_fence =>        -- fence
                ctrl_sys <= '1';
            when opcode_jal =>          -- jal
                ctrl_alu_src_a_sel <= '1';
                ctrl_alu_src_b_sel <= '1';
                ctrl_rd_w_en_E <= '1';
                ctrl_rd_data_sel_E <= "10";
                ctrl_jump <= '1';
            when others => 
                flg_error_ctrl <= '1';
        end case;

    end process;
    
    
    process(all) -- PC next multiplexer
    begin
        if ctrl_branch = '1' then
            ctrl_pc_next_sel <= "01";
        elsif ctrl_jump = '1' then
            ctrl_pc_next_sel <= "10";
        elsif ctrl_sys = '1' then
            ctrl_pc_next_sel <= "11";
        else
            ctrl_pc_next_sel <= "00";
        end if;
    end process;
    
    process(all)    -- Read data from register file and memory
    begin
        -- Registers
        rs1_data <= registers(to_integer(unsigned(rs1)));
        rs2_data_E <= registers(to_integer(unsigned(rs2)));
        -- Memory
        mem_data <= Dmem_data_in;
        Dmem_data_out <= rs2_data_D;
        Dmem_addr_out <= alu_result_D;
        
        if ctrl_mem_w_D = '1' then
            Dmem_valid_out <= '1';
            Dmem_r_w_out <= '1';
        elsif ctrl_mem_r_D = '1' then
            Dmem_valid_out <= '1';
            Dmem_r_w_out <= '0';
        else
            Dmem_valid_out <= '0';
            Dmem_r_w_out <= '0';
        end if;
    end process;
    
    
    process(all)    -- RD data multiplexer
    begin
        case ctrl_rd_data_sel_D is
            when "00" =>  
                rd_data <= alu_result_D;
            when "01" =>  
                rd_data <= mem_data;
            when "10" =>  
                rd_data <= PC4_D;
            when "11" =>  
                rd_data <= imm_D;
            when others =>
                rd_data <= (others => '0');
        end case;
    end process;
    
    process(all)    -- ALU logic and control
    begin
        --ALU control
        flg_error_alu <= '0';
        alu_op <= "1111";
        case ctrl_alu_op is
            when "00" =>                -- Load/Store ect., use alu to calculate address
                alu_op <= "0010";
            when "01" =>                -- Branch
                alu_op <= "0110";
            when "10" =>                -- Its an R-instruction
                case func7(5)&func3 is 
                    when "0000" =>  --add
                        alu_op <= "0010";
                    when "1000" =>  --sub
                        alu_op <= "0110";
                    when "0001" =>  --sll
                        alu_op <= "1000";
--                    when "0010" =>  --slt
--                        alu_op <= "";
--                    when "0011" =>  --sltu
--                        alu_op <= "";    
                    when "0100" =>  --xor
                        alu_op <= "0111";    
                    when "0101" =>  --srl
                        alu_op <= "1100";
                    when "1101" =>  --sra
                        alu_op <= "1101";
                    when "0110" =>  --or
                        alu_op <= "0001";          
                    when "0111" =>  --and
                        alu_op <= "0000";                        
                    when others => 
                        flg_error_alu <= '1';
                end case;
            when "11" =>                -- Its an I-instruction
                case func3 is 
                    when "000" => --addi
                        alu_op <= "0010";
                    when "001" => --slli
                        alu_op <= "1000"; 
--                    when "010" => --slti
--                        alu_op <= "";         
--                    when "011" => --sltiu
--                        alu_op <= "";   
                    when "100" => --xori
                        alu_op <= "0111";   
                    when "101" => --sr(l/a)i
                        if func7(5) = '1' then  --srai
                            alu_op <= "1101";   
                        else
                            alu_op <= "1100";       --srli
                        end if;
                    when "110" => --ori
                        alu_op <= "0001";                
                    when "111" => --andi
                        alu_op <= "0000";

                    when others => 
                        flg_error_alu <= '1';
                end case;
            when others => 
                flg_error_alu <= '1';  
        end case;
        
        -- ALU source multiplexers
        if ctrl_alu_src_a_sel = '1' then
            alu_src_a <= PC_E;
        else
            alu_src_a <= rs1_data;
        end if;
        if ctrl_alu_src_b_sel = '1' then
            alu_src_b <= imm_E;
        else
            alu_src_b <= rs2_data_E;
        end if;
        -- ALU
        case alu_op is
            when "0000" => --AND
                alu_result_E <= alu_src_a and alu_src_b;
            when "0001" => --OR
                alu_result_E <= alu_src_a or alu_src_b;
            when "0010" => --add
                alu_result_E <= std_logic_vector(unsigned(alu_src_a) + unsigned(alu_src_b));
            when "0110" => --sub
                alu_result_E <= std_logic_vector(unsigned(alu_src_a) - unsigned(alu_src_b));
            when "0111" => --XOR
                alu_result_E <= alu_src_a xor alu_src_b;
            when "1000" => --shift left (5bit)
                alu_result_E <= std_logic_vector(shift_left(unsigned(alu_src_a), to_integer(unsigned(alu_src_b(4 downto 0)))));
            when "1100" => --shift right (5bit)
                alu_result_E <= std_logic_vector(shift_right(unsigned(alu_src_a), to_integer(unsigned(alu_src_b(4 downto 0)))));
            when "1101" => --shift right arithmetic (5bit)
                alu_result_E <= std_logic_vector(shift_right(signed(alu_src_a), to_integer(unsigned(alu_src_b(4 downto 0))))); 
            when others =>
                alu_result_E <= (others => '0');
                flg_error_alu <= '1';
        end case;
        if alu_result_E = x"00000000" then
            flg_alu_zero <= '1';
        else
            flg_alu_zero <= '0';
        end if;
    end process;
    
    process(all)    -- Immidiate Gen
    begin
        flg_error_imm <= '0';
        case opcode is
            when opcode_load => --Format I
                imm_E <= ((XLEN-1 downto 12 => inst_E(31)) & inst_E(31 downto 20));
            when opcode_imm => --Format I
                imm_E <= ((XLEN-1 downto 12 => inst_E(31)) & inst_E(31 downto 20));
            when opcode_store => --Format S
                imm_E <= ((XLEN-1 downto 12 => inst_E(31)) & inst_E(31 downto 25) & inst_E(11 downto 7));
            when opcode_r => --Format R
                imm_E <= (others => '0');    
            when opcode_branch => --Format SB
                imm_E <= ((XLEN-1 downto 12 => inst_E(31)) & inst_E(7) & inst_E(30 downto 25) & inst_E(11 downto 8) & '0');
            when opcode_sys => --Format I
                imm_E <= ((XLEN-1 downto 12 => inst_E(31)) & inst_E(31 downto 20));     
            when opcode_auipc => --Format U
                imm_E <= (inst_E(31 downto 12) & (11 downto 0 => '0'));
            when opcode_lui => --Format U
                imm_E <= (inst_E(31 downto 12) & (11 downto 0 => '0'));           
            when opcode_jalr => --Format I
                imm_E <= ((XLEN-1 downto 12 => inst_E(31)) & inst_E(31 downto 20)); 
            when opcode_fence => --Format I
                imm_E <= (others => '0');    
            when opcode_jal => --Format UJ
                imm_E <= ((XLEN-1 downto 20 => inst_E(31)) & inst_E(19 downto 12) & inst_E(20) & inst_E(30 downto 21) & '0');
            when others => 
                imm_E <= (others => '0');
                flg_error_imm <= '1';
        end case;
    end process;
end Behavioral;
