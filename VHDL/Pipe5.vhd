library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.static.all;

entity Processor is
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

-- Register file
    type registerFile is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal registers : registerFile;

-- CONTROL PIPELINE
-- R Stage
    --ALU
    signal ctrl_R_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal ctrl_R_alu_src_a_sel, ctrl_R_alu_src_b_sel : STD_LOGIC;
    --Register
    signal ctrl_R_rd_w_en, ctrl_R_PC4_imm_2reg: STD_LOGIC;
    --Branch/Jump
    signal ctrl_R_branch, ctrl_R_jump, ctrl_R_sys : STD_LOGIC;
    --Data memory
    signal ctrl_R_mem_w, ctrl_R_mem_r: STD_LOGIC; 
       
-- A Stage
    --ALU
    signal ctrl_A_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal ctrl_A_alu_src_a_sel, ctrl_A_alu_src_b_sel : STD_LOGIC;
    --Register
    signal ctrl_A_rd_w_en, ctrl_A_PC4_imm_2reg: STD_LOGIC;
    --Branch/Jump
    signal ctrl_A_branch, ctrl_A_jump : STD_LOGIC;
    --Data memory
    signal ctrl_A_mem_w, ctrl_A_mem_r: STD_LOGIC;     
    
-- M Stage
    --Register
    signal ctrl_M_rd_w_en, ctrl_M_PC4_imm_2reg: STD_LOGIC;
    signal ctrl_M_jump: STD_LOGIC;
    --Data memory
    signal ctrl_M_mem_w, ctrl_M_mem_r: STD_LOGIC;
             
-- W Stage
    --Register
    signal ctrl_W_rd_w_en : STD_LOGIC;
    signal ctrl_W_mem_r: STD_LOGIC;

-- MAIN PIPELINE
    signal I_PC_next, A_PC_branch : STD_LOGIC_VECTOR(31 downto 0);
-- I Stage
    signal I_inst, I_PC, I_PC4 : STD_LOGIC_VECTOR(31 downto 0);
-- R Stage
    signal R_inst, R_PC, R_PC4 : STD_LOGIC_VECTOR(31 downto 0);
    signal R_rs1_data, R_rs2_data, R_imm : STD_LOGIC_VECTOR(31 downto 0);
    signal R_opcode : STD_LOGIC_VECTOR(6 downto 0);
    signal R_rd, R_rs1, R_rs2 : STD_LOGIC_VECTOR(4 downto 0);
    signal R_func3 : STD_LOGIC_VECTOR(2 downto 0);
    signal R_func7_bit : STD_LOGIC;
-- A Stage
    signal A_PC : STD_LOGIC_VECTOR(31 downto 0);
    signal A_rs1_data, A_rs2_data : STD_LOGIC_VECTOR(31 downto 0);
    signal A_imm, A_PC4, A_rd_data_A : STD_LOGIC_VECTOR(31 downto 0);
    signal A_rd, A_rs1, A_rs2 : STD_LOGIC_VECTOR(4 downto 0);
    signal A_func3 : STD_LOGIC_VECTOR(2 downto 0);
    signal A_func7_bit : STD_LOGIC;
    --Forwarding
    signal A_rs1_data_forw, A_rs2_data_forw : STD_LOGIC_VECTOR(31 downto 0);
    --ALU
    signal A_alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal A_alu_src_a, A_alu_src_b : STD_LOGIC_VECTOR(31 downto 0);
    signal A_alu_result : STD_LOGIC_VECTOR(31 downto 0);
-- M Stage
    signal M_rs2_data_forw, M_rd_data_A, M_alu_result, M_rd_data_M: STD_LOGIC_VECTOR(31 downto 0);
    signal M_rd: STD_LOGIC_VECTOR(4 downto 0);
    signal M_mem_data: STD_LOGIC_VECTOR(31 downto 0);
-- W Stage
    signal W_mem_data, W_rd_data, W_rd_data_M: STD_LOGIC_VECTOR(31 downto 0);
    signal W_rd: STD_LOGIC_VECTOR(4 downto 0);

