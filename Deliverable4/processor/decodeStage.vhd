library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decodeStage is
  port (
    clock : in std_logic;
    PCPlus4In : in std_logic_vector(3 downto 0);
    writeData : in std_logic_vector(31 downto 0);
    writeRegister : in integer range 0 to 31;
    instructionIn : in std_logic_vector(31 downto 0);
    valA : out ;
    valB : out;
    iSignExtended : out ;
    PCPlus4Out : out;
    instructionOut : out std_logic_vector(31 downto 0);
    
  ) ;
end decodeStage ;

architecture decodeStage_arch of decodeStage is



begin



end architecture ; -- arch