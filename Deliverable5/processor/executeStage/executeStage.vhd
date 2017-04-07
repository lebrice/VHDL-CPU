library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;

entity executeStage is
  port (
    instruction_in : in Instruction;
    val_a : in std_logic_vector(31 downto 0);
    val_b : in std_logic_vector(31 downto 0);
    imm_sign_extended : in std_logic_vector(31 downto 0);
    PC : in integer; 
    instruction_out : out Instruction;
    ALU_result : out std_logic_vector(63 downto 0);
    val_b_out : out std_logic_vector(31 downto 0);
    PC_out : out integer
  ) ;
end executeStage ;

architecture executeStage_arch of executeStage is
  COMPONENT ALU
  port (
    instruction_type : in INSTRUCTION_TYPE;
    op_a : in std_logic_vector(31 downto 0); -- RS
    op_b : in std_logic_vector(31 downto 0); -- RT
    ALU_out : out std_logic_vector(63 downto 0) -- RD
  );
  END COMPONENT;
  
  --Signals for what go into the ALU
  SIGNAL input_a: std_logic_vector(31 downto 0);
  SIGNAL input_b: std_logic_vector(31 downto 0);
  SIGNAL internal_ALU_result : std_logic_vector(63 downto 0);

  function signExtend(immediate : std_logic_vector(15 downto 0))
    return std_logic_vector is
  begin
    if(immediate(15) = '1') then
      return X"FFFF" & immediate;
    else
      return X"0000" & immediate;
    end if;
  end signExtend;



  --SIGNAL ALU_result : std_logic_vector(31 downto 0);
begin
  --define alu component
  exAlu: ALU port map (instruction_in.instruction_type, input_a, input_b, internal_ALU_result);


  --ALU_result <= ALU_result; --from alu --not needed since done in port map
  instruction_out <= instruction_in; --pass through
  PC_out <= PC;
  ALU_result <= internal_ALU_result;
  val_b_out <= val_b; --used to send val b to the next stage
 
  -- Process 2: Pass in values to ALU and get result
  compute_inputs : process(instruction_in, val_a, val_b, imm_sign_extended, PC)
  begin
 
    -- The instruction changes what is passed to the ALU
    -- We either pass in:
    --  a) values read from registers
    --  b) shamt
    --  c) address vector
    --  d) immediate sign extended
    --  e) branch target

    --TODO: Check divide mips command with hi lo stuff

    -- just going to go through every instruction type and act accordingly
    case instruction_in.INSTRUCTION_TYPE is
        when ADD | SUBTRACT | MULTIPLY | DIVIDE | SET_LESS_THAN | BITWISE_AND | BITWISE_OR | BITWISE_NOR | BITWISE_XOR =>
          input_a <= val_a; -- rs
          input_b <= val_b; -- rt
        when ADD_IMMEDIATE | SET_LESS_THAN_IMMEDIATE | BITWISE_AND_IMMEDIATE | BITWISE_OR_IMMEDIATE | BITWISE_XOR_IMMEDIATE | LOAD_WORD | STORE_WORD =>
          input_a <= val_a; -- rs
          -- FIXME: temp fix:
          input_b <= signExtend(instruction_in.immediate_vect);
          -- input_b <= imm_sign_extended;
        when LOAD_UPPER_IMMEDIATE | MOVE_FROM_HI | MOVE_FROM_LOW =>
          -- Note: in these special cases, decode already constructed the right information for us, and it is in the val_a signal.
          input_a <= val_a;
          input_b <= val_b;
        when SHIFT_LEFT_LOGICAL | SHIFT_RIGHT_LOGICAL | SHIFT_RIGHT_ARITHMETIC =>
          input_a <= (31 downto 5 => '0') & instruction_in.shamt_vect;
          input_b <= val_b;
        when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL | JUMP | JUMP_AND_LINK | JUMP_TO_REGISTER =>
          -- Do nothing, the logic was added into the ID stage.
          input_a <= (others => '0');
          input_b <= (others => '0');
        when UNKNOWN => --this is unknown: report an error.
          report "ERROR: unknown instruction format in execute stage!" severity WARNING;
    end case;
  end process; -- compute_inputs
end architecture ; -- arch