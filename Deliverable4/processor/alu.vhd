library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- opcode tool library
use work.OPCODE_TOOLS.all;

entity ALU is
  port (
    clock : in std_logic;
    instruction : in std_logic_vector(31 downto 0);
    op_a : in std_logic_vector(31 downto 0); -- RS
    op_b : in std_logic_vector(31 downto 0); -- RT
    ALU_out : out std_logic_vector(63 downto 0); -- RD
    BranchCondition : out std_logic
  );
end ALU ;




architecture ALU_arch of ALU is

-- Implements assembly of a limited set of 32 instructions:
-- R-Instructions: mult, mflo, jr, mfhi, add, sub, and, div, slt, or, nor, xor, sra, srl, sll;
-- I-Instructions: addi, slti, bne, sw, beq, lw, lb, sb, lui, andi, ori, xori, asrt, asrti, halt;
-- J-Instructions: jal, jr, j;
-- Custom test instructions: asrt, asrti, halt

  function signExtend(immediate : std_logic_vector(15 downto 0))
    return std_logic_vector is
  begin
    if(immediate(15) = '1') then
      return X"FFFF" & immediate;
    else
      return X"0000" & immediate;
    end if;
  end signExtend;


begin

  
  computation : process( instruction, op_a, op_b )
  variable instructionType : INSTRUCTION_TYPE := getInstructionType(instruction);
  variable a : signed(31 downto 0) := signed(op_a);
  variable b : signed(31 downto 0) := signed(op_b);
  variable immediate_vector : std_logic_vector(31 downto 0) := signExtend(instruction(15 downto 0));
  variable s_immediate : signed(31 downto 0) := signed(immediate_vector);
  variable shift_amount : integer := to_integer(unsigned(instruction(10 downto 6)));
  variable jump_address : std_logic_vector(25 downto 0) := instruction(25 downto 0);
  begin
    case instructionType is
      when ADD =>
        ALU_out <= std_logic_vector(a + b);
      when SUBTRACT =>
        ALU_out <= std_logic_vector(a - b);
      when ADD_IMMEDIATE =>
        ALU_out <= std_logic_vector(a + s_immediate);
      when MULTIPLY =>
        ALU_out <= std_logic_vector(a * b);
      when DIVIDE =>
        ALU_out <= std_logic_vector(a / b);
      when SET_LESS_THAN =>
        if a < b then 
          ALU_out <= "1";
        else 
          ALU_out <= "0";
        end if;
      when SET_LESS_THAN_IMMEDIATE =>
        if a < s_immediate then
          ALU_out <= "1";
        else
          ALU_out <= "0";
        end if;  
      when BITWISE_AND =>
        ALU_out <= op_a AND op_b;
      when BITWISE_OR =>
        ALU_out <= op_a OR op_b;
      when BITWISE_NOR =>
        ALU_out <= op_a NOR op_b;
      when BITWISE_XOR =>
        ALU_out <= op_a XOR op_b;
      when BITWISE_AND_IMMEDIATE =>
        ALU_out <= op_a XOR immediate_vector;
      when BITWISE_OR_IMMEDIATE =>
        ALU_out <= op_a OR immediate_vector;
      when BITWISE_XOR_IMMEDIATE =>
        ALU_out <= op_a XOR immediate_vector;
      when MOVE_FROM_HI =>
        -- TODO:  understand what's happening in this case.
      when MOVE_FROM_LOW =>
        -- TODO:  understand what's happening in this case.
      when LOAD_UPPER_IMMEDIATE =>
        -- loads the upper 16 bits of RT with the 16 bit immediate, and all the lower bits to '0'.
        ALU_out <= op_a(31 downto 16) & X"0000";
      when SHIFT_LEFT_LOGICAL =>
        ALU_out <= std_logic_vector(b SLL shift_amount);
      when SHIFT_RIGHT_LOGICAL =>
        ALU_out <= std_logic_vector(b SRL shift_amount);
      when SHIFT_RIGHT_ARITHMETIC =>
        ALU_out <= to_stdlogicvector(to_bitvector(op_b) sra shift_amount);      
      when LOAD_WORD =>
        -- provide the target address, (R[rs] + SignExtendedImmediate).
        ALU_out <= std_logic_vector(a + s_immediate);
      when STORE_WORD =>
        ALU_out <= std_logic_vector(a + s_immediate);
      when BRANCH_IF_EQUAL =>
        -- PC = PC + 4 + branch target
        -- TODO: Assuming that the Branch target is calculated with A being the current PC + 4.
        ALU_out <= std_logic_vector(a + s_immediate);
      when BRANCH_IF_NOT_EQUAL =>
        ALU_out <= std_logic_vector(a + s_immediate);
      when JUMP =>
      -- PC = PC(31 downto 26) & jump_address;
      -- Assuming that PC is given as input.
      -- TODO: this should probably be done in ID or in IF, not sure it belongs in EX stage.
        ALU_out <= op_a(31 downto 26) & jump_address;
      when JUMP_TO_REGISTER =>
      -- TODO: Not sure this is handled here.
      -- NOTE: assuming that the content of register is given in A, just passing it along.
        ALU_out <= op_a;
      when JUMP_AND_LINK =>
      -- TODO: also put the current PC into Register 31.
        ALU_out <= op_a(31 downto 26) & jump_address;
      when UNKNOWN =>
        report "ERROR: unknown instruction given to ALU!" severity FAILURE;
    end case;
  end process ; -- computation
  

end architecture ; -- arch