library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.instruction_tools.all;

-- writeback stage is essentially just a MUX
entity writebackStage is
  port (
    mem_data_in : in std_logic_vector(31 downto 0);
    ALU_result_in : in std_logic_vector(63 downto 0);
    instruction_in : in instruction;
    write_data : out std_logic_vector(63 downto 0); --TODO: should this be 31 or 63?
    -- writeRegister : out integer range 0 to 31; -- uncomment if you wish to implement register choice here
    instruction_out : out instruction
  ) ;
end writebackStage ;

architecture writebackStage_arch of writebackStage is
begin
  -- process to act as mux
  mux : process
    -- vars
  begin
      instruction_out <= instruction_in;
      case instruction_in.format is
        -- register-register ALU instruction
        when r_type => 
          write_data <= ALU_result_in;

-- uncomment if you wish to implement register choice here
          -- if (instruction_in.rt != 0) then
          --   writeRegister <= instruction_in.rd;
          -- end if;

        -- register-immediate ALU instruction
        when i_type  => 
          if (instruction_in.instruction_type = LOAD_WORD) then
            write_data <= mem_data_in;
          else
            write_data <= ALU_result_in; --TODO: currently this is wrong (32 to 64 bits)
          end if;

-- uncomment if you wish to implement register choice here     
          -- if (instruction_in.rt != 0) then
          --   writeRegister <= instruction_in.rt;
          -- end if;
          
        when others => 
          -- do nothing

      end case;
   
  end process mux;

end architecture ; 