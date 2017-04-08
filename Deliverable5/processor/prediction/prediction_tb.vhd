library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.numeric_std_unsigned.all ; 

use work.prediction.all;

entity prediction_tb is
end prediction_tb;

        -----------------------------------------------------------------------------
        -- note this test is configured to run on a taken history vector of size 4 --
        -----------------------------------------------------------------------------

architecture behaviour of prediction_tb is
begin
    test_process : process
    variable buff : branch_buffer;
    variable pc : Integer; 
    variable taken: std_logic;
    variable decision : boolean;
    variable entry : buffer_entry;
    begin

        report "test beginning";
        
        -- no asserts for datatstructure checking, waste of time 
        -- put breakpoints and check contents of buff
        buff := buffer_init;
        -- check to see contents of buff is all zeros

        -- test update taken
        entry.pc := 9;
        entry.taken := "0000";

        entry := update_taken(entry, '1');
        entry := update_taken(entry, '1');

        assert entry.taken = "0011" report "checking entry" severity error;

        buff := add_entry(buff, 9);
        buff := add_entry(buff, 8);
        buff := add_entry(buff, 7);
        buff := add_entry(buff, 6);

       

        -- set values for placing first entry
        pc := 1;
        taken := '0';

        -- place first entry
        buff := update_branch_buff(buff, pc, taken); -- entry at 0 should be {1,0,1,0}, A

        decision := branch_decision(pc, buff);
        assert decision = false report "check 1" severity error;

        taken := '1';

         -- update first entry
        buff := update_branch_buff(buff, pc, taken); -- entry at 0 should be {0,1,0,1}, A

        decision := branch_decision(pc, buff);
        assert decision = true report "check 2" severity error;

        pc := 2;
        -- place second entry just to see if buffer accepts multiple entries
        buff := update_branch_buff(buff, pc, taken); -- entry at 0 should be {1,0,1,0,}, 5

        decision := branch_decision(pc, buff);
        assert decision = false report "check 3" severity error;

        pc := 1;

        buff := update_branch_buff(buff, pc, taken); -- entry at 1 should be {1,0,1,1}, A
        buff := update_branch_buff(buff, pc, taken); -- entry at 1 should be {0,1,1,1}, A
        buff := update_branch_buff(buff, pc, taken); -- entry at 1 should be {1,1,1,1}, A

        decision := branch_decision(pc, buff);
        assert decision = true report "check 4" severity error;

        taken := '0';

        buff := update_branch_buff(buff, pc, taken); -- entry at 1 should be {1,1,1,0}, A
        
        decision := branch_decision(pc, buff);
        assert decision = true report "check 5" severity error;

        buff := update_branch_buff(buff, pc, taken); -- entry at 1 should be {1,1,0,0}, A

        decision := branch_decision(pc, buff);
        assert decision = false report "check 6" severity error;

        buff := update_branch_buff(buff, pc, taken); -- entry at 1 should be {0,0,0,0}, A

        decision := branch_decision(pc, buff);
        assert decision = false report "check 7" severity error;
        
        report "test completed";

    wait;
    end process; 
    
end;



