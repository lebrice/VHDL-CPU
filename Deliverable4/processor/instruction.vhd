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
        rs : integer range 0 to 31;
        rt : integer range 0 to 31;
        rd : integer range 0 to 31;
        shamt : integer range 0 to 31;
        immediate : integer;
        address : integer;   

        -- vector versions (for convenience)
        rs_vect : std_logic_vector(4 downto 0);
        rt_vect : std_logic_vector(4 downto 0);
        rd_vect : std_logic_vector(4 downto 0);
        shamt_vect : std_logic_vector(4 downto 0);
        immediate_vect : std_logic_vector(15 downto 0);
        address_vect : std_logic_vector(25 downto 0);

    end record;

    function getInstructionFormat(instruction : std_logic_vector(31 downto 0))
        return INSTRUCTION_FORMAT;

    function getInstructionType(instruction : std_logic_vector(31 downto 0))
        return INSTRUCTION_TYPE;

    function getInstruction(instruction_vector : std_logic_vector(31 downto 0))
        return INSTRUCTION;

    function makeInstruction(opCode : std_logic_vector; rs: integer; rt : integer; rd : integer; shamt : integer; funct : std_logic_vector)
        return INSTRUCTION;

    function makeInstruction(opCode : std_logic_vector; rs: integer; rt : integer; immediate : integer)
        return INSTRUCTION;

    function makeInstruction(opCode : std_logic_vector(5 downto 0); address : integer)
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
        when J_OP       =>  return JUMP;
        when JAL_OP     =>  return JUMP_AND_LINK;
        when others     =>  return UNKNOWN;
    end case;
    end getInstructionType;

    function getInstruction(instruction_vector : std_logic_vector(31 downto 0))
        return INSTRUCTION is
        variable inst : INSTRUCTION;
    begin
        -- set the instruction type and format
        inst.instruction_type := getInstructionType(instruction_vector);
        inst.format := getInstructionFormat(instruction_vector);

        -- set all vector fields
        inst.rs_vect := instruction_vector(25 downto 21);
        inst.rt_vect := instruction_vector(20 downto 16);
        inst.rd_vect := instruction_vector(15 downto 11);
        inst.shamt_vect := instruction_vector(10 downto 6);
        inst.immediate_vect := instruction_vector(15 downto 0);
        inst.address_vect := instruction_vector(25 downto 0);

        -- set all integer fields
        inst.rs := to_integer(unsigned(inst.rs_vect));
        inst.rt := to_integer(unsigned(inst.rt_vect));
        inst.rd := to_integer(unsigned(inst.rd_vect));
        inst.shamt := to_integer(unsigned(inst.shamt_vect));
        inst.immediate := to_integer(unsigned(inst.immediate_vect));
        inst.address := to_integer(unsigned(inst.address_vect));

        return inst;
    end getInstruction;


    function makeInstruction(opCode : std_logic_vector(5 downto 0); rs: integer; rt : integer; rd : integer; shamt : integer; funct : std_logic_vector(5 downto 0))
        return INSTRUCTION is
        variable instruction : INSTRUCTION;
        variable instruction_v : std_logic_vector(31 downto 0);
        variable opcode_v, funct_v: std_logic_vector(5 downto 0);
        variable rs_v, rt_v, rd_v, shamt_v: std_logic_vector(4 downto 0);
    begin
        opcode_v := opCode(5 downto 0);
        funct_v := funct(5 downto 0);
        rs_v := std_logic_vector(to_unsigned(rs, 5));
        rt_v := std_logic_vector(to_unsigned(rt, 5));
        rd_v := std_logic_vector(to_unsigned(rd, 5));
        shamt_v := std_logic_vector(to_unsigned(shamt, 5));
        
        instruction_v := opcode_v & rs_v & rt_v & rd_v & shamt_v & funct_v;
        instruction := getInstruction(instruction_v);
        return instruction;
    end makeInstruction;

    function makeInstruction(opCode : std_logic_vector(5 downto 0); rs: integer; rt : integer; immediate : integer)
        return INSTRUCTION is
        variable instruction : INSTRUCTION;
        variable instruction_v : std_logic_vector(31 downto 0);
        variable opcode_v : std_logic_vector(5 downto 0);
        variable rs_v, rt_v: std_logic_vector(4 downto 0);
        variable immediate_v : std_logic_vector(15 downto 0);
    begin
        opcode_v := opCode(5 downto 0);
        rs_v := std_logic_vector(to_unsigned(rs, 5));
        rt_v := std_logic_vector(to_unsigned(rt, 5));
        immediate_v := std_logic_vector(to_unsigned(immediate, 16));  

        instruction_v := opcode_v & rs_v & rt_v & immediate_v;
        instruction := getInstruction(instruction_v);
        return instruction;
    end makeInstruction;

    function makeInstruction(opCode : std_logic_vector(5 downto 0); address : integer)
        return INSTRUCTION is
        variable instruction : INSTRUCTION;
        variable instruction_v : std_logic_vector(31 downto 0);
        variable opcode_v : std_logic_vector(5 downto 0);
        variable address_v : std_logic_vector(25 downto 0);
    begin
        opcode_v := opCode(5 downto 0);
        address_v := std_logic_vector(to_unsigned(address, 26));
        instruction_v := opcode_v & address_v;
        instruction := getInstruction(instruction_v);
        return instruction;
    end makeInstruction;

end INSTRUCTION_TOOLS;