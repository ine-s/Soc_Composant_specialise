LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY lights IS
	PORT (
		SW       : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		KEY      : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		CLOCK_50 : IN STD_LOGIC;

		-- LEDs de validation
		LED      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);

		-- SDRAM
		DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
		DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
		DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END lights;

ARCHITECTURE Structure OF lights IS

	COMPONENT niosII_v1 IS
		PORT (
			reset_reset_n           : IN STD_LOGIC;
			sw_export               : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

			sdram_wire_addr         : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
			sdram_wire_ba           : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			sdram_wire_cas_n        : OUT STD_LOGIC;
			sdram_wire_cke          : OUT STD_LOGIC;
			sdram_wire_cs_n         : OUT STD_LOGIC;
			sdram_wire_dq           : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			sdram_wire_dqm          : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			sdram_wire_ras_n        : OUT STD_LOGIC;
			sdram_wire_we_n         : OUT STD_LOGIC;

			clk_clk                 : IN STD_LOGIC;
			sdram_clk_clk           : OUT STD_LOGIC;

			pwm_left_export_export  : OUT STD_LOGIC;
			pwm_right_export_export : OUT STD_LOGIC;
			dir_left_export_export  : OUT STD_LOGIC;
			dir_right_export_export : OUT STD_LOGIC
		);
	END COMPONENT;

BEGIN

	NiosII : niosII_v1
	PORT MAP (

		clk_clk                 => CLOCK_50,
		reset_reset_n           => KEY(0),

		sw_export               => SW,

		sdram_clk_clk           => DRAM_CLK,
		sdram_wire_addr         => DRAM_ADDR,
		sdram_wire_ba           => DRAM_BA,
		sdram_wire_cas_n        => DRAM_CAS_N,
		sdram_wire_cke          => DRAM_CKE,
		sdram_wire_cs_n         => DRAM_CS_N,
		sdram_wire_dq           => DRAM_DQ,
		sdram_wire_dqm          => DRAM_DQM,
		sdram_wire_ras_n        => DRAM_RAS_N,
		sdram_wire_we_n         => DRAM_WE_N,

		pwm_left_export_export  => LED(0),
		pwm_right_export_export => LED(1),
		dir_left_export_export  => LED(2),
		dir_right_export_export => LED(3)

	);

END Structure;