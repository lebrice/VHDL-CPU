library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_textio.all;
    use ieee.numeric_std.all;

library std;
    use std.textio.all;


package registers is
     -- number of registers
    constant NUM_REGISTERS : integer := 32;

    -- register entry data structure
    type register_entry is
    record
        busy : std_logic;
        data : std_logic_vector(31 downto 0);
    end record;

    -- register block data structure
    type register_block is array (NUM_REGISTERS-1 downto 0) of register_entry;

    -- function declarations
    function reset_register_block(reg_block : register_block)
        return register_block;
    function set_register(reg_number: integer; reg_data : std_logic_vector(31 downto 0); reg_block : register_block)
        return register_block;
    impure function load_registers
        return register_block;
    procedure dump_registers(reg_block  : register_block);

end registers;

package body registers is

    --function to set all registers to 0;
    function reset_register_block(reg_block : register_block)
        return register_block is
        variable r_block : register_block := reg_block;
    begin 
        for i in r_block' range loop
            r_block(i).busy := '0';
            r_block(i).data := (others => '0');
        end loop;
        return r_block;
    end reset_register_block;

   -- function to set desired register (register_number - 0 to 31) to hold data (register_data)
    function set_register(reg_number: integer; reg_data : std_logic_vector(31 downto 0); reg_block : register_block)
        return register_block is
        variable r_block : register_block := reg_block;
    begin
        r_block(reg_number).data := reg_data;
        return r_block;
    end set_register;

    -- procedure to dump all register contents to a file "register_dump.txt"
    procedure dump_registers(reg_block  : register_block) is
        file      outfile  : text;
        variable  outline  : line;
    begin
        file_open(outfile, "register_file.txt", write_mode);
        for i in reg_block' reverse_range loop
            -- write(outline, string'("R"));
            -- write(outline, i);
            -- write(outline, string'(":"));
            -- write(outline, HT);
            write(outline, reg_block(i).data);
            writeline(outfile, outline);
        end loop;
        file_close(outfile);
    end procedure dump_registers;


    -- -- function to read registers in from file "register_load.txt"
    -- impure function load_registers
    --     return register_block is
    --     file     infile : text;
    --     variable inline : line;
    --     variable r_block : register_block;
    --     -- variable data : std_logic_vector(31 downto 0);
    -- begin
    --     file_open(infile, "register_file.txt", read_mode);
    --     for i in r_block' reverse_range loop
    --         readline(infile, inline);
    --         read(inline, r_block(i).data);
    --     end loop;
    --     return r_block;
    -- end load_registers;

end registers;