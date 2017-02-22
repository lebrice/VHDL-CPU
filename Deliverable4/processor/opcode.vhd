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


package OPCODE_TOOLS is
    -- Arithmetic
    constant ADD_INSTR : std_logic_vector(5 downto 0) := "010000"; -- add
    constant SUB_INSTR : std_logic_vector(5 downto 0) := "010000"; -- subtract
    constant ADDI_INSTR : std_logic_vector(5 downto 0) := "010000"; -- add immediate
    constant MULT_INSTR : std_logic_vector(5 downto 0) := "010000"; -- multiply
    constant DIV_INSTR : std_logic_vector(5 downto 0) := "010000"; -- divide
    constant SLT_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Set Less than
    constant SLTI_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Set less than immediate

    -- Logical
    constant AND_INSTR : std_logic_vector(5 downto 0) := "010000"; -- AND
    constant OR_INSTR : std_logic_vector(5 downto 0) := "010000"; -- OR
    constant NOR_INSTR : std_logic_vector(5 downto 0) := "010000"; -- NOR
    constant XOR_INSTR : std_logic_vector(5 downto 0) := "010000"; -- XOR
    constant ANDI_INSTR : std_logic_vector(5 downto 0) := "010000"; -- AND Immediate
    constant ORI_INSTR : std_logic_vector(5 downto 0) := "010000"; -- OR immediate
    constant XORI_INSTR : std_logic_vector(5 downto 0) := "010000"; -- XOR immediate

    -- transfer
    constant MFHI_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Move from HI : (used after multiplications)
    constant MFLO_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Move from Lo : (used after multiplications)
    constant LUI_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Load Upper Immediate (@TODO: not sure what this does.)

    -- shift
    constant SLL_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Shift Left Logical
    constant SRL_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Shift Right Logical
    constant SRA_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Shift Right Arithmetic (keeps track of the MSB, preserving sign of the number.)

    -- Memory
    constant LW_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Load word
    constant LB_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Load Byte
    constant SW_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Store Word
    constant SB_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Store Byte

    -- Control-flow
    constant BEQ_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Branch if equal
    constant BNE_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Branch if NOT equal
    constant J_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Jump : Jump to an immediate (relative, sign-extended) address
    constant JR_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Jump To Register : (Jumpts to the address in a register)
    constant JAL_INSTR : std_logic_vector(5 downto 0) := "010000"; -- Jump and Link


    type INSTRUCTION_FORMAT is (R_TYPE, J_TYPE, I_TYPE);
end OPCODE_TOOLS;
package body OPCODE_TOOLS is 
    function getInstructionFormat(opcode : std_logic_vector(5 downto 0))
              return INSTRUCTION_FORMAT is
    begin
    case opcode is
        when ADD_INSTR =>    return R_TYPE;
        when SUB_INSTR =>    return R_TYPE;
        when ADDI_INSTR =>   return R_TYPE;
        when MULT_INSTR =>   return R_TYPE;
        when DIV_INSTR =>    return R_TYPE;
        when SLT_INSTR =>    return R_TYPE;
        when SLTI_INSTR =>   return R_TYPE;
        when AND_INSTR =>    return R_TYPE;
        when OR_INSTR =>     return R_TYPE;
        when NOR_INSTR =>    return R_TYPE;
        when XOR_INSTR =>    return R_TYPE;
        when ANDI_INSTR =>   return R_TYPE;
        when ORI_INSTR =>    return R_TYPE;
        when XORI_INSTR =>   return R_TYPE;            
        when MFHI_INSTR =>   return R_TYPE;
        when MFLO_INSTR =>   return R_TYPE;
        when LUI_INSTR =>    return R_TYPE;
        when SLL_INSTR =>    return R_TYPE;
        when SRL_INSTR =>    return R_TYPE;
        when SRA_INSTR =>    return R_TYPE;
        when LW_INSTR =>     return R_TYPE;
        when LB_INSTR =>     return R_TYPE;
        when SW_INSTR =>     return R_TYPE;
        when SB_INSTR =>     return R_TYPE;
        when BEQ_INSTR =>    return R_TYPE;
        when BNE_INSTR =>    return R_TYPE;
        when J_INSTR =>      return R_TYPE;
        when JR_INSTR =>     return R_TYPE;
        when JAL_INSTR =>    return R_TYPE;
    end case;
    end getInstructionFormat;
end OPCODE_TOOLS;