-- FLAGS
    --Error
    signal flg_error_branch : STD_LOGIC;
    signal flg_error_alu : STD_LOGIC;
    signal flg_error_ctrl : STD_LOGIC;
    --branch
    signal flg_branch : STD_LOGIC;
    signal flg_alu_zero : STD_LOGIC;
    --Flush, stall, hazard
    signal flg_stall, flg_hazard : STD_LOGIC;
    signal flg_flush_I, flg_flush_R : STD_LOGIC;
    
-- ENABLE
    signal en_PC_reg : STD_LOGIC;
    signal en_IR_reg : STD_LOGIC;
begin
    flg_error <= flg_error_alu or flg_error_ctrl or flg_error_branch;
    flg_flush_I <= flg_branch or ctrl_A_jump;
    flg_flush_R <= flg_branch or flg_hazard or ctrl_A_jump;
    en_PC_reg <= ctrl_R_sys or ctrl_A_jump or flg_branch or (flg_stall nor flg_hazard);
    en_IR_reg <= not flg_hazard;
    
    process(all)     -- Main Pipeline registers
    begin
        if reset = '1' then
            ctrl_A_alu_op           <= "00";
            ctrl_A_alu_src_a_sel    <= '0';
            ctrl_A_alu_src_b_sel    <= '0';
            ctrl_A_rd_w_en          <= '0';
            ctrl_A_PC4_imm_2reg     <= '0';
            ctrl_A_branch           <= '0';
            ctrl_A_jump             <= '0';
            ctrl_A_mem_w            <= '0';
            ctrl_A_mem_r            <= '0';


            ctrl_M_rd_w_en          <= '0';
            ctrl_M_PC4_imm_2reg     <= '0';
            ctrl_M_mem_w            <= '0';
            ctrl_M_mem_r            <= '0';       
            
            ctrl_W_rd_w_en          <= '0';
            ctrl_W_mem_r            <= '0';
        elsif rising_edge(clk) then
            --FLUSH
            if flg_flush_R = '1' then
                ctrl_A_alu_op           <= "00";
                ctrl_A_alu_src_a_sel    <= '0';
                ctrl_A_alu_src_b_sel    <= '0';
                ctrl_A_rd_w_en          <= '0';
                ctrl_A_PC4_imm_2reg     <= '0';
                ctrl_A_branch           <= '0';
                ctrl_A_jump             <= '0';
                ctrl_A_mem_w            <= '0';
                ctrl_A_mem_r            <= '0';
            else
                ctrl_A_alu_op           <= ctrl_R_alu_op;       
                ctrl_A_alu_src_a_sel    <= ctrl_R_alu_src_a_sel;
                ctrl_A_alu_src_b_sel    <= ctrl_R_alu_src_b_sel;
                ctrl_A_rd_w_en          <= ctrl_R_rd_w_en;
                ctrl_A_PC4_imm_2reg     <= ctrl_R_PC4_imm_2reg;
                ctrl_A_branch           <= ctrl_R_branch;       
                ctrl_A_jump             <= ctrl_R_jump;       
                ctrl_A_mem_w            <= ctrl_R_mem_w;
                ctrl_A_mem_r            <= ctrl_R_mem_r;
            end if;   
                                
            ctrl_M_rd_w_en      <= ctrl_A_rd_w_en;
            ctrl_M_PC4_imm_2reg <= ctrl_A_PC4_imm_2reg;
            ctrl_M_mem_w        <= ctrl_A_mem_w;
            ctrl_M_mem_r        <= ctrl_A_mem_r;
            
            ctrl_W_rd_w_en      <= ctrl_M_rd_w_en;
            ctrl_W_mem_r        <= ctrl_M_mem_r;
        end if;
    end process;
    
    process(all)     -- Main Pipeline registers
    begin
        if reset = '1' then
            R_PC            <= (others => '0');
            R_inst          <= (others => '0');
            R_PC4           <= (others => '0');
            A_PC            <= (others => '0');
            A_PC4           <= (others => '0');
            A_rs1_data      <= (others => '0');
            A_rs2_data      <= (others => '0');
            A_imm           <= (others => '0');
            A_rs1           <= (others => '0');
            A_rs2           <= (others => '0');
            A_rd            <= (others => '0');
            A_func3         <= (others => '0');
            A_func7_bit     <= '0';   
            M_alu_result    <= (others => '0');
            M_rs2_data_forw <= (others => '0');
            M_rd_data_A     <= (others => '0');
            M_rd            <= (others => '0');
            W_mem_data      <= (others => '0');
            W_rd_data_M     <= (others => '0');
            W_rd            <= (others => '0');     
                   
        elsif rising_edge(clk) then
            --FLUSH
            if flg_flush_I = '1' then
                R_inst       <= (others => '0');
                R_PC         <= I_PC;        
                R_PC4        <= I_PC4;
            --ENABLE
            elsif en_IR_reg = '1' then
                R_inst       <= I_inst;    
                R_PC         <= I_PC;        
                R_PC4        <= I_PC4;
            end if;
            
            
            A_PC         <= R_PC;      
            A_PC4        <= R_PC4;       
            A_rs1_data   <= R_rs1_data;
            A_rs2_data   <= R_rs2_data; 
            A_imm        <= R_imm;       
            A_rs1        <= R_rs1;       
            A_rs2        <= R_rs2;       
            A_rd         <= R_rd;                     
            A_func3      <= R_func3;
            A_func7_bit  <= R_func7_bit;
            
            M_alu_result    <= A_alu_result;
            M_rs2_data_forw <= A_rs2_data_forw;
            M_rd_data_A     <= A_rd_data_A;
            M_rd            <= A_rd;      
               
            W_mem_data   <= M_mem_data;
            W_rd_data_M  <= M_rd_data_M;
            W_rd         <= M_rd;      
        end if;
    end process;
    
    process(all) -- PC next multiplexers
    begin
        if flg_branch = '1' then
            I_PC_next <= A_PC_branch;
        elsif ctrl_A_jump = '1' then
            I_PC_next <= A_alu_result; 
        elsif ctrl_R_sys = '1' then
            I_PC_next <= PC_base;
        else
            I_PC_next <= I_PC4; 
        end if;
    end process;
    
    process(all)     -- PC
    begin
        I_PC4 <= std_logic_vector(unsigned(I_PC) + 4);
        if reset = '1' then
            I_PC <= pc_base;
        elsif rising_edge(clk) then
            if en_PC_reg = '1' then
                I_PC <= I_PC_next;
            end if;
        end if;
    end process;
    
    process(all)     -- Instruction memory
    begin
        Imem_addr_out <= I_PC;
        Imem_valid_out <= '1';
        Imem_data_out <= (others => '0');
        Imem_r_w_out <= '0';
        if Imem_ready_in = '0' then
            I_inst <= (others => '0');
            flg_stall <= '1';
        else
            I_inst <= Imem_data_in;
            flg_stall <= '0';
        end if;
    end process;
    
    process(all)     -- Registerfile
    begin
        if reset = '1' then
            registers(2) <= x"00001000";
        elsif rising_edge(clk) then
            if ctrl_W_rd_w_en = '1' then
                registers(to_integer(unsigned(W_rd))) <= W_rd_data;
            end if;
        end if;
        
        registers(0) <= (others => '0');

        -- Register file forwards data if the same register is written to and read from
        if R_rs1 = W_rd and R_rs1 /= "00000" then         -- dont forward when x0
            R_rs1_data <= W_rd_data;
        else
            R_rs1_data <= registers(to_integer(unsigned(R_rs1)));
        end if;
        
        if R_rs2 = W_rd and R_rs2 /= "00000" then          -- dont forward when x0
            R_rs2_data <= W_rd_data;
        else
            R_rs2_data <= registers(to_integer(unsigned(R_rs2)));
        end if;
    end process;
    
    process(all)    -- Decoder
    begin
        R_opcode    <= R_inst(6 downto 0);
        R_func7_bit <= R_inst(30);          -- Should be 7 bits, but only one bit of func7 is ever used (func7(5))
        R_rd        <= R_inst(11 downto 7);
        R_rs1       <= R_inst(19 downto 15);
        R_rs2       <= R_inst(24 downto 20);
        R_func3     <= R_inst(14 downto 12);
    end process;
    
    process(all)     -- Forwarding
    begin
    
        if A_rs1 = "00000" then
            -- dont forward when x0
            A_rs1_data_forw <= A_rs1_data;
        elsif A_rs1 = M_rd and ctrl_M_rd_w_en = '1' then
            A_rs1_data_forw <= M_rd_data_M;
        elsif A_rs1 = W_rd and ctrl_W_rd_w_en = '1' then
            A_rs1_data_forw <= W_rd_data;
        else
            A_rs1_data_forw <= A_rs1_data;
        end if;
        
        if A_rs2 = "00000" then
            -- dont forward when x0
            A_rs2_data_forw <= A_rs2_data;
        elsif A_rs2 = M_rd and ctrl_M_rd_w_en = '1' then
            A_rs2_data_forw <= M_rd_data_M;
        elsif A_rs2 = W_rd and ctrl_W_rd_w_en = '1' then
            A_rs2_data_forw <= W_rd_data;
        else
            A_rs2_data_forw <= A_rs2_data;
        end if;
    end process;
    
    process(all)     -- Hazard detection
    begin
        if ctrl_A_mem_r = '1' then
            if A_rd = "00000" then
                flg_hazard <= '0';
            elsif R_rs1 = A_rd or R_rs2 = A_rd then
                flg_hazard <= '1';
            else
                flg_hazard <= '0';
            end if;
        else
            flg_hazard <= '0';
        end if;
    end process;
    
    process(all)        --Branch control
    begin
        A_PC_branch <= std_logic_vector(signed(A_PC) + signed(A_imm));
        flg_error_branch <= '0';
        flg_branch <= '0';
        if ctrl_A_branch = '1' then
            case A_func3 is
                when "000" => -- beq
                    flg_branch <= flg_alu_zero;
                when "001" => --bne
                    flg_branch <= not flg_alu_zero;
                when "100" => --blt
                    flg_branch <= A_alu_result(31);  
                when "101" => --bge
                    flg_branch <= not A_alu_result(31);
                when "110" => --bltu
                    flg_branch <= (A_alu_src_a(31) xor A_alu_src_b(31)) xor A_alu_result(31);
                when "111" => --bgeu
                    flg_branch <= not((A_alu_src_a(31) xor A_alu_src_b(31)) xor A_alu_result(31));      
                when others =>
                    flg_error_branch <= '1';
            end case;
        end if;
        
    end process;
    
    process(all)    -- Control
    begin
         
        ctrl_R_alu_src_a_sel <= '0';
        ctrl_R_alu_src_b_sel <= '0';
        ctrl_R_alu_op <= "00";
    
        ctrl_R_rd_w_en <= '0';
        ctrl_R_PC4_imm_2reg <= '0';
        ctrl_R_mem_w <= '0';
        ctrl_R_mem_r <= '0';
    
        ctrl_R_branch <= '0';
        ctrl_R_jump <= '0';
        ctrl_R_sys <= '0';

        flg_error_ctrl <= '0';
        
        case R_opcode is 
            when opcode_load =>         -- Load
                ctrl_R_alu_src_b_sel <= '1';
                ctrl_R_rd_w_en <= '1';
                ctrl_R_mem_r <= '1';
            when opcode_imm =>          -- I-type
                ctrl_R_alu_src_b_sel <= '1';
                ctrl_R_alu_op <= "11";
                ctrl_R_rd_w_en <= '1';
            when opcode_store =>        -- Store
                ctrl_R_alu_src_b_sel <= '1';
                ctrl_R_mem_w <= '1';
            when opcode_r =>            -- R-type
                ctrl_R_alu_op <= "10";
                ctrl_R_rd_w_en <= '1';
            when opcode_branch =>       -- Branch
                ctrl_R_alu_op <= "01";
                ctrl_R_branch <= '1';       
            when opcode_sys =>          -- ecall
                ctrl_R_sys <= '1';
            when opcode_auipc =>        -- auipc
                ctrl_R_alu_src_a_sel <= '1';
                ctrl_R_alu_src_b_sel <= '1';
                ctrl_R_rd_w_en <= '1';
            when opcode_lui =>          -- lui
                ctrl_R_rd_w_en <= '1';
                ctrl_R_PC4_imm_2reg <= '1';
            when opcode_jalr =>         -- jalr
                ctrl_R_alu_src_b_sel <= '1';
                ctrl_R_rd_w_en <= '1';
                ctrl_R_jump <= '1';     
                ctrl_R_PC4_imm_2reg <= '1';  
            when opcode_fence =>        -- fence
                ctrl_R_sys <= '1';
            when opcode_jal =>          -- jal
                ctrl_R_alu_src_a_sel <= '1';
                ctrl_R_alu_src_b_sel <= '1';
                ctrl_R_rd_w_en <= '1';
                ctrl_R_jump <= '1';      
                ctrl_R_PC4_imm_2reg <= '1'; 
            when "0000000" =>
                -- An all zero instruction counts as a nop
            when others => 
                --ERROR
                flg_error_ctrl <= '1';
        end case;

    end process;
        
    process(all)    -- Memory
    begin
        M_mem_data <= Dmem_data_in;
        Dmem_data_out <= M_rs2_data_forw;
        Dmem_addr_out <= M_alu_result;
        
        if ctrl_M_mem_w = '1' then
            Dmem_valid_out <= '1';
            Dmem_r_w_out <= '1';
        elsif ctrl_M_mem_r = '1' then
            Dmem_valid_out <= '1';
            Dmem_r_w_out <= '0';
        else
            Dmem_valid_out <= '0';
            Dmem_r_w_out <= '0';
        end if;
    end process;
    
    
    process(all)    -- RD data multiplexers
    begin
        if ctrl_A_jump = '1' then
            A_rd_data_A <= A_PC4;
        else
            A_rd_data_A <= A_imm;
        end if;
        
        if ctrl_M_PC4_imm_2reg = '1' then
            M_rd_data_M <= M_rd_data_A;
        else
            M_rd_data_M <= M_alu_result;
        end if;
    
        if ctrl_W_mem_r = '1' then
            W_rd_data <= W_mem_data;
        else
            W_rd_data <= W_rd_data_M;
        end if;
    end process;
    
    process(all)   -- ALU source multiplexers
    begin
        if ctrl_A_alu_src_a_sel = '1' then
            A_alu_src_a <= A_PC;
        else
            A_alu_src_a <= A_rs1_data_forw;
        end if;
        if ctrl_A_alu_src_b_sel = '1' then
            A_alu_src_b <= A_imm;
        else
            A_alu_src_b <= A_rs2_data_forw;
        end if;
    end process;    
    
    process(all)    -- ALU control
    begin
        --ALU control
        flg_error_alu <= '0';
        A_alu_op <= "1111";
        case ctrl_A_alu_op is
            when "00" =>                -- Load/Store ect., use alu to calculate address
                A_alu_op <= "0010";
            when "01" =>                -- Branch
                A_alu_op <= "0110";
            when "10" =>                -- Its an R-instruction
                case A_func7_bit&A_func3 is 
                    when "0000" =>  --add
                        A_alu_op <= "0010";
                    when "1000" =>  --sub
                        A_alu_op <= "0110";
                    when "0001" =>  --sll
                        A_alu_op <= "1000";
