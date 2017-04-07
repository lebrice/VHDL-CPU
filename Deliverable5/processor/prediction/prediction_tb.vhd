library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.numeric_std_unsigned.all ; 

use work.prediction.all;

entity prediction_tb is
end prediction_tb;

architecture behaviour of prediction_tb is
begin
    test_process : process
    variable buff : branch_buffer;
    variable pc : Integer; 
    variable taken: std_logic;
    begin
        report "test beginning";
        -- no asserts, waste of time w this datastructure
        -- put breakpoints and check contents of buff
        buff := buffer_init;
        -- check to see contents of buff is all zeros
        pc := 10;
        taken := '0';

        -- buff := update_taken(buff, )
        report "test completed";

    wait;
    end process; 
    
end;



