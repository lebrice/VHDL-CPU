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
    instruction_out : out INSTRUCTION;
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
signal PC_next : integer := 4;
signal PC_register : integer := 0;
begin 

PC <= PC_register;

PC_next <= 
  branch_target when branch_condition = '1' else
  PC_register   when stall = '1' else 
  PC_register + 4;

--   m_read <= '1';
--   m_addr <= PC_register;
-- -- inst := getInstruction(m_readdata);
--   instruction_out <= getInstruction(m_readdata);

report_stall : process( clock, stall )
begin
  if stall = '1' then
    report "FETCH IS STALLED";
  end if;
end process ; -- report_stall


mem_process : process(clock, m_waitrequest)
variable inst : INSTRUCTION;
begin
  -- TODO: add the proper timing and avalon interface stuff later.
  
  
  if reset = '1' then
    report "reset is '1', we are outputting a no-op.";
    instruction_out <= NO_OP_INSTRUCTION;
  else
    report " reading instruction from PC address of " & integer'image(PC_register);
    m_read <= '1';
    m_addr <= PC_register / 4;
    inst := getInstruction(m_readdata);
    instruction_out <= inst;
  end if;
end process;

pc_process : process( clock, reset )
begin
  if( reset = '1' ) then
    PC_register <= 0;
  elsif( rising_edge(clock) ) then
    PC_register <= PC_next;
  end if ;
end process ; -- pc_process

end architecture ; -- arch