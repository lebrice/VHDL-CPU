library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio;


package INSTRUCTION_TOOLS is
    
    -- R type opcodes:
    constant ALU_OP : std_logic_vector(5 downto 0)   := "000000";

    constant ADDI_OP : std_logic_vector(5 downto 0)  := "001000"; -- (I-Type) add immediate
    constant SLTI_OP : std_logic_vector(5 downto 0)  := "001010"; -- (I-Type) Set less than immediate
    constant ANDI_OP : std_logic_vector(5 downto 0)  := "001100"; -- (I-Type) AND Immediate
    constant ORI_OP : std_logic_vector(5 downto 0)   := "001101"; -- (I-Type) OR immediate
    constant XORI_OP : std_logic_vector(5 downto 0)  := "001110"; -- (I-Type) XOR immediate
    constant LUI_OP : std_logic_vector(5 downto 0)   := "001111"; -- (I-Type) Load Upper Immediate (@TODO: not sure what this does.)
    constant LW_OP : std_logic_vector(5 downto 0)    := "100011"; -- (I-Type) Load word
    constant SW_OP : std_logic_vector(5 downto 0)    := "101011"; -- (I-Type) Store Word
    constant BEQ_OP : std_logic_vector(5 downto 0)   := "000100"; -- (I-Type) Branch if equal
    constant BNE_OP : std_logic_vector(5 downto 0)   := "000101"; -- (I-Type) Branch if NOT equal

    -- J type opcodes: 
    constant JAL_OP : std_logic_vector(5 downto 0)   := "000011"; -- (J-Type) Jump and Link
    constant J_OP : std_logic_vector(5 downto 0)     := "000010"; -- (J-Type) Jump : Jump to an immediate (relative, sign-extended) address

    -- R Types 'funct' fields:
    -- --------------------------------------------
    constant ADD_FN : std_logic_vector(5 downto 0)   := "100000"; -- (R-Type) add
    constant SUB_FN : std_logic_vector(5 downto 0)   := "100010"; -- (R-Type) subtract
    constant MULT_FN : std_logic_vector(5 downto 0)  := "011000"; -- (R-Type) multiply
    constant DIV_FN : std_logic_vector(5 downto 0)   := "011010"; -- (R-Type) divide
    constant SLT_FN : std_logic_vector(5 downto 0)   := "101010"; -- (R-Type) Set Less than
    constant AND_FN : std_logic_vector(5 downto 0)   := "100100"; -- (R-Type) AND
    constant OR_FN : std_logic_vector(5 downto 0)    := "100101"; -- (R-Type) OR
    constant NOR_FN : std_logic_vector(5 downto 0)   := "100111"; -- (R-Type) NOR
    constant XOR_FN : std_logic_vector(5 downto 0)   := "100110"; -- (R-Type) XOR
    constant MFHI_FN : std_logic_vector(5 downto 0)  := "010000"; -- (R-Type) Move from HI : (used after multiplications)
    constant MFLO_FN : std_logic_vector(5 downto 0)  := "010010"; -- (R-Type) Move from Lo : (used after multiplications)
    constant SLL_FN : std_logic_vector(5 downto 0)   := "000000"; -- (R-Type) Shift Left Logical
    constant SRL_FN : std_logic_vector(5 downto 0)   := "000010"; -- (R-Type) Shift Right Logical
    constant SRA_FN : std_logic_vector(5 downto 0)   := "000011"; -- (R-Type) Shift Right Arithmetic (keeps track of the MSB, preserving sign of the number.)
    constant JR_FN : std_logic_vector(5 downto 0)    := "001000"; -- (R-Type) Jump To Register : (Jumpts to the address in a register)



    type INSTRUCTION_FORMAT is (R_TYPE, J_TYPE, I_TYPE, UNKNOWN);

    type INSTRUCTION_TYPE is (
        ADD,
        SUBTRACT,
        ADD_IMMEDIATE,
        MULTIPLY,
        DIVIDE,
        SET_LESS_THAN,
        SET_LESS_THAN_IMMEDIATE,
        BITWISE_AND,
        BITWISE_OR,
        BITWISE_NOR,
        BITWISE_XOR,
        BITWISE_AND_IMMEDIATE,
        BITWISE_OR_IMMEDIATE,
        BITWISE_XOR_IMMEDIATE,
        MOVE_FROM_HI,
        MOVE_FROM_LOW,
        LOAD_UPPER_IMMEDIATE,
        SHIFT_LEFT_LOGICAL,
        SHIFT_RIGHT_LOGICAL,
        SHIFT_RIGHT_ARITHMETIC,
        LOAD_WORD,
        STORE_WORD,
        BRANCH_IF_EQUAL,
        BRANCH_IF_NOT_EQUAL,
        JUMP,
        JUMP_TO_REGISTER,
        JUMP_AND_LINK,
        UNKNOWN
        );
    
    type INSTRUCTION is
    record
        instruction_type : INSTRUCTION_TYPE;
        format : INSTRUCTION_FORMAT;
        rs : std_logic_vector(4 downto 0);
        rt : std_logic_vector(4 downto 0);
        rd : std_logic_vector(4 downto 0);
        shamt : std_logic_vector(4 downto 0);
        immediate : std_logic_vector(15 downto 0);
        address : std_logic_vector(25 downto 0);
    end record;

    function getInstructionFormat(instruction : std_logic_vector(31 downto 0))
        return INSTRUCTION_FORMAT;

    function getInstructionType(instruction : std_logic_vector(31 downto 0))
        return INSTRUCTION_TYPE;

    function getInstruction(instruction_vector : std_logic_vector(31 downto 0))
        return INSTRUCTION;

