library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- opcode tool library
use work.INSTRUCTION_TOOLS.all;

entity ALU is
  port (
    clock : in std_logic;
    instruction_type : in INSTRUCTION.instruction_type;
    op_a : in std_logic_vector(31 downto 0); -- RS
    op_b : in std_logic_vector(31 downto 0); -- RT
    ALU_out : out std_logic_vector(63 downto 0) -- RD
  );
end ALU ;

architecture ALU_arch of ALU is

  -- Implements assembly of a limited set of 32 instructions:
  -- R-Instructions: mult, mflo, jr, mfhi, add, sub, and, div, slt, or, nor, xor, sra, srl, sll;
  -- I-Instructions: addi, slti, bne, sw, beq, lw, lb, sb, lui, andi, ori, xori, asrt, asrti, halt;
  -- J-Instructions: jal, jr, j;
  -- Custom test instructions: asrt, asrti, halt

  -- function signExtend(immediate : std_logic_vector(15 downto 0))
  --   return std_logic_vector is
  -- begin
  --   if(immediate(15) = '1') then
  --     return X"FFFF" & immediate;
  --   else
  --     return X"0000" & immediate;
  --   end if;
  -- end signExtend;

begin
  
  computation : process( instruction_typ, op_a, op_b )
  variable a : signed(31 downto 0) := signed(op_a);
  variable b : signed(31 downto 0) := signed(op_b);

  --variable sign_extended_immediate_vector : std_logic_vector(31 downto 0) := signExtend(instruction.immediate_vect);
  --variable sign_extended_immediate : signed(31 downto 0) := signed(sign_extended_immediate_vector);
  --shamt is stored in last 5 bits of "a"
  variable shift_amount : integer := to_integer(op_a(4 downto 0));
  --jump address will be last 26 bits of "a"
  variable jump_address : std_logic_vector(25 downto 0) := op_a(25 downto 0);
  begin
    
    case instruction_type is
      
      when ADD | ADD_IMMEDIATE | LOAD_WORD | STORE_WORD | BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL =>
        --for load word, provide the target address, (R[rs] + SignExtendedImmediate).

        -- for branch if equal PC = PC + 4 + branch target
          -- TODO: Assuming that the Branch target is calculated with A being the current PC + 4.
        ALU_out <= std_logic_vector(a + b); 
      
      when SUBTRACT =>
        ALU_out <= std_logic_vector(a - b);
      
      when MULTIPLY =>
        ALU_out <= std_logic_vector(a * b);
      
      when DIVIDE =>
        ALU_out <= std_logic_vector(a / b);
      
      when SET_LESS_THAN | SET_LESS_THAN_IMMEDIATE =>
        if a < b then 
          ALU_out <= "1";
        else 
          ALU_out <= "0";
        end if;  
      
      when BITWISE_AND | BITWISE_AND_IMMEDIATE=>
        ALU_out <= op_a AND op_b;
      
      when BITWISE_OR | BITWISE_OR_IMMEDIATE =>
        ALU_out <= op_a OR op_b;
      
      when BITWISE_NOR =>
        ALU_out <= op_a NOR op_b;
      
      when BITWISE_XOR | BITWISE_XOR_IMMEDIATE =>
        ALU_out <= op_a XOR op_b;
      
      when MOVE_FROM_HI =>
        -- This case is never reached (handled in decode)
        report "ERROR: MOVE_FROM_HI should not be given to ALU!" severity WARNING;
      when MOVE_FROM_LOW =>
        -- This case is never reached (handled in decode)
        report "ERROR: MOVE_FROM_HI should not be given to ALU!" severity WARNING;
      when LOAD_UPPER_IMMEDIATE =>
        -- loads the upper 16 bits of RT with the 16 bit immediate, and all the lower bits to '0'.
        ALU_out <= op_b(31 downto 16) & X"0000";
      
      when SHIFT_LEFT_LOGICAL =>
        ALU_out <= std_logic_vector(b SLL shift_amount); 
      
      when SHIFT_RIGHT_LOGICAL =>
        ALU_out <= std_logic_vector(b SRL shift_amount);
      
      when SHIFT_RIGHT_ARITHMETIC =>
        ALU_out <= to_stdlogicvector(to_bitvector(op_b) sra shift_amount);      
      
      when JUMP =>
      -- JUMP:
      -- PC = PC(31 downto 26) & jump_address;
      -- Assuming that PC is given as input.
      -- TODO: this should probably be done in ID or in IF, not sure it belongs in EX stage.
      
        ALU_out <= op_a(31 downto 26) & jump_address;
      
      when JUMP_AND_LINK =>
      -- JUMP_AND_LINK:
      -- TODO: also put the current PC into Register 31.

        ALU_out <= op_a(31 downto 26) & jump_address;
      
      when JUMP_TO_REGISTER =>
      -- TODO: Not sure this is handled here.
      -- NOTE: assuming that the content of register is given in A, just passing it along.
        ALU_out <= op_a;
      
      when UNKNOWN =>
        report "ERROR: unknown instruction given to ALU!" severity FAILURE;
    end case;
  end process ; -- computation

end architecture ; -- arch