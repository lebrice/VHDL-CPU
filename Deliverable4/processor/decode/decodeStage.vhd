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
    -- TODO: the write_back_data signal should be of length 64, since Multiply gives back 64 bits!
    write_back_data : in std_logic_vector(31 downto 0);


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
  -- TODO: Add the LO and HI special registers!
begin
  rs_reg <= register_file(instruction_in.rs);
  rt_reg <= register_file(instruction_in.rt);
  rd_reg <= register_file(instruction_in.rd);

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

  write_to_registers : process(write_back_instruction, write_back_data, register_file)
  begin
    if clock = '1' then
      -- first half of clock cycle: write result of instruction to the registers.
      case write_back_instruction.instruction_type is

        -- instructions where we simply write back the data to the "rd" register:
        when ADD | SUBTRACT | BITWISE_AND | BITWISE_OR | BITWISE_NOR | BITWISE_XOR | SET_LESS_THAN =>
          rd_reg.data <= write_back_data(31 downto 0);
          rd_reg.busy <= '0';
        when ADD_IMMEDIATE | BITWISE_AND_IMMEDIATE | BITWISE_OR_IMMEDIATE | BITWISE_XOR_IMMEDIATE | SET_LESS_THAN_IMMEDIATE =>

        when MULTIPLY =>
        when DIVIDE =>

        -- TODO: There is no need to go through the rest of the pipeline stages in the case of Move from Low and move from hi,
        -- since they only move data from the HI or LOW special registers to another register.
        -- (they move half of the result from a MULTIPLY instruction.)
        when MOVE_FROM_LOW => 
        when MOVE_FROM_HI =>
        when others =>
      end case;
   end if;
  end process write_to_registers;

  read_from_registers : process(instruction_in, write_back_instruction, register_file)
  begin
    if clock = '0' then
      -- second half of clock cycle: read data from registers, and output the correct instruction.
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