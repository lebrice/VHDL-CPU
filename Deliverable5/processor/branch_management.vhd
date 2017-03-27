library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;

package BRANCH_MANAGEMENT is

    -- Returns True if the given instruction is branch-like, (Jumps and branches)
    function isBranchType(instruction : INSTRUCTION)
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

    function shouldTakeBranch(currentState : pipeline_state_snapshot)
        return boolean;

    procedure detectBranchStalls(
        currentState : in pipeline_state_snapshot; 
        signal manual_decode_stall : out std_logic
        );
        


end package ;


package body BRANCH_MANAGEMENT is

    function isBranchType(instruction : INSTRUCTION) 
        return boolean is
    begin
        case instruction.instruction_type is
            when BRANCH_IF_EQUAL | BRANCH_IF_NOT_EQUAL | JUMP_TO_REGISTER | JUMP | JUMP_AND_LINK =>
                return true;
            when others => 
                return false;
        end case;
    end isBranchType;

    function shouldTakeBranch(currentState : pipeline_state_snapshot)
        return boolean is
    begin
        --TODO: implement branch prediction here later maybe ?
        return true;
    end shouldTakeBranch;

    procedure detectBranchStalls(
        currentState : in pipeline_state_snapshot; 
        signal manual_decode_stall : out std_logic
        ) is
    begin
    end detectBranchStalls;

end BRANCH_MANAGEMENT;