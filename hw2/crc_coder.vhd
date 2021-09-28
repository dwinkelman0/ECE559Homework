-- Daniel Winkelman (ddw30)
-- Duke University
-- ECE 559 Fall 2021
-- Homework 2

library ieee;
use ieee.std_logic_1164.all;

entity crc_coder is
	port (
	   -- port names changed between parts a) and b), so I'm sticking with a)
		clk, reset, preset, enable, data: in std_logic;
		output: out std_logic_vector (15 downto 0)
	);
end crc_coder;


architecture crc_coder_impl of crc_coder is
	component reg16 is
		port (
			aclr	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			data	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			enable	: IN STD_LOGIC ;
			load	: IN STD_LOGIC ;
			shiftin	: IN STD_LOGIC ;
			sset	: IN STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	end component;
	
	signal state, next_state: std_logic_vector (15 downto 0);
	signal reg_rden: std_logic;
	
begin
	reg1: reg16 port map (
		aclr => reset,
		clock => clk,
		data => next_state,
		enable => reg_rden,
		load => enable,
		shiftin => '0',
		sset => preset,
		q => state
	);
	
	process (state, data) begin
		next_state(0) <= state(15) xor data;
		next_state(4 downto 1) <= state(3 downto 0);
		next_state(5) <= state(4) xor state(15) xor data;
		next_state(11 downto 6) <= state(10 downto 5);
		next_state(12) <= state(11) xor state(15) xor data;
		next_state(15 downto 13) <= state(14 downto 12);
		output <= state;
	end process;
	
	process (enable, preset) begin
		reg_rden <= enable or preset;
	end process;
end crc_coder_impl;
