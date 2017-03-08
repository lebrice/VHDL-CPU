library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


package REGISTER is

    TYPE REGISTER_ENTRY is
    record
        busy : std_logic;
        data : std_logic_vector(31 downto 0);
    end record;
    
    TYPE REGISTER is array (31 downto 0) of REGISTER_ENTRY;  

end REGISTER;

package body REGISTER is

    function set_register(instruction : std_logic_vector(31 downto 0))
     
    end set_register;

end REGISTER;