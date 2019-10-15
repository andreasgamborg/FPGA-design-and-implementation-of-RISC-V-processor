----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.09.2019 12:33:49
-- Design Name: 
-- Module Name: Processor - Behavioral
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

entity Processor is
    Port (  sysclk : IN STD_LOGIC;
            btn_reset, btn_run, btn_stop, btn_load : IN STD_LOGIC;
            switch :IN STD_LOGIC_VECTOR(15 downto 0);
            led : OUT STD_LOGIC_VECTOR(15 downto 0);
            RsRx : IN STD_LOGIC;
            RsTx : OUT STD_LOGIC;
            seg7:   OUT STD_LOGIC_VECTOR(7 downto 0);
            an :    OUT STD_LOGIC_VECTOR(3 downto 0)
    );
end Processor;

architecture Behavioral of Processor is

    component clk_wiz_0
        port(
            clk_in1     : in     std_logic;
            reset       : in std_logic;
            clk_out1    : out    std_logic
        );
     end component;
    signal clk : std_logic;
    type debug_state_type is (dDone, dLoad, dRun, dError);
    signal dState, dState_next : debug_state_type;
    signal flg_ddone : STD_LOGIC;
-- CPU State
    signal PC, PC_next : STD_LOGIC_VECTOR(63 downto 0);
    type registerFile is array(0 to 31) of STD_LOGIC_VECTOR(63 downto 0);
    type Mem is array(0 to 255) of STD_LOGIC_VECTOR(7 downto 0);
    signal registers : registerFile;
    signal d_mem : Mem;
    signal i_mem : Mem;
-- Instrucion
    signal inst : STD_LOGIC_VECTOR(31 downto 0);
    signal opcode, func7 : STD_LOGIC_VECTOR(6 downto 0);
    signal rd, rs1, rs2 : STD_LOGIC_VECTOR(4 downto 0);
    signal func3 : STD_LOGIC_VECTOR(2 downto 0);
    signal opcode_byte : STD_LOGIC_VECTOR(7 downto 0);
-- Control
    --ALU
    signal ctrl_alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal ctrl_alu_src, ctrl_zero : STD_LOGIC;
    --Register
    signal ctrl_w_en : STD_LOGIC;
    --Branch
    signal ctrl_branch : STD_LOGIC;
    --Data memory
    signal ctrl_mem_w, ctrl_mem_r, ctrl_mem_to_reg : STD_LOGIC;
-- Data
    signal rs1_data, rs2_data, rd_data, mem_data: STD_LOGIC_VECTOR(63 downto 0);
    signal imm : STD_LOGIC_VECTOR(63 downto 0);
-- Misc
    signal alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_result : STD_LOGIC_VECTOR(63 downto 0);
    signal alu_src : STD_LOGIC_VECTOR(63 downto 0);
    signal branch : STD_LOGIC;
    constant c3 : STD_LOGIC_VECTOR(1 downto 0) := "11";
    constant c2 : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant c1 : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant c0 : STD_LOGIC_VECTOR(1 downto 0) := "00";

-- Error Flags
    signal flg_error : STD_LOGIC;
    signal flg_error_branch : STD_LOGIC;
    signal flg_error_alu : STD_LOGIC;
    signal flg_error_ctrl : STD_LOGIC;
    signal flg_error_imm : STD_LOGIC;

    component Input_driver is
        Port (  
            clk : IN STD_LOGIC;
            btn_run : IN STD_LOGIC;
            btn_stop : IN STD_LOGIC;
            btn_reset : IN STD_LOGIC;
            btn_load : IN STD_LOGIC;
            sbtn_run : OUT STD_LOGIC;
            sbtn_stop : OUT STD_LOGIC;
            sbtn_reset : OUT STD_LOGIC;
            sbtn_load : OUT STD_LOGIC
        );
    end component;
    signal sbtn_run, sbtn_stop, sbtn_reset, sbtn_load : STD_LOGIC;

    component UART_driver is
        Port (  
            clk : IN STD_LOGIC;
            RsRx : IN STD_LOGIC;
            RsTx : OUT STD_LOGIC;
            done_flg : OUT STD_LOGIC;
            payload : OUT std_logic_vector(7 downto 0)
        );
    end component;
    signal uart_payload_ready : STD_LOGIC;
    signal uart_payload : std_logic_vector(7 downto 0);
    signal UART_ptr, UART_ptr_next : unsigned(9 downto 0);
    
    component Seg7_driver is
        Port(   
            clk :   IN STD_LOGIC;
            to_seg7:IN STD_LOGIC_VECTOR(15 downto 0);
            seg7:   OUT STD_LOGIC_VECTOR(7 downto 0);
            an :    OUT STD_LOGIC_VECTOR(3 downto 0)
            );
    end component;
    signal to_seg7 : std_logic_vector(15 downto 0);
    
    signal ifetch_byte0, ifetch_byte1, ifetch_byte2, ifetch_byte3 : STD_LOGIC_VECTOR(63 downto 0);

    
