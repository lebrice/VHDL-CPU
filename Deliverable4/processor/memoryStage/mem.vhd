LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY mem is
    generic (
      ram_size : integer := 8196;
      bit_width  : integer := 32
    );
    port (
        ALU_result_in : in std_logic_vector(63 downto 0);
        ALU_result_out : out std_logic_vector(63 downto 0);
        instruction_in : in INSTRUCTION;
        instruction_out : out INSTRUCTION;
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
    --set outputs
    instruction_out <= instruction_in;
    ALU_result_out <= ALU_result_in;

    mem_process : process(instruction_in, m_waitrequest)
    BEGIN
        CASE instruction_in.INSTRUCTION_TYPE IS
            WHEN load_word =>
                -- TODO: add the proper timing and avalon interface stuff later.
                m_read <= '1';
                m_addr <= to_integer(unsigned(ALU_result_in(31 downto 0)));
                mem_data <= m_readdata;
            WHEN store_word =>
                -- TODO: add the proper timing and avalon interface stuff later.
                m_write <= '1';
                m_addr <= to_integer(unsigned(ALU_result_in(31 downto 0)));
                m_writedata <= val_b;
            WHEN others =>
              -- do nothing.  
        END CASE;

    END PROCESS;

END ARCHITECTURE;