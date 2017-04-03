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
    constant N_BIT_PREDICTION : integer := 2;

    -- fifo queue to record history of branches taken on a certain instruction
    type taken_fifo is
    record
        head : integer;
        tail : integer;
        bits : std_logic_vector(N_BIT_PREDICTION-1 downto 0);
    end record;

     -- branch buffer table data structure
    type buffer_entry is
    record
        taken : taken_fifo; -- use when updating to N bit prediction
        pc : Integer;
    end record;

    type pc_data is array (SIZE-1 downto 0) of buffer_entry;

    type branch_buffer is
    record
        head : integer;
        tail : integer;
        data : pc_data;
    end record;


    -- function declarations
    function buffer_init return branch_buffer;
    function update_branch(buff : branch_buffer ; pc : Integer ; taken : std_logic ; inst : Instruction) 
        return branch_buffer;
    



end prediction;


-- package body
package body prediction is

    -- initializes the branch buffer to have 0's as all it's PCs and to set all taken bits to 0
    function buffer_init return branch_buffer is
        variable buff : branch_buffer;
    begin
        buff.head := 0;
        buff.tail := N_BIT_PREDICTION;
        for i in buff.data' range loop
            buff.data(i).pc := 0;
            buff.data(i).taken.bits := (others => '0');
        end loop;
        return buff;
    end buffer_init;

    -- update_branch is called on instruction exiting the execute stage
    -- if instruction is a branch, this function handles updating the buffer
    function update_branch(buff : branch_buffer ; pc : Integer ; taken : std_logic ; inst : Instruction)
        return branch_buffer is
        variable buff_fn : branch_buffer := buff;
        variable found : std_logic := '0';
    begin
        -- check to see if instruction is branch type
        if (inst.instruction_type = branch_if_equal or inst.instruction_type = branch_if_not_equal) then

            -- check to see if this instruction/line/pc is already in the buffer
            for i in buff_fn.data'range loop
                if (buff_fn.data(i).pc = pc) then
                    found := '1'; -- it is in the buffer, update its taken bit profile
                    -- buff_fn = update_taken(buff_fn, taken, i) -- update taken fifo
                end if;
            end loop;

            if(found = '0') then -- it was not in the buffer, add it
                -- buff_fn = add_entry(buff_fn, pc)
            end if;
        end if;
    end update_branch;
    


    -- function update_taken(taken : std_logic_vector(N_BIT_PREDICTION-1 downto 0)) 
    --     return std_logic_vector(N_BIT_PREDICTION-1 downto 0) is 
    -- begin
    -- end update_taken;


    -- function update_buffer(buff: branch_buffer; pc : Integer; taken std_logic) 
    --     return branch_buffer is
        
    -- begin
        
    -- end update_buffer;



end prediction;