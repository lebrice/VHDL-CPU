--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	USE ieee.numeric_std.all;
	USE ieee.std_logic_textio.all;

library std;
    use std.textio.all;

ENTITY memory IS
	GENERIC(
		ram_size : INTEGER := 8192;
		bit_width : INTEGER := 32;
		mem_delay : time := 0.1 ns;
		clock_period : time := 1 ns;
		data_dump_filename : STRING := "memory.txt";
		instruction_load_filename : STRING := "program.txt"
	);
	PORT (
		clock: IN STD_LOGIC;
		writedata: IN STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
		address: IN INTEGER RANGE 0 TO ram_size-1;
		memwrite: IN STD_LOGIC;
		memread: IN STD_LOGIC;
		readdata: OUT STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
		waitrequest: OUT STD_LOGIC;
		memdump: IN STD_LOGIC;
		memload: IN STD_LOGIC
	);
END memory;

ARCHITECTURE rtl OF memory IS
	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(bit_width-1 DOWNTO 0);
	
  	constant empty_ram_block : MEM := (others => (others => '0'));
	SIGNAL ram_block: MEM := empty_ram_block;
	SIGNAL read_address_reg: INTEGER RANGE 0 to ram_size-1;
	SIGNAL write_waitreq_reg: STD_LOGIC := '1';
	SIGNAL read_waitreq_reg: STD_LOGIC := '1';

	procedure dump_memory_to_file (mem : MEM) is
		file     outfile  : text;
		variable outline : line;
	begin
		--TODO: Add generics for the paths
		file_open(outfile, data_dump_filename, write_mode);
		for i in 0 to RAM_SIZE-1 loop
			write(outline, mem(i));
			writeline(outfile, outline);
		end loop;
		file_close(outfile);
	end dump_memory_to_file;

	-- load memory from file "program.txt" when a rising edge is seen on memload
	-- load memory is used for testing only, file IO is not synthesizeable
	procedure load_memory_from_file (signal mem : out MEM) is
		file 	 infile: text;
		variable inline: line;
		variable data: std_logic_vector(bit_width-1 DOWNTO 0);
	begin
		file_open(infile, instruction_load_filename, read_mode);
		for i in 0 to RAM_SIZE-1 loop
			readline(infile, inline);
			read(inline, data);
			mem(i) <= data;
		end loop;
		file_close(infile);
	end load_memory_from_file;



BEGIN
	dump_process: PROCESS(memdump)
	BEGIN
		IF(rising_edge(memdump)) THEN
			dump_memory_to_file(ram_block);
		END IF;
	END PROCESS;

	mem_process: PROCESS (clock, memload, address)
	BEGIN	
		if(rising_edge(memload)) THEN
			report "Loading data memory from file 'program.txt'.";
			load_memory_from_file(ram_block);
		else
			IF (memwrite = '1') THEN
				ram_block(address) <= writedata;
			END IF;
		END IF;
	END PROCESS;
	readdata <= ram_block(address);

	--The waitrequest signal is used to vary response time in simulation
	--Read and write should never happen at the same time.
	waitreq_w_proc: PROCESS (memwrite)
	BEGIN
		IF(rising_edge(memwrite))THEN
			write_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;
		END IF;
	END PROCESS;

	waitreq_r_proc: PROCESS (memread)
	BEGIN
		IF(rising_edge(memread))THEN
			read_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;
		END IF;
	END PROCESS;

	waitrequest <= write_waitreq_reg and read_waitreq_reg;


END rtl;
