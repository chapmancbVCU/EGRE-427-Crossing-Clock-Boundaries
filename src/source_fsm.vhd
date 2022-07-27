--------------------------------------------------------------------------------
--        Name: Chad Chapman
-- Module Name: source_fsm - behav
-- Description: The finite state machine on the source side of the clock 
--              boundary.  
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.EXEMPLAR.ALL;

ENTITY source_fsm is
   PORT(clk        : IN std_logic;
        reset      : IN std_logic;
        data_valid : IN std_logic;
        ack        : IN std_logic;
        ready      : OUT std_logic);
END source_fsm;

ARCHITECTURE behav OF source_fsm IS
   
   CONSTANT delay : time := 5 ns;
   TYPE state_type IS(idle, send, done);
   SIGNAL present_state, next_state : state_type;
   SIGNAL ack_demet, ack_sig : std_logic;
   
   BEGIN
       
   -----------------------------------------------------------------------------
   --     PROCESS: demet_ff1
   -- DESCRIPTION: The first flip flop on the source side of the clock boundry 
   --              that the ack (acknowledgment) signal has to go through from 
   --              the destination side fsm.      
   -----------------------------------------------------------------------------
   demet_ff1 : PROCESS(clk, reset)
      BEGIN
         IF (reset = '0') THEN
            ack_demet <= '0';
         ELSIF (rising_edge(clk)) THEN
            ack_demet <= ack;
         END IF;
   END PROCESS demet_ff1;
   
   -----------------------------------------------------------------------------
   --     PROCESS: demet_ff2
   -- DESCRIPTION: The second flip flop on the source side of the clock boundry
   --              that the ack signal has to go through from the destination 
   --              side fsm.    
   -----------------------------------------------------------------------------
   demet_ff2 : PROCESS(clk, reset)
      BEGIN
         IF (reset = '0') THEN
            ack_sig <= '0';
         ELSIF (rising_edge(clk)) THEN
            ack_sig <= ack_demet;
         END IF;
   END PROCESS demet_ff2;
   
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
   --              data_valid, and ack_sig.             
   -----------------------------------------------------------------------------
   nextstate : PROCESS(present_state, data_valid, ack_sig)
      BEGIN
         CASE present_state IS
            WHEN idle =>
               IF(data_valid = '0') THEN
                  next_state <= present_state;
               ELSIF(data_valid = '1') THEN
                  next_state <= send;
               ELSE
                  next_state <= present_state;
               END IF;
            WHEN send =>
               IF(ack_sig = '0') THEN
                  next_state <= present_state;
               ELSIF(ack_sig = '1') THEN
                  next_state <= done;
               ELSE 
                  next_state <= present_state;
               END IF; 
            WHEN done =>
               IF(ack_sig = '1') THEN
                  next_state <= present_state;
               ELSIF(ack_sig = '0')  THEN
                  next_state <= idle;
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
         CASE present_state is
            WHEN idle =>
               ready <= '0';
            WHEN send =>
               ready <= '1';
            WHEN done =>
               ready <= '0';
            WHEN OTHERS => 
               ready <= '0';
         END CASE;
   END PROCESS output_function;     
END behav;