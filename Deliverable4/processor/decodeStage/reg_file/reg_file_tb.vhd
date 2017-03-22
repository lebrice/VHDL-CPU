library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.numeric_std_unsigned.all ; 

library std;
    use std.textio.all;

use work.registers.all;

entity reg_file_tb is
end reg_file_tb;

architecture behaviour of reg_file_tb is
begin
    test_process : process
    variable reg_block : register_block;
    begin
        report "test beginning";
        -- test reseting register block
        reg_block := reset_register_block(reg_block);
        for i in reg_block' range loop
            assert reg_block(i).busy = '0' report "failed to reset busy bit" severity error;
            assert reg_block(i).data = to_std_logic_vector(0, 32) report "failed to reset data" severity error;
        end loop;

        -- test setting register block
        for i in reg_block' range loop  -- set
            reg_block := set_register(i, to_std_logic_vector(i, 32), reg_block);
        end loop;
        for i in reg_block' range loop  -- test (in seperate loop to ensure no overwrite)
             assert reg_block(i).data = to_std_logic_vector(i, 32) report "failed to set data" severity error;
        end loop;

        -- test register dump
        -- reg_block := load_registers;
        dump_registers(reg_block);
        report "test completed";

    wait;
    end process; 
end;



