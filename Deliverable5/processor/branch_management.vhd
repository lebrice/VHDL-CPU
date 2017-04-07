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
        variable ones : Integer;
        variable zeros: Integer;
    begin
        ones := 0;
        -- parse through branch buffer entries
        for i in branch_buff' range loop

            -- fetch pc matches one in buffer
            if (branch_buff(i).pc = fetch_stage_pc) then
                
                -- 1 bit branch prediction
                if (N_BIT_PREDICTION = 1) then
                    if (branch_buff(i).taken(0) = '1') then -- branch was taken last
                        return true;    -- assume it will be taken again
                    else
                        return false;  -- branch was not taken last, assume not taken
                    end if;
                end if;

                -- multiple bit branch prediction

                -- count the number of ones in the in the taken history of identified PC
                for j in branch_buff(i).taken' range loop     
                    if branch_buff(i).taken(j) = '1' then
                        ones := ones + 1; 
                    end if;
                end loop;

                -- determine if the number of 1s if greater than number of 0s
                zeros := N_BIT_PREDICTION - ones;

                -- act
                if (ones > zeros) then      -- more branches, predict taken
                    return true;
                elsif (ones < zeros)then    -- less branches, assume not taken
                    return false;
                elsif(ones = zeros) then    -- equal taken and not taken
                    
                    -- check to see which happened last
                    if (branch_buff(i).taken(0) = '1') then -- branch was taken last
                        return true;    -- assume it will be taken again
                    else
                        return false;  -- branch was not taken last, assume not taken
                    end if;

                end if;  -- act 
            end if; -- fetch pc matches one in buffer
        end loop; -- parse through branch buffer entries

        return false;   -- default return is false for prediction not taken
    end should_take_branch;


end BRANCH_MANAGEMENT;