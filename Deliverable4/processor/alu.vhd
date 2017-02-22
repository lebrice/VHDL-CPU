library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- opcode tool library
use work.OPCODE_TOOLS.all;

entity ALU is
  port (
    clock : in std_logic;
    instruction : in std_logic_vector(31 downto 0);
    op_a : in std_logic_vector(31 downto 0);
    op_b : in std_logic_vector(31 downto 0);
    ALU_result : out std_logic_vector(63 downto 0)
  );
end ALU ;

architecture ALU_arch of ALU is

-- Implements assembly of a limited set of 32 instructions:
-- R-Instructions: mult, mflo, jr, mfhi, add, sub, and, div, slt, or, nor, xor, sra, srl, sll;
-- I-Instructions: addi, slti, bne, sw, beq, lw, lb, sb, lui, andi, ori, xori, asrt, asrti, halt;
-- J-Instructions: jal, jr, j;
-- Custom test instructions: asrt, asrti, halt
begin

  computation : process( instruction, op_a, op_b )
  variable instructionType : INSTRUCTION_TYPE := getInstructionType(instruction);
  variable a_unsigned : unsigned(31 downto 0);
  variable b_unsigned : unsigned(31 downto 0);
  begin
    a_unsigned := unsigned(op_a);    
    b_unsigned := unsigned(op_b);
    case instructionType is
      when ADD =>
        ALU_result <= std_logic_vector(a_unsigned + b_unsigned);
      when SUBTRACT =>
        
      when ADD_IMMEDIATE =>
        
      when MULTIPLY =>
        
      when DIVIDE =>
        
      when SET_LESS_THAN =>
        
      when SET_LESS_THAN_IMMEDIATE =>
        
      when BITWISE_AND =>
        
      when BITWISE_OR =>
        
      when BITWISE_NOR =>
        
      when BITWISE_XOR =>
        
      when BITWISE_AND_IMMEDIATE =>
        
      when BITWISE_OR_IMMEDIATE =>
        
      when BITWISE_XOR_IMMEDIATE =>
        
      when MOVE_FROM_HI =>
        
      when MOVE_FROM_LOW =>
        
      when LOAD_UPPER_IMMEDIATE =>
        
      when SHIFT_LEFT_LOGICAL =>
        
      when SHIFT_RIGHT_LOGICAL =>
        
      when SHIFT_RIGHT_ARITHMETIC =>
        
      when LOAD_WORD =>
        
      when STORE_WORD =>
        
      when BRANCH_IF_EQUAL =>
        
      when BRANCH_IF_NOT_EQUAL =>
        
      when JUMP =>
        
      when JUMP_TO_REGISTER =>
        
      when JUMP_AND_LINK =>
        
      when UNKNOWN =>
        
    end case;
  end process ; -- computation
  

end architecture ; -- arch