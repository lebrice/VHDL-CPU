library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_textio.all;
    use ieee.numeric_std.all;

use work.prediction.all;
use work.instruction_tools.all;

entity predictor is
	port (
		clock : in std_logic;	
        fetch_pc : in Integer;
        execute_pc : in Integer;
        taken : in std_logic;
        inst : in instruction;
        branch : out std_logic
	);
end predictor;

architecture working of predictor is

    -- check to see if instruction is a branch type
    function is_branch(inst : instruction)
        return boolean is
    begin
       case inst.instruction_type is
            when branch_if_equal | branch_if_not_equal  =>
                return true;
            when others => 
                return false;
            end case;
    end is_branch;

begin

    -- check to see if branch should be taken
    -- sets branch to '1' is it should and '0' otherwise
    branch_prediction : process(clock)
        variable branch_buff : branch_buffer;
        variable init_buffer : boolean := true;
    begin
        if (init_buffer) then
            branch_buff := buffer_init;
            init_buffer := false;
        end if;

        if rising_edge(clock) then
            if (is_branch(inst)) then
                -- update the branch buffer
                branch_buff := update_branch_buff(branch_buff, execute_pc, taken);
                -- ask if branch should be taken
                if (branch_decision(fetch_pc, branch_buff)) then
                    branch <= '1';
                else
                    branch <= '0';
                end if;  
            end if;   
        end if;

    end process;

end working;