begin
    flg_error <= flg_error_alu or flg_error_ctrl or flg_error_imm or flg_error_branch;
    process(all)   -- State logic
    begin
        dState_next <= dState;
        case dState is
            when dLoad =>
                to_seg7 <= x"000a";
                PC_next <= (others => '0');
                if (uart_payload_ready = '1') then
                    UART_ptr_next <= UART_ptr + 1;
                else
                    UART_ptr_next <= UART_ptr;
                end if;
                
                if sbtn_run = '1' then
                    dState_next <= dRun;
                end if;
            when dRun =>
                to_seg7 <= x"000f";
                if branch = '1' then
                    PC_next <= std_logic_vector(signed(PC) + signed(imm));
                else
                    PC_next <= std_logic_vector(unsigned(PC) + 4);
                end if;
                UART_ptr_next <= (others => '0');
                if flg_error = '1' then
                    dState_next <= dError;
                elsif (sbtn_stop='1' or flg_ddone='1') then
                    dState_next <= dDone;
                end if;
            when dDone =>
                to_seg7 <= x"000d";
                PC_next <= (others => '0');
                UART_ptr_next <= (others => '0');
                
                if sbtn_run='1' then
                    dState_next <= dRun;
                elsif sbtn_load='1' then
                    dState_next <= dLoad;
                end if;
            when dError =>
                to_seg7 <= x"000e";
                PC_next <= PC;
                UART_ptr_next <= (others => '0');
                if (sbtn_run='1' or sbtn_stop='1' or sbtn_load='1') then
                    dState_next <= dDone;
                end if;
        end case;
    end process;
    
    process(all)   -- Output
    begin
        if switch(15) = '0' then
            led <= std_logic_vector(UART_ptr(7 downto 0)) & i_mem(to_integer(unsigned(switch(11 downto 0))))(7 downto 0);
        else
            led <= PC(7 downto 0) & registers(to_integer(unsigned(switch(4 downto 0))))(7 downto 0);
        end if;
    end process;

    ifetch_byte0 <= PC(63 downto 2) & "00";
    ifetch_byte1 <= PC(63 downto 2) & "01";
    ifetch_byte2 <= PC(63 downto 2) & "10";
    ifetch_byte3 <= PC(63 downto 2) & "11";

    inst <= i_mem(to_integer(unsigned(ifetch_byte3))) & 
            i_mem(to_integer(unsigned(ifetch_byte2))) & 
            i_mem(to_integer(unsigned(ifetch_byte1))) & 
            i_mem(to_integer(unsigned(ifetch_byte0)));


    process(clk, sbtn_reset)     -- Clock dependent signals
    begin
        if rising_edge(clk) then
            dState <= dState_next;
            PC <= PC_next;
            UART_ptr <= UART_ptr_next;

            if ctrl_w_en = '1' then
                registers(to_integer(unsigned(rd))) <= rd_data;
            end if;
            if ctrl_mem_w = '1' then
