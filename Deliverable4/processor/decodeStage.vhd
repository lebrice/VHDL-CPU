library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decodeStage is
  port (
    clock : in std_logic;
    PCPlus4In : in std_logic_vector(3 downto 0);
    writeData : in std_logic_vector(31 downto 0);
    writeRegister : in std_logic_vector(31 downto 0);
    instructionIn : in std_logic_vector(31 downto 0);
    valA : out std_logic_vector(31 downto 0);
    valB : out std_logic_vector(31 downto 0);
    iSignExtended : out std_logic_vector(31 downto 0);
    PCPlus4Out : out std_logic_vector(3 downto 0);
    instructionOut : out std_logic_vector(31 downto 0)
    
  ) ;
end decodeStage ;

architecture decodeStage_arch of decodeStage is



begin



end architecture ; -- arch