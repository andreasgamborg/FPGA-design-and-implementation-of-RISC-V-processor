library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.cpu_constants.all;

entity Processor is
    generic(
        XLEN : integer := 32
    );
    Port(  
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        --Imem interface
        Imem_addr_out: OUT STD_LOGIC_VECTOR(31 downto 0);
        --Imem_data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
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
end Processor;

architecture Behavioral of Processor is

-- CPU State
    signal PC, PC_next, PC4, PC_branch : STD_LOGIC_VECTOR(XLEN-1 downto 0);
    type registerFile is array(0 to 31) of STD_LOGIC_VECTOR(XLEN-1 downto 0);
    signal registers : registerFile;
-- Instrucion
    signal inst : STD_LOGIC_VECTOR(31 downto 0);
    signal opcode, func7 : STD_LOGIC_VECTOR(6 downto 0);
    signal rd, rs1, rs2 : STD_LOGIC_VECTOR(4 downto 0);
    signal func3 : STD_LOGIC_VECTOR(2 downto 0);
-- Control
    --ALU
    signal ctrl_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal ctrl_alu_src_a_sel, ctrl_alu_src_b_sel : STD_LOGIC;
    --Register
    signal ctrl_rd_w_en : STD_LOGIC;
    signal ctrl_rd_data_sel : STD_LOGIC_VECTOR(1 downto 0);
    --Branch/Jump
    signal ctrl_branch, ctrl_jump, ctrl_sys : STD_LOGIC;
    signal ctrl_pc_next_sel : STD_LOGIC_VECTOR(1 downto 0);
    --Data memory
    signal ctrl_mem_w, ctrl_mem_r: STD_LOGIC;
    signal ctrl_mem_to_reg: STD_LOGIC;
-- Data lines
    signal rs1_data, rs2_data, rd_data, mem_data: STD_LOGIC_VECTOR(XLEN-1 downto 0);
    signal imm : STD_LOGIC_VECTOR(XLEN-1 downto 0);
-- Misc
    --ALU
    signal alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_result : STD_LOGIC_VECTOR(XLEN-1 downto 0);
    signal alu_src_a,alu_src_b : STD_LOGIC_VECTOR(XLEN-1 downto 0);
    --branch/jump
    signal pc_branch_sel : STD_LOGIC;
    
-- Flags
    signal flg_error_branch : STD_LOGIC;
    signal flg_error_alu : STD_LOGIC;
    signal flg_error_ctrl : STD_LOGIC;
    signal flg_error_imm : STD_LOGIC;
    signal flg_alu_zero : STD_LOGIC;

  begin
    flg_error <= flg_error_alu or flg_error_ctrl or flg_error_imm or flg_error_branch;
    PC4 <= std_logic_vector(unsigned(PC) + 4);
    inst <= Imem_data_in;
    Imem_addr_out <= PC;
    process(clk, reset)     -- Clocked signals
    begin
        if reset = '1' then
            PC <= pc_base;
            registers(2) <= x"000003ff";
        elsif rising_edge(clk) then
            PC <= PC_next;
            if ctrl_rd_w_en = '1' then
                registers(to_integer(unsigned(rd))) <= rd_data;
            end if;
        end if;
        registers(0) <= (others => '0');
    end process;
    
    process(all) -- PC next multiplexer
    begin
        case ctrl_pc_next_sel is
            when "00" =>
                PC_next <= PC4;
            when "01" =>
                PC_next <= PC_branch;
            when "10" =>
                PC_next <= alu_result;  
            when "11" =>
                PC_next <= PC_base;
            when others =>
                PC_next <= PC_base;
        end case;
        
    end process;
    
    process(all)    -- Cutting up instruction
    begin
        opcode <= inst(6 downto 0);
        func7 <= inst(31 downto 25);
        rd <=  inst(11 downto 7);
        rs1 <= inst(19 downto 15);
        rs2 <= inst(24 downto 20);
        func3 <= inst(14 downto 12);
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
                    pc_branch_sel <= alu_result(XLEN-1);  
                when "101" => --bge
                    pc_branch_sel <= not alu_result(XLEN-1);
                when "110" => --bltu
                    pc_branch_sel <= (alu_src_a(XLEN-1) xor alu_src_b(XLEN-1)) xor alu_result(XLEN-1);
                when "111" => --bgeu
                    pc_branch_sel <= not((alu_src_a(XLEN-1) xor alu_src_b(XLEN-1)) xor alu_result(XLEN-1));      
                when others =>
                    flg_error_branch <= '1';
            end case;
        end if;
        if pc_branch_sel = '1' then
            PC_branch <= std_logic_vector(signed(PC) + signed(imm));
        else
            PC_branch <= PC4;
        end if;
    end process;
    
    process(opcode)    -- Control
    begin
    ctrl_alu_src_a_sel <= '0';
    ctrl_alu_src_b_sel <= '0';
    ctrl_alu_op <= "00";

    ctrl_rd_w_en <= '0';
    ctrl_rd_data_sel <= "00";

    ctrl_mem_w <= '0';
    ctrl_mem_r <= '0';

    ctrl_branch <= '0';
    ctrl_jump <= '0';
    ctrl_sys <= '0';
    flg_error_ctrl <= '0';
        case opcode is 
            when opcode_load =>         -- Load
                ctrl_alu_src_b_sel <= '1';
                ctrl_rd_w_en <= '1';
                ctrl_mem_r <= '1';
                ctrl_rd_data_sel <= "01";
            when opcode_imm =>          -- I-type
                ctrl_alu_src_b_sel <= '1';
                ctrl_alu_op <= "11";
                ctrl_rd_w_en <= '1';
            when opcode_store =>        -- Store
                ctrl_alu_src_b_sel <= '1';
                ctrl_mem_w <= '1';
            when opcode_r =>            -- R-type
                ctrl_alu_op <= "10";
                ctrl_rd_w_en <= '1';
            when opcode_branch =>       -- Branch
                ctrl_alu_op <= "01";
                ctrl_branch <= '1';       
            when opcode_sys =>          -- ecall
                ctrl_sys <= '1';
            when opcode_auipc =>        -- auipc
                ctrl_alu_src_a_sel <= '1';
                ctrl_alu_src_b_sel <= '1';
                ctrl_rd_w_en <= '1';
            when opcode_lui =>          -- lui
                ctrl_rd_w_en <= '1';
                ctrl_rd_data_sel <= "11";
            when opcode_jalr =>         -- jalr
                ctrl_alu_src_b_sel <= '1';
                ctrl_rd_w_en <= '1';
                ctrl_rd_data_sel <= "10";
                ctrl_jump <= '1';
            when opcode_fence =>        -- fence
                ctrl_sys <= '1';
            when opcode_jal =>          -- jal
                ctrl_alu_src_a_sel <= '1';
                ctrl_alu_src_b_sel <= '1';
                ctrl_rd_w_en <= '1';
                ctrl_rd_data_sel <= "10";
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
        rs2_data <= registers(to_integer(unsigned(rs2)));
        -- Memory
        mem_data <= Dmem_data_in;
        Dmem_data_out <= rs2_data;
        Dmem_addr_out <= alu_result;
        
        if ctrl_mem_w = '1' then
            Dmem_valid_out <= '1';
            Dmem_r_w_out <= '1';
        elsif ctrl_mem_r = '1' then
            Dmem_valid_out <= '1';
            Dmem_r_w_out <= '0';
        else
            Dmem_valid_out <= '0';
            Dmem_r_w_out <= '0';
        end if;
    end process;
    
    process(all)    -- RD data multiplexer
    begin
        case ctrl_rd_data_sel is
            when "00" =>  
                rd_data <= alu_result;
            when "01" =>  
                rd_data <= mem_data;
            when "10" =>  
                rd_data <= PC4;
            when "11" =>  
                rd_data <= imm;
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
            when "00" =>                -- Load/Store, use alu to calculate address
                alu_op <= "0010";
            when "01" =>                -- Branch
                alu_op <= "0110";
            when "10" =>                -- Its an R-instruction
                case func7(5)&func3 is 
                    when "0000" =>
                        alu_op <= "0010";
                    when "1000" =>
                        alu_op <= "0110";
                    when "0111" =>
                        alu_op <= "0000";
                    when "0110" =>
                        alu_op <= "0001";
                    when others => 
                        flg_error_alu <= '1';
                end case;
            when "11" =>                -- Its an I-instruction
                case func3 is 
                    when "000" => --addi
                        alu_op <= "0010";
                    when "111" => --andi
                        alu_op <= "0000";
                    when "110" => --ori
                        alu_op <= "0001";
                    when others => 
                        flg_error_alu <= '1';
                end case;
            when others => 
                flg_error_alu <= '1';  
        end case;
        
        -- ALU sources
        if ctrl_alu_src_a_sel = '1' then
            alu_src_a <= PC;
        else
            alu_src_a <= rs1_data;
        end if;
        if ctrl_alu_src_b_sel = '1' then
            alu_src_b <= imm;
        else
            alu_src_b <= rs2_data;
        end if;
        -- ALU
        case alu_op is
            when "0000" => --AND
                alu_result <= alu_src_a and alu_src_b;
            when "0001" => --OR
                alu_result <= alu_src_a or alu_src_b;
            when "0010" => --add
                alu_result <= std_logic_vector(unsigned(alu_src_a) + unsigned(alu_src_b));
            when "0110" => --sub
                alu_result <= std_logic_vector(unsigned(alu_src_a) - unsigned(alu_src_b));
            when others =>
                alu_result <= (others => '0');
                flg_error_alu <= '1';
        end case;
        if alu_result = x"00000000" then
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
                imm <= ((XLEN-1 downto 12 => inst(31)) & inst(31 downto 20));
            when opcode_imm => --Format I
                imm <= ((XLEN-1 downto 12 => inst(31)) & inst(31 downto 20));
            when opcode_store => --Format S
                imm <= ((XLEN-1 downto 12 => inst(31)) & inst(31 downto 25) & inst(11 downto 7));
            when opcode_r => --Format R
                imm <= (others => '0');    
            when opcode_branch => --Format SB
                imm <= ((XLEN-1 downto 12 => inst(31)) & inst(7) & inst(30 downto 25) & inst(11 downto 8) & '0');
            when opcode_sys => --Format I
                imm <= ((XLEN-1 downto 12 => inst(31)) & inst(31 downto 20));     
            when opcode_auipc => --Format U
                imm <= (inst(31 downto 12) & (11 downto 0 => '0'));
            when opcode_lui => --Format U
                imm <= (inst(31 downto 12) & (11 downto 0 => '0'));           
            when opcode_jalr => --Format I
                imm <= ((XLEN-1 downto 12 => inst(31)) & inst(31 downto 20)); 
            when opcode_fence => --Format I
                imm <= (others => '0');    
            when opcode_jal => --Format UJ
                imm <= ((XLEN-1 downto 20 => inst(31)) & inst(19 downto 12) & inst(20) & inst(30 downto 21) & '0');
            when others => 
                imm <= (others => '0');
                flg_error_imm <= '1';
        end case;
    end process;
end Behavioral;
