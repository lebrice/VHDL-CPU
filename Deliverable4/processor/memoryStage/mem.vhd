LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY mem is
    port (
        clock : in std_logic;
        ALU_result_in : in std_logic_vector(31 downto 0);
        ALU_result_out : out std_logic_vector(31 downto 0);
        instruction_in : in std_logic_vector(31 downto 0);
        instruction_out : out std_logic_vector(31 downto 0);
        branch_taken_in : in  std_logic;
        branch_taken_out : out  std_logic;
        val_b : in std_logic_vector(31 downto 0);
        mem_data : out std_logic_vector(31 downto 0);

        m_addr : out integer range 0 to ram_size-1;
        m_read : out std_logic;
        m_readdata : in std_logic_vector (bit_width-1 downto 0);        
        m_writedata : out std_logic_vector (bit_width-1 downto 0);
        m_write : out std_logic;
        m_waitrequest : in std_logic -- Unused until the Avalon Interface is added.

    );
END mem;

ARCHITECTURE memArch OF mem IS
BEGIN

    mem_process : process(clock, m_waitrequest)
    BEGIN
        CASE instruction_in.INSTRUCTION_TYPE IS
            WHEN branch_if_equal | branch_if_not_equal =>
                IF(branch_taken_in = '1') THEN
                    branch_taken_out <= '1';
                END IF;
            WHEN load_word =>
                -- TODO: add the proper timing and avalon interface stuff later.
                m_read <= '1';
                m_addr <= ALU_result_in;
                mem_data <= m_readdata;
            WHEN store_word =>
                -- TODO: add the proper timing and avalon interface stuff later.
                m_write <= '1';
                m_addr <= ALU_result_in;
                m_writedata <= val_b;
                
        END CASE;
        instruction_out <= instruction_in;
        ALU_result_out <= ALU_result_in;
    END PROCESS;
END ARCHITECTURE;