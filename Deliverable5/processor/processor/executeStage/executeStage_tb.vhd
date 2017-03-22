LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;

ENTITY executeStage_tb IS
END executeStage_tb;

ARCHITECTURE behaviour OF executeStage_tb IS
--components go here
COMPONENT executeStage IS
    port (
    instruction_in : in Instruction;
    val_a : in std_logic_vector(31 downto 0);
    val_b : in std_logic_vector(31 downto 0);
    imm_sign_extended : in std_logic_vector(31 downto 0);
    PC : in integer; 
    instruction_out : out Instruction;
    branch : out std_logic;
    ALU_result : out std_logic_vector(63 downto 0);
    branch_target_out : out std_logic_vector(31 downto 0);
    val_b_out : out std_logic_vector(31 downto 0);
    PC_out : out integer
  ) ;
END COMPONENT;

--these are our input signals 
signal instruction_in : Instruction;
signal val_a : std_logic_vector(31 downto 0);
signal val_b : std_logic_vector(31 downto 0);
signal imm_sign_extended : std_logic_vector(31 downto 0);
signal PC : integer;
signal INSTRUCTION_OUT : Instruction;
signal branch : std_logic;
signal ALU_Result : std_logic_vector(63 downto 0);
signal branch_target_out : std_logic_vector(31 downto 0);
signal val_b_out : std_logic_vector(31 downto 0);
signal PC_out : integer;



