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
    PCPlus4In : in std_logic_vector(3 downto 0);
    instructionOut : out Instruction;
    branch : std_logic;
    ALU_Result : std_logic_vector(31 downto 0)
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


  -- here's what we need to do:
  -- 1) decide between Val from memory and PC+4
    -- we choose val if it's not a jump (pretty sure)
    -- otherwise we choose PC+4
  -- 2) decide between Val from memory and SE
    -- If it is an Immediate OP then we choose ISE (and val for "1)")
    -- otherwise we choose the val ()
  -- 3) set 1) and 2) to op_a, op_b for the ALU
  -- 4) we also need to do stuff for whether we branch. Do this last


  -- strategy: we pretty much just need to go through the type of op_a
  -- if it is immediate, choose ISE and valA
  -- if it is Jump, we choose PC+4 (but what for B?)
  -- if it is R, we choose Val A and val B 
  case instructionIn.INSTRUCTION_FORMAT is
    when R_TYPE =>
      --if it is a shift, we store the shamt in "a"
      case instructionIn.INSTRUCTION_TYPE is
        when SHIFT_LEFT_LOGICAL | SHIFT_RIGHT_LOGICAL | SHIFT_RIGHT_ARITHMETIC =>
          input_a <= (31 downto 5 => '0') & instructionIn.shamt_vect; --padded with 0s
        when others =>
          input_a <= valA;
      end case; --TODO: figure out why there's an error here 
      
      input_b <= valB;
    when J_TYPE =>
      input_a <= "000000" & instructionIn.address_vect;
      input_b <= valB; --doesn't matter
    when I_TYPE =>
      input_a <= valA;
      input_b <= iSignExtended;
    when UNKNOWN => --this is unknown. Just do vals.
      report "ERROR: unknown instruction format in execute stage!" severity FAILURE;
  end case;
end architecture ; -- arch