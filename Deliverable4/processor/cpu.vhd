library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- opcode tool library
use work.INSTRUCTION_TOOLS.all;

use work.REGISTERS.all;
--entity declaration
entity CPU is
  port (
    clock : in std_logic
  );
end CPU ;


architecture CPU_arch of CPU is
  constant ram_size : integer := 8196;
  constant bit_width : integer := 32;
   COMPONENT fetchStage IS
        generic(
            bit_width : integer := bit_width;
            ram_size : integer := ram_size
        );
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
            -- TODO: Figure out why there's an error here (Won't compile!)
            register_file_out : out REGISTER_BLOCK;
            write_register_file : in std_logic;
            reset_register_file : in std_logic;

            -- might have to add this in at some point:
            stall_in : in std_logic;

            -- Stall signal out.
            stall_out : out std_logic
            
        ) ;
    END COMPONENT;
    COMPONENT decodeExecuteReg IS
        PORT (
            clock: IN STD_LOGIC;
            pc_in: IN INTEGER;
            pc_out: OUT INTEGER;
            instruction_in: IN INSTRUCTION;
            instruction_out: OUT INSTRUCTION;
            sign_extend_imm_in: IN INTEGER;
            sign_extend_imm_out: OUT INTEGER;
            a_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            a_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            b_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            b_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT executeStage IS
        port(instruction_in : in Instruction;
            val_a : in std_logic_vector(31 downto 0);
            val_b : in std_logic_vector(31 downto 0);
            imm_sign_extended : in std_logic_vector(31 downto 0);
            PC : in integer; 
            instruction_out : out Instruction;
            branch : out std_logic;
            ALU_Result : out std_logic_vector(31 downto 0)
    );
    END COMPONENT;
    COMPONENT executeMemoryReg IS
        PORT (
            clock: IN STD_LOGIC;
            pc_in: IN INTEGER;
            pc_out: OUT INTEGER;
            instruction_in: IN INSTRUCTION;
            instruction_out: OUT INSTRUCTION;
            does_branch_in: IN STD_LOGIC;
            does_branch_out: OUT STD_LOGIC;
            alu_result_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            alu_result_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            b_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            b_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        ); 
    END COMPONENT;
    COMPONENT memoryStage IS
        PORT (
            clock : in std_logic;
            ALU_result_in : in std_logic_vector(31 downto 0);
            ALU_result_out : out std_logic_vector(31 downto 0);
            instruction_in : in INSTRUCTION;
            instruction_out : out INSTRUCTION;
            branch_taken_in : in  std_logic;
            branch_taken_out : out  std_logic;
            val_b : in std_logic_vector(31 downto 0);
            mem_data : out std_logic_vector(31 downto 0);

            m_addr : out integer range 0 to ram_size-1;
            m_read : out std_logic;
            m_readdata : in std_logic_vector (bit_width-1 downto 0);        
            m_writedata : out std_logic_vector (bit_width-1 downto 0);
            m_write : out std_logic;
            m_waitrequest : in std_logic -- Unused until the Avalon Interface is added.
        );
    END COMPONENT;
    COMPONENT memoryWritebackReg IS
        PORT (
            clock: IN STD_LOGIC;
            pc_in: IN INTEGER;
            pc_out: OUT INTEGER;
            instruction_in: IN INSTRUCTION;
            instruction_out: OUT INSTRUCTION;
            alu_result_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            alu_result_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_mem_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_mem_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT memory IS
        GENERIC(
          ram_size : INTEGER := ram_size;
		      bit_width : INTEGER := bit_width;
		      mem_delay : time := 0.1 ns
        );
        PORT (
            clock: IN STD_LOGIC;
            writedata: IN STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
            address: IN INTEGER RANGE 0 TO ram_size-1;
            memwrite: IN STD_LOGIC := '0';
            memread: IN STD_LOGIC := '0';
            readdata: OUT STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
            waitrequest: OUT STD_LOGIC
        );
    END COMPONENT;
begin

end architecture;