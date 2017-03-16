library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;

entity cpu_tb is
end cpu_tb ; 

architecture processor_test of cpu_tb is
    COMPONENT CPU is
        generic(
            ram_size : integer := 8196;
            bit_width : integer := 32
        );
        port (
            clock : in std_logic;
            initialize : in std_logic -- signals to load Instruciton and Data Memories. Should be held at '1' for at least a few clock cycles.
        );
    end COMPONENT;

    signal clock : std_logic := '0';
    signal initialize : std_logic := '0';

    constant clock_period : time := 1 ns;
begin

c1 : CPU PORT MAP (
    clock,
    initialize
);


clock_process : process
begin
    clock <= '0';
    wait for clock_period/2;
    clock <= '1';
    wait for clock_period/2;
end process ; -- clock_process


test_process : process
begin
    report "starting test process";
    wait for clock_period;
    initialize <= '1';
    wait for clock_period;
    initialize <= '0';
    wait for clock_period;

    wait;



end process test_process;

end architecture ;