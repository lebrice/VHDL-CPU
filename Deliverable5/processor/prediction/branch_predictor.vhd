library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_textio.all;
    use ieee.numeric_std.all;

use work.instruction_tools.all;

entity branch_predictor is
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
end branch_predictor;

architecture branch_prediction_arch of branch_predictor is

    constant minimum_predictor_value : integer := - (2**PREDICTOR_BIT_WIDTH); 
    constant maximum_predictor_value : integer :=   (2**PREDICTOR_BIT_WIDTH) -1;
            
    type predictor_array is array (PREDICTOR_COUNT-1 downto 0) of integer range minimum_predictor_value to maximum_predictor_value;
    signal predictors : predictor_array := (others => 0);
    signal predictor_index : integer;
    signal current_predictor_value : integer range minimum_predictor_value to maximum_predictor_value;
    signal next_predictor_value : integer range minimum_predictor_value to maximum_predictor_value;

    function increment_predictor(value : integer) return integer is
    begin
        if(value < maximum_predictor_value) then
            return value + 1;
        else
            return value;
        end if;    
    end increment_predictor;

    function decrement_predictor(value : integer) return integer is
    begin
        if(value > minimum_predictor_value) then
            return value - 1;
        else
            return value;
        end if;  
    end decrement_predictor;


begin
    -- the predictor we are going to use is the indexed by the lower bit
    predictor_index <= to_integer(unsigned(branch_target(PREDICTOR_BIT_WIDTH-1 downto 0)));
    prediction <= '1' when predictors(predictor_index) > 0 else '0';
    
    current_predictor_value <= predictors(predictor_index);
    predictors(predictor_index) <= next_predictor_value;

    update_predictors : process(clock, instruction, branch_target, branch_taken)
    begin
        -- start with this assumption. We will overwrite it if we find there should be a change.
        next_predictor_value <= current_predictor_value;
        if(rising_edge(clock)) then
            if(instruction.instruction_type = BRANCH_IF_EQUAL OR instruction.instruction_type = BRANCH_IF_NOT_EQUAL) then
                                
                if(branch_taken = '1') then
                    next_predictor_value <= increment_predictor(current_predictor_value);
                else
                    next_predictor_value <= decrement_predictor(current_predictor_value);
                end if;
            end if;
        end if;
    end process;

    

end branch_prediction_arch;

