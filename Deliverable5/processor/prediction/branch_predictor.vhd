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
        -- inputs that are used to update the predictor.
        target : in std_logic_vector(31 downto 0);
        branch_taken : in std_logic;
        -- input that is used to query the branch predictor for a prediction.
        target_to_evaluate : in std_logic_vector(31 downto 0);
        prediction : out std_logic
    );
end branch_predictor;

architecture branch_prediction_arch of branch_predictor is

    constant minimum_predictor_value : integer := - (2**PREDICTOR_BIT_WIDTH); 
    constant maximum_predictor_value : integer :=   (2**PREDICTOR_BIT_WIDTH) -1;
            
    type predictor_array is array (PREDICTOR_COUNT-1 downto 0) of integer range minimum_predictor_value to maximum_predictor_value;
    signal predictors : predictor_array := (others => 0);
    signal evaluation_predictor_index : integer range 0 to PREDICTOR_COUNT-1;
    signal predictor_index : integer range 0 to PREDICTOR_COUNT-1;
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

    -- index of the predictor to evaluate: we use only some of the lowest bits, to index into the array.
    -- Since the target can be the PC or the target address, etc, we forget about the lowest two bits, since they would always be zeroes.
    evaluation_predictor_index <= to_integer(unsigned(target_to_evaluate(2 + PREDICTOR_BIT_WIDTH-1 downto 2)));
    -- we predict taken when the counter is positive or zero, and not_taken whenever it is negative.
    prediction <= '1' when predictors(evaluation_predictor_index) >= 0 else '0';

    -- index of the predictor to update
    predictor_index <= to_integer(unsigned(target(PREDICTOR_BIT_WIDTH-1 downto 0)));
    current_predictor_value <= predictors(predictor_index);
    predictors(predictor_index) <= next_predictor_value;

    update_predictors : process(clock, instruction, target, branch_taken)
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

