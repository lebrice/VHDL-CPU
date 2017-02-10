-- cache_tb.vhd: For testing cache.vhd
-- Fabrice Normandin, ID 260636800
-- Asher Wright, ID 260559393
-- William Stephen Poole, ID 260508650
-- Stephan Greto-McGrath, ID 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache_tb is

end cache_tb;

architecture behavior of cache_tb is

component cache is
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
end component;

component memory is 
GENERIC(
    ram_size : INTEGER := 32768;
    mem_delay : time := 10 ns;
    clock_period : time := 1 ns
);
PORT (
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    address: IN INTEGER RANGE 0 TO ram_size-1;
    memwrite: IN STD_LOGIC;
    memread: IN STD_LOGIC;
    readdata: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    waitrequest: OUT STD_LOGIC
);
end component;
	
-- test signals 
signal reset : std_logic := '0';
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal s_addr : std_logic_vector (31 downto 0);
signal s_read : std_logic;
signal s_readdata : std_logic_vector (31 downto 0);
signal s_write : std_logic;
signal s_writedata : std_logic_vector (31 downto 0);
signal s_waitrequest : std_logic;

signal m_addr : integer range 0 to 2147483647;
signal m_read : std_logic;
signal m_readdata : std_logic_vector (7 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (7 downto 0);
signal m_waitrequest : std_logic; 


function make_addr (tag : integer; block_index : integer; block_offset: integer) return std_logic_vector is
    variable tag_vector : std_logic_vector(5 downto 0) := std_logic_vector(to_unsigned(tag, 6));
    variable block_index_vector : std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(block_index, 5));
    variable block_offset_vector : std_logic_vector(1 downto 0) := std_logic_vector(to_unsigned(block_offset, 2));
begin

    -- the address looks like this;
    -- -------------------------------
    -- 0000 0000 0000 0000 0000 0000 0000 0000
    -- ssss ssss ssss ssss sttt ttts ssss WWBB
    return X"0000" & "0" & tag_vector & block_index_vector & block_offset_vector & "00";
end make_addr;
begin

-- Connect the components which we instantiated above to their
-- respective signals.
dut: cache 
port map(
    clock => clk,
    reset => reset,

    s_addr => s_addr,
    s_read => s_read,
    s_readdata => s_readdata,
    s_write => s_write,
    s_writedata => s_writedata,
    s_waitrequest => s_waitrequest,

    m_addr => m_addr,
    m_read => m_read,
    m_readdata => m_readdata,
    m_write => m_write,
    m_writedata => m_writedata,
    m_waitrequest => m_waitrequest
);

MEM : memory
port map (
    clock => clk,
    writedata => m_writedata,
    address => m_addr,
    memwrite => m_write,
    memread => m_read,
    readdata => m_readdata,
    waitrequest => m_waitrequest
);
				

clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process : process
variable tag : integer;
variable block_index : integer range 0 to 31;
variable block_offset : integer range 0 to 3;
variable tag_1 : integer;
variable tag_2 : integer;
variable data_1 : std_logic_vector(31 downto 0);
variable data_2 : std_logic_vector(31 downto 0);
begin

-- put your tests here
s_read <= '0';
s_write <= '0';

wait for 2 * clk_period;
report "---------------------------------------------------------------------------------------------------";
report "------------------------------------------- START OF TESTING --------------------------------------";
report "---------------------------------------------------------------------------------------------------";
report "Start of Functional Testing";

