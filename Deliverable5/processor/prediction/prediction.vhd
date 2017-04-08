library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_textio.all;
    use ieee.numeric_std.all;

-- package head
package prediction is

    -- size of the buffer
    constant SIZE : integer := 64;
    -- bits to predict
    constant N_BIT_PREDICTION : integer := 4;

     -- branch buffer table data structure
    type buffer_entry is
    record
        taken : std_logic_vector(N_BIT_PREDICTION-1 downto 0);
        pc : Integer;
    end record;

    type branch_buffer is array (SIZE-1 downto 0) of buffer_entry;

    -- function declarations
    function buffer_init return branch_buffer;
    function update_branch_buff(buff : branch_buffer ; pc : Integer ; taken : std_logic) 
        return branch_buffer;
    function update_taken(entry : buffer_entry ; taken : std_logic) 
        return buffer_entry;
    function add_entry(buff : branch_buffer; pc : Integer)
        return branch_buffer;
    function branch_decision(fetch_stage_pc : Integer ; branch_buff: branch_buffer)
        return boolean;
    
end prediction;


-- package body
package body prediction is
    
    -- initializes the branch buffer to have 0's as all it's PCs 
    -- and to sets taken bits to alternation 1's and 0's beginning with 0
    function buffer_init return branch_buffer is
        variable buff : branch_buffer;
    begin
        for i in buff' range loop
            buff(i).pc := 0;
            for j in buff(i).taken' range loop
                if ((j mod 2)) = 0 then
                    buff(i).taken(j) := '0';
                    else
                    buff(i).taken(j) := '1';
                end if; 
            end loop;
        end loop;
        return buff;
    end buffer_init;

    -- update_branch_buff is called on all branching instructions exiting the execute stage
    -- this function handles updating the buffer
    function update_branch_buff(buff : branch_buffer ; pc : Integer ; taken : std_logic)
        return branch_buffer is
        variable buff_v : branch_buffer := buff;
        variable found : std_logic;
    begin  
        -- check to see if this instruction/line/pc is already in the buffer
        found := '0';
        for i in buff_v'range loop
            if (buff_v(i).pc = pc) then
                found := '1'; -- it is in the buffer, update its taken bit profile
                buff_v(i) := update_taken(buff_v(i), taken); -- update taken fifo
            end if;
        end loop;

        if(found = '0') then -- it was not in the buffer, add it
            buff_v := add_entry(buff_v, pc);
        end if;
        
        return buff_v;
    end update_branch_buff;
    

    -- update_taken operates on a branch_buffer entry (buffer_entry) by updating its taken bits
    -- it adds the latest taken bit and pushes the oldest one out
    function update_taken(entry : buffer_entry ; taken : std_logic) 
        return buffer_entry is 
        variable entry_v : buffer_entry := entry;
    begin
        if (N_BIT_PREDICTION >= 2) then
            for i in N_BIT_PREDICTION-2 downto 0 loop
                entry_v.taken(i+1) := entry_v.taken(i);
            end loop;
        end if;
        entry_v.taken(0) := taken;
        return entry_v; 
    end update_taken;

    -- add_entry adds and entry to the buffer and pushes the oldest one out
    function add_entry(buff : branch_buffer; pc : Integer)
        return branch_buffer is
        variable buff_v : branch_buffer := buff;
    begin
        for i in SIZE-2 downto 0 loop
                buff_v(i+1) := buff_v(i);
        end loop;
        buff_v(0).pc := pc;
        buff_v(0).taken := "1010";
        return buff_v;
    end add_entry;

    
    -- Function responsible for making an assumption about the taken/not taken behaviour, for branch prediction.
    function branch_decision(fetch_stage_pc : Integer ; branch_buff: branch_buffer)
        return boolean is
        variable ones : Integer;
        variable zeros: Integer;
    begin
        ones := 0;
        -- parse through branch buffer entries
        for i in branch_buff' range loop

            -- fetch pc matches one in buffer
            if (branch_buff(i).pc = fetch_stage_pc) then
                
                -- 1 bit branch prediction
                if (N_BIT_PREDICTION = 1) then
                    if (branch_buff(i).taken(0) = '1') then -- branch was taken last
                        return true;    -- assume it will be taken again
                    else
                        return false;  -- branch was not taken last, assume not taken
                    end if;
                end if;

                -- multiple bit branch prediction

                -- count the number of ones in the in the taken history of identified PC
                for j in branch_buff(i).taken' range loop     
                    if branch_buff(i).taken(j) = '1' then
                        ones := ones + 1; 
                    end if;
                end loop;

                -- determine if the number of 1s if greater than number of 0s
                zeros := N_BIT_PREDICTION - ones;

                -- act
                if (ones > zeros) then      -- more branches, predict taken
                    return true;
                elsif (ones < zeros)then    -- less branches, assume not taken
                    return false;
                elsif(ones = zeros) then    -- equal taken and not taken
                    
                    -- check to see which happened last
                    if (branch_buff(i).taken(0) = '1') then -- branch was taken last
                        return true;    -- assume it will be taken again
                    else
                        return false;  -- branch was not taken last, assume not taken
                    end if;

                end if;  -- act 
            end if; -- fetch pc matches one in buffer
        end loop; -- parse through branch buffer entries

        return false;   -- default return is false for prediction not taken
    end branch_decision;

end prediction;