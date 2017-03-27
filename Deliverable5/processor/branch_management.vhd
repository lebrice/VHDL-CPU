library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;

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

    function should_take_branch(state : pipeline_state_snapshot)
        return boolean;

    procedure detect_branch_stalls(
        signal state : in pipeline_state_snapshot; 
        signal manual_fetch_stall : out std_logic;
        signal manual_IF_ID_stall : out std_logic;
        signal manual_decode_stall : out std_logic;
        signal feed_IF_ID_no_op : out boolean
        );
        


end package ;


package body BRANCH_MANAGEMENT is

    -- Returns True if the given instruction is branch-like, (Jumps and branches)
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
    function should_take_branch(state : pipeline_state_snapshot)
        return boolean is
    begin
        --TODO: implement branch prediction here later maybe ?
        return true;
    end should_take_branch;

    procedure detect_branch_stalls(
        signal state : in pipeline_state_snapshot; 
        signal manual_fetch_stall : out std_logic;
        signal manual_IF_ID_stall : out std_logic;
        signal manual_decode_stall : out std_logic;
        signal feed_IF_ID_no_op : out boolean
        ) is
    begin
        if is_branch_type(state.IF_ID_inst) then
            feed_IF_ID_no_OP <= true;
        end if;
    end detect_branch_stalls;

end BRANCH_MANAGEMENT;