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
signal PC_next : integer;
signal PC_register : integer;
begin 
PC <= PC_register;

PC_next <= 
  4             when reset = '1' else
  branch_target when branch_condition = '1' else
  PC_register   when stall = '1' else 
  PC_register + 4;



pc_process : process( clock, reset )
begin
  if( reset = '1' ) then
    PC_register <= 0;
  elsif( rising_edge(clock) ) then
    PC_register <= PC_next;
  end if ;
end process ; -- pc_process


end architecture ; -- arch