--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port (
        i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
    );
    
	end component thunderbird_fsm;

	-- test I/O signals
	
	
	-- constants
 
    signal w_right : std_logic := '0';
    signal w_left : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_clk : std_logic := '0';
 
    signal w_right_light : std_logic_vector(2 downto 0) := "000";
	signal w_left_light : std_logic_vector(2 downto 0) := "000";
	
	constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
	
	-----------------------------------------------------
     uut: thunderbird_fsm port map (
         
          i_reset => w_reset,       
          i_clk => w_clk, 
          i_right => w_right,
          i_left => w_left,
          o_lights_L(2 downto 0) => w_left_light(2 downto 0),
          o_lights_R(2 downto 0) => w_right_light(2 downto 0)
        );
	
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
	-----------------------------------------------------
		clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
	
	-- Test Plan Process --------------------------------
	-----------------------------------------------------	
	sim_proc: process
	begin
	
	w_reset <= '1';
		wait for k_clk_period*1;
		  assert w_right_light = "000" report "bad reset" severity failure;
		  assert w_left_light = "000" report "bad reset" severity failure;
	
	w_reset <= '0';
	
	w_left <= '0';
	w_right <= '1';
	   wait for k_clk_period*1;
	   assert w_right_light = "001" report "bad r1" severity failure;
	   wait for k_clk_period*1;
	   assert w_right_light = "011" report "bad r2" severity failure;
	   wait for k_clk_period*1;
	   assert w_right_light = "111" report "bad r3" severity failure;
	   wait for k_clk_period*1;
	   assert w_right_light = "000" report "bad r0" severity failure;
	   wait for k_clk_period*1;
	   assert w_right_light = "001" report "bad r1,secondtime" severity failure;
	   wait for k_clk_period*2;
	   --*2 bc has to cycle throught the rest if the lights
	   
	W_right <= '0';
	   wait for k_clk_period*1;
	w_left <= '1';
	   wait for k_clk_period*1;
	   assert w_left_light = "001" report "bad l1" severity failure;
	   wait for k_clk_period*1;
	   assert w_left_light = "011" report "bad l2" severity failure;
	   wait for k_clk_period*1;
	   assert w_left_light = "111" report "bad l3" severity failure;
	   wait for k_clk_period*1;
	   assert w_left_light = "000" report "bad l0" severity failure;
	   wait for k_clk_period*1;
	   assert w_left_light = "001" report "bad l1,secondtime" severity failure;
	   wait for k_clk_period*2;
	   
	w_left <= '0';
	wait for k_clk_period*1;
	--turning both on, checking to see if it is flashing
	W_right <= '1';
	w_left <= '1';
	wait for k_clk_period*1;
	assert w_left_light = "111" report "bad ON" severity failure;
    assert w_right_light = "111" report "bad ON" severity failure;
	wait for k_clk_period*1;
    assert w_left_light = "000" report "bad OFF" severity failure;
    assert w_right_light = "000" report "bad OFF" severity failure;
    wait for k_clk_period*1;
    assert w_left_light = "111" report "bad ON" severity failure;
    assert w_right_light = "111" report "bad ON" severity failure;
    
	W_right <= '0';
	w_left <= '0';
	
	
	   wait for k_clk_period*1 ;
    end process;
	
	
	
end test_bench;
