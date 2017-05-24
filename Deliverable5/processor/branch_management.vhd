library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;
use work.prediction.all;

package BRANCH_MANAGEMENT is

    -- Returns True if the given instruction is branch-like, (Jumps and branches)
    function is_branch_type(instruction : INSTRUCTION)
        return boolean;

    type pipeline_state_snapshot is
    record
        fetch_inst :    INSTRUCTION;
        IF_ID_inst :    INSTRUCTION;
        ID_EX_inst :    INSTRUCTION;
        EX_MEM_inst :   INSTRUCTION;
        MEM_WB_inst :   INSTRUCTION;
        EX_MEM_branch_taken :   std_logic;
    end record;  

end package ;


package body BRANCH_MANAGEMENT is

    -- Returns True if the given instruction is branch-like, (Jumps and branches)
    -- TODO: check to see if we want J and JAL instructions in here!!!!!
    function is_branch_type(instruction : INSTRUCTION) 
        return boolean is
    begin
        case instruction.instruction_type is
            when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL | JUMP_TO_REGISTER | JUMP | JUMP_AND_LINK =>
                return true;
            when others => 
                return false;
        end case;
    end is_branch_type;


end BRANCH_MANAGEMENT;