library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;

entity decodeStage is
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
end decodeStage ;

architecture decodeStage_arch of decodeStage is

  function signExtend(immediate : std_logic_vector(15 downto 0))
    return std_logic_vector is
  begin
    if(immediate(15) = '1') then
      return X"FFFF" & immediate;
    else
      return X"0000" & immediate;
    end if;
  end signExtend;

  function zeroExtend(immediate : std_logic_vector(15 downto 0))
    return std_logic_vector is
  begin
    return X"0000" & immediate;
  end zeroExtend;

  constant link_register : integer := 31;

  constant empty_register : REGISTER_ENTRY := (busy => '0', data => (others => '0'));
  constant empty_register_file : REGISTER_BLOCK := (others => empty_register);
  

  signal stall_reg : std_logic;
  signal LOW, HI : REGISTER_ENTRY;
  signal register_file : REGISTER_BLOCK := empty_register_file;


begin
  stall_out <= stall_reg;
  PC_out <= PC;
  register_file_out <= register_file;

  -- Rough Pseudocode:
  -- Conditions that create a stall:
  -- A register is busy, and the incoming instruction from fetch is using it.
  -- OR perhaps the higher-level "Processor" entity wants to stall the pipeline for some reason.
  -- 


  -- Description of most basic desired behaviour:
  -- in first half of clock cycle, write data into the REGISTERS
  -- in second half of clock cycle, read data from registers and output the correct values.
  -- if a stall is required, output a no_op instead.


  -- Just as a visual aid, here's all possible instruciton types:
  -- ADD,
  -- SUBTRACT,
  -- ADD_IMMEDIATE,
  -- MULTIPLY,
  -- DIVIDE,
  -- SET_LESS_THAN,
  -- SET_LESS_THAN_IMMEDIATE,
  -- BITWISE_AND,
  -- BITWISE_OR,
  -- BITWISE_NOR,
  -- BITWISE_XOR,
  -- BITWISE_AND_IMMEDIATE,
  -- BITWISE_OR_IMMEDIATE,
  -- BITWISE_XOR_IMMEDIATE,
  -- MOVE_FROM_HI,
  -- MOVE_FROM_LOW,
  -- LOAD_UPPER_IMMEDIATE,
  -- SHIFT_LEFT_LOGICAL,
  -- SHIFT_RIGHT_LOGICAL,
  -- SHIFT_RIGHT_ARITHMETIC,
  -- LOAD_WORD,
  -- STORE_WORD,
  -- BRANCH_IF_EQUAL,
  -- BRANCH_IF_NOT_EQUAL,
  -- JUMP,
  -- JUMP_TO_REGISTER,
  -- JUMP_AND_LINK,
  -- UNKNOWN



  read_from_registers : process(clock, instruction_in, register_file)
    variable rs, rt, rd : integer range 0 to NUM_REGISTERS-1;
    variable immediate : std_logic_vector(15 downto 0);
  begin
    rs := instruction_in.rs;
    rt := instruction_in.rt;
    rd := instruction_in.rd;
    immediate := instruction_in.immediate_vect;



    if clock = '0' AND stall_in = '0' then
      if stall_reg = '0' then        
        -- second half of clock cycle: read data from registers, and output the correct instruction.
        -- TODO: There is no need to go through the rest of the pipeline stages in the case of MFHI and MFLO,
        -- since they only move data from the HI or LOW special registers to another register.
        -- (they move half of the result from a MULTIPLY instruction.)
        
        case instruction_in.instruction_type is 
          -- TODO: Make sure that we're clear on what exactly EX or ID handles in each case.

          when ADD | SUBTRACT | BITWISE_AND | BITWISE_NOR | BITWISE_OR | BITWISE_XOR | SET_LESS_THAN =>
            val_a <= register_file(rs).data;
            val_b <= register_file(rt).data;
            register_file(rd).busy <= '1';

          when ADD_IMMEDIATE | SET_LESS_THAN_IMMEDIATE =>
            val_a <= register_file(rs).data;
            val_b <= signExtend(immediate);
            register_file(rt).busy <= '1'; 

          when BITWISE_AND_IMMEDIATE | BITWISE_OR_IMMEDIATE | BITWISE_XOR_IMMEDIATE =>
            val_a <= register_file(rs).data;
            i_sign_extended <= zeroExtend(immediate);
            register_file(rt).busy <= '1';

          when MULTIPLY | DIVIDE =>
            val_a <= register_file(rs).data;
            val_b <= register_file(rt).data;
            LOW.busy <= '1';
            HI.busy <= '1';

          when MOVE_FROM_HI =>
            register_file(rd).data <= HI.data;
            val_a <= (others => '0');
            val_b <= (others => '0');

          when MOVE_FROM_LOW =>
            register_file(rd).data <= LOW.data;
            val_a <= (others => '0');
            val_b <= (others => '0');

          when LOAD_UPPER_IMMEDIATE =>
            register_file(rt).data <= immediate & (15 downto 0 => '0');
            val_a <= (others => '0');
            val_b <= (others => '0');

          when SHIFT_LEFT_LOGICAL | SHIFT_RIGHT_LOGICAL | SHIFT_RIGHT_ARITHMETIC =>
            val_b <= register_file(rt).data;
            val_a <= (31 downto 5 => '0') & instruction_in.shamt_vect;
            register_file(rd).busy <= '1';

          when LOAD_WORD =>
            val_a <= register_file(rs).data;
            i_sign_extended <= signExtend(immediate);
            register_file(rt).busy <= '1';

          when STORE_WORD =>
          -- TODO: It is unclear how we pass data to the EX stage in the case of STORE_WORD.
            val_a <= register_file(rs).data; -- the base address
            val_b <= register_file(rt).data; -- the word to store
            i_sign_extended <= signExtend(immediate); -- the offset

          when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL =>
            val_a <= register_file(rs).data;
            val_b <= register_file(rt).data;
            i_sign_extended <= signExtend(immediate);

          when JUMP =>
            -- do nothing

          when JUMP_AND_LINK =>
            register_file(link_register).data <= std_logic_vector(to_unsigned(PC + 8, 32));

          when JUMP_TO_REGISTER =>
            -- TODO: Clarify this with Asher
            val_a <= register_file(rs).data;

          when UNKNOWN =>
            report "ERROR: There is an unknown instruction coming into the DECODE stage from the WRITE-BACK stage!" severity failure;
        
        end case;

      else
      
        val_a <= (others => '0');
        val_b <= (others => '0');   
      end if;
    end if;
  end process read_from_registers;



  write_to_registers : process(clock, write_back_instruction, write_back_data, register_file)
    variable rs, rt, rd : integer range 0 to NUM_REGISTERS-1;
  begin
    rs := write_back_instruction.rs;
    rt := write_back_instruction.rt;
    rd := write_back_instruction.rd;

    if reset_register_file = '1' then
      -- reset register file
      register_file <= reset_register_block(register_file);
      -- FOR i in 0 to NUM_REGISTERS-1 LOOP
      --   register_file(i).data <= (others => '0');
      --   register_file(i).busy <= '0';
      -- end loop;

    elsif clock = '1' AND stall_in = '0' then

      -- first half of clock cycle: write result of instruction to the registers.
      case write_back_instruction.instruction_type is

        -- NOTE: using a case based on the instruction_type instead of the format, since I'm not sure that all instrucitons of the same format 
        -- behave in exactly the same way. (might be wrong though).
        when ADD | SUBTRACT | BITWISE_AND | BITWISE_OR | BITWISE_NOR | BITWISE_XOR | SET_LESS_THAN | SHIFT_LEFT_LOGICAL | SHIFT_RIGHT_LOGICAL | SHIFT_RIGHT_ARITHMETIC =>
          -- instructions where we simply write back the data to the "rd" register:
          register_file(rd).data <= write_back_data(31 downto 0);
          register_file(rd).busy <= '0';

        when ADD_IMMEDIATE | BITWISE_AND_IMMEDIATE | BITWISE_OR_IMMEDIATE | BITWISE_XOR_IMMEDIATE | SET_LESS_THAN_IMMEDIATE | LOAD_WORD =>
          -- instructions where we use "rt" as a destination
          register_file(rt).data <= write_back_data(31 downto 0);
          register_file(rt).busy <= '0';

        when MULTIPLY | DIVIDE =>
          LOW.data <= write_back_data(31 downto 0);
          LOW.busy <= '0';
          HI.data <= write_back_data(63 downto 32);
          HI.busy <= '0';

        when LOAD_UPPER_IMMEDIATE | MOVE_FROM_HI | MOVE_FROM_LOW =>
          -- Do nothing, these instructions are handled immediately by the process handling the incoming instruction from fetchStage.

        when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL | JUMP | JUMP_TO_REGISTER | JUMP_AND_LINK =>
          -- TODO: Not 100% sure if we're supposed to do anything here.

        when STORE_WORD =>
          -- Do Nothing.

        when UNKNOWN =>
          report "ERROR: There is an unknown instruction coming into the DECODE stage from the WRITE-BACK stage!" severity failure;

      end case;
   end if;
  end process write_to_registers;



  stall_detection : process(clock, instruction_in, register_file)
    variable rs, rt, rd : REGISTER_ENTRY;
  begin
    rs := register_file(instruction_in.rs);
    rt := register_file(instruction_in.rt);
    rd := register_file(instruction_in.rd);

    case instruction_in.instruction_type is
      -- TODO: Maybe this has to only happen on the second half of the clock cycle ?

      when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL | JUMP | JUMP_TO_REGISTER | JUMP_AND_LINK =>
        -- if the instruction coming in from Fetch is one of these, then we wait until the same instruction 
        -- comes back from Write-Back until releasing the pipeline.
        -- (We assume here that whenever a BRANCH-like instruction comes into the DECODE stage, it will stay at the input of the Decode stage until
        -- it comes back from Write-Back, since we freeze the fetch stage, but let the instruction through to EX-MEM-WB-Etc.)
        
        -- TODO: We HAVE to make sure that Fetch will work properly with this: 
        --    - Even when stalled, it should latch the PC_NEXT value from a JUMP or BRANCH instruction.
        --    - HOWEVER, the instruction coming into DECODE should stay the same until STALL is DE-ASSERTED! (This seems like a challenge right now.)
        if (write_back_instruction.instruction_type = instruction_in.instruction_type) then
          stall_reg <= '0';
        else
          stall_reg <= '1';
        end if;

      when ADD | SUBTRACT | SET_LESS_THAN | BITWISE_AND | BITWISE_OR | BITWISE_NOR | BITWISE_XOR =>
        if rs.busy = '1' OR rt.busy = '1' OR rd.busy = '1' then
          stall_reg <= '1';
        else
          stall_reg <= '0';
        end if;

      when ADD_IMMEDIATE | SET_LESS_THAN_IMMEDIATE | BITWISE_AND_IMMEDIATE | BITWISE_OR_IMMEDIATE | BITWISE_XOR_IMMEDIATE | LOAD_WORD | STORE_WORD =>
        if rs.busy = '1' OR rt.busy = '1' then
          stall_reg <= '1';
        else
          stall_reg <= '0';
        end if;

      when MULTIPLY | DIVIDE =>
        if rs.busy = '1' OR rt.busy = '1' OR HI.busy = '1' OR LOW.busy = '1' then
          stall_reg <= '1';
        else 
          stall_reg <= '0';
        end if;

      when MOVE_FROM_HI =>
        if rd.busy = '1' OR HI.busy = '1' then
          stall_reg <= '1';
        else
          stall_reg <= '0';
        end if;

      when MOVE_FROM_LOW =>
        if rd.busy = '1' OR LOW.busy = '1' then
          stall_reg <= '1';
        else
          stall_reg <= '0';
        end if;

      when LOAD_UPPER_IMMEDIATE =>
        if rt.busy = '1' then
          stall_reg <= '1';
        else 
          stall_reg <= '0';
        end if;

      when SHIFT_LEFT_LOGICAL | SHIFT_RIGHT_LOGICAL | SHIFT_RIGHT_ARITHMETIC =>
        if rd.busy = '1' OR rt.busy = '1' then
          stall_reg <= '1';
        else
          stall_reg <= '0';
        end if;

      when UNKNOWN =>
        report "ERROR: unknown Instruction type in Decode stage!" severity failure;

    end case;
  end process stall_detection;


  instruction_out <= 
    NO_OP_INSTRUCTION when stall_reg = '1' 
      OR instruction_in.instruction_type = MOVE_FROM_HI
      OR instruction_in.instruction_type = MOVE_FROM_LOW
      OR instruction_in.instruction_type = LOAD_UPPER_IMMEDIATE 
    else instruction_in;

  write_registers_to_file : process( write_register_file )
  begin
    if write_register_file = '1' then
      -- TODO: call the procedure to write out the register_file to a file.
    end if;    
  end process ; -- write_registers_to_file

end architecture ; -- arch