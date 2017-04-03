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

    function should_take_branch(fetch_stage_pc : Integer ; branch_buff: branch_buffer)
        return boolean;

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


    -- Function responsible for making an assumption about the taken/not taken behaviour, for branch prediction.
    function should_take_branch(fetch_stage_pc : Integer ; branch_buff: branch_buffer)
        return boolean is
    begin
        for i in branch_buff' range loop
            if (branch_buff(i).pc = fetch_stage_pc) then
                -- access: branch_buff(i).taken to evaluate
                -- do some magic i.e. look at the string of taken bits and decide
                -- if some condition on taken bits : return true;
            else
                null;
            end if;
        end loop;
        return false;   -- default return is false for prediction not taken
    end should_take_branch;


end BRANCH_MANAGEMENT;