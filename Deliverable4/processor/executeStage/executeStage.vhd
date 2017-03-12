library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;

entity executeStage is
  port (
    clock : in std_logic;
    instructionIn : in Instruction;
    valA : in std_logic_vector(31 downto 0);
    valB : in std_logic_vector(31 downto 0);
    iSignExtended : in std_logic_vector(31 downto 0);
    PC : in std_logic_vector(3 downto 0);
    instructionOut : out Instruction;
    branch : out std_logic;
    ALU_Result : out std_logic_vector(31 downto 0)
  ) ;
end executeStage ;

architecture executeStage_arch of executeStage is
  COMPONENT ALU
  port (
    clock : in std_logic;
    instruction : in INSTRUCTION;
    op_a : in std_logic_vector(31 downto 0); -- RS
    op_b : in std_logic_vector(31 downto 0); -- RT
    ALU_out : out std_logic_vector(63 downto 0) -- RD
  );
  END COMPONENT;
  
  --Signals for what go into the ALU
  SIGNAL input_a: std_logic_vector(31 downto 0);
  SIGNAL input_b: std_logic_vector(31 downto 0);
begin
  --define alu component
  exAlu: ALU port map (clock, instructionIn, input_a, input_b, ALU_Result);

  computation : process( instructionIn, iSignExtended, branch, input_a, input_b)

  begin
    -- first we will compute the "branch" output
    case instructionIn.INSTRUCTION_TYPE is

      when BRANCH_IF_EQUAL =>
        if ((signed(op_b)-signed(iSignExtended)) = 0) then
          branch <= 1;
        else
          branch <= 0;
        end if;

      when BRANCH_IF_NOT_EQUAL =>
        if ((signed(op_b)-signed(iSignExtended)) /= 0) then
          branch <= 1;
        else
          branch <= 0;
        end if;

      when others =>
        branch <= 0;
    end case; --TODO: figure out why there's an error here 
    -- The instruction changes what is passed to the ALU
    -- We either pass in:
    --  a) values read from registers
    --  b) shamt
    --  c) address vector
    --  d) immediate sign extended
    --  e) branch target
    case instructionIn.INSTRUCTION_FORMAT is
      
      --if it's an R-type, we pass in values (unless shifting)
      when R_TYPE =>
        --if it is a shift, we store the shamt in "a"
        case instructionIn.INSTRUCTION_TYPE is
          
          when SHIFT_LEFT_LOGICAL | SHIFT_RIGHT_LOGICAL | SHIFT_RIGHT_ARITHMETIC =>
            input_a <= (31 downto 5 => '0') & instructionIn.shamt_vect; --padded with 0s
          
          when others =>
            input_a <= valA;
        end case; 
        
        input_b <= valB;
     
      --if it's a J-type, we pass in the address vector and b value
      when J_TYPE =>
        input_a <= "000000" & instructionIn.address_vect;
        input_b <= valB; --doesn't matter
      
      --if it's an I-type we pass in the value A and the immediate sign extended
      when I_TYPE =>
        --we need to check if it's a branch (in which case we do PC + 4)
        case instructionIn.INSTRUCTION_TYPE is
          
          when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL =>
            --with branches, we want "a" to have the PCPlus4
            input_a <= (31 downto 4 => '0') & PC;
          
          when others =>
            input_a <= valA;   
        end case;
        input_b <= iSignExtended;
      
      when UNKNOWN => --this is unknown. report an error.
        report "ERROR: unknown instruction format in execute stage!" severity FAILURE;
    end case;
  end process; -- computation
end architecture ; -- arch