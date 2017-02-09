-- Fabrice Normandin, ID 260636800
-- Asher Wright, ID 
-- William Stephen Poole, ID
-- Stephan Greto-McGrath, ID 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768;
  block_count : INTEGER := 32;
  words_per_block : INTEGER := 4
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
  TYPE DATA is array (words_per_block - 1 downto 0) of WORD;
  TYPE CACHE_BLOCK is
  record
      valid : std_logic;
      dirty : std_logic;
      tag : std_logic_vector(5 downto 0);
      data : DATA;
  end record;  
  TYPE CACHE_TYPE IS ARRAY(block_count-1 downto 0) OF CACHE_BLOCK;
    
  
  constant empty_word : WORD := (others => X"00");
  constant empty_cache_block : CACHE_BLOCK := (
                                              valid => '0',
                                              dirty => '0',
                                              tag => (others => '0'),
                                              data => (others => empty_word)
                                              );
  -- the cache
  SIGNAL cache : CACHE_TYPE := (others => empty_cache_block);


  TYPE state_type is (IDLE, COMPARE_TAG, ALLOCATE, WRITE_BACK);
  signal state : state_type;
  signal next_state : state_type;
  
  -- states used for memory interaction FSM's in WRITE_BACK and ALLOCATE states.
  TYPE write_back_sub_state_type is (COMPARE_BYTE_COUNT, WRITE_DATA, INCREMENT);  
  signal write_back_sub_state : write_back_sub_state_type;
  signal next_write_back_sub_state : write_back_sub_state_type;

  TYPE allocate_sub_state_type is (COMPARE_BYTE_COUNT, READ_DATA, GRAB_AND_INCREMENT);
  signal allocate_sub_state : allocate_sub_state_type;
  signal next_allocate_sub_state : allocate_sub_state_type;

  
  -- Using only the 15 relevant bits of the address, since address space is larger than main memory size.
  signal short_address : std_logic_vector(14 downto 0);
  
  signal tag : std_logic_vector(5 downto 0);
  
  signal block_index : integer range block_count - 1 downto 0;
  signal block_offset : integer range words_per_block - 1 downto 0;
  
  
  
  -- we are going to read and write the 4 words of a block to memory one byte at a time.
  -- To do this, we'll use a counter variable (byte_counter) to tell which word, and which byte of this word we're using.
  -- byte_counter will progressively increase from 0 to 15.
  signal byte_counter : integer RANGE 0 to 16;
  
  -- index of which word of the block we are (reading/writing) (to/from) memory.
  signal word_index_counter : integer range 0 to words_per_block;
    
  -- index of which byte in the word we are (reading/writing) (to/from) memory.
  signal word_byte_counter : integer range 0 to 3;
  
  
