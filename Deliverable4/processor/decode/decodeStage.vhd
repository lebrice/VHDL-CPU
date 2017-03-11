library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;

entity decodeStage is
  port (
    clock : in std_logic;

    -- Inputs coming from the IF/ID Register
    PC : in integer;
    instruction_in : in INSTRUCTION;


    -- Instruction and data coming from the Write-Back stage.
    write_back_instruction : in INSTRUCTION;
    write_back_data : in std_logic_vector(31 downto 0);


    -- Outputs to the ID/EX Register
    val_a : out std_logic_vector(31 downto 0);
    val_b : out std_logic_vector(31 downto 0);
    i_sign_extended : out std_logic_vector(31 downto 0);
    PC_out : out integer;
    instruction_out : out INSTRUCTION;

    -- Register file
    register_file : in REGISTER_BLOCK;

    -- Stall signal out.
    stall_out : out std_logic
    
  ) ;
end decodeStage ;

architecture decodeStage_arch of decodeStage is
  signal rs_reg, rt_reg, rd_reg : REGISTER_ENTRY;
begin
  rs_reg <= register_file(instruction_in.rs);
  rt_reg <= register_file(instruction_in.rt);
  rd_reg <= register_file(instruction_in.rd);

  detect_stall : process(instruction_in, register_file)
  begin
    case instruction_in.format is
      when R_TYPE =>
        if rs_reg.busy = '1' OR rt_reg.busy = '1' OR rd_reg.busy = '1' then
          stall_out <= '1';
        else 
          stall_out <= '0';
        end if;
      when I_TYPE =>

      when J_TYPE =>

      when UNKNOWN =>
        report "ERROR: unknown Instruction format in Decode stage!" severity failure;
    end case;
  end process detect_stall;



end architecture ; -- arch