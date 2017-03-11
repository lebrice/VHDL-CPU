LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.INSTRUCTION_TOOLS.all;
USE work.registers.all;

ENTITY decode_tb IS
END decode_tb;

architecture behaviour of decode_tb is

    constant clock_period : time := 1 ns;

    component decodeStage is
        port (
            clock : in std_logic;

            -- Inputs coming from the IF/ID Register
            PC : in integer;
            instruction_in : in INSTRUCTION;


            -- Instruction and data coming from the Write-Back stage.
            write_back_instruction : in INSTRUCTION;
            write_back_data : in std_logic_vector(31 downto 0);


            -- Outputs to the ID/EX Register
            val_a : out std_logic_vector(31 downto 0);
            val_b : out std_logic_vector(31 downto 0);
            i_sign_extended : out std_logic_vector(31 downto 0);
            PC_out : out integer;
            instruction_out : out INSTRUCTION;

            -- Register file
            register_file : in REGISTER_BLOCK;

            -- Stall signal out.
            stall_out : out std_logic
            
        );
    end component;

signal clock : std_logic;
signal PC : integer;
signal instruction_in : INSTRUCTION;
signal write_back_instruction : INSTRUCTION;
signal write_back_data : std_logic_vector(31 downto 0);
signal val_a : std_logic_vector(31 downto 0);
signal val_b : std_logic_vector(31 downto 0);
signal i_sign_extended : std_logic_vector(31 downto 0);
signal PC_out : integer;
signal instruction_out : INSTRUCTION;
signal register_file : REGISTER_BLOCK;
signal stall_out : std_logic;

signal val_a_int : integer;
signal val_b_int : integer;

signal write_back_data_int : integer;

constant no_op : INSTRUCTION := makeInstruction(ALU_OP, 0,0,0,0, ADD_FN);
begin

    val_a_int <= to_integer(unsigned(val_a));
    val_b_int <= to_integer(unsigned(val_b));
    write_back_data <= std_logic_vector(to_unsigned(write_back_data_int, 32));

    dec : decodeStage port map (
        clock,
        PC,
        instruction_in,
        write_back_instruction,
        write_back_data,
        val_a,val_b,
        i_sign_extended,
        PC_out,
        instruction_out,
        register_file,
        stall_out
    );

    clk_process : process
    BEGIN
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;

    test_process : process
    variable registers : register_block;
    begin
        -- TODO: figure out if the return value really needs to be used or not.
        registers := reset_register_block(registers);

        for I in 0 to NUM_REGISTERS-1 loop
            -- Each register contains the integer value of 10 times their index. (i.e. R1 = 10, R17 = 170, etc.)
            registers(I).data := std_logic_vector(to_unsigned(I * 10, 32));
            registers(I).busy := '0';
        end loop;
        write_back_instruction <= no_op;
        PC <= 0;

        instruction_in <= makeInstruction(ALU_OP, 1,2,3,0, ADD_FN); -- ADD R1 R2 R3
        assert val_a_int = 10 report "Value A should be 10, but we have " & integer'image(val_a_int) severity error;
        assert val_b_int = 20 report "Value B should be 20, but we have " & integer'image(val_b_int) severity error;
        assert registers(3).busy = '1' report "Register R3 should be busy, since the result of the addition is going into it." severity error;
        assert stall_out = '0' report "Stall_Out should definitely NOT be '0' right here." severity error;
        assert instruction_out.format = R_TYPE report "The output instruction does not have the right format! (Should have R Type)" severity error;
        assert instruction_out.instruction_type = ADD report "The output instruction does NOT have the right type (expecting Add)" severity error;
        assert instruction_out.rs = 1 report "Instruction RS is wrong! (got " & integer'image(instruction_out.rs) & ", was expecting 1" severity error;
        assert instruction_out.rt = 2 report "Instruction RT is wrong! (got " & integer'image(instruction_out.rt) & ", was expecting 2" severity error;
        assert instruction_out.rd = 3 report "Instruction RD is wrong! (got " & integer'image(instruction_out.rd) & ", was expecting 3" severity error;
        assert instruction_out.shamt = 0 report "Instruction shift amount should be 0." severity error;

        wait for clock_period;    

        instruction_in <= no_op;
        assert registers(3).busy = '1' report "Register R3 should still be busy, since we haven't received the Write-Back instruction writing its result." severity error;
        
        wait for clock_period;

        -- simulate the data coming back from the Write-Back stage, and check that it is written correctly.
        write_back_instruction <= makeInstruction(ALU_OP, 1,2,3,0, ADD_FN); -- the "same" instruction comes back from WB
        write_back_data_int <= 30; -- result of 10 + 20.

        assert registers(3).data = std_logic_vector(to_unsigned(30, 32)) report "The result (30) should have been written back!" severity error;
        assert registers(3).busy = '0' report "$R3 should not be busy, since we just wrote the result back in from WB." severity error;

        wait for clock_period;

        write_back_instruction <= no_op;
        instruction_in <= makeInstruction(ALU_OP, 10,15,25,0, ADD_FN); -- ADD $R10, $R15, $R25.
        
        wait for clock_period;
        assert registers(25).busy = '1' report "Last cycle, we started an operation using $R25, it should be busy!" severity error;
        -- this instruction would use $R25, but since it's busy, we would expect a STALL_OUT to arise.
        instruction_in <= makeInstruction(ALU_OP, 20, 25, 10, 0, ADD_FN); -- ADD $R20, $R25, $R10 
        assert stall_out = '1' report "Stall_out should be '1', since there's a data dependency, and the instruction hasn't come back from WB yet." severity error;

        wait for clock_period;
        -- the instruction came back from the WB stage.
        write_back_instruction <= makeInstruction(ALU_OP, 10,15,25,0, ADD_FN); -- ADD $R10, $R15, $R25.
        write_back_data_int <= 250;
        assert stall_out = '0' report "The Instruction coming back from WB should de-assert Stall_out" severity error;
        assert registers(25).busy = '0' report "Register should be marked with 'busy'='0' after the instruction comes back from WB." severity error;
        assert registers(25).data = write_back_data;

        report "Done testing decode stage." severity NOTE;
        wait;

    end process;


end behaviour;