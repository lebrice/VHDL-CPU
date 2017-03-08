LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mem is
    port (
        clock : in std_logic;
        ALU_ResultIn : in std_logic_vector(31 downto 0);
        ALU_ResultOut : out std_logic_vector(31 downto 0);
        instructionIn : in std_logic_vector(31 downto 0);
        instructionOut : out std_logic_vector(31 downto 0);
        branchTakenIn : in  std_logic;
        branchTakenOut : out  std_logic;
        valB : in std_logic_vector(31 downto 0);
        mem_data : out std_logic_vector(31 downto 0)
    );
END mem;

ARCHITECTURE memArch OF mem IS
BEGIN

    mem_process : PROCESS ()
    BEGIN
        IF(instructionIn is branch and branchTakenIn == '1') THEN
            branchTakenOut = '1';
        ELSIF(instructionIn is load) THEN
            mem_data <= DATACACHE[ALU_ResultIn];
        ELSIF(instructionIn is store) THEN
            DATACACHE[ALU_ResultIn] <= valB;
        END IF;

        instructionOut <= instructionIn;
        ALU_ResultOut <= ALU_ResultIn;

    END PROCESS;

END memArch;