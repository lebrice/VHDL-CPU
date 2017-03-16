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
		clock_period : time := 1 ns
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
		memload: IN STD_LOGIC;
		data_or_instruction_specifier: IN character
	);
END memory;

ARCHITECTURE rtl OF memory IS
	TYPE MEM IS ARRAY(ram_size-1 downto 0) OF STD_LOGIC_VECTOR(bit_width-1 DOWNTO 0);
	
  	constant empty_ram_block : MEM := (others => (others => '0'));
	SIGNAL ram_block: MEM := empty_ram_block;
	SIGNAL read_address_reg: INTEGER RANGE 0 to ram_size-1;
	SIGNAL write_waitreq_reg: STD_LOGIC := '1';
	SIGNAL read_waitreq_reg: STD_LOGIC := '1';
BEGIN
	--This is the main section of the SRAM model

	-- process to dump memory to file
	dump_process: PROCESS(memdump)
		file     outfile  : text;
		variable outline : line;
	BEGIN
		IF(rising_edge(memdump)) THEN
			--TODO: Add generics for the paths
			file_open(outfile, "processor\memory\mem_out" & data_or_instruction_specifier & ".txt", write_mode);
        	for i in ram_block' reverse_range loop
				write(outline, ram_block(i));
				writeline(outfile, outline);
        	end loop;
			file_close(outfile);

		END IF;
	END PROCESS;


	mem_process: PROCESS (clock, memload)
		file 	 infile: text;
		variable inline: line;
		variable data: std_logic_vector(bit_width-1 DOWNTO 0);
		variable data_init_complete: boolean := false;
	BEGIN
		--This is a cheap trick to initialize the SRAM in simulation
		-- IF(now < 1 ps)THEN
		-- 	For i in 0 to ram_size-1 LOOP
		-- 		ram_block(i) <= std_logic_vector(to_unsigned(i,bit_width));
		-- 	END LOOP;
		-- end if;
	

	-- load memory from file "memory_load.text" when a rising edge is see on memload
	-- load memory is used for testing only, file IO is not synthesizeable	
	if(rising_edge(memload) && data_init_complete = false) THEN
			data_init_complete := true;
			-- TODO: add generics for the paths
			file_open(infile, "processor\memory\mem_in" & data_or_instruction_specifier & ".txt", read_mode);
			for i in ram_block' reverse_range loop
				readline(infile, inline);
				read(inline, data);
				-- writedata <= data;
				ram_block(i) <= data;
			end loop;
			file_close(infile);
	-- This is the actual synthesizable SRAM block 
	elsif (rising_edge(clock)) THEN
			IF (memwrite = '1') THEN
				ram_block(address) <= writedata;
			END IF;
		read_address_reg <= address;
		END IF;
	END PROCESS;
	readdata <= ram_block(read_address_reg);


	--The waitrequest signal is used to vary response time in simulation
	--Read and write should never happen at the same time.
	waitreq_w_proc: PROCESS (memwrite)
	BEGIN
		IF(memwrite'event AND memwrite = '1')THEN
			write_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;

		END IF;
	END PROCESS;

	waitreq_r_proc: PROCESS (memread)
	BEGIN
		IF(memread'event AND memread = '1')THEN
			read_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;
		END IF;
	END PROCESS;
	waitrequest <= write_waitreq_reg and read_waitreq_reg;


END rtl;