-- ------------------Functionality testing ----------------------------
--(testing the innards of the code, rather than the high-level interaction
tag_1 := 17;
tag_2 := 23;
data_1 := X"12345678";
data_2 := X"FFFF7777";

s_addr <= make_addr(tag_1,0,0);
s_writedata <= data_1;
s_read <= '0';
s_write <= '1';
wait until falling_edge(s_waitrequest);
s_write <= '0';

-- read, expect to have data_1 back.
s_read <= '1';
wait until falling_edge(s_waitrequest);
assert s_readdata = data_1 report "Functional test: first read failed! (expected data_1)" severity ERROR;
s_read <= '0';
report "First functional test complete";
-- write data_2 over data_1. (cache miss, write_back should flush data_1 to memory first)

s_addr <= make_addr(tag_2, 0, 0);
s_writedata <= data_2;
s_write <= '1';
wait until falling_edge(s_waitrequest);
s_write <= '0';


-- read what's in cache, should have data_2.
s_read <= '1';
wait until falling_edge(s_waitrequest);
assert s_readdata = data_2 report "Functional test: second read failed! (expected data_2)" severity ERROR;
s_read <= '0';
report "Second functional test complete";

-- now: try to read data_1 (which was previously flushed to memory!)
s_addr <= make_addr(tag_1, 0, 0);
s_read <= '1';
wait until falling_edge(s_waitrequest);
assert s_readdata = data_1 report "Functional test: third read failed! (expected data_1 to be fetched from memory and then served!)" severity ERROR;
report "Third functional test complete.";
s_read <= '0';

-- now, try to read data_2 again! (which was flushed to memory in the last read).
s_addr <= make_addr(tag_2, 0, 0);
s_read <= '1';
wait until falling_edge(s_waitrequest);
assert s_readdata = data_2 report "Functional test: fourth read failed! (expected data_2 to be fetched from memory and then served!)" severity ERROR;
s_read <= '0';
report "Fourth functional test complete.";
report "Functional Testing complete.";

report "Beginning of Integration testing.";
------------------- Integration tests (16 cases) ---------------------------

-- the address looks like this;
-- -------------------------------
-- 0000 0000 0000 0000 0000 0000 0000 0000
-- ssss ssss ssss ssss ssss sstt tttt WWBB

-- ***********************************************************************************
-- Case 1: Invalid, Clean, Write, Different Tags (0000).
-- ***********************************************************************************
report "Testing Case 1 (invalid, clean, write, different tags)";
s_read <= '0';
s_write <= '1';
s_addr <= make_addr(0,0,0); -- Tag = 0.
s_writedata <= X"FFFFFFFF";
wait until falling_edge(s_waitrequest);

--Read and assert
s_write <= '0';
s_read <= '1';
wait until falling_edge(s_waitrequest);
s_read <= '0';
assert s_readdata = X"FFFFFFFF" report "Write unsuccesfull!" severity ERROR;
report "Case 1 Finished";

-- Cases 2,3, & 4 are not possible without interference with a reset. Thus they will not be tested
-- Case 2: Invalid, Clean, Write, Same Tags (0001).
-- Case 3: Invalid, Clean, Read, Different Tags (0010).
-- Case 4: Invalid, Clean, Read, Same Tags (0011).

-- Cases 5 - 8: IMPOSSIBLE (can't be invalid and dirty...)
report "Skipping impossible cases";

-- ***********************************************************************************
-- Preparation/Setup for future cases.
-- ***********************************************************************************
-- Now we will fill in a bunch of the cache blocks with "good", valid data.
-- This way we have valid data for the end of time...
report "Setting up Memory and Cache for future cases...";
s_read <= '0';
s_write <= '1';
FOR i IN 2 to 9 LOOP
    s_addr <= make_addr(i,i,0); -- Tag = i.
    s_writedata <= X"FFFFFFFE"; -- & std_logic_vector(to_unsigned(i-2, 4));
    wait until falling_edge(s_waitrequest);
END LOOP;

-- Write in second wave of data.
FOR i IN 2 to 9 LOOP
    s_addr <= make_addr(65-i,i,0); -- Tag = i.
    s_writedata <= X"FFFFFFFD"; -- & std_logic_vector(to_unsigned(i-2, 4));
    wait until falling_edge(s_waitrequest);
END LOOP;

-- Read in first half of values to make their blocks Clean in the cache.
s_read <= '1';
s_write <= '0';
FOR i IN 2 to 5 LOOP
    s_addr <= make_addr(i,i,0);
    wait until falling_edge(s_waitrequest);
END LOOP;
report "Finished setting up Memory and Cache.";
-- ***********************************************************************************
-- Case 9: Valid, Clean, Write, Different Tags.
-- ***********************************************************************************
report "Testing Case 9 (valid, clean, write, different tags)";
s_read <= '0';
s_write <= '1';
s_addr <= make_addr(3,2,0); -- Note that tags don't match. Corresponding tag of block 2 is 2.
s_writedata <= X"FFFFFFFF";
wait until falling_edge(s_waitrequest);

-- Read data back and assert.
s_write <= '0';
s_read <= '1';
wait until falling_edge(s_waitrequest);
s_read <= '0';
assert s_readdata = X"FFFFFFFF" report "Write unsuccesfull! Was expecting FFFFFFFF " SEVERITY ERROR;
report "Case 9 Finished";


-- ***********************************************************************************
-- Case 10: Valid, Clean, Write, Same Tags.
-- ***********************************************************************************
report "Testing Case 10 (Valid, clean, write, same tags)";
s_read <= '0';
s_write <= '1';
s_addr <= make_addr(3,3,0); -- Note that tags do match. Corresponding tag of block 3 is 3.
s_writedata <= X"FFFFFFFF";
wait until falling_edge(s_waitrequest);
-- Read data back and assert.
s_write <= '0';
s_read <= '1';
wait until falling_edge(s_waitrequest);
s_read <= '0';
assert s_readdata = X"FFFFFFFF" report "Write unsuccesfull! Was expecting FFFFFFFF " SEVERITY ERROR;
report "Case 10 Finished";

-- ***********************************************************************************
-- Case 11: Valid, Clean, Read, Different Tags. *** This does not work.
-- ***********************************************************************************
report "Testing Case 11 (Valid, clean, read, different tags)";
s_read <= '1';
s_write <= '0';
s_addr <= make_addr(61,4,0); -- Note that tags don't match. Corresponding tag of block 4 is 4.
wait until falling_edge(s_waitrequest);
assert s_readdata = X"FFFFFFFD" report "Read unsuccesfull! Was expecting FFFFFFFD " SEVERITY ERROR;
report "Case 11 Finished";

-- ***********************************************************************************
-- Case 12: Valid, Clean, Read, Same Tags.
-- ***********************************************************************************
report "Testing Case 12 (valid, clean, read, same tags)";
s_read <= '1';
s_write <= '0';
s_addr <= make_addr(5,5,0); -- Note that tags do match. Corresponding tag of block 5 is 5.
wait until falling_edge(s_waitrequest);
assert s_readdata = X"FFFFFFFE" report "Read unsuccesfull! Was expecting FFFFFFFE " SEVERITY ERROR;
report "Case 12 finished";

-- ***********************************************************************************
-- Case 13: Valid, Dirty, Write, Different Tags.
-- ***********************************************************************************
report "Testing Case 13 (valid, dirty, write, different tags";
s_read <= '0';
s_write <= '1';
s_addr <= make_addr(7,6,0); -- Note that tags don't match. Corresponding tag of block 6 is 6.
s_writedata <= X"FFFFFFFF";
wait until falling_edge(s_waitrequest);
-- Read data back and assert.
s_write <= '0';
s_read <= '1';
wait until falling_edge(s_waitrequest);
s_read <= '0';
assert s_readdata = X"FFFFFFFF" report "Write unsuccesfull! Was expecting FFFFFFFF " SEVERITY ERROR;
report "Case 13 Finished.";

-- ***********************************************************************************
-- Case 14: Valid, Dirty, Write, Same Tags.
-- ***********************************************************************************
report "Testing Case 14 (valid, dirty, write, same tags)";
s_read <= '0';
s_write <= '1';
s_addr <= make_addr(7,7,0); -- Note that tags do match. Corresponding tag of block 7 is 7.
s_writedata <= X"FFFFFFFF";
wait until falling_edge(s_waitrequest);
-- Read data back and assert.
s_write <= '0';
s_read <= '1';
wait until falling_edge(s_waitrequest);
s_read <= '0';
assert s_readdata = X"FFFFFFFF" report "Write unsuccesfull! Was expecting FFFFFFFF " SEVERITY ERROR;
report "Case 14 Finished.";
-- ***********************************************************************************
-- Case 15: Valid, Dirty, Read, Different Tags. *** This does not work.
-- ***********************************************************************************
report "Testing Case 15 (valid, dirty, read, different tags)";
s_read <= '1';
s_write <= '0';
s_addr <= make_addr(57,8,0); -- Note that tags don't match. Corresponding tag of block 8 is 8.
wait until falling_edge(s_waitrequest);
assert s_readdata = X"FFFFFFFD" report "Read unsuccesfull! Was expecting FFFFFFFD " SEVERITY ERROR;
report "Case 15 Finished.";

-- ***********************************************************************************
-- Case 16: Valid, Dirty, Read, Same Tags. *** This does not work.
-- ***********************************************************************************
report "Testing Case 16 (valid, dirty, read, same tags)";
s_read <= '1';
s_write <= '0';
s_addr <= make_addr(56,9,0); -- Note that tags do match. Corresponding tag of block 9 is 9.
wait until falling_edge(s_waitrequest);
assert s_readdata = X"FFFFFFFD" report "Read unsuccesfull! Was expecting FFFFFFFD " SEVERITY ERROR;
report "Case 16 Finished.";
report "Testing Complete.";


report "---------------------------------------------------------------------------------------------------";
report "------------------------------------------- END OF TESTING --------------------------------------";
report "---------------------------------------------------------------------------------------------------";
wait;	

end process;
	
end;