end INSTRUCTION_TOOLS;



package body INSTRUCTION_TOOLS is 
    function getInstructionFormat(instruction : std_logic_vector(31 downto 0))
        return INSTRUCTION_FORMAT is
        variable opcode : std_logic_vector(5 downto 0) := instruction(31 downto 26);
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

    function getInstructionType(instruction : std_logic_vector(31 downto 0))
        return INSTRUCTION_TYPE is
        variable opcode : std_logic_vector(5 downto 0) := instruction(31 downto 26);
        variable funct : std_logic_vector(5 downto 0) := instruction(5 downto 0);
    begin
    case opcode is
        when ALU_OP => 
            case funct is
               when ADD_FN  => return ADD;
               when SUB_FN  => return SUBTRACT;
               when MULT_FN => return MULTIPLY;
               when DIV_FN  => return DIVIDE;
               when SLT_FN  => return SET_LESS_THAN;
               when AND_FN  => return BITWISE_AND;
               when OR_FN   => return BITWISE_OR;
               when NOR_FN  => return BITWISE_NOR;
               when XOR_FN  => return BITWISE_XOR;
               when MFHI_FN => return MOVE_FROM_HI;
               when MFLO_FN => return MOVE_FROM_LOW;
               when SLL_FN  => return SHIFT_LEFT_LOGICAL;
               when SRL_FN  => return SHIFT_RIGHT_LOGICAL;
               when SRA_FN  => return SHIFT_RIGHT_ARITHMETIC;
               when JR_FN   => return JUMP_TO_REGISTER;
               when others  => return UNKNOWN;
            end case;
        when ADDI_OP    =>  return ADD_IMMEDIATE;
        when SLTI_OP    =>  return SET_LESS_THAN_IMMEDIATE;
        when ANDI_OP    =>  return BITWISE_AND_IMMEDIATE;
        when ORI_OP     =>  return BITWISE_OR_IMMEDIATE;
        when XORI_OP    =>  return BITWISE_XOR_IMMEDIATE;
        when LUI_OP     =>  return LOAD_UPPER_IMMEDIATE;
        when LW_op      =>  return LOAD_WORD;
        when SW_OP      =>  return STORE_WORD;
        when BEQ_OP     =>  return BRANCH_IF_EQUAL;
        when BNE_OP     =>  return BRANCH_IF_NOT_EQUAL;
        when others     =>  return UNKNOWN;
    end case;
    end getInstructionType;

    function getInstruction(instruction_vector : std_logic_vector(31 downto 0))
        return INSTRUCTION is
        variable inst : INSTRUCTION;
    begin
        inst.instruction_type := getInstructionType(instruction_vector);
        inst.format := getInstructionFormat(instruction_vector);
        -- report "instruction opcode is " & integer'image(to_integer(unsigned(instruction_vector(31 downto 26)))) severity note;
        -- report "instruction function code is " & integer'image(to_integer(unsigned(instruction_vector(5 downto 0)))) severity note;
        inst.rs := instruction_vector(25 downto 21);
        inst.rt := instruction_vector(20 downto 16);
        inst.rd := instruction_vector(15 downto 11);
        inst.shamt := instruction_vector(10 downto 6);
        inst.immediate := instruction_vector(15 downto 0);
        inst.address := instruction_vector(25 downto 0);
        return inst;
    end getInstruction;

end INSTRUCTION_TOOLS;