--                    when "0010" =>  --slt
--                        A_alu_op <= "";
--                    when "0011" =>  --sltu
--                        A_alu_op <= "";    
                    when "0100" =>  --xor
                        A_alu_op <= "0111";    
                    when "0101" =>  --srl
                        A_alu_op <= "1100";
                    when "1101" =>  --sra
                        A_alu_op <= "1101";
                    when "0110" =>  --or
                        A_alu_op <= "0001";          
                    when "0111" =>  --and
                        A_alu_op <= "0000";                        
                    when others => 
                        flg_error_alu <= '1';
                end case;
            when "11" =>                -- Its an I-instruction
                case A_func3 is 
                    when "000" => --addi
                        A_alu_op <= "0010";
                    when "001" => --slli
                        A_alu_op <= "1000"; 
--                    when "010" => --slti
--                        A_alu_op <= "";         
--                    when "011" => --sltiu
--                        A_alu_op <= "";   
                    when "100" => --xori
                        A_alu_op <= "0111";   
                    when "101" => --sr(l/a)i
                        if A_func7_bit = '1' then   --srai
                            A_alu_op <= "1101";   
                        else                        --srli
                            A_alu_op <= "1100";
                        end if;
                    when "110" => --ori
                        A_alu_op <= "0001";                
                    when "111" => --andi
                        A_alu_op <= "0000";

                    when others => 
                        flg_error_alu <= '1';
                end case;
            when others => 
                flg_error_alu <= '1';  
        end case;
    end process;
    
    process(all)    -- ALU
    begin        
        -- ALU
        case A_alu_op is
            when "0000" => --AND
                A_alu_result <= A_alu_src_a and A_alu_src_b;
            when "0001" => --OR
                A_alu_result <= A_alu_src_a or A_alu_src_b;
            when "0010" => --add
                A_alu_result <= std_logic_vector(unsigned(A_alu_src_a) + unsigned(A_alu_src_b));
            when "0110" => --sub
                A_alu_result <= std_logic_vector(unsigned(A_alu_src_a) - unsigned(A_alu_src_b));
            when "0111" => --XOR
                A_alu_result <= A_alu_src_a xor A_alu_src_b;
            when "1000" => --shift left (5bit)
                A_alu_result <= std_logic_vector(shift_left(unsigned(A_alu_src_a), to_integer(unsigned(A_alu_src_b(4 downto 0)))));
            when "1100" => --shift right (5bit)
                A_alu_result <= std_logic_vector(shift_right(unsigned(A_alu_src_a), to_integer(unsigned(A_alu_src_b(4 downto 0)))));
            when "1101" => --shift right arithmetic (5bit)
                A_alu_result <= std_logic_vector(shift_right(signed(A_alu_src_a), to_integer(unsigned(A_alu_src_b(4 downto 0))))); 
            when others =>
                A_alu_result <= (others => '0');
        end case;
        if A_alu_result = x"00000000" then
            flg_alu_zero <= '1';
        else
            flg_alu_zero <= '0';
        end if;
    end process;
    
    process(all)    -- Immidiate Gen
    begin
        case R_opcode is
            when opcode_load => --Format I
                R_imm <= ((31 downto 12 => R_inst(31)) & R_inst(31 downto 20));
            when opcode_imm => --Format I
                R_imm <= ((31 downto 12 => R_inst(31)) & R_inst(31 downto 20));
            when opcode_store => --Format S
                R_imm <= ((31 downto 12 => R_inst(31)) & R_inst(31 downto 25) & R_inst(11 downto 7));
            when opcode_r => --Format R
                R_imm <= (others => '0');    
            when opcode_branch => --Format SB
                R_imm <= ((31 downto 12 => R_inst(31)) & R_inst(7) & R_inst(30 downto 25) & R_inst(11 downto 8) & '0');
            when opcode_sys => --Format I
                R_imm <= ((31 downto 12 => R_inst(31)) & R_inst(31 downto 20));     
            when opcode_auipc => --Format U
                R_imm <= (R_inst(31 downto 12) & (11 downto 0 => '0'));
            when opcode_lui => --Format U
                R_imm <= (R_inst(31 downto 12) & (11 downto 0 => '0'));           
            when opcode_jalr => --Format I
                R_imm <= ((31 downto 12 => R_inst(31)) & R_inst(31 downto 20)); 
            when opcode_fence => --Format I
                R_imm <= (others => '0');    
            when opcode_jal => --Format UJ
                R_imm <= ((31 downto 20 => R_inst(31)) & R_inst(19 downto 12) & R_inst(20) & R_inst(30 downto 21) & '0');
            when others => 
                R_imm <= (others => '0');
        end case;
    end process;
end Behavioral;
