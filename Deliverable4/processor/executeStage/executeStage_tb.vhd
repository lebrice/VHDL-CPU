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
begin
    
    --TODO: figure out: maybe don't need the clock process?
    -- clk_process : PROCESS
    -- BEGIN
    --     clock <= '0';
    --     WAIT FOR clk_period/2;
    --     clock <= '1';
    --     WAIT FOR clk_period/2;
    -- END PROCESS;

    exAlu: EXECUTE port map (clock, instruction_in, val_a, val_b, imm_sign_extended, PC, instruction_out, branch, ALU_Result);
    test_process : PROCESS(clock)
    BEGIN
        -- Add
        instruction_in <= x"014B4820"; --add t1 t2 t3
        val_a <= x"0000000A"; --10
        val_b <= x"000000AB"; --171
        imm_sign_extended <= x"00000000"; --0
        PC <= "50";
        WAIT FOR clk_period; 
        ASSERT (ALU_Result = x"000000b5") REPORT "ALU_Result should = 0xb5, but wasn't... " SEVERITY ERROR;

        -- Addi
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00010009") REPORT "ALU_Result should = 0x10009, but wasn't... " SEVERITY ERROR;

        -- LOAD_WORD -TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- STORE_WORD -TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- BRANCH_IF_EQUAL
        instruction_in <= x"112A0000"; --beq t1,t2,0x0000
        val_a <= x"0000000A"; --10
        val_b <= x"0000000A"; --0
        imm_sign_extended <= x"00000000"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000003C") REPORT "ALU_Result should = 0x0000003C, but wasn't... " SEVERITY ERROR;

        -- BRANCH_IF_NOT_EQUAL
        instruction_in <= x"152A0000"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"0000000A"; --0
        imm_sign_extended <= x"00000000"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000003C") REPORT "ALU_Result should = 0x0000003C, but wasn't... " SEVERITY ERROR;
   
        -- SUBTRACT
        instruction_in <= x"014B4822"; --addi t1 t2 FFFF
        val_a <= x"000000AA"; --10
        val_b <= x"00000099"; --0
        imm_sign_extended <= x"00000000"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00000022") REPORT "ALU_Result should = 0x0000003C, but wasn't... " SEVERITY ERROR;

        -- MULTIPLY -TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- DIVIDE -TODO
        instruction_in <= x"2149FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;

        -- SET_LESS_THAN
        instruction_in <= x"014B482A"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00000001") REPORT "ALU_Result should = 0x00000001, but wasn't... " SEVERITY ERROR;


        -- SET_LESS_THAN_IMMEDIATE
        instruction_in <= x"29490000"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00000001") REPORT "ALU_Result should = 0x00000001, but wasn't... " SEVERITY ERROR;


        -- BITWISE_AND
        instruction_in <= x"014B4824"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000000A") REPORT "ALU_Result should = 0x0000000A, but wasn't... " SEVERITY ERROR;

        -- BITWISE_AND_IMMEDIATE 
        instruction_in <= x"3149FFFF"; --andi t1, t2, 0xffff
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000000A") REPORT "ALU_Result should = 0x0000000A, but wasn't... " SEVERITY ERROR;

        -- BITWISE_OR
        instruction_in <= x"014B4825"; --or t1, t2, t3
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"0000000B") REPORT "ALU_Result should = 0x0000000B, but wasn't... " SEVERITY ERROR;

        -- BITWISE_OR_IMMEDIATE
        instruction_in <= x"3549FFFF"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"FFFFFFFF") REPORT "ALU_Result should = 0xFFFFFFFF, but wasn't... " SEVERITY ERROR;

        -- BITWISE_NOR
        instruction_in <= x"014B4827"; --addi t1 t2 FFFF
        val_a <= x"0000000F"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"FFFFFFF0") REPORT "ALU_Result should = 0xFFFFFFF0, but wasn't... " SEVERITY ERROR;

        -- BITWISE_XOR
        instruction_in <= x"014B4826"; --addi t1 t2 FFFF
        val_a <= x"0000000A"; --10
        val_b <= x"0000000B"; --0
        imm_sign_extended <= x"FFFFFFFF"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00000006") REPORT "ALU_Result should = 0x00000006, but wasn't... " SEVERITY ERROR;   

        -- BITWISE_XOR_IMMEDIATE
        instruction_in <= x"3949000A"; --addi t1 t2 FFFF
        val_a <= x"0000000B"; --10
        val_b <= x"00000000"; --0
        imm_sign_extended <= x"0000000A"; --full
        PC <= "50";
        WAIT FOR clk_period;
        ASSERT (ALU_Result = x"00000006") REPORT "ALU_Result should = 0x00000006, but wasn't... " SEVERITY ERROR;   

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