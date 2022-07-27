LIBRARY IEEE;
USE work.EXEMPLAR.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY async_tb is
END async_tb;

ARCHITECTURE structure OF async_tb IS

  SIGNAL c1, c2 : std_logic := '0';
  SIGNAL data_valid, data_latch, reset, dest_hold: std_logic;
  SIGNAL data_packet, data_trans, data_dest : std_logic_vector(7 downto 0);

  SIGNAL ready, ack : std_logic;

  BEGIN

  reset <= '0', '1' after 80 ns;

  clock_one : PROCESS(c1)
    BEGIN
      c1 <= not(c1) AFTER 15 ns;
  END PROCESS clock_one;

  clock_two : PROCESS(c2)
    BEGIN
      c2 <= not(c2) AFTER 95 ns;
  END PROCESS clock_two;

  SOURCE_STATE_MACHINE : ENTITY work.source_fsm 
     PORT MAP(c1, reset, data_valid, ack, ready);

  DESTINATION_STATE_MACHINE : ENTITY work.dest_fsm 
     PORT MAP(c2, reset, dest_hold, ready, ack, data_latch);

  DATA_GENERATOR : ENTITY work.data_gen 
     PORT MAP(c1, data_valid, dest_hold, data_packet);

  SRC_REG : ENTITY work.reg8 PORT MAP(data_packet,c1,data_valid,
                                      reset,data_trans);

  DEST_REG : ENTITY work.reg8 PORT MAP(data_trans,c2,data_latch,
                                       reset,data_dest);

END structure;
