library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator is
    port (
        clk        : in  std_logic;
        resetn     : in  std_logic;
        enable     : in  std_logic;
        duty_cycle : in  std_logic_vector(7 downto 0);
        pwm_out    : out std_logic
    );
end pwm_generator;

architecture rtl of pwm_generator is
    signal counter : unsigned(7 downto 0) := (others => '0');
    signal duty    : unsigned(7 downto 0);
begin

    duty <= unsigned(duty_cycle);

    process(clk, resetn)
    begin
        if resetn = '0' then
            counter <= (others => '0');
            pwm_out <= '0';

        elsif rising_edge(clk) then
            if enable = '1' then
                counter <= counter + 1;

                if counter < duty then
                    pwm_out <= '1';
                else
                    pwm_out <= '0';
                end if;

            else
                counter <= (others => '0');
                pwm_out <= '0';
            end if;
        end if;
    end process;

end rtl;