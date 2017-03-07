library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;

entity fetchStage is
  port (
    clock : in std_logic;
    reset : in std_logic;
    branch_target : in integer;
    branch_condition : in std_logic;
    stall : in std_logic;
    instruction : out Instruction;
    PC : out integer
  ) ;
end fetchStage;

architecture fetchStage_arch of fetchStage is


begin



end architecture ; -- arch