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
    COMPONENT fetchDecodeReg IS
        PORT (
            instruction_in : in Instruction;
            PC_in : in integer;            
            instruction_out : out Instruction;
            PC_out : out integer
        );
    END COMPONENT;
    COMPONENT decodeStage IS
        port (
            clock : in std_logic;

            -- Inputs coming from the IF/ID Register
            PC : in integer;
            instruction_in : in INSTRUCTION;


            -- Instruction and data coming from the Write-Back stage.
            write_back_instruction : in INSTRUCTION;
            write_back_data : in std_logic_vector(63 downto 0);


            -- Outputs to the ID/EX Register
            val_a : out std_logic_vector(31 downto 0);
            val_b : out std_logic_vector(31 downto 0);
            i_sign_extended : out std_logic_vector(31 downto 0);
            PC_out : out integer;
            instruction_out : out INSTRUCTION;

            -- Register file
            register_file_out : out REGISTER_BLOCK;
            write_register_file : in std_logic;
            reset_register_file : in std_logic;

            -- might have to add this in at some point:
            stall_in : in std_logic;

            -- Stall signal out.
            stall_out : out std_logic
            
        ) ;
    END COMPONENT;
begin

end architecture;