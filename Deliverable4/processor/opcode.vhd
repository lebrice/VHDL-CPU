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

    constant ALU_OP : std_logic_vector(5 downto 0)   := "000000";

    -- constant ADD_OP : std_logic_vector(5 downto 0)   := "100000"; -- (R-Type) add
    -- constant SUB_OP : std_logic_vector(5 downto 0)   := "100010"; -- (R-Type) subtract
    -- constant MULT_OP : std_logic_vector(5 downto 0)  := "011000"; -- (R-Type) multiply
    -- constant DIV_OP : std_logic_vector(5 downto 0)   := "011010"; -- (R-Type) divide
    -- constant SLT_OP : std_logic_vector(5 downto 0)   := "101010"; -- (R-Type) Set Less than
    constant ADDI_OP : std_logic_vector(5 downto 0)  := "001000"; -- (I-Type) add immediate
    constant SLTI_OP : std_logic_vector(5 downto 0)  := "001010"; -- (I-Type) Set less than immediate

    -- Logical
    -- constant AND_OP : std_logic_vector(5 downto 0)   := "100100"; -- (R-Type) AND
    -- constant OR_OP : std_logic_vector(5 downto 0)    := "100101"; -- (R-Type) OR
    -- constant NOR_OP : std_logic_vector(5 downto 0)   := "100111"; -- (R-Type) NOR
    -- constant XOR_OP : std_logic_vector(5 downto 0)   := "100110"; -- (R-Type) XOR
    constant ANDI_OP : std_logic_vector(5 downto 0)  := "001100"; -- (I-Type) AND Immediate
    constant ORI_OP : std_logic_vector(5 downto 0)   := "001101"; -- (I-Type) OR immediate
    constant XORI_OP : std_logic_vector(5 downto 0)  := "001110"; -- (I-Type) XOR immediate

    -- transfer
    -- constant MFHI_OP : std_logic_vector(5 downto 0)  := "010000"; -- (R-Type) Move from HI : (used after multiplications)
    -- constant MFLO_OP : std_logic_vector(5 downto 0)  := "010010"; -- (R-Type) Move from Lo : (used after multiplications)
    constant LUI_OP : std_logic_vector(5 downto 0)   := "001111"; -- (I-Type) Load Upper Immediate (@TODO: not sure what this does.)

    -- shift
    -- constant SLL_OP : std_logic_vector(5 downto 0)   := "000000"; -- (R-Type) Shift Left Logical
    -- constant SRL_OP : std_logic_vector(5 downto 0)   := "000010"; -- (R-Type) Shift Right Logical
    -- constant SRA_OP : std_logic_vector(5 downto 0)   := "000011"; -- (R-Type) Shift Right Arithmetic (keeps track of the MSB, preserving sign of the number.)

    -- Memory
    constant LW_OP : std_logic_vector(5 downto 0)    := "100011"; -- (I-Type) Load word
    constant SW_OP : std_logic_vector(5 downto 0)    := "101011"; -- (I-Type) Store Word
    
    -- Control-flow
    constant BEQ_OP : std_logic_vector(5 downto 0)   := "000100"; -- (I-Type) Branch if equal
    constant BNE_OP : std_logic_vector(5 downto 0)   := "000101"; -- (I-Type) Branch if NOT equal
    constant J_OP : std_logic_vector(5 downto 0)     := "000010"; -- (J-Type) Jump : Jump to an immediate (relative, sign-extended) address
    -- constant JR_OP : std_logic_vector(5 downto 0)    := "001000"; -- (R-Type) Jump To Register : (Jumpts to the address in a register)
    constant JAL_OP : std_logic_vector(5 downto 0)   := "000011"; -- (J-Type) Jump and Link


    type INSTRUCTION_FORMAT is (R_TYPE, J_TYPE, I_TYPE, UNKNOWN);
end OPCODE_TOOLS;
package body OPCODE_TOOLS is 
    function getInstructionFormat(opcode : std_logic_vector(5 downto 0))
              return INSTRUCTION_FORMAT is
    begin
    case opcode is
        when ALU_OP => 
            return R_TYPE;
        when ADDI_OP | SLTI_OP | ANDI_OP | ORI_OP | XORI_OP | LUI_OP | LW_op | SW_OP | BEQ_OP | BNE_OP =>
            return I_TYPE;
        when J_OP | JAL_OP =>
            return J_TYPE;
        when others =>
            return UNKNOWN;
    end case;
    end getInstructionFormat;
end OPCODE_TOOLS;