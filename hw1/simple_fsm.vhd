-- Daniel Winkelman (ddw30)
-- Duke University
-- ECE 559 Fall 2021
-- Homework 1

library ieee;
use ieee.std_logic_1164.all;

entity simple_fsm is
	port (
		clk, reset, w:
			in std_logic;
		z:
			out std_logic
	);
end simple_fsm;

architecture simple_fsm_impl of simple_fsm is
	type state_type is (
		s0,  -- NULL state
		s1,  -- seen 1
		s2,  -- seen 10
		s3,  -- seen 101
		s4,  -- seen 11
		s5,  -- seen 110
		s6,  -- seen 1101
		s7   -- seen 1011
	);
	signal state_reg, state_next: state_type;
begin
	process (clk, reset) begin  -- initialization, clock edges
		if (reset = '1') then
			state_reg <= s0;
		elsif (clk'event and clk = '1') then
			state_reg <= state_next;
		end if;
	end process;
	process (state_reg, w) begin  -- next state logic
		case state_reg is
			when s0 =>
				if w = '1' then
					state_next <= s1;
				else
					state_next <= s0;
				end if;
			when s1 =>
				if w = '1' then
					state_next <= s4;
				else
					state_next <= s2;
				end if;
			when s2 =>
				if w = '1' then
					state_next <= s3;
				else
					state_next <= s0;
				end if;
			when s3 =>
				if w = '1' then
					state_next <= s7;
				else
					state_next <= s2;
				end if;
			when s4 =>
				if w = '1' then
					state_next <= s4;
				else
					state_next <= s5;
				end if;
			when s5 =>
				if w = '1' then
					state_next <= s6;
				else
					state_next <= s0;
				end if;
			when s6 =>
				if w = '1' then
					state_next <= s7;
				else
					state_next <= s2;
				end if;
			when s7 =>
				if w = '1' then
					state_next <= s4;
				else
					state_next <= s5;
				end if;
		end case;
	end process;
	process (state_reg) begin  -- Moore output logic
		if state_reg = s6 or state_reg = s7 then
			z <= '1';
		else
			z <= '0';
		end if;
	end process;
end simple_fsm_impl;

--architecture shift_fsm_impl of simple_fsm is
--	component shift_reg is
--		port (
--			aclr		: IN STD_LOGIC ;
--			clock		: IN STD_LOGIC ;
--			shiftin		: IN STD_LOGIC ;
--			q		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
--		);
--	end component;
--	signal regq: std_logic_vector (3 downto 0);
--begin
--	sr1: shift_reg port map (
--		aclr => reset,
--		clock => clk,
--		shiftin => w,
--		q => regq
--	);
--	process (regq) begin  -- Moore output logic
--		if regq = "1101" or regq = "1011" then
--			z <= '1';
--		else
--			z <= '0';
--		end if;
--	end process;
--end shift_fsm_impl;
