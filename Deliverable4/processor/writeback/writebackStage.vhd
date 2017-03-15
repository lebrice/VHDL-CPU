library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.instruction_tools.all;

-- writeback stage is essentially just a MUX
entity writebackStage is
  port (
    memDataIn : in std_logic_vector(31 downto 0);
    ALU_ResultIn : in std_logic_vector(31 downto 0);
    instructionIn : in instruction;
    writeData : out std_logic_vector(31 downto 0);
    -- writeRegister : out integer range 0 to 31; -- uncomment if you wish to implement register choice here
    instructionOut : out instruction
  ) ;
end writebackStage ;

architecture writebackStage_arch of writebackStage is
begin
  -- process to act as mux
  mux : process
    -- vars
  begin
      instructionOut <= instructionIn;
      case instructionIn.format is
        -- register-register ALU instruction
        when r_type => 
          writeData <= ALU_ResultIn;

-- uncomment if you wish to implement register choice here
          -- if (instructionIn.rt != 0) then
          --   writeRegister <= instructionIn.rd;
          -- end if;

        -- register-immediate ALU instruction
        when i_type  => 
          if (instructionIn.instruction_type = LOAD_WORD) then
            writeData <= memDataIn;
          else
            writeData <= ALU_ResultIn;
          end if;

-- uncomment if you wish to implement register choice here     
          -- if (instructionIn.rt != 0) then
          --   writeRegister <= instructionIn.rt;
          -- end if;
          
        when others => 
          -- do nothing

      end case;
   
  end process mux;

end architecture ; 