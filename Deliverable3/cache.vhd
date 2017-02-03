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
  TYPE WORD is array (3 downto 0) of std_logic_vector(7 downto 0);
  TYPE DATA is array (3 downto 0) of WORD;
  TYPE CACHE_BLOCK is
  record
      valid : std_logic;
      dirty : std_logic;
      tag : std_logic_vector(5 downto 0);
      data : DATA;
  end record;  
  TYPE CACHE_TYPE IS ARRAY(31 downto 0) OF CACHE_BLOCK;
  
  
  -- @TODO: figure out which states the FSM needs.
  type state_type is (IDLE, COMPARE_TAG, ALLOCATE, WRITE_BACK);
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
  
  signal old_block : CACHE_BLOCK;
  
  
  -- we are going to read and write the 4 words of a block to memory one byte at a time.
  -- To do this, we'll use a counter variable (byte_counter) to tell which word, and which byte of this word we're using.
  -- byte_counter will progressively increase from 0 to 16.
  signal byte_counter : integer RANGE 0 to 15;
  
  -- index of which word of the block we are (reading/writing) (to/from) memory.
  signal word_index_counter : integer range 0 to 3;
    
  -- index of which byte in the word we are (reading/writing) (to/from) memory.
  signal word_byte_counter : integer range 0 to 3;
  
  
begin
    
  short_address <= s_addr(14 downto 0);
  
  -- @TODO: Make sure that the TAG is indeed only 6 bits and doesn't include the rest of the 32-bit address (ask Prof.).
  tag <= short_address(14 downto 9);
  block_index_vector <= short_address(8 downto 4);
  block_index <= to_integer(unsigned(block_index_vector));
  
  block_offset_vector <= short_address(3 downto 2);
  block_offset <= to_integer(unsigned(block_offset_vector));
  
  word_index_counter <= byte_counter / 4;
  word_byte_counter <= byte_counter MOD 4;
  
  
  -- @TODO: handle states. (need Asher's godly state diagram for that!)
  process (clock, reset)
  begin
   if (reset = '1') then
      state <= IDLE;
    elsif(rising_edge(clock)) then
      state <= next_state;
    end if;
  end process;
  
  update_process : process(state)  
  variable WW : std_logic_vector(1 downto 0);
  variable BB : std_logic_vector(1 downto 0);
  variable m_addr_vector : std_logic_vector(31 downto 0);
  begin
    case state is
      
      --------------------------------------------------------------------------
      when IDLE =>
        if(s_read = '1' OR s_write = '1') then
          s_waitrequest <= '1';
          next_state <= COMPARE_TAG;
        else 
          next_state <= IDLE;
        end if;
      ---------------------------------------------------------------------------
      when COMPARE_TAG =>
        -- check if there is a miss or a hit.
        -- if there is a hit, just go back to the IDLE state.
        -- if there is a miss, and the old block is dirty, write it back to memory. (go to WRITE_BACK)
        -- if there is a miss, and the old block is clean, just grab the rest of new block from memory, 
        --  and then add the new word (for a write), or read the word (for a read).
        old_block <= cache(block_index);
        
        -- check the tag to see if it matches.
        if((old_block.tag = tag) AND (old_block.valid = '1')) then
        
          -- we have a cache hit!
          if(s_read = '1') then
            s_readdata <= old_block.data(block_offset)(3) & old_block.data(block_offset)(2) & old_block.data(block_offset)(1) & old_block.data(block_offset)(0);
          else
            -- we write one byte at a time.
            old_block.data(block_offset)(3) <= s_writedata(31 downto 24);       
            old_block.data(block_offset)(2) <= s_writedata(23 downto 16);
            old_block.data(block_offset)(1) <= s_writedata(15 downto 8);     
            old_block.data(block_offset)(0) <= s_writedata(8 downto 0);
            
            -- we need this in case we're coming from the "ALLOCATE" stage.
            old_block.dirty <= '1';
            old_block.valid <= '1';
          end if;
          
          -- we're done reading or writing.
          next_state <= IDLE;
          s_waitrequest <= '0'; 
        else      
          -- We have a cache miss!
          if(old_block.dirty = '1') then
            next_state <= WRITE_BACK;
          else
            next_state <= ALLOCATE;
          end if;      
          -- since we will be handling memory in the next states, we need to reset the byte_counter variable.            
          byte_counter <= 0;
        end if;
        ---------------------------------------------------------------------------
      when ALLOCATE =>
            
        m_read <= '1';
        
        -- the address looks like this;
        -- -------------------------------
        -- 0000 0000 0000 0000 0000 0000 0000 0000
        -- ssss ssss ssss ssss ssss ssss ssWW BB00
        -- -------------------------------
        -- s: coming from s_addr.
        -- W: which word in the block
        -- B: which byte in the word
        -- which is done with this:   
        WW := std_logic_vector(to_unsigned(word_index_counter, 2));
        BB := std_logic_vector(to_unsigned(word_byte_counter, 2));
        
        m_addr_vector := s_addr(31 downto 6) & WW & BB & "00";
        m_addr <= to_integer(unsigned(m_addr_vector));
        
        
        -- if the memory is ready, we can copy over one byte.
        if(m_waitrequest = '0') then
        
          -- write the 8 bits of data from memory in the right position in the cache block.
          old_block.data(block_offset)(word_byte_counter) <= m_readdata;
          
          if(byte_counter = 15) then
            -- we're done! we copied the whole word from memory into the cache block.
            -- move on to the COMPARE stage and reset the byte counter.
            byte_counter <= 0;
            next_state <= COMPARE_TAG;
          else
            byte_counter <= byte_counter + 1; 
            next_state <= ALLOCATE;
          end if;
          
        else
          -- Memory is not ready, we just wait until memory is done fetching the byte we want.
          next_state <= ALLOCATE; 
        end if;
            
      ---------------------------------------------------------------------------
      when WRITE_BACK =>
        -- write the old block to memory.
        if(m_waitrequest = '0') then
          -- Memory is ready! We can start writing data on the memory bus.
          m_write <= '1';
          m_writedata <= old_block.data(word_index_counter)(word_byte_counter);
                    
        else
          -- memomy just finished writing the data. we can move to the next byte.
          if(byte_counter = 15) then
            -- we're done!
            m_write <= '0';
            byte_counter <= 0;
            next_state <= ALLOCATE;
          else 
            byte_counter <= byte_counter + 1;
            next_state <= WRITE_BACK;
          end if;
        end if;
    end case;
  end process update_process;

compare_tags_process : process(state)
begin
end process compare_tags_process;

write_back_process : process(state)
begin
if(state = WRITE_BACK) then  
  
end if;   
end process write_back_process;

allocate_process : process(state)
begin
if(state = ALLOCATE) then
 
  
  
end if;
end process allocate_process;



end arch;
