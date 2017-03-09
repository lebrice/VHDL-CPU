library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio;


package register is
    -- number of registers
    -- constant NUM_REGISTERS : integer := 31;
    -- register entry data structure
    -- TYPE REGISTER_ENTRY is
    -- record
    --     busy : std_logic;
    --     data : std_logic_vector(31 downto 0);
    -- end record;
    -- -- register block data structure
    -- TYPE REGISTER_BLOCK is array (NUM_REGISTERS downto 0) of REGISTER_ENTRY; 

    -- function reset_register_block(register_block : REGISTER_BLOCK)
    --     return REGISTER_BLOCK;
    -- function set_register(register_number: integer, register_data : std_logic_vector(31 downto 0), register_block : REGISTER_BLOCK)
    --     return REGISTER_BLOCK;
    -- function dump_registers(register_block  : REGISTER_BLOCK);
end register;

package body register is

--     --function to set all registers to 0;
--     function reset_register_block(register_block : REGISTER_BLOCK)
--         return REGISTER_BLOCK is
--         variable reg_block : REGISTER_BLOCK;
--         signal    reg_number : integer:=0;
--     begin 
--         reg_block <= register_block;
--         while reg_number <= REGISTER_LENGTH
--             reg_block(reg_number) <= '0';
--             reg_number <= reg_number + 1;
--         end loop;
--     end reset_register_block;

--     -- function to set desired register (register_number - up to 32) to hold data (register_data)
--     function set_register(register_number: integer, register_data : std_logic_vector(31 downto 0), register_block : REGISTER_BLOCK)
--         return REGISTER_BLOCK is
--         variable reg_block : REGISTER_BLOCK;
--     begin
--         reg_block <= register_block;
--         reg_block(register_number) <= register_data;
--     end set_register;


--     -- function to dump all register contents to a file "register_dump.txt"
--     function dump_registers(register_block  : REGISTER_BLOCK)
--         file      outfile  : text is out "register_dump.txt";   --declare output file
--         variable  outline  : line;                              --line number declaration  
--         signal    reg_number : integer:=0;
--     begin
--         -- wait until clock = '0' and clock'event;
--         while reg_number <= REGISTER_LENGTH
--             write(line, register_block(reg_number));
--             writeline(outfile, outline);
--             reg_number <= reg_number + 1;
--         end loop;
--     end dump_registers;

end register;