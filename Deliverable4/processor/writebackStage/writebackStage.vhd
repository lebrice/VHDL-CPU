library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.instruction_tools.all;

-- writeback stage is essentially just a MUX
entity writebackStage is
  port (
    mem_data_in : in std_logic_vector(31 downto 0);
    ALU_result_in : in std_logic_vector(63 downto 0);
    instruction_in : in instruction;
    write_data : out std_logic_vector(63 downto 0); 
    instruction_out : out instruction
  ) ;
end writebackStage ;

architecture writebackStage_arch of writebackStage is
begin
  instruction_out <= instruction_in;

  write_data <= 
    X"00000000" & mem_data_in when instruction_in.instruction_type = LOAD_WORD else
    ALU_result_in;
end architecture ; 