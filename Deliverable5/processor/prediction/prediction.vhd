library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_textio.all;
    use ieee.numeric_std.all;

use work.instruction_tools.all;

-- package head
package prediction is

    -- size of the buffer
    constant SIZE : integer := 64;
    -- bits to predict
    constant N_BIT_PREDICTION : integer := 1;

     -- branch buffer table data structure
    type buffer_entry is
    record
        taken : std_logic_vector(N_BIT_PREDICTION-1 downto 0);
        pc : Integer;
    end record;

    type branch_buffer is array (SIZE-1 downto 0) of buffer_entry;

    -- function declarations
    function buffer_init return branch_buffer;
    function update_branch_buff(buff : branch_buffer ; pc : Integer ; taken : std_logic ; inst : Instruction) 
        return branch_buffer;
    function update_taken(entry : buffer_entry ; taken : std_logic) 
        return buffer_entry;
    function add_entry(buff : branch_buffer; pc : Integer)
        return branch_buffer;
    
end prediction;


-- package body
package body prediction is
    -- initializes the branch buffer to have 0's as all it's PCs and to set all taken bits to 0
    function buffer_init return branch_buffer is
        variable buff : branch_buffer;
    begin
        for i in buff' range loop
            buff(i).pc := 0;
            buff(i).taken := (others => '0');
        end loop;
        return buff;
    end buffer_init;

    -- update_branch_buff is called on all instructions exiting the execute stage
    -- if instruction is a branch, this function handles updating the buffer
    -- if not, it does nothing
    function update_branch_buff(buff : branch_buffer ; pc : Integer ; taken : std_logic ; inst : Instruction)
        return branch_buffer is
        variable buff_fn : branch_buffer := buff;
        variable found : std_logic := '0';
    begin
        -- check to see if instruction is branch type
        if (inst.instruction_type = branch_if_equal or inst.instruction_type = branch_if_not_equal) then

            -- check to see if this instruction/line/pc is already in the buffer
            for i in buff_fn'range loop
                if (buff_fn(i).pc = pc) then
                    found := '1'; -- it is in the buffer, update its taken bit profile
                    buff_fn(i) := update_taken(buff_fn(i), taken); -- update taken fifo
                end if;
            end loop;

            if(found = '0') then -- it was not in the buffer, add it
                buff_fn := add_entry(buff_fn, pc);
            end if;
        end if;
        return buff_fn;
    end update_branch_buff;
    

    -- update_taken operates on a branch_buffer entry (buffer_entry) by updating its taken bits
    -- it adds the latest taken bit and pushes the oldest one out
    function update_taken(entry : buffer_entry ; taken : std_logic) 
        return buffer_entry is 
        variable entry_fn : buffer_entry := entry;
    begin
        if (N_BIT_PREDICTION >= 2) then
            for i in 0 to N_BIT_PREDICTION-2 loop
                entry_fn.taken(i+1) := entry_fn.taken(i);
            end loop;
        end if;
        entry_fn.taken(0) := taken;
        return entry_fn; 
    end update_taken;

    -- add_entry adds and entry to the buffer and pushes the oldest one out
    function add_entry(buff : branch_buffer; pc : Integer)
        return branch_buffer is
        variable buff_fn : branch_buffer := buff;
    begin
        if (N_BIT_PREDICTION >= 2) then
            for i in 0 to N_BIT_PREDICTION-2 loop
                    buff_fn(i+1).pc := buff_fn(i).pc;
            end loop;
        end if;
        buff_fn(0).pc := pc;
        return buff_fn;
    end add_entry;

end prediction;