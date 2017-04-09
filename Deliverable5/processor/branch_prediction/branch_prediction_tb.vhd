library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_textio.all;
    use ieee.numeric_std.all;

use work.instruction_tools.all;

entity branch_prediction_tb is
end branch_prediction_tb;

        -----------------------------------------------------------------------------
        -- note this test is configured to run on a taken history vector of size 4 --
        -----------------------------------------------------------------------------


architecture behavior of branch_prediction_tb is 
    
    constant clock_period : time := 1 ns;
    constant size : Integer := 5;
    constant history_size : Integer := 4;
    constant precition_active : std_logic := '1';

    component branch_prediction is 
        generic(
            size : Integer := size;
            history_size : Integer := history_size;
            precition_active : std_logic := precition_active
        );
        port (
            clock : in std_logic;	
            fetch_pc : in Integer;
            execute_pc : in Integer;
            taken : in std_logic;
            inst : in instruction;
            branch : out std_logic
        );
    end component;

    signal clock : std_logic := '0';	    
    signal fetch_pc : Integer := 0;
    signal execute_pc : Integer := 9;
    signal taken : std_logic := '0';	
    signal inst : instruction := makeInstruction(BEQ_OP, 1, 2, 10); -- BEQ $1, $2, 10
    signal branch : std_logic := '0';

    begin

        pre : branch_prediction 
        generic map(
            size => size,
            history_size => history_size,
            precition_active => precition_active
        )
        port map(
            clock,
            fetch_pc,
            execute_pc,
            taken,
            inst,
            branch
        );

        clock_process : process 
        begin
            clock <= '0';
            wait for clock_period/2;
            clock <= '1';
            wait for clock_period/2;
        end process;

        test_process : process
        begin
            report "begin test";
                     
            wait for clock_period; -- pc 9 should be added to buffer with history (1,0,1,0)
            assert branch = '0' report "checking inital condition" severity error;

            taken <= '1';

            wait for clock_period; -- add a 1 to the taken history vector of 9 -> (0,1,0,1)
            assert branch = '0' report "check 2" severity error;

            wait for clock_period; -- add a 1 to the taken history vector of 9 -> (1,0,1,1)
            assert branch = '0' report "check 3" severity error;
            
            execute_pc <= 8; -- stop updating 9 vector
            fetch_pc <= 9;
            
            -- fetch_pc matches execute_pc, predictor should run the check on bits now
            wait for clock_period; -- add nothing to the taken history vector of 9 -> (1,0,1,1)
            assert branch = '1' report "check 4" severity error;

            execute_pc <= 9;   -- start updating 9 vector again
            taken <= '0';

            wait for clock_period; -- add a 0 to the taken history vector of 9 -> (0,1,1,0)
            assert branch = '0' report "check 5" severity error;

            wait for clock_period; -- add a 0 to the taken history vector of 9 -> (1,1,0,0)
            assert branch = '0' report "check 6" severity error;

            taken <= '1';

            wait for clock_period; -- add a 0 to the taken history vector of 9 -> (1,0,0,1)
            assert branch = '1' report "check 7" severity error;

            wait for clock_period; -- add a 0 to the taken history vector of 9 -> (0,0,1,1)
            assert branch = '1' report "check 8" severity error;

            report "end testing";
            wait;

        end process;

end;

