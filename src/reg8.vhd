LIBRARY IEEE;
USE work.EXEMPLAR.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY reg8 is

  GENERIC(tprop : time := 8 ns;
          tsu   : time := 2 ns);

  PORT(d      : IN std_logic_vector(7 downto 0);
       clk    : IN std_logic;
       enable : IN std_logic;
       rst    : IN std_logic;
       q      : OUT std_logic_vector(7 downto 0));

END reg8;

ARCHITECTURE behav OF reg8 IS

  BEGIN

    one : PROCESS (clk,rst)

      BEGIN
        IF(rst = '0') THEN
          q <= (OTHERS => '0');
        ELSIF ((rising_edge(clk)) AND		-- rising clock edge
           enable = '1') THEN			-- ff enabled
          IF (d'STABLE(tsu)) THEN		-- check setup
            q <= d after tprop;
          ELSE					-- else invalid date
            q <= (OTHERS => 'X');
          END IF;
        END IF;
    END PROCESS one;

END behav;
