library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;

library STD;
use STD.textio.all;


package REGISTERS is
     -- number of registers
    constant NUM_REGISTERS : integer := 31;
    -- register entry data structure
    TYPE REGISTER_ENTRY is
    record
        busy : std_logic;
        data : std_logic_vector(31 downto 0);
    end record;
    -- register block data structure
    TYPE REGISTER_BLOCK is array (NUM_REGISTERS downto 0) of REGISTER_ENTRY; 

    function reset_register_block(reg_block : REGISTER_BLOCK)
        return REGISTER_BLOCK;
    function set_register(reg_number: integer; reg_data : std_logic_vector(31 downto 0); reg_block : REGISTER_BLOCK)
        return REGISTER_BLOCK;
    function dump_registers(reg_block  : REGISTER_BLOCK)
        return std_logic;
end REGISTERS;

package body REGISTERS is

    --function to set all registers to 0;
    function reset_register_block(reg_block : REGISTER_BLOCK)
        return REGISTER_BLOCK is
        variable r_block : REGISTER_BLOCK := reg_block;
    begin 
        for i in r_block' range loop
            r_block(i).busy := '0';
            r_block(i).data := (others => '0');
        end loop;
        return r_block;
    end reset_register_block;

   -- function to set desired register (register_number - 0 to 31) to hold data (register_data)
    function set_register(reg_number: integer; reg_data : std_logic_vector(31 downto 0); reg_block : REGISTER_BLOCK)
        return REGISTER_BLOCK is
        variable r_block : REGISTER_BLOCK := reg_block;
    begin
        r_block(reg_number).data := reg_data;
        return r_block;
    end set_register;


    -- TODO check out warning (vcom-1283) Cannot reference file "outfile" inside pure function "dump_registers".
    -- function to dump all register contents to a file "register_dump.txt"
    function dump_registers(register_block  : REGISTER_BLOCK)
        return std_logic is
        file      outfile  : text;
        variable  outline  : line;
    begin
        file_open(outfile, "register_dump.txt", write_mode);
        for i in register_block' range loop
            write(outline, register_block(i).data);
            writeline(outfile, outline);
        end loop;
        file_close(outfile);
        return '1';
    end dump_registers;

end REGISTERS;