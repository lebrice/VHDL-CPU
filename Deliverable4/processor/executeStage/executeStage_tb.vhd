LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY executeStage_tb IS
END executeStage_tb;

ARCHITECTURE behaviour OF executeStage_tb IS
--components go here
COMPONENT EXECUTE IS
    port(clock : in std_logic;
    instruction_in : in Instruction;
    val_a : in std_logic_vector(31 downto 0);
    val_b : in std_logic_vector(31 downto 0);
    imm_sign_extended : in std_logic_vector(31 downto 0);
    PC : in integer; 
    instruction_out : out Instruction;
    branch : out std_logic;
    ALU_Result : out std_logic_vector(31 downto 0)
  );
END COMPONENT;

--these are our input signals 
signal instruction_in Instruction;
signal val_a : std_logic_vector(31 downto 0);
signal val_b : std_logic_vector(31 downto 0);
signal imm_sign_extended : std_logic_vector(31 downto 0);
signal PC : integer;

CONSTANT clk_period : time := 1 ns; --TODO: figure out how long we wait here for...
signal val_a_int, val_b_int, immediate_int : integer;
begin
    -- val_a <= std_logic_vector(to_unsigned(val_a_int,32));
    --TODO: figure out: maybe don't need the clock process?
    -- clk_process : PROCESS
    -- BEGIN
    --     clock <= '0';
    --     WAIT FOR clk_period/2;
    --     clock <= '1';
    --     WAIT FOR clk_period/2;
    -- END PROCESS;
    --TODO: think carefully about two's complement and the format of values.

    exAlu: EXECUTE port map (clock, instruction_in, val_a, val_b, imm_sign_extended, PC, instruction_out, branch, ALU_Result);
    test_process : PROCESS(clock)
    BEGIN
        -- Add
        -- instruction_in <= x"014B4820"; --add t1 t2 t3
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, 0, ADD_FN);
        val_a <= std_logic_vector(to_signed(10,32)); -- x"0000000A"; --10
        val_b <= std_logic_vector(to_signed(171,32)); -- x"000000AB"; --171
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period; 
        ASSERT (to_integer(signed(ALU_Result)) = 181) REPORT "ADD: ALU_Result should = 181, but wasn't." SEVERITY ERROR;

        -- Addi
        instruction_in <= makeInstruction(ADDI_OP, 1, 2, 12); --addi t1 t2 10
        val_a <= std_logic_vector(to_signed(10,32));
        val_b <= x"00000000"; --0
        imm_sign_extended <= std_logic_vector(to_signed(12,32));; 
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 22) REPORT "ADDI: ALU_Result should = 22, but wasn't." SEVERITY ERROR;

        -- LOAD_WORD -TODO
        instruction_in <= x"2149FFFF"; --lw 
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= 50;
        WAIT FOR clk_period;

        -- STORE_WORD -TODO
        instruction_in <= x"2149FFFF"; --sw 
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= 50;
        WAIT FOR clk_period;

        -- BRANCH_IF_EQUAL
        instruction_in <= makeInstruction(BEQ_OP, 1, 2, 40); --beq t1,t2,0x0000
        val_a <= x"0000000A";
        val_b <= x"0000000A"; --0
        imm_sign_extended <= std_logic_vector(to_signed(40,32)); --full
        PC <= 20;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 60) REPORT "BEQ: ALU_Result should = 50, but wasn't." SEVERITY ERROR;

        -- BRANCH_IF_NOT_EQUAL
        instruction_in <= makeInstruction(BNE_OP, 1, 2, 40); --beq t1,t2,0x0000
        val_a <= x"0000000A";
        val_b <= x"0000000A"; --0
        imm_sign_extended <= std_logic_vector(to_signed(40,32)); --full
        PC <= 20;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 60) REPORT "BNE: ALU_Result should = 60, but wasn't." SEVERITY ERROR;

   
        -- SUBTRACT
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, SUB_FN); -- x"014B4822"; --sub t1, t2, t3
        val_a <= std_logic_vector(to_signed(500,32)); --500
        val_b <= std_logic_vector(to_signed(300,32)); --300
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 200) REPORT "SUB: ALU_Result should = 200, but wasn't." SEVERITY ERROR;

        -- MULTIPLY
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, MULT_FN); 
        val_a <= std_logic_vector(to_signed(20,32)); --20
        val_b <= std_logic_vector(to_signed(30,32)); --30
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 600) REPORT "MULT: ALU_Result should = 600, but wasn't." SEVERITY ERROR;

        -- DIVIDE 
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, DIV_FN);
        val_a <= std_logic_vector(to_signed(60,32)); --60
        val_b <= std_logic_vector(to_signed(30,32)); --30
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 2) REPORT "DIV: ALU_Result should = 2, but wasn't." SEVERITY ERROR;


        -- SET_LESS_THAN
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, SLT_FN); --x"014B482A"; --slt t1 t2 t3
        val_a <= std_logic_vector(to_signed(20,32)); --20
        val_b <= std_logic_vector(to_signed(10,32)); --10
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 1) REPORT "SLT: ALU_Result should = 1, but wasn't." SEVERITY ERROR;


        -- SET_LESS_THAN_IMMEDIATE
        instruction_in <= makeInstruction(SLTI_OP, 1, 2, 10); --slti t1 t2 0xFFFF
        val_a <= std_logic_vector(to_signed(20,32)); --20
        val_b <= x"00000000"; --0
        imm_sign_extended <= std_logic_vector(to_signed(10,32)); --10 (as per instruction)
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (to_integer(signed(ALU_Result)) = 1) REPORT "SLTI: ALU_Result should = 1, but wasn't." SEVERITY ERROR;


        -- BITWISE_AND
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, AND_FN); --and t1 t2 t3
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000000A") REPORT "AND: ALU_Result should = 0x0000000A, but wasn't." SEVERITY ERROR;

        -- BITWISE_AND_IMMEDIATE 
        instruction_in <= makeInstruction(ANDI_OP, 1, 2, to_integer(unsigned("0000000B"))); --andi t1, t2, 0xB
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"0000000B"; --0xB
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000000A") REPORT "ANDI: ALU_Result should = 0x0000000A, but wasn't." SEVERITY ERROR;

        -- BITWISE_OR
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, OR_FN); --or t1, t2, t3
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000000B") REPORT "OR: ALU_Result should = 0x0000000B, but wasn't." SEVERITY ERROR;

        -- BITWISE_OR_IMMEDIATE
        instruction_in <= makeInstruction(ORI_OP, 1, 2, to_integer(unsigned("0000000B"))); --ori t1 t2 0xB
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"0000000B"; --0xB
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"FFFFFFFF") REPORT "ORI: ALU_Result should = 0x0000000B, but wasn't... " SEVERITY ERROR;

        -- BITWISE_NOR
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, NOR_FN); --nor t1 t2 t3
        val_a <= x"0000000F"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"00000000"; --0
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"FFFFFFF0") REPORT "NOR: ALU_Result should = 0xFFFFFFF0, but wasn't." SEVERITY ERROR;

        -- BITWISE_XOR
        instruction_in <= makeInstruction(ALU_OP, 1, 2, 3, XOR_FN); --xor t1 t2 t3
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"00000000"; --full
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00000006") REPORT "XOR: ALU_Result should = 0x00000006, but wasn't... " SEVERITY ERROR;   

        -- BITWISE_XOR_IMMEDIATE
        instruction_in <= makeInstruction(XORI, 1, 2, to_integer(unsigned("0000000B"))); --xori t1 t2 0xB
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"0000000B"; --0xB
        PC <= 50;
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00000006") REPORT "XORI: ALU_Result should = 0x00000006, but wasn't... " SEVERITY ERROR;   

        -- MOVE_FROM_HI --TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- MOVE_FROM_LOW --TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- LOAD_UPPER_IMMEDIATE --TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- SHIFT_LEFT_LOGICAL --TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- SHIFT_RIGHT_LOGICAL --TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- SHIFT_RIGHT_ARITHMETIC --TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- JUMP --TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- JUMP_AND_LINK --TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- JUMP_TO_REGISTER --TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        wait;
    END PROCESS;
END;