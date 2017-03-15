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
    branch : out std_logic;
    ALU_Result : out std_logic_vector(31 downto 0)
  ) ;
end executeStage ;

architecture executeStage_arch of executeStage is
  COMPONENT ALU
  port (
    instruction : in INSTRUCTION;
    op_a : in std_logic_vector(31 downto 0); -- RS
    op_b : in std_logic_vector(31 downto 0); -- RT
    ALU_out : out std_logic_vector(31 downto 0) -- RD
  );
  END COMPONENT;
  
  --Signals for what go into the ALU
  SIGNAL input_a: std_logic_vector(31 downto 0);
  SIGNAL input_b: std_logic_vector(31 downto 0);
  SIGNAL internal_branch : std_logic;
  --SIGNAL ALU_Result : std_logic_vector(31 downto 0);
begin
  --define alu component
  exAlu: ALU port map (instruction_in, input_a, input_b, ALU_Result);

  --here are our output values
  branch <= internal_branch; --from first process below
  --ALU_Result <= ALU_Result; --from alu --not needed since done in port map
  instruction_out <= instruction_in; --pass through

  -- Process 1: calculate branch boolean (whether we branch or not)
  branch_condition : process(instruction_in)
  begin
    -- first we will compute the "branch" output
    case instruction_in.INSTRUCTION_TYPE is

      when BRANCH_IF_EQUAL =>
        --check if the two values from regs are equal
        if (val_a = val_b) then
          internal_branch <= '1';
        else
          internal_branch <= '0';
        end if;

      when BRANCH_IF_NOT_EQUAL =>
        --check if the two values from regs are equal
        if (val_a /= val_b) then
          internal_branch <= '1';
        else
          internal_branch <= '0';
        end if;

      when others =>
        internal_branch <= '0';
    end case;
  end process ; -- branch_condition  

  -- Process 2: Pass in values to ALU and get result
  compute_inputs : process(input_a, input_b) --TODO: ask about this. 
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
        when ADD_IMMEDIATE | SET_LESS_THAN_IMMEDIATE | BITWISE_AND_IMMEDIATE | BITWISE_OR_IMMEDIATE | BITWISE_XOR_IMMEDIATE | LOAD_UPPER_IMMEDIATE | LOAD_WORD | STORE_WORD =>
          input_a <= val_a; -- rs
          input_b <= imm_sign_extended;
        when MOVE_FROM_HI =>
          -- This case is never reached (handled in decode)
          report "ERROR: MOVE_FROM_HI should not be given to ALU!" severity WARNING;
        when MOVE_FROM_LOW =>
          -- This case is never reached (handled in decode)
          report "ERROR: MOVE_FROM_LOW should not be given to ALU!" severity WARNING;
        when SHIFT_LEFT_LOGICAL | SHIFT_RIGHT_LOGICAL | SHIFT_RIGHT_ARITHMETIC =>
          input_a <= (31 downto 5 => '0') & instruction_in.shamt_vect; --TODO: should I do this? Fab did it in decode. Should he?
        when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL =>
          --with branches, we want "a" to have the PC, b the immediate
          input_a <= std_logic_vector(to_unsigned(PC, 32)); --TODO: signed or unsigned?
          input_b <= imm_sign_extended;
        when JUMP | JUMP_TO_REGISTER =>
          input_a <= std_logic_vector(to_signed(PC, 6)) & instruction_in.address_vect; --TODO: Unsigned? signed? etc? I don't know
          input_b <= val_b; --doesn't matter
        when JUMP_AND_LINK =>
          input_a <= val_a; --this should contain the new PC (the place we want to jump to)
          input_a <= val_b; --doesn't matter
        when UNKNOWN => --this is unknown: report an error.
          report "ERROR: unknown instruction format in execute stage!" severity WARNING;
    end case;
  end process; -- compute_inputs
end architecture ; -- arch