library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

    use work.instruction_tools.all;

entity branch_predictor_tb is
end branch_predictor_tb ; 

architecture arch of branch_predictor_tb is
    constant clock_period : time := 1 ns;
    signal clock  : std_logic := '0';
    component branch_predictor is
        generic(
            PREDICTOR_BIT_WIDTH : integer := 2;
            PREDICTOR_COUNT : integer := 8
        );
        port(
            clock : in std_logic;
            instruction : in INSTRUCTION;
            branch_target : in std_logic_vector(31 downto 0);
            branch_taken : in std_logic;
            prediction : out std_logic
        );
    end component;

    signal instruction :INSTRUCTION := NO_OP_INSTRUCTION;
    signal branch_target : std_logic_vector(31 downto 0) := (others => '0');
    signal branch_taken : std_logic := '0';
    signal prediction : std_logic;
begin

    p1 : branch_predictor
    generic map (
        predictor_bit_width => 2
    )
    port map (
        clock,
        instruction,
        branch_target,
        branch_taken,
        prediction
    );


    clk_process : process
    BEGIN
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;

    test_process : process
    begin
        wait;
    end process;



end architecture ;