--                d_mem(to_integer(unsigned(alu_result)))   <= rs2_data(63 downto 56);
--                d_mem(to_integer(unsigned(alu_result)+1)) <= rs2_data(55 downto 48);
--                d_mem(to_integer(unsigned(alu_result)+2)) <= rs2_data(47 downto 40);
--                d_mem(to_integer(unsigned(alu_result)+3)) <= rs2_data(39 downto 32);
--                d_mem(to_integer(unsigned(alu_result)+4)) <= rs2_data(31 downto 24);
--                d_mem(to_integer(unsigned(alu_result)+5)) <= rs2_data(23 downto 16);
--                d_mem(to_integer(unsigned(alu_result)+6)) <= rs2_data(15 downto 8);
--                d_mem(to_integer(unsigned(alu_result)+7)) <= rs2_data(7 downto 0);
            end if;
            if sbtn_reset = '1' then
                PC <= (others => '0');
                UART_ptr <= (others => '0');
                registers(2) <= x"00000000000003ff"; -- Stack pointer
            end if;
            registers(0) <= x"0000000000000000";
            if (uart_payload_ready = '1') and (dState = dLoad) then
                i_mem(to_integer(UART_ptr))<= uart_payload;
            end if;

        end if;
    end process;
    
    process(all)    -- Cutting up instruction
    begin
        opcode <= inst(6 downto 0);
        opcode_byte <= '0'&opcode; -- 7 bit -> 8 bit (Makes it easy to construct cases)
        func7 <= inst(31 downto 25);
        rd <=  inst(11 downto 7);
        rs1 <= inst(19 downto 15);
        rs2 <= inst(24 downto 20);
        func3 <= inst(14 downto 12);
    end process;
    
    process(all)        --Branch or next
    begin
        flg_error_branch <= '0';
        branch <= '0';
        if ctrl_branch = '1' then
            case func3 is
                when "000" => -- beq
                    branch <= ctrl_zero;
                when "001" => --bne
                    branch <= not ctrl_zero;
                when "100" => --blt
                    branch <= alu_result(63);  
                when "101" => --bge
                    branch <= not alu_result(63);    
                when others =>
                    flg_error_branch <= '1';
            end case;
        end if;
    end process;
    
    process(all)    -- Control
    begin
    ctrl_alu_src <= '0';
    ctrl_w_en <= '0';
    ctrl_branch <= '0';
    ctrl_mem_w <= '0';
    ctrl_mem_r <= '0';
    ctrl_mem_to_reg <= '0';
    flg_ddone <= '0'; 
    flg_error_ctrl <= '0';
    flg_ddone <= '0';        
        case opcode_byte is 
            when x"03" =>       -- Load
                ctrl_alu_op <= "00";
                ctrl_alu_src <= '1';
                ctrl_w_en <= '1';
                ctrl_mem_r <= '1';
                ctrl_mem_to_reg <= '1';
            when x"13" =>       -- I-type
                ctrl_alu_op <= "11";
                ctrl_alu_src <= '1';
                ctrl_w_en <= '1';
            when x"23" =>       -- Store
                ctrl_alu_op <= "00";
                ctrl_alu_src <= '1';
                ctrl_mem_w <= '1';
            when x"33" =>       -- R-type
                ctrl_alu_op <= "10";
                ctrl_w_en <= '1';
            when x"63" =>       -- Branch
                ctrl_alu_op <= "01";
                ctrl_branch <= '1';       
            when x"73" =>       -- ecall
                ctrl_alu_op <= "00";
                flg_ddone <= '1';
            when others => 
                ctrl_alu_op <= "00";    
                flg_error_ctrl <= '1';
        end case;
    end process;
    
    process(all)    -- Read data from register file and memory
    begin
        -- Registers
        rs1_data <= registers(to_integer(unsigned(rs1)));
        rs2_data <= registers(to_integer(unsigned(rs2)));
        -- Memory
        if ctrl_mem_r = '1' then
