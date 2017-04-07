library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.numeric_std_unsigned.all ; 

use work.prediction.all;
use work.instruction_tools.all;

entity prediction_tb is
end prediction_tb;

architecture behaviour of prediction_tb is
begin
    test_process : process
    variable buff : branch_buffer;
    variable pc : Integer; 
    variable taken: std_logic;
    variable inst : Instruction;
    variable decision : boolean;
    begin
        report "test beginning";
        
        -- no asserts for datatstructure checking, waste of time 
        -- put breakpoints and check contents of buff
        buff := buffer_init;
        -- check to see contents of buff is all zeros

        -- set values for placing first entry
        pc := 10;
        taken := '0';
        inst := makeInstruction(BEQ_OP, 1, 2, 10); -- BEQ $1, $2, 10

        -- place first entry
        buff := update_branch_buff(buff, pc, taken, inst); -- entry at 0 should be {0,...,0,0}, A

        taken := '1';

         -- place second entry
        buff := update_branch_buff(buff, pc, taken, inst); -- entry at 0 should be {0,...,0,1}, A

        pc := 5;
        -- place third entry
        buff := update_branch_buff(buff, pc, taken, inst); -- entry at 1 should be {0,...,0,1}, 5

        decision := branch_decision(10, buff);
        assert decision = true report "check should be true" severity error;

        


        report "test completed";

    wait;
    end process; 
    
end;



