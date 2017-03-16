library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.numeric_std_unsigned.all ;   

    use work.instruction_tools.all;

entity writebackStage_tb is
end writebackStage_tb; 

architecture behaviour of writebackStage_tb is
begin
    test_process : process
        -- vars
    begin
        report "Start of Write Back Stage.";
        -- test process body
        report "End of Write Back Stage.";
        wait;
    end process;

end;