--            mem_data <= d_mem(to_integer(unsigned(alu_result)+7))   &
--                        d_mem(to_integer(unsigned(alu_result)+6))   &
--                        d_mem(to_integer(unsigned(alu_result)+5))   &
--                        d_mem(to_integer(unsigned(alu_result)+4))   &
--                        d_mem(to_integer(unsigned(alu_result)+3))   &
--                        d_mem(to_integer(unsigned(alu_result)+2))   &
--                        d_mem(to_integer(unsigned(alu_result)+1))   &
--                        d_mem(to_integer(unsigned(alu_result)));
        else
            mem_data <= (others => '0');
        end if;
        if ctrl_mem_to_reg = '1' then
            rd_data <= mem_data;
        else
            rd_data <= alu_result;
        end if;
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
        
        -- ALU source
        if ctrl_alu_src = '1' then
            alu_src <= imm;
        else
            alu_src <= rs2_data;
        end if;
        -- ALU
        case alu_op is
            when "0000" => --AND
                alu_result <= rs1_data and alu_src;
            when "0001" => --OR
                alu_result <= rs1_data or alu_src;
            when "0010" => --add
                alu_result <= std_logic_vector(unsigned(rs1_data) + unsigned(alu_src));
            when "0110" => --sub
                alu_result <= std_logic_vector(unsigned(rs1_data) - unsigned(alu_src));
            when others =>
                alu_result <= (others => '0');
                flg_error_alu <= '1';
        end case;
        if alu_result = x"0000000000000000" then
            ctrl_zero <= '1';
        else
            ctrl_zero <= '0';
        end if;
    end process;
    
    process(all)    -- Immidiate Gen
    begin
        flg_error_imm <= '0';
        case opcode_byte is
            when x"03" => --Format I
                imm <= ((63 downto 12 => inst(31)) & inst(31 downto 20));
            when x"0f" => --Format I
                imm <= ((63 downto 12 => inst(31)) & inst(31 downto 20));
            when x"13" => --Format I
                imm <= ((63 downto 12 => inst(31)) & inst(31 downto 20));
            when x"17" => --Format U
                imm <= ((63 downto 32 => inst(31)) & inst(31 downto 12) & (11 downto 0 => '0'));
            when x"1b" => --Format I
                imm <= ((63 downto 12 => inst(31)) & inst(31 downto 20));
            when x"23" => --Format S
                imm <= ((63 downto 12 => inst(31)) & inst(31 downto 25) & inst(11 downto 7));
            when x"33" => --Format R
                imm <= (others => '0');
            when x"37" => --Format U
                imm <= ((63 downto 32 => inst(31)) & inst(31 downto 12) & (11 downto 0 => '0'));           
            when x"3b" => --Format R
                imm <= (others => '0');
            when x"63" => --Format SB
                imm <= ((63 downto 12 => inst(31)) & inst(7) & inst(30 downto 25) & inst(11 downto 8) & '0');
            when x"67" => --Format I
                imm <= ((63 downto 12 => inst(31)) & inst(31 downto 20));
            when x"6F" => --Format UJ
                imm <= ((63 downto 20 => inst(31)) & inst(19 downto 12) & inst(20) & inst(30 downto 21) & '0');
            when x"73" => --Format I
                imm <= ((63 downto 12 => inst(31)) & inst(31 downto 20));          
            when others => 
                imm <= (others => '0');
                flg_error_imm <= '1';
        end case;
    end process;
    
            
    clk_wiz_0_inst : clk_wiz_0
        port map(
            reset => btn_reset,
            clk_in1 => sysclk,
            clk_out1 => clk
        );
    
    Input : Input_driver 
        port map(
            clk => clk,           
            btn_run => btn_run,
            btn_stop => btn_stop,
            btn_reset => btn_reset,
            btn_load => btn_load,                                                 
            sbtn_run => sbtn_run,
            sbtn_stop => sbtn_stop,           
            sbtn_reset => sbtn_reset,
            sbtn_load => sbtn_load
        ); 
    UART : UART_driver 
        port map(
            clk => clk,           
            RsRx => RsRx,
            RsTx => RsTx,
            done_flg => uart_payload_ready,                                                 
            payload => uart_payload
        );
    Seg7_display : Seg7_driver 
        port map(
            clk => clk,           
            to_seg7 => to_seg7,
            seg7 => seg7,
            an => an
        );          
end Behavioral;
