-- Daniel Winkelman (ddw30)
-- Duke University
-- ECE 559 Fall 2021
-- Homework 2

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crc_controller is
	port (
		clk, reset, data_in, data_ready: in std_logic;
		data_length: in std_logic_vector (7 downto 0);
		check_result, look_now: out std_logic
	);
end crc_controller;

architecture crc_controller_impl of crc_controller is
	component crc_coder is
		port (
			-- port names changed between parts a) and b), so I'm sticking with a)
			clk, preset, enable, data, reset: in std_logic;
			output: out std_logic_vector (15 downto 0)
		);
	end component;
	
	component reg16 is
		port (
			aclr	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			enable	: IN STD_LOGIC ;
			load	: IN STD_LOGIC ;
			shiftin	: IN STD_LOGIC ;
			sset	: IN STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	end component;
	
	type state_type is (READY, CODING, CHECKING, DONE);
	signal state, next_state: state_type;
	signal counter, next_counter: unsigned (7 downto 0);
	
	-- Capture 16-bit checksum from CRC coder and checksum buffer
	signal crc_output, checksum_output: std_logic_vector (15 downto 0);
	
	-- Make sure the CRC coder is processing only at correct times
	signal crc_enable: std_logic;
	
	-- Preset signal for CRC coder
	signal crc_preset: std_logic;
	
	-- Whether the checksum buffer should be accepting data
	signal checksum_enable: std_logic;
	
begin
	coder: crc_coder port map (
		clk => clk,
		reset => reset,
		preset => crc_preset,
		enable => crc_enable,
		data => data_in,
		output => crc_output
	);
	
	checksum: reg16 port map (  -- only shift-in when enabled
		aclr => reset,
		clock => clk,
		enable => checksum_enable,
		load => '0',
		shiftin => data_in,
		sset => '0',
		q => checksum_output
	);
	
	process (clk, reset) begin  -- initialization, clock edges
		if (reset = '1') then
			state <= DONE;
		elsif (clk'event and clk = '1') then
			state <= next_state;
			counter <= next_counter;
		end if;
	end process;
	
	process (state, counter, data_ready) begin  -- handle state changes
		case state is
			when READY =>
				next_state <= CODING;
				next_counter <= counter;
			when CODING =>
				if (counter = 0) then
					next_state <= CHECKING;
					next_counter <= to_unsigned(15, 8);
				else
					next_state <= CODING;
					next_counter <= counter - 1;
				end if;
			when CHECKING =>
				next_counter <= counter - 1;
				if (counter = 0) then
					next_state <= DONE;
				else
					next_state <= CHECKING;
				end if;
			when DONE =>
				if (data_ready = '1') then
					next_state <= READY;
				else
					next_state <= DONE;
				end if;
				next_counter <= unsigned(data_length) - 1;
		end case;
	end process;
	
	process (state) begin  -- handle Moore outputs
		case state is
			when READY =>
				crc_preset <= '1';
				crc_enable <= '0';
				checksum_enable <= '0';
				look_now <= '0';
			when CODING =>
				crc_preset <= '0';
				crc_enable <= '1';
				checksum_enable <= '0';
				look_now <= '0';
			when CHECKING =>
				crc_preset <= '0';
				crc_enable <= '0';
				checksum_enable <= '1';
				look_now <= '0';
			when DONE =>
				crc_preset <= '0';
				crc_enable <= '0';
				checksum_enable <= '0';
				look_now <= '1';
		end case;
	end process;
	
	process (crc_output, checksum_output) begin  -- handle comparison output
		if (crc_output = checksum_output) then
			check_result <= '1';
		else
			check_result <= '0';
		end if;
	end process;
	
end crc_controller_impl;
