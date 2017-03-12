LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY mem is
    port (
        clock : in std_logic;
        ALU_result_in : in std_logic_vector(31 downto 0);
        ALU_result_out : out std_logic_vector(31 downto 0);
        instruction_in : in std_logic_vector(31 downto 0);
        instruction_out : out std_logic_vector(31 downto 0);
        branch_taken_in : in  std_logic;
        branch_taken_out : out  std_logic;
        val_b : in std_logic_vector(31 downto 0);
        mem_data : out std_logic_vector(31 downto 0)
    );
END mem;

ARCHITECTURE memArch OF mem IS
BEGIN

    mem_process : process(clock)
    BEGIN
        CASE instruction_in.INSTRUCTION_TYPE IS
            WHEN branch_if_equal | branch_if_not_equal =>
                IF(branch_taken_in = '1') THEN
                    branch_taken_out <= '1';
                END IF;
            WHEN load_word =>
                mem_data <= DATACACHE[ALU_result_in]; --TODO: Call memory correctly
            WHEN store_word =>
                DATACACHE[ALU_result_in] <= valB; --TODO: Call memory correctly
        END CASE;
        instruction_out <= instruction_in;
        ALU_result_out <= ALU_result_in;
    END PROCESS;
END ARCHITECTURE;