CONSTANT clk_period : time := 1 ns; --TODO: figure out how long we wait here for...
signal val_a_int, val_b_int, immediate_int : integer;
begin
    -- val_a <= std_logic_vector(to_unsigned(val_a_int,32));

    --TODO: think carefully about signed vs unsigned and the format of values
    exAlu: executeStage port map (
        instruction_in,
        val_a,
        val_b,
        imm_sign_extended,
        PC,
        instruction_out,
        branch,
        ALU_result,
        branch_target_out,
        val_b_out,
        PC_out
    );
    test_process : PROCESS
    variable temp : std_logic_vector(31 downto 0) ;
    BEGIN
        report "starting testing of EX stage";

        -- Add
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, ADD_FN); -- add t1 t2 t3
        val_a <= std_logic_vector(to_signed(10,32)); -- x"0000000A"; --10
        val_b <= std_logic_vector(to_signed(171,32)); -- x"000000AB"; --171
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period; 
        ASSERT (to_integer(signed(ALU_Result)) = 181) REPORT "ADD: ALU_Result should be 181, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

        -- Addi
        instruction_in <= makeInstruction(ADDI_OP, 1, 2, 12); --addi t1 t2 10
        val_a <= std_logic_vector(to_signed(10,32));
        val_b <= x"00000000"; --0
        imm_sign_extended <= std_logic_vector(to_signed(12,32));
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 22) REPORT "ADDI: ALU_Result should be 22, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

        -- LOAD_WORD
        instruction_in <= makeInstruction(LW_OP, 1, 2, 50); --lw 
        val_a <= std_logic_vector(to_signed(10,32)); --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= std_logic_vector(to_signed(50,32));
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 60) REPORT "LW: ALU_Result should be 60, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

        -- STORE_WORD
        instruction_in <= makeInstruction(SW_OP, 1, 2, 50); --sw
        val_a <= std_logic_vector(to_signed(10,32)); --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= std_logic_vector(to_signed(50,32));
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 60) REPORT "SW: ALU_Result should be 60, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

        -- BRANCH_IF_EQUAL
        instruction_in <= makeInstruction(BEQ_OP, 1, 2, 40); --beq t1,t2,0x0000
        val_a <= x"0000000A";
        val_b <= x"0000000A"; --0
        imm_sign_extended <= std_logic_vector(to_signed(40,32)); --full
        PC <= 20;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 60) REPORT "BEQ: ALU_Result should be 50, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

        -- BRANCH_IF_NOT_EQUAL
        instruction_in <= makeInstruction(BNE_OP, 1, 2, 40); --beq t1,t2,0x0000
        val_a <= x"0000000A";
        val_b <= x"0000000A"; --0
        imm_sign_extended <= std_logic_vector(to_signed(40,32)); --full
        PC <= 20;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 60) REPORT "BNE: ALU_Result should be 60, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

   
        -- SUBTRACT
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, SUB_FN); -- x"014B4822"; --sub t1, t2, t3
        val_a <= std_logic_vector(to_signed(500,32)); --500
        val_b <= std_logic_vector(to_signed(300,32)); --300
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 200) REPORT "SUB: ALU_Result should be 200, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

        -- MULTIPLY
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, MULT_FN); 
        val_a <= std_logic_vector(to_signed(20,32)); --20
        val_b <= std_logic_vector(to_signed(30,32)); --30
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 600) REPORT "MULT: ALU_Result should be 600, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

        -- DIVIDE 
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, DIV_FN);
        val_a <= std_logic_vector(to_signed(60,32)); --60
        val_b <= std_logic_vector(to_signed(30,32)); --30
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 2) REPORT "DIV: ALU_Result should be 2, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

        -- SET_LESS_THAN
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, SLT_FN); --x"014B482A"; --slt t1 t2 t3
        val_a <= std_logic_vector(to_signed(10,32)); --10
        val_b <= std_logic_vector(to_signed(20,32)); --20
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 1) REPORT "SLT: ALU_Result should be 1, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

        -- SET_LESS_THAN_IMMEDIATE
        instruction_in <= makeInstruction(SLTI_OP, 1, 2, 10); --slti t1 t2 0xFFFF
        val_a <= std_logic_vector(to_signed(20,32)); --20
        val_b <= x"00000000"; --0
        imm_sign_extended <= std_logic_vector(to_signed(10,32)); --10 (as per instruction)
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 0) REPORT "SLTI: ALU_Result should be 0, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;

        -- BITWISE_AND
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, AND_FN); --and t1 t2 t3
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"000000000000000A") REPORT "AND: ALU_Result should be 0x0000000A, but wasn't" SEVERITY FAILURE;

        -- BITWISE_AND_IMMEDIATE 
        temp := x"0000000B";
        instruction_in <= makeInstruction(ANDI_OP, 1, 2, to_integer(unsigned(temp))); --andi t1, t2, 0xB
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"0000000B"; --0xB
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"000000000000000A") REPORT "ANDI: ALU_Result should be 0x0000000A, but wasn't" SEVERITY FAILURE;

        -- BITWISE_OR
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, OR_FN); --or t1, t2, t3
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"000000000000000B") REPORT "OR: ALU_Result should be 0x0000000B, but wasn't" SEVERITY FAILURE;

        -- BITWISE_OR_IMMEDIATE
        instruction_in <= makeInstruction(ORI_OP, 1, 2, 11); --ori t1 t2 0xB
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"0000000B"; --0xB
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"000000000000000B") REPORT "ORI: ALU_Result should be 0x0000000B, but wasn't" SEVERITY FAILURE;

        -- BITWISE_NOR
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, NOR_FN); --nor t1 t2 t3
        val_a <= x"0000000F"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00000000FFFFFFF0") REPORT "NOR: ALU_Result should be 0xFFFFFFF0, but wasn't" SEVERITY FAILURE;

        -- BITWISE_XOR
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, XOR_FN); --xor t1 t2 t3
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"00000000"; --full
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000000000000001") REPORT "XOR: ALU_Result should be 0x00000001, but wasn't" SEVERITY FAILURE;   

        -- BITWISE_XOR_IMMEDIATE
        instruction_in <= makeInstruction(XORI_OP, 1, 2, 11); --xori t1 t2 0xB
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"0000000B"; --0xB
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000000000000001") REPORT "XORI: ALU_Result should be 0x00000001, but wasn't" SEVERITY FAILURE;   

        -- MOVE_FROM_HI
        -- The execute stage will never reach MOVE_FROM_HI (handled in decode)

        -- MOVE_FROM_LOW
        -- The execute stage will never reach MOVE_FROM_LOW (handled in decode)

        -- SHIFT_LEFT_LOGICAL
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 1, SLL_FN); --SLL t1 t2 t3 
        val_a <= x"00000000"; --
        val_b <= x"000000F0"; --0
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00000000000001E0") REPORT "SLL: ALU_Result should be 0x000001E0, but wasn't" SEVERITY FAILURE;

        -- SHIFT_RIGHT_LOGICAL
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 1, SRL_FN); --SRL t1 t2 t3
        val_a <= x"00000000"; --
        val_b <= x"80001000"; --0
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000000040000800") REPORT "SRL: ALU_Result should be 0x40000800, but wasn't" SEVERITY FAILURE;

        -- SHIFT_RIGHT_ARITHMETIC
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 1, SRA_FN); --SRA t1 t2 t3
        val_a <= x"00000000"; --
        val_b <= x"80001000"; --0
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00000000C0000800") REPORT "SRA: ALU_Result should be 0xC0000800, but wasn't" SEVERITY FAILURE;

        -- JUMP
        instruction_in <= makeInstruction(J_OP, 500); --j 
        val_a <= x"00000000"; --0: doesn't matter
        val_b <= x"00000000"; --0: doesn't matter
        imm_sign_extended <= x"00000000"; --0: doesn't matter
        PC <= 536870912;
        -- 536870912
        WAIT FOR clk_period;
        -- ASSERT (to_integer(signed(ALU_Result)) = 500) REPORT "J: ALU_Result should be 550, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;
        ASSERT branch = '1' report "J: Branch should always be 1 in the case of JUmp instructions." SEVERITY FAILURE;
        ASSERT branch_target_out = std_logic_vector(to_unsigned(536871412, 32)) REPORT "J: Branch target should be 550, but was " & integer'image(to_integer(signed(branch_target_out))) SEVERITY FAILURE;
        
        -- JUMP_AND_LINK
        instruction_in <= makeInstruction(JAL_OP, 500); --jal
        val_a <= x"00000000"; --0: doesn't matter
        val_b <= x"00000000"; --0: doesn't matter
        imm_sign_extended <= x"00000000"; --0: doesn't matter
        PC <= 50;
        WAIT FOR clk_period;
        -- ASSERT (to_integer(signed(ALU_Result)) = 500) REPORT "JAL: ALU_Result should be 500, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;
        ASSERT branch = '1' report "JAL: Branch should always be 1 in the case of JUmp instructions." SEVERITY FAILURE;
        ASSERT branch_target_out = std_logic_vector(to_unsigned(500, 32)) REPORT "JAL: Branch targer should be 500, but was " & integer'image(to_integer(signed(branch_target_out))) SEVERITY FAILURE;

        -- JUMP_TO_REGISTER
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, JR_FN); --jr
        val_a <= std_logic_vector(to_signed(500,32)); --500
        val_b <= x"00000000"; --0: doesn't matter
        imm_sign_extended <= x"00000000"; --0: doesn't matter
        PC <= 50;
        WAIT FOR clk_period;
        -- ASSERT (to_integer(signed(ALU_Result)) = 550) REPORT "JR: ALU_Result should be 550, but was " & integer'image(to_integer(signed(ALU_Result))) SEVERITY FAILURE;
        ASSERT branch = '1' report "JR: Branch should always be 1 in the case of JUmp instructions." SEVERITY FAILURE;
        ASSERT branch_target_out = std_logic_vector(to_unsigned(500, 32)) REPORT "JR: Branch targer should be 500, but was " & integer'image(to_integer(signed(branch_target_out))) SEVERITY FAILURE;

        report "DONE testing the EX stage.";
        wait;
    END PROCESS;
END;