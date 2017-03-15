library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- opcode tool library
use work.INSTRUCTION_TOOLS.all;


--entity declaration
entity CPU is
  port (
    clock : in std_logic
  );
end CPU ;


architecture CPU_arch of ALU is
   COMPONENT fetchStage IS
        PORT (
            clock : in std_logic;
            reset : in std_logic;
            branch_target : in integer;
            branch_condition : in std_logic;
            stall : in std_logic;
            instruction_out : out Instruction;
            PC : out integer;
            m_addr : out integer;
            m_read : out std_logic;
            m_readdata : in std_logic_vector (bit_width-1 downto 0);
            -- m_write : out std_logic;
            -- m_writedata : out std_logic_vector (bit_width-1 downto 0);
            m_waitrequest : in std_logic -- unused until the Avalon Interface is added.
        );
    END COMPONENT;
    
    
begin

end architecture;