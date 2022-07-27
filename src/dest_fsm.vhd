--------------------------------------------------------------------------------
--        Name: Chad Chapman
-- Module Name: dest_fsm - behav
-- Description: The finite state machine on the destination side of the clock 
--              boundary.
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.EXEMPLAR.ALL;

ENTITY dest_fsm is
   PORT(clk        : IN std_logic;
        reset      : IN std_logic;
        dest_hold  : IN std_logic;
        ready      : IN std_logic;
        ack        : OUT std_logic;
        data_latch : OUT std_logic);
END dest_fsm;

ARCHITECTURE behav OF dest_fsm IS
    
   CONSTANT delay : time := 5 ns;
   TYPE state_type IS(idle, receive, done);
   SIGNAL present_state, next_state : state_type;
   SIGNAL ready_demet, ready_sig : std_logic;
   
   BEGIN
       
   -----------------------------------------------------------------------------
   --     PROCESS: sync_ff1
   -- DESCRIPTION: The first flip flop on the destination side of the clock 
   --              boundry that the ready signal has to go through from the 
   --              destination side fsm.   
   -----------------------------------------------------------------------------    
   sync_ff1 : PROCESS(clk, reset)
      BEGIN
         IF (reset = '0') THEN
            ready_demet <= '0';
         ELSIF (rising_edge(clk)) THEN
            ready_demet <= ready;
         END IF;
   END PROCESS sync_ff1;
   
   -----------------------------------------------------------------------------
   --     PROCESS: sync_ff2
   -- DESCRIPTION: The second flip flop on the source side of the clock boundry
   --              that the ack signal has to go through from the destination 
   --              side fsm.
   -----------------------------------------------------------------------------    
   sync_ff2 : PROCESS(clk, reset)
      BEGIN
         IF (reset = '0') THEN
            ready_sig <= '0';
         ELSIF (rising_edge(clk)) THEN
            ready_sig <= ready_demet;
         END IF; 
   END PROCESS sync_ff2;
   
   -----------------------------------------------------------------------------
   --     PROCESS: clocked
   -- DESCRIPTION: The memory portion of the source fsm which stores the value 
   --              of the present state.
   -----------------------------------------------------------------------------
   clocked : PROCESS (clk, reset)
      BEGIN
         IF (reset = '0') THEN
            present_state <= idle;
         ELSIF (rising_edge(clk)) THEN
            present_state <= next_state;
         END IF;
   END PROCESS clocked;
   
   -----------------------------------------------------------------------------
   --     PROCESS: nextstate
   -- DESCRIPTION: This process determines the next state for the finite state 
   --              machine with respect to the signals present_state, 
   --              dest_hold, and ready_sig.
   -----------------------------------------------------------------------------
   nextstate : PROCESS(present_state, dest_hold, ready_sig)
      BEGIN
         CASE present_state IS
            WHEN idle =>
               IF(ready_sig = '0') THEN
                  next_state <= present_state;
               ELSIF(ready_sig = '1') THEN
                  next_state <= receive;
               ELSE
                  next_state <= present_state;
               END IF;
            WHEN receive =>
               IF(dest_hold = '1') THEN
                  next_state <= present_state;
               ELSIF(dest_hold = '0') THEN
                  next_state <= done;
               ELSE
                  next_state <= done;
               END IF;
            WHEN done =>
               IF(ready_sig = '0' and dest_hold = '0') THEN
                  next_state <= idle;
               ELSIF(ready_sig = '0' and dest_hold = '1') THEN
                  next_state <= present_state;
               ELSE 
                  next_state <= present_state;
               END IF;
            WHEN OTHERS =>
               next_state <= idle;
            END CASE;
   END PROCESS nextstate;
   
   -----------------------------------------------------------------------------
   --     PROCESS: output_function
   -- DESCRIPTION: This process determines the output of the finite state 
   --              machine with respect to the fsm's present state.
   -----------------------------------------------------------------------------         
   output_function : PROCESS(present_state)
      BEGIN
         CASE present_state IS
            WHEN idle =>
               ack <= '0';
               data_latch <= '0';
            WHEN receive =>
               ack <= '0';
               data_latch <= '1';
            WHEN done =>
               ack <= '1';
               data_latch <= '0';
            WHEN OTHERS =>
               ack <= '0';
               data_latch <= '0';   
         END CASE;
   END PROCESS output_function;
END behav;