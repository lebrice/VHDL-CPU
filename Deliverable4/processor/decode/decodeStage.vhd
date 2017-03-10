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



begin



end architecture ; -- arch