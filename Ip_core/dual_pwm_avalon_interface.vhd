library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dual_pwm_avalon_interface is
    port (
        -- Clock / Reset
        clk        : in  std_logic;
        resetn     : in  std_logic;

        -- Avalon MM Slave
        address    : in  std_logic_vector(1 downto 0);
        chipselect : in  std_logic;
        read       : in  std_logic;
        write      : in  std_logic;
        writedata  : in  std_logic_vector(31 downto 0);
        readdata   : out std_logic_vector(31 downto 0);
        byteenable : in  std_logic_vector(3 downto 0);

        -- Sorties vers moteurs / LEDs de test
        pwm_left_export  : out std_logic;
        pwm_right_export : out std_logic;
        dir_left_export  : out std_logic;
        dir_right_export : out std_logic
    );
end dual_pwm_avalon_interface;

architecture rtl of dual_pwm_avalon_interface is

    component pwm_generator is
        port (
            clk        : in  std_logic;
            resetn     : in  std_logic;
            enable     : in  std_logic;
            duty_cycle : in  std_logic_vector(7 downto 0);
            pwm_out    : out std_logic
        );
    end component;

    signal duty_left_reg  : std_logic_vector(7 downto 0) := (others => '0');
    signal duty_right_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal dir_left_reg   : std_logic := '0';
    signal dir_right_reg  : std_logic := '0';

    signal command_reg    : std_logic_vector(31 downto 0) := (others => '0');

begin

    --------------------------------------------------------------------
    -- Sorties direction
    --------------------------------------------------------------------
    dir_left_export  <= dir_left_reg;
    dir_right_export <= dir_right_reg;

    --------------------------------------------------------------------
    -- Écriture Avalon MM
    --
    -- Format de writedata :
    -- bits [7:0]   : duty moteur gauche
    -- bits [15:8]  : duty moteur droit
    -- bit  [16]    : direction moteur gauche
    -- bit  [17]    : direction moteur droit
    -- bits [31:18] : réservés
    --------------------------------------------------------------------
    process(clk, resetn)
    begin
        if resetn = '0' then
            duty_left_reg  <= (others => '0');
            duty_right_reg <= (others => '0');
            dir_left_reg   <= '0';
            dir_right_reg  <= '0';
            command_reg    <= (others => '0');

        elsif rising_edge(clk) then
            if chipselect = '1' and write = '1' then

                -- Octet 0 : duty moteur gauche
                if byteenable(0) = '1' then
                    duty_left_reg <= writedata(7 downto 0);
                    command_reg(7 downto 0) <= writedata(7 downto 0);
                end if;

                -- Octet 1 : duty moteur droit
                if byteenable(1) = '1' then
                    duty_right_reg <= writedata(15 downto 8);
                    command_reg(15 downto 8) <= writedata(15 downto 8);
                end if;

                -- Octet 2 : directions
                if byteenable(2) = '1' then
                    dir_left_reg  <= writedata(16);
                    dir_right_reg <= writedata(17);
                    command_reg(23 downto 16) <= writedata(23 downto 16);
                end if;

                -- Octet 3 : réservé
                if byteenable(3) = '1' then
                    command_reg(31 downto 24) <= writedata(31 downto 24);
                end if;

            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- Lecture Avalon MM
    --------------------------------------------------------------------
    process(command_reg)
    begin
        readdata <= command_reg;
    end process;

    --------------------------------------------------------------------
    -- PWM moteur gauche
    --------------------------------------------------------------------
    pwm_left_inst : pwm_generator
        port map (
            clk        => clk,
            resetn     => resetn,
            enable     => '1',
            duty_cycle => duty_left_reg,
            pwm_out    => pwm_left_export
        );

    --------------------------------------------------------------------
    -- PWM moteur droit
    --------------------------------------------------------------------
    pwm_right_inst : pwm_generator
        port map (
            clk        => clk,
            resetn     => resetn,
            enable     => '1',
            duty_cycle => duty_right_reg,
            pwm_out    => pwm_right_export
        );

end rtl;