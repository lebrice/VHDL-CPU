library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetchStage is
  port (
    clock : in std_logic;
    branchTarget : in std_logic_vector(31 downto 0);
    branch : in std_logic;
    disableAdder : in std_logic;
    instruction : out std_logic_vector(31 downto 0);
    PCPlus4 : out std_logic_vector(3 downto 0)
  ) ;
end fetchStage;

architecture fetchStage_arch of fetchStage is


begin



end architecture ; -- arch