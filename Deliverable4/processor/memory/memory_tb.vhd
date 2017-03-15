LIBRARY ieee;
    USE ieee.std_logic_1164.all;
    USE ieee.numeric_std.all;

ENTITY memory_tb IS
END memory_tb;

ARCHITECTURE behaviour OF memory_tb IS

  
    constant bit_width : INTEGER := 32;
    constant ram_size : INTEGER := 8192;
    constant clock_period : time := 1 ns;
    
--Declare the component that you are testing:
    COMPONENT memory IS
        GENERIC(
          ram_size : INTEGER := ram_size;
		      bit_width : INTEGER := bit_width;
		      mem_delay : time := 0.1 ns;
		      clock_period : time := clock_period
        );
        PORT (
            clock: IN STD_LOGIC;
            writedata: IN STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
            address: IN INTEGER RANGE 0 TO ram_size-1;
            memwrite: IN STD_LOGIC := '0';
            memread: IN STD_LOGIC := '0';
            memdump: IN STD_LOGIC := '0';
            memload: IN STD_LOGIC := '0';
            readdata: OUT STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);  -- doesnt compile
            waitrequest: OUT STD_LOGIC                              -- doesnt compile
        ); 
    END COMPONENT;
    
    

    --all the input signals with initial values
    signal clk : std_logic := '0';
    signal writedata: std_logic_vector(bit_width-1 downto 0);
    signal address: INTEGER RANGE 0 TO ram_size-1;
    signal memwrite: STD_LOGIC := '0';
    signal memread: STD_LOGIC := '0';
    signal memdump: STD_LOGIC := '0';
    signal memload: STD_LOGIC := '0';
    signal readdata: STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
    signal waitrequest: STD_LOGIC;


BEGIN
    --dut => Device Under Test
    dut: memory GENERIC MAP(
            ram_size => 15
                )
                PORT MAP(
                    clk,
                    writedata,
                    address,
                    memwrite,
                    memread,
                    memdump,
                    memload,
                    readdata,
                    waitrequest
                );

    clk_process : process
    BEGIN
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;
    end process;

    test_process : process
    BEGIN
        report "testing memory" severity note;
        wait for clock_period;
        address <= 14; 
        writedata <= X"12345678";
        memwrite <= '1';
        report "data written" severity note;
        --waits are NOT synthesizable and should not be used in a hardware design
        wait until rising_edge(waitrequest);
        memwrite <= '0';
        memread <= '1';
        wait until rising_edge(waitrequest);
        assert readdata = x"12345678" report "write unsuccessful" severity error;
        memread <= '0';
        report "data read" severity note;
        memload <= '1';
        wait for clock_period;
        memload <= '0';
        report "memory loaded" severity note;
        memdump <= '1';
        report "memory dumped" severity note;
        report "done testing memory." severity note;
        wait;


    END PROCESS;

 
END;