library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity executeStage is
  port (
    clock : in std_logic;
    instructionIn : in std_logic_vector(31 downto 0);
    valA : in std_logic_vector(31 downto 0);
    valB : in std_logic_vector(31 downto 0);
    iSignExtended : in std_logic_vector(31 downto 0);
    PCPlus4In : in std_logic_vector(3 downto 0);
    instructionOut : out std_logic_vector(31 downto 0);
    branch : std_logic;
    ALU_Result : std_logic_vector(31 downto 0);
  ) ;
end executeStage ;

architecture executeStage_arch of executeStage is



begin



end architecture ; -- arch