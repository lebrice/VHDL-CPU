LIBRARY ieee;
    USE ieee.std_logic_1164.all;
    USE ieee.numeric_std.all;
    USE ieee.numeric_std_unsigned.all ; 

USE work.REGISTERS.all;

ENTITY reg_file_tb IS
END reg_file_tb;

ARCHITECTURE behaviour OF reg_file_tb IS
BEGIN
    test_process : process
    variable data : std_logic_vector (31 downto 0);
    variable reg_block : REGISTER_BLOCK;
    BEGIN
        -- test reseting register block
        reg_block := reset_register_block(reg_block);
        for i in reg_block' range loop
            assert reg_block(i).busy = '0' report "failed to reset busy bit" severity error;
            assert reg_block(i).data = to_std_logic_vector(0, 32) report "failed to reset data" severity error;
        end loop;

        -- test setting regiester block
        for i in reg_block' range loop  -- set
            reg_block := set_register(i, to_std_logic_vector(i, 32), reg_block);
        end loop;

        for i in reg_block' range loop  -- test
             assert reg_block(i).data = to_std_logic_vector(i, 32) report "failed to set data" severity error;
        end loop;

    wait;
    END PROCESS; 
END;



