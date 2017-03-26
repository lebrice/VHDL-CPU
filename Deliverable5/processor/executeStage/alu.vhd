library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- opcode tool library
use work.INSTRUCTION_TOOLS.all;

entity ALU is
  port (
    instruction_type : in INSTRUCTION_TYPE;
    op_a : in std_logic_vector(31 downto 0); -- RS
    op_b : in std_logic_vector(31 downto 0); -- RT
    ALU_out : out std_logic_vector(63 downto 0) -- RD
  );
end ALU ;

architecture ALU_arch of ALU is
  function extend64(value : std_logic_vector(31 downto 0))
    return std_logic_vector is
  begin
      return X"00000000" & value;
  end extend64;
  -- Implements assembly of a limited set of 32 instructions:
  -- R-Instructions: mult, mflo, jr, mfhi, add, sub, and, div, slt, or, nor, xor, sra, srl, sll;
  -- I-Instructions: addi, slti, bne, sw, beq, lw, lb, sb, lui, andi, ori, xori, asrt, asrti, halt;
  -- J-Instructions: jal, jr, j;
  -- Custom test instructions: asrt, asrti, halt
begin
  
  computation : process( instruction_type, op_a, op_b )
  variable a : signed(31 downto 0);
  variable b : signed(31 downto 0);
  --shamt is stored in last 5 bits of "a"
  variable shift_amount : integer; 

  begin
    --set initial values
    a := signed(op_a);
    b := signed(op_b);
    shift_amount := to_integer(unsigned(op_a(4 downto 0))); --TODO: find out if this is unsigned or signed... (shamt is positive, I think)

    case instruction_type is
      
      when ADD | ADD_IMMEDIATE | LOAD_WORD | STORE_WORD  =>
        --for load word, provide the target address, (R[rs] + SignExtendedImmediate).
        -- for branch if equal PC = PC + 4 + branch target
        ALU_out <= extend64(std_logic_vector(a + b)); 
      when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL =>
        --b is the unsigned representation of our PC
        --a is the signed representation of our movement amount
        --we will add a and b as integers, and store it in an std_logic_vector (as unsigned)
        --then we extend by 64 since we want a 64 bit output...
        ALU_out <= extend64(std_logic_vector(to_unsigned(to_integer(a) + to_integer(unsigned(op_b)),32))); 
      when SUBTRACT =>
        ALU_out <= extend64(std_logic_vector(a - b)); -- rs - rt
      when MULTIPLY =>
        ALU_out <= std_logic_vector(a*b); 
      
      when DIVIDE =>  
        -- $LO = $s / $t; $HI = $s % $t
        if(b = x"00000000") then
          -- report "THIS IS BAD: DIVISION BY ZERO!" severity ERROR;
          ALU_out <= std_logic_vector(to_signed(-1, 64));
        else
          ALU_out(63 downto 32) <=  std_logic_vector(a rem b);
          ALU_out(31 downto 0)  <=  std_logic_vector(a / b);
        end if;

      when SET_LESS_THAN | SET_LESS_THAN_IMMEDIATE =>
        if a < b then  -- if rs < rd
          ALU_out <= x"0000000000000001";
        else 
          ALU_out <= x"0000000000000000";
        end if;  
      
      when BITWISE_AND | BITWISE_AND_IMMEDIATE=>
        ALU_out <= extend64(op_a AND op_b);
      
      when BITWISE_OR | BITWISE_OR_IMMEDIATE =>
        ALU_out <= extend64(op_a OR op_b);
      
      when BITWISE_NOR =>
        ALU_out <= extend64(op_a NOR op_b);
      
      when BITWISE_XOR | BITWISE_XOR_IMMEDIATE =>
        ALU_out <= extend64(op_a XOR op_b);
      
      when MOVE_FROM_HI =>
        -- This case is never reached (handled in decode)
        report "ERROR: MOVE_FROM_HI should not be given to ALU!" severity WARNING;

      when MOVE_FROM_LOW =>
        -- This case is never reached (handled in decode)
        report "ERROR: MOVE_FROM_LOW should not be given to ALU!" severity WARNING;

      when LOAD_UPPER_IMMEDIATE =>
        -- This is never reached (handled in decode)
        report "ERROR: LOAD_UPPER_IMMEDIATE should not be given to ALU!" severity WARNING;
      
      when SHIFT_LEFT_LOGICAL =>
        ALU_out <= extend64(std_logic_vector(b SLL shift_amount)); 
      
      when SHIFT_RIGHT_LOGICAL =>
        ALU_out <= extend64(std_logic_vector(b SRL shift_amount));
      
      when SHIFT_RIGHT_ARITHMETIC =>
        ALU_out <= extend64(to_stdlogicvector(to_bitvector(op_b) sra shift_amount));
      
      when JUMP | JUMP_AND_LINK | JUMP_TO_REGISTER =>
        --assumes the correctly formatted new address is set to a.
        ALU_out <= extend64(op_a);

      when UNKNOWN =>
        report "ERROR: unknown instruction given to ALU!" severity FAILURE;
    end case;
  end process ; -- computation

end architecture ; -- arch