LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

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

    mem_process : PROCESS ()
    BEGIN
        IF(instruction_in is branch and branch_taken_in == '1') THEN
            branch_taken_out = '1';
        ELSIF(instruction_in is load) THEN
            mem_data <= DATACACHE[ALU_result_in];
        ELSIF(instruction_in is store) THEN
            DATACACHE[ALU_result_in] <= valB;
        END IF;

        instresult_iut <= instruction_in;
        ALU_result_out <= ALU_result_in;_i
    END PROCESS;
END ARCHITECTURE;