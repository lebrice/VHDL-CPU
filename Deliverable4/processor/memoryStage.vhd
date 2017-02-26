library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memoryStage is
  port (
    clock : in std_logic;
    ALU_ResultIn : in std_logic_vector(25 downto 0);
    valB : in ;
    instructionIn : in std_logic_vector(31 downto 0);
    mem_data : out std_logic_vector(31 downto 0);
    ALU_ResultOut : out std_logic_vector(31 downto 0);
    instructionOut : out std_logic_vector(31 downto 0);
  ) ;
end memoryStage ;

architecture memoryStage_arch of memoryStage is



begin



end architecture ; -- arch