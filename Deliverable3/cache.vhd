-- Fabrice Normandin, ID 260636800
-- Asher Wright, ID 
-- William Stephen Poole, ID
-- Stephan Greto-McGrath, ID 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic; 
    
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is  
  TYPE DATA is array (3 downto 0) of std_logic_vector(31 downto 0);
  TYPE CACHE_BLOCK is
  record
      valid : std_logic;
      dirty : std_logic;
      tag : std_logic_vector(5 downto 0);
      data : DATA;
  end record;  
  TYPE CACHE_TYPE IS ARRAY(31 downto 0) OF CACHE_BLOCK;
  
  
  -- @TODO: figure out which states the FSM needs.
  type state_type is (READING, WRITING, WAITING, IDLE);
  signal state : state_type;
  signal next_state : state_type;

  
  -- the cache
  SIGNAL cache : CACHE_TYPE;
  
  -- Using only the 15 relevant bits of the address, since address space is larger than main memory size.
  signal short_address : std_logic_vector(14 downto 0);
  
  signal tag : std_logic_vector(5 downto 0);
  
  signal block_index_vector : std_logic_vector(4 downto 0);
  signal block_index : integer range 31 downto 0;
    
  signal block_offset_vector: std_logic_vector(1 downto 0);
  signal block_offset : integer range 3 downto 0;
  
begin
    
  short_address <= s_addr(14 downto 0);
  
  -- @TODO: Make sure that the TAG is indeed only 6 bits and doesn't include the rest of the 32-bit address (ask Prof.).
  tag <= short_address(14 downto 9);
  block_index_vector <= short_address(8 downto 4);
  block_index <= to_integer(unsigned(block_index_vector));
  
  block_offset_vector <= short_address(3 downto 2);
  block_offset <= to_integer(unsigned(block_offset_vector));
  
  -- @TODO: handle states. (need Asher's godly state diagram for that!)
  --process (clock, reset)
  --begin
  -- if (reset = '1') then
  --    state <= IDLE;
  --  elsif(rising_edge(clock)) then
  --    -- state <= next_state;
  --  end if;
  --end process;
  
  
  -- process responsible for reading data from cache.
  read_process : process(s_read)
    variable read_block : CACHE_BLOCK;
    variable hit : std_logic;
  begin
      if(rising_edge(s_read)) then
          s_waitrequest <= '1';
          -- get the block from cache.
          read_block := cache(block_index);
          
          -- check the tag to see if it matches.
          if((read_block.tag = tag) AND (read_block.valid = '1')) then
          
            -- we have a cache hit!
            hit := '1';
            
            -- @TODO: make sure this is the correct way of outputting data.
            s_readdata <= read_block.data(block_offset);
            
            -- we're done reading.
            s_waitrequest <= '0';
          else
            -- @TODO: We have a cache miss! need to fetch from main memory.
            hit := '0';             
          end if;
        end if;
  end process read_process;
  
  write_process : process(s_write)
  variable write_block : CACHE_BLOCK;
  variable hit : std_logic;
  begin
    if(rising_edge(s_write)) then
        
        -- we start writing.
        s_waitrequest <= '1';
        
        -- get the cache block we're about to write to
        write_block := cache(block_index);
        
        -- check if we have to flush the previous data to main memory or not.      
        if (write_block.tag = tag OR write_block.dirty = '0' OR write_block.valid = '0') then
          -- no need to flush the previous data.
        else         
          -- we need to flush the previous data.
          
          
          -- @TODO: we need to flush the previous block to main memory before we can write the new data in.   
          --
          --
          --
          --
          --
          --
          --
          
          
        end if;        
          
        -- now we can simply overwrite what was previously in the cache.
        
        -- setting the valid and dirty bits to '1'.
          write_block.dirty := '1';
          write_block.valid := '1';
          
          -- we overwrite the tag
          write_block.tag := tag;
          
          -- writing the word that is in 's_writedata' to the corresponding word in cache.
          write_block.data(block_offset) := s_writedata;
          
          
          -- @TODO: check if modifying the variable (write_block) actually changes the block in cache ('cache' signal).
          -- (Not sure that there is a need to set cache[index] = write_block;, just doing it to make sure nothing weird happens)
          cache(block_index) <= write_block;
                    
        -- we're done writing.
        s_waitrequest <= '0';
      end if;
  end process write_process;

end arch;