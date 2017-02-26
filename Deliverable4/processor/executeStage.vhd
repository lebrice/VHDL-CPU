library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity executeStage is
  port (
    clock : in std_logic;
    instructionIn : in std_logic_vector(31 downto 0);
    valA : in ;
    valB : in ;
    iSignExtended : in ;
    PCPlus4In : in ;
    instructionOut : out std_logic_vector(31 downto 0);
    branch : std_logic;
    ALU_Result : std_logic_vector(25 downto 0);
  ) ;
end executeStage ;

architecture executeStage_arch of executeStage is



begin



end architecture ; -- arch