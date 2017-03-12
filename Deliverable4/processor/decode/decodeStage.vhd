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
    register_file : in REGISTER_BLOCK;


    -- might have to add this in at some point:
    -- stall_in : in std_logic;

    -- Stall signal out.
    stall_out : out std_logic
    
  ) ;
end decodeStage ;

architecture decodeStage_arch of decodeStage is
  signal rs_reg, rt_reg, rd_reg : REGISTER_ENTRY;
  signal stall_reg : std_logic;
  signal LOW, HI : REGISTER_ENTRY;

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
begin
  stall_out <= stall_reg;

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

  write_to_registers : process(clock, write_back_instruction, write_back_data, register_file)
  variable rs : REGISTER_ENTRY := register_file(write_back_instruction.rs);
  variable rt : REGISTER_ENTRY := register_file(write_back_instruction.rt);
  variable rd : REGISTER_ENTRY := register_file(write_back_instruction.rd);
  begin
    if clock = '1' then
      -- first half of clock cycle: write result of instruction to the registers.
      case write_back_instruction.instruction_type is
        -- NOTE: using a case based on the instruction_type instead of the format, since I'm not sure that all instrucitons of the same format 
        -- behave in exactly the same way. (might be wrong though).
        when ADD | SUBTRACT | BITWISE_AND | BITWISE_OR | BITWISE_NOR | BITWISE_XOR | SET_LESS_THAN | SHIFT_LEFT_LOGICAL | SHIFT_RIGHT_LOGICAL | SHIFT_RIGHT_ARITHMETIC =>
          -- instructions where we simply write back the data to the "rd" register:
          rd.data := write_back_data(31 downto 0);
          rd.busy := '0';
        when ADD_IMMEDIATE | BITWISE_AND_IMMEDIATE | BITWISE_OR_IMMEDIATE | BITWISE_XOR_IMMEDIATE | SET_LESS_THAN_IMMEDIATE | LOAD_WORD =>
          -- instructions where we use "rt" as a destination
          rt.data := write_back_data(31 downto 0);
          rt.busy := '0';
        when MULTIPLY | DIVIDE =>
          LOW.data <= write_back_data(31 downto 0);
          LOW.busy <= '0';
          HI.data <= write_back_data(63 downto 32);
          HI.busy <= '0';
        when LOAD_UPPER_IMMEDIATE | MOVE_FROM_HI | MOVE_FROM_LOW =>
          -- Do nothing, these instructions are handled immediately by the process handling the incoming instruction from fetchStage.
        when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL | JUMP | JUMP_TO_REGISTER | JUMP_AND_LINK =>
          -- TODO: Not 100% sure if we're supposed to do anything here.
        when UNKNOWN =>
          report "ERROR: There is an unknown instruction coming into the DECODE stage from the WRITE-BACK stage!" severity failure;
        when others =>          
      end case;
   end if;
  end process write_to_registers;




  read_from_registers : process(clock, instruction_in, register_file)
  variable rs : REGISTER_ENTRY := register_file(instruction_in.rs);
  variable rt : REGISTER_ENTRY := register_file(instruction_in.rt);
  variable rd : REGISTER_ENTRY := register_file(instruction_in.rd);
  variable immediate : std_logic_vector(15 downto 0) := instruction_in.immediate_vect;
  begin
    if clock = '0' then
      if stall_reg = '0' then
      -- second half of clock cycle: read data from registers, and output the correct instruction.
      -- TODO: There is no need to go through the rest of the pipeline stages in the case of MFHI and MFLO,
      -- since they only move data from the HI or LOW special registers to another register.
      -- (they move half of the result from a MULTIPLY instruction.)
      
      case instruction_in.instruction_type is 
        when ADD | SUBTRACT =>
          val_a <= rs.data;
          val_b <= rt.data;
          rd.busy := '1';
        when ADD_IMMEDIATE | SET_LESS_THAN_IMMEDIATE =>
          val_a <= rs.data;
          val_b <= signExtend(immediate);
          rt.busy := '1';        
        when BITWISE_AND_IMMEDIATE | BITWISE_OR_IMMEDIATE | BITWISE_XOR_IMMEDIATE =>
          val_a <= rs.data;
          val_b <= zeroExtend(immediate);
          rt.busy := '1';
        when MULTIPLY | DIVIDE =>
          val_a <= rs.data;
          val_b <= rt.data;
          LOW.busy <= '1';
          HI.busy <= '1';
        when others =>

      end case;

      else
      -- A stall was detected/required, so output a NO_OP.
        instruction_out <= NO_OP_INSTRUCTION;
        val_a <= (others => '0');
        val_b <= (others => '0');
      end if;
    end if;
  end process read_from_registers;



  detect_stall : process(instruction_in, register_file)
  begin
    case instruction_in.format is
      when R_TYPE =>
        if rs_reg.busy = '1' OR rt_reg.busy = '1' OR rd_reg.busy = '1' then
          stall_reg <= '1';
        else 
          stall_reg <= '0';
        end if;
      when I_TYPE =>

      when J_TYPE =>

      when UNKNOWN =>
        report "ERROR: unknown Instruction format in Decode stage!" severity failure;
    end case;
  end process detect_stall;



end architecture ; -- arch