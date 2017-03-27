library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;

package BRANCH_MANAGEMENT is
    function isBranchType(instruction : INSTRUCTION)
        return boolean;
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

end BRANCH_MANAGEMENT;