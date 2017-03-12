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
begin
    
    --TODO: figure out: maybe don't need the clock process?
    clk_process : PROCESS
    BEGIN
        clock <= '0';
        WAIT FOR clk_period/2;
        clock <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    exAlu: EXECUTE port map (clock, instruction_in, val_a, val_b, imm_sign_extended, PC, instruction_out, branch, ALU_Result);
    test_process : PROCESS(clock)
    BEGIN
        
    wait;
    END PROCESS;
END;