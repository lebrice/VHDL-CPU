library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;

entity fetchStage is
  GENERIC(
		ram_size : INTEGER := 8192;
		bit_width : INTEGER := 32
	);
  port (
    clock : in std_logic;
    reset : in std_logic;
    branch_target : in integer;
    branch_condition : in std_logic;
    stall : in std_logic;
    instruction : out Instruction;
    PC : out integer;

    m_addr : out integer range 0 to ram_size-1;
    m_read : out std_logic;
    m_readdata : in std_logic_vector (bit_width-1 downto 0);
    -- m_write : out std_logic; (fetch doesn't write to memory)
    -- m_writedata : out std_logic_vector (bit_width-1 downto 0); (fetch doesn't write to memory)
    m_waitrequest : in std_logic -- unused until the Avalon Interface is added.

  ) ;
end fetchStage;

architecture fetchStage_arch of fetchStage is
signal PC_next : integer;
signal PC_register : integer := 0;
begin 

PC <= PC_register;

PC_next <= 
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