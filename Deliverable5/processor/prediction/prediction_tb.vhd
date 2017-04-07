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
    begin
        report "test beginning";

        buff := buffer_init;
        report "test completed";

    wait;
    end process; 
    
end;