begin
  -- the subset of s_addr that we actually care about.
  short_address <= s_addr(14 downto 0);
  
  -- @TODO: Make sure that the TAG is indeed only 6 bits and doesn't include the rest of the 32-bit address (ask Prof.).
  tag <= short_address(14 downto 9);

  -- the index of the block in cache
  block_index <= to_integer(unsigned(short_address(8 downto 4)));
  
  -- offset within the block (index of which word in the block)
  block_offset <= to_integer(unsigned(short_address(3 downto 2)));
  
  -- We initialize the word and word_byte counters using the byte_counter value.
  -- tells which word in the block we are currently transfering
  word_index_counter <= byte_counter / 4;
  -- tells which byte in the word we want to read/write
  word_byte_counter <= byte_counter MOD 4;

  -- Standard process (as in PD_1), transitions state at each clock cycle.
  process (clock, reset)
  begin
   if (reset = '1') then
      state <= IDLE;
    elsif(rising_edge(clock)) then
      state <= next_state;
      -- @Fabrice: Not sure where to put these state transitions.
      write_back_sub_state <= next_write_back_sub_state;
      allocate_sub_state <= next_allocate_sub_state;
    end if;
  end process;
  
  update_process : process(state, s_read, s_write, m_waitrequest, allocate_sub_state, write_back_sub_state)
  variable WW : std_logic_vector(1 downto 0);
  variable BB : std_logic_vector(1 downto 0);
  variable m_addr_vector : std_logic_vector(31 downto 0);
  begin
    
    -- simple reset of all blocks if reset = '1'.
    if reset = '1' then
      clear_blocks : for i in 0 to block_count - 1 loop
          cache(i).valid <= '0';
      end loop ; -- clear_blocks
    else
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
          -- if there is a miss, and the old block is clean, grab the rest of the new block from memory, 
          -- and then add the new word (for a write), or read the word (for a read).
          
          -- check the tag to see if it matches.
          if((cache(block_index).tag = tag) AND (cache(block_index).valid = '1')) then
          
            -- we have a cache hit!
            if(s_read = '1') then
              s_readdata <= cache(block_index).data(block_offset)(3) & cache(block_index).data(block_offset)(2) & cache(block_index).data(block_offset)(1) & cache(block_index).data(block_offset)(0);
            else
              -- We are doing a cache write.
              -- we write one byte at a time.
              cache(block_index).data(block_offset)(3) <= s_writedata(31 downto 24);       
              cache(block_index).data(block_offset)(2) <= s_writedata(23 downto 16);
              cache(block_index).data(block_offset)(1) <= s_writedata(15 downto 8);     
              cache(block_index).data(block_offset)(0) <= s_writedata(7 downto 0);
              
              -- We need this in case we're coming from the "ALLOCATE" stage.
              -- (see the PDF for a better explanation)
              cache(block_index).dirty <= '1';
            end if;
            -- we're done reading or writing.

            next_state <= IDLE;
            s_waitrequest <= '0'; 
          else        
            -- We have a cache miss! 
            -- check if we need to write the content back to memory or not.
            if(cache(block_index).dirty = '1' AND cache(block_index).valid = '1') then
              next_state <= WRITE_BACK;
            else
              next_state <= ALLOCATE;
            end if;      
            
            
            
          end if;
          -- since we will be handling memory in the next states, we need to reset the byte_counter variable.            
          byte_counter <= 0;
          -- set the 'valid' field such that we get a cache hit when we get back to this stage, after fetching data from memory.
          cache(block_index).valid <= '1';
          ---------------------------------------------------------------------------
        when ALLOCATE =>

          case allocate_sub_state is
            when COMPARE_BYTE_COUNT =>
              m_read <= '0';
              if byte_counter = 16 then
                -- we're done allocating a block. set the tag appropriately.
                next_state <= COMPARE_TAG;
                -- @TODO: test this out to make sure we're setting the tag at the right moment.
                cache(block_index).tag <= tag;
              else
                next_state <= ALLOCATE;
                if m_waitrequest = '0' then 
                  -- wait until memory is at "idle".
                  next_allocate_sub_state <= COMPARE_BYTE_COUNT;
                else
                  next_allocate_sub_state <= READ_DATA;
                end if;
              end if;

            when READ_DATA =>
              next_state <= ALLOCATE;
              -- the address looks like this;
              -- -------------------------------
              -- 0000 0000 0000 0000 0000 0000 0000 0000
              -- ssss ssss ssss ssss ssss ssss ssWW BB00
              -- -------------------------------
              -- s: coming from s_addr.
              -- W: which word in the block
              -- B: which byte in the word
              -- NOTE: memory uses bytes as the unit of measurement, hence we need to divide the resulting integer by 4 
              -- (or shift right twice before converting to an integer), giving:
              -- 00ss ssss ssss ssss ssss ssss ssss WWBB
              -- which is done with this:  
              WW := std_logic_vector(to_unsigned(word_index_counter, 2));
              BB := std_logic_vector(to_unsigned(word_byte_counter, 2));
              
              m_addr_vector := "00" & s_addr(31 downto 6) & WW & BB;
              m_addr <= to_integer(unsigned(m_addr_vector));       
              m_read <= '1';

              if m_waitrequest = '1' then
                next_allocate_sub_state <= READ_DATA;
              else
                next_allocate_sub_state <= GRAB_AND_INCREMENT;
              end if;

            when GRAB_AND_INCREMENT =>
              -- write the 8 bits of data from memory in the right position in the cache block.
              cache(block_index).data(word_index_counter)(word_byte_counter) <= m_readdata;
              m_read <= '0';
              byte_counter <= byte_counter + 1;
              
              next_state <= ALLOCATE;
              next_allocate_sub_state <= COMPARE_BYTE_COUNT;
          end case;   
        ---------------------------------------------------------------------------
        when WRITE_BACK =>
          -- write the old block to memory.

          -- @Fabrice: we're using another FSM for the interaction with memory. (see the PDF for an illustration)
          case write_back_sub_state is

            when COMPARE_BYTE_COUNT => -- we compare the byte_counter to check if we're done.
              -- we set the output for this state.
              m_write <= '0';
              if byte_counter = 16 then -- we're done. Move on to ALLOCATE.
                next_state <= ALLOCATE;
              else -- we're not done yet.
                next_state <= WRITE_BACK;
                if m_waitrequest = '1' then -- memory is at "idle" and ready to accept another byte.
                  next_write_back_sub_state <= WRITE_DATA;
                else
                  next_write_back_sub_state <= COMPARE_BYTE_COUNT;
                end if;
              end if;


            when WRITE_DATA =>
              next_state <= WRITE_BACK;
              -- we're writing data on the bus for memory to grab.
              -- the address looks like this;
              -- -------------------------------
              -- 0000 0000 0000 0000 0000 0000 0000 0000
              -- ssss ssss ssss ssss ssss ssss ssWW BB00
              -- -------------------------------
              -- s: coming from s_addr.
              -- W: which word in the block
              -- t: coming from the tag.
              -- B: which byte in the word
              -- NOTE: memory uses bytes as the unit of measurement, hence we need to divide the resulting integer by 4 
              -- (or shift right twice before converting to an integer), giving this address:
              -- 00ss ssss ssss ssss ssss sstt tttt WWBB
              -- which is done with this:   
              WW := std_logic_vector(to_unsigned(word_index_counter, 2));
              BB := std_logic_vector(to_unsigned(word_byte_counter, 2));          
              
              m_addr_vector := "00" & s_addr(31 downto 11) & cache(block_index).tag & WW & BB;
              m_addr <= to_integer(unsigned(m_addr_vector));

              m_write <= '1';
              m_writedata <= cache(block_index).data(word_index_counter)(word_byte_counter);

              if m_waitrequest = '1' then 
                -- memory hasn't grabbed the data yet.
                next_write_back_sub_state <= WRITE_DATA;
              else 
              -- we move to the INCREMENT stage.
                next_write_back_sub_state <= INCREMENT;
              end if;

            when INCREMENT =>
              -- we increment the byte_counter value, and move back to the COMPARE_BYTE_COUNT sub-state.
              m_write <= '0';
              byte_counter <= byte_counter + 1;
              next_state <= WRITE_BACK;
              next_write_back_sub_state <= COMPARE_BYTE_COUNT;
          end case;
      end case;
    end if;
  end process update_process;

end arch;
