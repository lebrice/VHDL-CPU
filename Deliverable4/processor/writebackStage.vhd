library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity writebackStage is
  port (
    clock : in std_logic;
    memDataIn : in std_logic_vector(31 downto 0);
    ALU_ResultIn : in std_logic_vector(31 downto 0);
    instructionIn : in std_logic_vector(31 downto 0);
    writeData : out std_logic_vector(31 downto 0);
    writeRegister : out integer std_logic_vector(31 downto 0);
    instructionOut : out std_logic_vector(31 downto 0);
  ) ;
end writebackStage ;

architecture writebackStage_arch of writebackStage is



begin



end architecture ; -- arch