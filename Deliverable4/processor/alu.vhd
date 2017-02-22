library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_bit.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use IEEE.math_complex.all;

library STD;
use STD.textio;

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

signal instructionType : INSTRUCTION_TYPE;
begin
  instructionType <= getInstructionType(instruction);
end architecture ; -- arch