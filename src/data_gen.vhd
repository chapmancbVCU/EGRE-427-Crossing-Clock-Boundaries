LIBRARY IEEE;
USE work.EXEMPLAR.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY data_gen is

  PORT(clk    : IN std_logic;
       enable : OUT std_logic;
       hold   : OUT std_logic;
       data   : OUT std_logic_vector(7 downto 0));

END data_gen;

ARCHITECTURE behav OF data_gen IS

procedure waitclocks(signal clock : std_logic;
                     N : INTEGER) is
 begin
  for i in 1 to N loop
   wait until clock'event and clock='0';
  end loop;
 end waitclocks;


  BEGIN

    hold <= '0', '1' AFTER 46000 ns, '0' AFTER 50000 ns,
            '1' AFTER 64000 ns, '0' AFTER 68000 ns;

    one : PROCESS

      BEGIN
        data <= (OTHERS => 'X');
        enable <= '0';

        waitclocks(clk,20);

        data <= "11001000";		-- first data block
        enable <= '1';
        waitclocks(clk,1);
        data <= (OTHERS => 'X');
        enable <= '0';
        waitclocks(clk,53);

        data <= "00101010";		-- second data block
        enable <= '1';
        waitclocks(clk,1);
        data <= (OTHERS => 'X');
        enable <= '0';
        waitclocks(clk,37);

        data <= "11101101";		-- third data block
        enable <= '1';
        waitclocks(clk,1);
        data <= (OTHERS => 'X');
        enable <= '0';
        waitclocks(clk,103);

        data <= "00010001";		-- fourth data block
        enable <= '1';
        waitclocks(clk,1);
        data <= (OTHERS => 'X');
        enable <= '0';
        waitclocks(clk,64);

        data <= "11101111";		-- fifth data block
        enable <= '1';
        waitclocks(clk,1);
        data <= (OTHERS => 'X');
        enable <= '0';
        waitclocks(clk,78);

        data <= "11010101";		-- sixth data block
        enable <= '1';
        waitclocks(clk,1);
        data <= (OTHERS => 'X');
        enable <= '0';
        waitclocks(clk,49);

        WAIT;

    END PROCESS one;

END behav;
