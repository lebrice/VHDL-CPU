library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_textio.all;
    use ieee.numeric_std.all;

use work.instruction_tools.all;

entity branch_prediction is
    generic(
        size : Integer := 64;
        history_size : Integer := 2;
        prediction_active : std_logic := '1'
	);
	port (
        clock : in std_logic;	
        fetch_pc : in Integer;
        execute_pc : in Integer;
        taken : in std_logic;
        inst : in instruction;
        branch : out std_logic
	);
end branch_prediction;

architecture behavior of branch_prediction is

    type buffer_entry is
    record
        taken : std_logic_vector(history_size-1 downto 0);
        pc : Integer;
    end record;

    type branch_buffer is array (size-1 downto 0) of buffer_entry;

    -- check to see if instruction is a branch type
    function is_branch(inst : instruction)
        return boolean is
    begin
       case inst.instruction_type is
            when branch_if_equal | branch_if_not_equal  =>
                return true;
            when others => 
                return false;
            end case;
    end is_branch;

    function init_taken_history return std_logic_vector is
        variable hist_v : std_logic_vector (history_size-1 downto 0);
    begin
        for i in hist_v' range loop
            if ((i mod 2)) = 0 then
                hist_v(i) := '0';
                else
                hist_v(i) := '1';
            end if; 
        end loop;
        return hist_v;
    end init_taken_history;

    -- initializes the branch buffer to have 0's as all it's PCs 
    -- and to sets taken bits to alternation 1's and 0's beginning with 0
    function init_buffer return branch_buffer is
        variable buff : branch_buffer;
    begin
        for i in buff' range loop
            buff(i).pc := 0;

            buff(i).taken := init_taken_history;
        end loop;
        return buff;
    end init_buffer;

    -- update_taken operates on a branch_buffer entry (buffer_entry) by updating its taken bits
    -- it adds the latest taken bit and pushes the oldest one out
    function update_taken(entry : buffer_entry ; taken : std_logic) 
        return buffer_entry is 
        variable entry_v : buffer_entry := entry;
    begin
        if (history_size >= 2) then
            for i in history_size-2 downto 0 loop
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
        for i in size-2 downto 0 loop
                buff_v(i+1) := buff_v(i);
        end loop;
        buff_v(0).pc := pc;
        buff_v(0).taken := init_taken_history;
        return buff_v;
    end add_entry;

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
                if (history_size = 1) then
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
                zeros := history_size - ones;
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

begin
    -- check to see if branch should be taken
    -- sets branch to '1' is it should and '0' otherwise
    branch_prediction : process(clock)
        variable branch_buff : branch_buffer;
        variable make_buffer : boolean := true;
    begin
        -- check to see if branch prediction is prediction_active
        if (prediction_active = '1') then
            -- initialize a buffer
            if (make_buffer) then
                branch_buff := init_buffer;
                make_buffer := false;
            end if;
            -- run the check on the clock
            if rising_edge(clock) and is_branch(inst) then              
                -- update the branch buffer
                branch_buff := update_branch_buff(branch_buff, execute_pc, taken);
                -- ask if branch should be taken
                if (branch_decision(fetch_pc, branch_buff)) then
                    branch <= '1';
                else
                    branch <= '0';
                end if;        
            end if; -- rising edge
        end if; -- prediction_active
    end process;
end behavior;