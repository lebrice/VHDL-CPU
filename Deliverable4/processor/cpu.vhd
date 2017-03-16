library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- opcode tool library
use work.INSTRUCTION_TOOLS.all;

use work.REGISTERS.all;
--entity declaration
entity CPU is
    generic(
        ram_size : integer := 8196;
        bit_width : integer := 32
    );
  port (
    clock : in std_logic;
    initialize : in std_logic; -- signals to load Instruciton and Data Memories. Should be held at '1' for at least a few clock cycles.
    dump : in std_logic -- similar to above but for dump instead of load.
  );
end CPU ;


architecture CPU_arch of CPU is
    --Fetch
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
            -- m_write_data : out std_logic_vector (bit_width-1 downto 0);
            m_waitrequest : in std_logic -- unused until the Avalon Interface is added.
        );
    END COMPONENT;

    --Fetch decode Register
    COMPONENT IF_ID_REGISTER IS
        PORT (
            clock: IN STD_LOGIC;
            pc_in: IN INTEGER;
            pc_out: OUT INTEGER;
            instruction_in: IN INSTRUCTION;
            instruction_out: OUT INSTRUCTION;
            stall: IN STD_LOGIC
        );
    END COMPONENT;

    --Decode
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

    --Decode Execute Register
    COMPONENT ID_EX_Register IS
        PORT (
            clock: IN STD_LOGIC;
            pc_in: IN INTEGER;
            pc_out: OUT INTEGER;
            instruction_in: IN INSTRUCTION;
            instruction_out: OUT INSTRUCTION;
            sign_extend_imm_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            sign_extend_imm_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            a_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            a_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            b_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            b_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    
    --Execute
    COMPONENT executeStage IS
        port(
            instruction_in : in Instruction;
            val_a : in std_logic_vector(31 downto 0);
            val_b : in std_logic_vector(31 downto 0);
            imm_sign_extended : in std_logic_vector(31 downto 0);
            PC : in integer; 
            instruction_out : out Instruction;
            branch : out std_logic;
            ALU_result : out std_logic_vector(63 downto 0);
            branch_target_out : out std_logic_vector(31 downto 0);
            PC_out : out integer
    );
    END COMPONENT;

    --Execute Memory Register
    COMPONENT EX_MEM_REGISTER IS
        PORT (
            clock: IN STD_LOGIC;
            pc_in: IN INTEGER;
            pc_out: OUT INTEGER;
            instruction_in: IN INSTRUCTION;
            instruction_out: OUT INSTRUCTION;
            does_branch_in: IN STD_LOGIC;
            does_branch_out: OUT STD_LOGIC;
            ALU_result_in: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            ALU_result_out: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
            branch_target_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            branch_target_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            b_value_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            b_value_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        ); 
    END COMPONENT;

    --Memory
    COMPONENT memoryStage IS
        PORT (
            ALU_result_in : in std_logic_vector(63 downto 0);
            ALU_result_out : out std_logic_vector(63 downto 0);
            instruction_in : in INSTRUCTION;
            instruction_out : out INSTRUCTION;
            val_b : in std_logic_vector(31 downto 0);
            mem_data : out std_logic_vector(31 downto 0);

            m_addr : out integer range 0 to ram_size-1;
            m_read : out std_logic;
            m_readdata : in std_logic_vector (bit_width-1 downto 0);        
            m_write_data : out std_logic_vector (bit_width-1 downto 0);
            m_write : out std_logic;
            m_waitrequest : in std_logic -- Unused until the Avalon Interface is added.

        );
    END COMPONENT;

    --Memory writeback register
    COMPONENT MEM_WB_REGISTER IS
        PORT (
            clock: IN STD_LOGIC;
            instruction_in: IN INSTRUCTION;
            instruction_out: OUT INSTRUCTION;
            ALU_result_in: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            ALU_result_out: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
            data_mem_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_mem_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    --Writeback
    COMPONENT writebackStage is
        port (
            mem_data_in : in std_logic_vector(31 downto 0);
            ALU_result_in : in std_logic_vector(63 downto 0);
            instruction_in : in instruction;
            write_data : out std_logic_vector(63 downto 0);
            -- writeRegister : out integer range 0 to 31; -- uncomment if you wish to implement register choice here
            instruction_out : out instruction
        );
    end COMPONENT;
    
    --memory component
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
            memwrite: IN STD_LOGIC;
            memread: IN STD_LOGIC;
            readdata: OUT STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
            waitrequest: OUT STD_LOGIC;
            memdump: IN STD_LOGIC;
            memload: IN STD_LOGIC          
        );
    END COMPONENT;
    
    
    -- SIGNALS
    --Fetch
    signal fetch_stage_reset : std_logic;
    signal fetch_stage_branch_target : integer;
    signal fetch_stage_branch_condition : std_logic;
    signal fetch_stage_stall : std_logic;
    signal fetch_stage_instruction_out : Instruction;
    signal fetch_stage_PC : integer;
    signal fetch_stage_m_addr : integer;
    signal fetch_stage_m_read : std_logic;
    signal fetch_stage_m_readdata : std_logic_vector (bit_width-1 downto 0);
    signal fetch_stage_m_waitrequest : std_logic; -- unused until the Avalon Interface is added.
    signal fetch_stage_m_write_data : std_logic_vector(bit_width-1 downto 0); -- unused;
    signal fetch_stage_m_write : std_logic; -- unused;
    
    --Fetch Decode Register
    signal IF_ID_register_pc_in: INTEGER;
    signal IF_ID_register_pc_out:  INTEGER;
    signal IF_ID_register_instruction_in: INSTRUCTION;
    signal IF_ID_register_instruction_out:  INSTRUCTION;
    signal IF_ID_register_stall: STD_LOGIC;

    --Decode
    signal decode_stage_PC : integer;
    signal decode_stage_instruction_in : INSTRUCTION;
    signal decode_stage_write_back_instruction : INSTRUCTION;
    signal decode_stage_write_back_data : std_logic_vector(63 downto 0);
    signal decode_stage_val_a :  std_logic_vector(31 downto 0);
    signal decode_stage_val_b :  std_logic_vector(31 downto 0);
    signal decode_stage_i_sign_extended :  std_logic_vector(31 downto 0);
    signal decode_stage_PC_out :  integer;
    signal decode_stage_instruction_out :  INSTRUCTION;
    signal decode_stage_register_file_out :  REGISTER_BLOCK;
    signal decode_stage_write_register_file : std_logic;
    signal decode_stage_reset_register_file : std_logic;
    signal decode_stage_stall_in : std_logic;
    signal decode_stage_stall_out :  std_logic;

    --Decode Execute Register 
    signal ID_EX_register_pc_in: INTEGER;
    signal ID_EX_register_pc_out:  INTEGER;
    signal ID_EX_register_instruction_in: INSTRUCTION;
    signal ID_EX_register_instruction_out:  INSTRUCTION;
    signal ID_EX_register_sign_extend_imm_in: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ID_EX_register_sign_extend_imm_out:  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ID_EX_register_a_in: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ID_EX_register_a_out:  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ID_EX_register_b_in: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ID_EX_register_b_out:  STD_LOGIC_VECTOR(31 DOWNTO 0);


    --Execute
    signal execute_stage_instruction_in : Instruction;
    signal execute_stage_val_a : std_logic_vector(31 downto 0);
    signal execute_stage_val_b : std_logic_vector(31 downto 0);
    signal execute_stage_imm_sign_extended : std_logic_vector(31 downto 0);
    signal execute_stage_PC : integer; 
    signal execute_stage_instruction_out : Instruction;
    signal execute_stage_branch : std_logic;
    signal execute_stage_ALU_result : std_logic_vector(63 downto 0);
    signal execute_stage_branch_target_out : std_logic_vector(31 downto 0);
    signal execute_stage_PC_out : integer;

    --Execute Memory register
    signal EX_MEM_register_pc_in: INTEGER;
    signal EX_MEM_register_pc_out: INTEGER;
    signal EX_MEM_register_instruction_in: INSTRUCTION;
    signal EX_MEM_register_instruction_out: INSTRUCTION;
    signal EX_MEM_register_does_branch_in: STD_LOGIC;
    signal EX_MEM_register_does_branch_out: STD_LOGIC;
    signal EX_MEM_register_ALU_result_in: STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal EX_MEM_register_ALU_result_out: STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal EX_MEM_register_branch_target_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal EX_MEM_register_branch_target_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal EX_MEM_register_b_value_in: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal EX_MEM_register_b_value_out: STD_LOGIC_VECTOR(31 DOWNTO 0);

    --Memory Stage
    signal memory_stage_ALU_result_in : std_logic_vector(63 downto 0);
    signal memory_stage_ALU_result_out : std_logic_vector(63 downto 0);
    signal memory_stage_instruction_in : INSTRUCTION;
    signal memory_stage_instruction_out : INSTRUCTION;
    signal memory_stage_val_b : std_logic_vector(31 downto 0);
    signal memory_stage_mem_data : std_logic_vector(31 downto 0);
    signal memory_stage_m_addr : integer range 0 to ram_size-1;
    signal memory_stage_m_read : std_logic;
    signal memory_stage_m_readdata : std_logic_vector (bit_width-1 downto 0);        
    signal memory_stage_m_write_data : std_logic_vector (bit_width-1 downto 0);
    signal memory_stage_m_write : std_logic;
    signal memory_stage_m_waitrequest : std_logic; -- Unused until the Avalon Interface is added.


    --Memory Writeback register
    signal MEM_WB_register_instruction_in: INSTRUCTION;
    signal MEM_WB_register_instruction_out: INSTRUCTION;
    signal MEM_WB_register_ALU_result_in: STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal MEM_WB_register_ALU_result_out: STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal MEM_WB_register_data_mem_in: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal MEM_WB_register_data_mem_out: STD_LOGIC_VECTOR(31 DOWNTO 0);

    --Write back
    signal write_back_stage_mem_data_in : std_logic_vector(31 downto 0);
    signal write_back_stage_ALU_result_in : std_logic_vector(63 downto 0);
    signal write_back_stage_instruction_in : instruction;
    signal write_back_stage_write_data : std_logic_vector(63 downto 0);
    signal write_back_stage_instruction_out : instruction;

    --memory
    signal instruction_memory_dump : std_logic := '0';
    signal instruction_memory_load : std_logic := '0';
    signal data_memory_dump : std_logic := '0';
    signal data_memory_load : std_logic := '0';

    --misc
    signal initialized : std_logic := '0';
    signal dumped : std_logic := '0';

begin

    fetch : fetchStage PORT MAP(
        clock,
        fetch_stage_reset,
        fetch_stage_branch_target,
        fetch_stage_branch_condition,
        fetch_stage_stall,
        fetch_stage_instruction_out,
        fetch_stage_PC,
        fetch_stage_m_addr,
        fetch_stage_m_read,
        fetch_stage_m_readdata,
        fetch_stage_m_waitrequest -- unused until the Avalon Interface is added.
    );

    fetch_stage_memory : memory GENERIC MAP(
        ram_size => ram_size,
        bit_width => bit_width
    )
    PORT MAP(
        clock,
        fetch_stage_m_write_data, -- unused in this case;
        fetch_stage_m_addr,
        fetch_stage_m_write, -- unused in this case.
        fetch_stage_m_read,
        fetch_stage_m_readdata,
        fetch_stage_m_waitrequest,
        instruction_memory_dump,
        instruction_memory_load,
        '0'
    );

    IF_ID_reg : IF_ID_REGISTER PORT MAP (
        clock,
        IF_ID_register_pc_in,
        IF_ID_register_pc_out,
        IF_ID_register_instruction_in,
        IF_ID_register_instruction_out,
        IF_ID_register_stall
	);

    decode : decodeStage port map (
        clock,
        decode_stage_PC,
        decode_stage_instruction_in,
        decode_stage_write_back_instruction,
        decode_stage_write_back_data,
        decode_stage_val_a,
        decode_stage_val_b,
        decode_stage_i_sign_extended,
        decode_stage_PC_out,
        decode_stage_instruction_out,
        decode_stage_register_file_out,
        decode_stage_write_register_file,
        decode_stage_reset_register_file,
        decode_stage_stall_in,
        decode_stage_stall_out
    );

    ID_EX_reg : ID_EX_Register PORT MAP (
        clock,
        ID_EX_register_pc_in,
        ID_EX_register_pc_out,
        ID_EX_register_instruction_in,
        ID_EX_register_instruction_out,
        ID_EX_register_sign_extend_imm_in,
        ID_EX_register_sign_extend_imm_out,
        ID_EX_register_a_in,
        ID_EX_register_a_out,
        ID_EX_register_b_in,
        ID_EX_register_b_out
    );

     execute_stage : executeStage PORT MAP (
        execute_stage_instruction_in,
        execute_stage_val_a,
        execute_stage_val_b,
        execute_stage_imm_sign_extended,
        execute_stage_PC, 
        execute_stage_instruction_out,
        execute_stage_branch,
        execute_stage_ALU_result,
        execute_stage_branch_target_out,
        execute_stage_PC_out
    );

    EX_MEM_reg : EX_MEM_REGISTER PORT MAP (
        clock,
        EX_MEM_register_pc_in,
        EX_MEM_register_pc_out,
        EX_MEM_register_instruction_in,
        EX_MEM_register_instruction_out,
        EX_MEM_register_does_branch_in,
        EX_MEM_register_does_branch_out,
        EX_MEM_register_ALU_result_in,
        EX_MEM_register_ALU_result_out,
        EX_MEM_register_branch_target_in,
        EX_MEM_register_branch_target_out,
        EX_MEM_register_b_value_in,
        EX_MEM_register_b_value_out
    );

    memory_stage : memoryStage PORT MAP (
        memory_stage_ALU_result_in,
        memory_stage_ALU_result_out,
        memory_stage_instruction_in,
        memory_stage_instruction_out,
        memory_stage_val_b,
        memory_stage_mem_data,
        memory_stage_m_addr,
        memory_stage_m_read,
        memory_stage_m_readdata,      
        memory_stage_m_write_data,
        memory_stage_m_write,
        memory_stage_m_waitrequest
    );

    memory_stage_memory : memory GENERIC MAP(
        ram_size => ram_size,
        bit_width => bit_width
    )
    PORT MAP(
        clock,
        memory_stage_m_write_data, -- unused in this case;
        memory_stage_m_addr,
        memory_stage_m_write, -- unused in this case.
        memory_stage_m_read,
        memory_stage_m_readdata,
        memory_stage_m_waitrequest,
        data_memory_dump,
        data_memory_load,
        '1'
    );

    MEM_WB_reg : MEM_WB_REGISTER PORT MAP (
        clock,
        MEM_WB_register_instruction_in,
        MEM_WB_register_instruction_out,
        MEM_WB_register_ALU_result_in,
        MEM_WB_register_ALU_result_out,
        MEM_WB_register_data_mem_in,
        MEM_WB_register_data_mem_out
    );

    write_back_stage : writebackStage PORT MAP (
        write_back_stage_mem_data_in,
        write_back_stage_ALU_result_in,
        write_back_stage_instruction_in,
        write_back_stage_write_data,
        write_back_stage_instruction_out
    );

    -- TODO: SIGNAL CONNECTIONS BETWEEN COMPONENTS
    fetch_stage_branch_target <= to_integer(unsigned(EX_MEM_register_ALU_result_out));
    fetch_stage_branch_condition <= EX_MEM_register_does_branch_out;

    IF_ID_register_instruction_in <= fetch_stage_instruction_out;
    IF_ID_register_pc_in <= fetch_stage_PC;
    IF_ID_register_stall <= decode_stage_stall_out;

    decode_stage_PC <= IF_ID_register_pc_out;
    decode_stage_instruction_in <= IF_ID_register_instruction_out;
    decode_stage_write_back_data <= write_back_stage_write_data;
    decode_stage_write_back_instruction <= write_back_stage_instruction_out;

    ID_EX_register_a_in <= decode_stage_val_a;
    ID_EX_register_b_in <= decode_stage_val_b;
    ID_EX_register_instruction_in <= decode_stage_instruction_out;
    ID_EX_register_pc_in <= decode_stage_PC_out;
    ID_EX_register_sign_extend_imm_in <= decode_stage_i_sign_extended;

    execute_stage_PC <= ID_EX_register_pc_out;
    execute_stage_instruction_in <= ID_EX_register_instruction_out;
    execute_stage_val_a <= ID_EX_register_a_out;
    execute_stage_val_b <= ID_EX_register_b_out;
    execute_stage_imm_sign_extended <= ID_EX_register_sign_extend_imm_out;
    
    EX_MEM_register_ALU_result_in <= execute_stage_ALU_result;
    EX_MEM_register_b_value_in <= execute_stage_val_b; 
    EX_MEM_register_does_branch_in <= execute_stage_branch;
    EX_MEM_register_branch_target_in <= execute_stage_branch_target_out;
    EX_MEM_register_pc_in <= execute_stage_PC_out;
    EX_MEM_register_instruction_in <= execute_stage_instruction_out;

    memory_stage_ALU_result_in <= EX_MEM_register_ALU_result_out;
    memory_stage_instruction_in <= EX_MEM_register_instruction_out;
    memory_stage_val_b <= EX_MEM_register_b_value_out;

    MEM_WB_register_ALU_result_in <= memory_stage_ALU_result_out;
    MEM_WB_register_data_mem_in <= memory_stage_mem_data;
    MEM_WB_register_instruction_in <= memory_stage_instruction_out;
    
    write_back_stage_ALU_result_in <= MEM_WB_register_ALU_result_out;
    write_back_stage_instruction_in <= MEM_WB_register_instruction_out;
    write_back_stage_mem_data_in <= MEM_WB_register_data_mem_out;

    -- TODO: Later, Take a look at page 684 (C-40) of the textbook "Computer Architecture : a quantitative approach"
    -- for some neat pseudo-code about forwarding.
    
    init : process( clock, initialize )
    begin
        if initialize = '1' AND initialized = '0' then
            report "Initializing...";
            -- data_memory_load <= '1';
            instruction_memory_load <= '1';
            initialized <= '1';  
        else 
            -- data_memory_load <= '0';
            instruction_memory_load <= '0';         
        end if;
    end process ; -- init

    dump_process : process( clock, dump )
    begin
        if dump = '1' AND dumped = '0' then
            report "Dumping...";
            data_memory_dump <= '1';
            -- instruction_memory_dump <= '1';
            decode_stage_write_register_file <= '1';
            dumped <= '1';  
        else 
            data_memory_dump <= '0';
            decode_stage_write_register_file <= '0';
            -- instruction_memory_dump <= '0';         
        end if;
    end process ; -- dump



end architecture;