library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;

entity executeStage is
  port (
    clock : in std_logic;
    instructionIn : in Instruction;
    valA : in std_logic_vector(31 downto 0);
    valB : in std_logic_vector(31 downto 0);
    iSignExtended : in std_logic_vector(31 downto 0);
    PCPlus4In : in std_logic_vector(3 downto 0);
    instructionOut : out Instruction;
    branch : std_logic;
    ALU_Result : std_logic_vector(31 downto 0)
  ) ;
end executeStage ;

architecture executeStage_arch of executeStage is
  COMPONENT ALU
  port (
    clock : in std_logic;
    instruction : in INSTRUCTION;
    op_a : in std_logic_vector(31 downto 0); -- RS
    op_b : in std_logic_vector(31 downto 0); -- RT
    ALU_out : out std_logic_vector(63 downto 0); -- RD
    BranchCondition : out std_logic
  );
  END COMPONENT;
  
begin
  --define alu component
  exAlu: ALU port map (clock, instructionIn, , , ALU_Result, branch);


  --here's what we need to do:
  --1) decide between Val from memory and PC+4
  --2) decide between Val from memory and SE
  --3) set 1) and 2) to op_a, op_b for the ALU
  


end architecture ; -- arch