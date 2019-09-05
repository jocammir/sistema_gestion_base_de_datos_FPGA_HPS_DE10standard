-- #############################################################################
-- Contador.vhd
-- ==============
-- This component describes a simple counter UP-DOWN with an Avalon-MM slave interface.
-- The Input Signals can be written to registers 0 and 1, and the outputs of the
-- counter can be read back from registers 2 and 3.
--
-- #############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_UNSIGNED.all;
use ieee.std_logic_Arith.all;

ENTITY bloque IS
	PORT(
		-- Avalon Clock interface
		clk1,clk2 : in std_logic; --clk1 for Avalon and clk2 for Counter
		-- Avalon Reset interface
		reset : in std_logic;
		-- Avalon-MM Slave interface
		address : in std_logic_vector(1 downto 0);
		read : in std_logic;
		write : in std_logic;
		readdata : out std_logic_vector(31 downto 0);
		writedata : in std_logic_vector(31 downto 0);
		counter_conduit: out std_logic_vector(9 downto 0)
		);
END bloque;

ARCHITECTURE sol OF bloque IS
	--Address for different registers
	constant REG_INPUT_1_OFST : std_logic_vector(1 downto 0) := "00";--Address for Cargar, habilcnt and descendente
	constant REG_INPUT_2_OFST : std_logic_vector(1 downto 0) := "01";--Address for dato_ent
	constant REG_OUTPUT_1_OFST : std_logic_vector(1 downto 0) := "10";--Address for Q
	constant REG_OUTPUT_2_OFST : std_logic_vector(1 downto 0) := "11";--Address for ct_term
	signal reg_input_1 : unsigned(writedata'range); --creating register 1 for Inputs -> Cargar, habilcnt and descendente
	signal reg_input_2 : unsigned(writedata'range); --creating register 2 for input -> dato_ent
	signal reg_output_1 : std_logic_vector(31 downto 0); --creating register 3 for Output -> Q 
	signal reg_output_2 : unsigned(readdata'range); --creating register 4 for Output -> ct_term
	SIGNAL cargar, habilcnt, descendente, ct_term : STD_LOGIC; -- Input Signals for the Counter Process
	SIGNAL dato_ent,Q : STD_LOGIC_VECTOR (9 downto 0); -- Input and Output Signals for the Counter Process
	SIGNAL conteo: STD_LOGIC_VECTOR(9 downto 0);  -- define a 4 bits Bus	

	BEGIN
	
	-- Avalon-MM slave write
		process(clk1, reset)
		begin
			if reset = '1' then
				reg_input_1 <= (others => '0');
				reg_input_2 <= (others => '0');
				elsif rising_edge(clk1) then
					if write = '1' then
						case address is
							when REG_INPUT_1_OFST => 	reg_input_1 <= unsigned(writedata);
							when REG_INPUT_2_OFST =>	reg_input_2 <= unsigned(writedata);
							-- RESULT register is read-only
							when REG_OUTPUT_1_OFST => null;
							when REG_OUTPUT_2_OFST => null;
							-- Remaining addresses in register map are unused.
							when others => null;
						end case;
					end if;
				end if;
		end process;

		-- Avalon-MM slave read
		process(clk1, reset)
		begin
		reg_output_1(9 downto 0)<=Q;reg_output_2(0)<=ct_term;
			if rising_edge(clk1) then
				if read = '1' then
					case address is
						when REG_INPUT_1_OFST =>	readdata <= std_logic_vector(reg_input_1); --assign readdata<=Cargar&habilcnt&descendente
						when REG_INPUT_2_OFST =>	readdata <= std_logic_vector(reg_input_2); --assign readdata<=data_ent
						when REG_OUTPUT_1_OFST =>		readdata <= reg_output_1; --assign readdata<=Q
						when REG_OUTPUT_2_OFST =>		readdata <= std_logic_vector(reg_output_2);--assign readdata<=ct_term
					
						-- Remaining addresses in register map are unmapped => return 0.
						when others =>	readdata <= (others => '0');
					end case;
				end if;
			end if;
		end process;
		
		--Counter Process
		PROCESS(clk2,reset,descendente)
		BEGIN
			cargar<=reg_input_1(2);habilcnt<=reg_input_1(1);descendente<=reg_input_1(2);
			dato_ent<=conv_std_logic_vector(reg_input_2,10);
			if reset='1' then conteo<="0000000000"; -- borrar asÃ­ncrona
			elsif (clk2'event and clk2='1') then -- flanco ascendente?
				if cargar='1' then conteo<=dato_ent; --carga en paralelo
				elsif habilcnt='1' then    -- habilitado?
					if descendente='0' then conteo<=conteo+1; --incremento
					else conteo<=conteo-1; --decremento
					end if;
				end if;
			end if;
			if (((conteo="0000000000" and descendente='1')) OR ((conteo="1111111111" and descendente='0'))) AND habilcnt='1'
				then ct_term<='1';
			else ct_term<='0';
			end if;
			q<=conteo; --transfer the content from register to output
		END PROCESS;
		
		counter_conduit<=Q; --transfer the content from register Q to output Conduit
		
END sol;