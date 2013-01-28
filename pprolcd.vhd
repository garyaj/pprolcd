----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:19:39 01/28/2013 
-- Design Name: 
-- Module Name:    pprolcd - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pprolcd is
    Port ( clk : in  STD_LOGIC;
  lcd_contrast : out std_logic; 
         lcd_d : inout std_logic_vector(7 downto 4);
        lcd_rs : out std_logic;
        lcd_rw : out std_logic;
         lcd_e : out std_logic);
end pprolcd;

architecture Behavioral of pprolcd is

--
-- Declaration of the KCPSM6 component including default values for generics.
--
  component kcpsm6 
    generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                    interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
             scratch_pad_memory_size : integer := 64);
    port (                   address : out std_logic_vector(11 downto 0);
                         instruction : in std_logic_vector(17 downto 0);
                         bram_enable : out std_logic;
                             in_port : in std_logic_vector(7 downto 0);
                            out_port : out std_logic_vector(7 downto 0);
                             port_id : out std_logic_vector(7 downto 0);
                        write_strobe : out std_logic;
                      k_write_strobe : out std_logic;
                         read_strobe : out std_logic;
                           interrupt : in std_logic;
                       interrupt_ack : out std_logic;
                               sleep : in std_logic;
                               reset : in std_logic;
                                 clk : in std_logic);
  end component;

--
-- Declaration of the default Program Memory recommended for development.
--

  component control
    generic(             C_FAMILY : string := "S6"; 
                C_RAM_SIZE_KWORDS : integer := 1;
             C_JTAG_LOADER_ENABLE : integer := 0);
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;
--
-- Signals for connection of KCPSM6 and Program Memory.
--

signal         address : std_logic_vector(11 downto 0);
signal     instruction : std_logic_vector(17 downto 0);
signal     bram_enable : std_logic;
signal         in_port : std_logic_vector(7 downto 0);
signal        out_port : std_logic_vector(7 downto 0);
signal         port_id : std_logic_vector(7 downto 0);
signal    write_strobe : std_logic;
signal  k_write_strobe : std_logic;
signal     read_strobe : std_logic;
signal       interrupt : std_logic;
signal   interrupt_ack : std_logic;
signal    kcpsm6_sleep : std_logic;
signal    kcpsm6_reset : std_logic;

-- Signals for LCD operation
--
-- Tri-state output requires internal signals
--
signal   lcd_rw_control : std_logic;
signal  lcd_output_data : std_logic_vector(7 downto 4);
signal        lcd_drive : std_logic;

begin
  -----------------------------------------------------------------------------------------
  -- Instantiate KCPSM6 and connect to Program Memory
  -----------------------------------------------------------------------------------------
  --
  -- The KCPSM6 generics can be defined as required but the default values are shown below
  -- and these would be adequate for most designs.
  --

  processor: kcpsm6
    generic map (                 hwbuild => X"00", 
                         interrupt_vector => X"3FF",
                  scratch_pad_memory_size => 64)
    port map(      address => address,
               instruction => instruction,
               bram_enable => bram_enable,
                   port_id => port_id,
              write_strobe => write_strobe,
            k_write_strobe => k_write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     sleep => kcpsm6_sleep,
                     reset => kcpsm6_reset,
                       clk => clk);
 

  --
  -- In many designs (especially your first) interrupt and sleep are not used.
  -- Tie these inputs Low until you need them. Tying 'interrupt' to 'interrupt_ack' 
  -- preserves both signals for future use and avoids a warning message.
  -- 

  kcpsm6_sleep <= '0';
  interrupt <= interrupt_ack;
 
 program_rom: control                    --Name to match your PSM file
    generic map(             C_FAMILY => "S6",   --Family 'S6', 'V6' or '7S'
                    C_RAM_SIZE_KWORDS => 1,      --Program size '1', '2' or '4'
                 C_JTAG_LOADER_ENABLE => 1)      --Include JTAG Loader when set to '1' 
    port map(      address => address,
               instruction => instruction,
                    enable => bram_enable,
                       rdl => kcpsm6_reset,
                       clk => clk);

  input_ports: process(clk)
  begin
    if clk'event and clk='1' then

      if port_id(2)='1' then
        -- read LCD data at address 02 hex
        in_port <= lcd_d & "0000";
      end if;

     end if;

  end process input_ports;
output_ports: process(clk)
  begin
    if clk'event and clk = '1' then
      -- 'write_strobe' is used to qualify all writes to general output ports.
      if write_strobe = '1' then
        -- LCD data output and controls at address 40 hex.
        if port_id(6)='1' then
          lcd_output_data <= out_port(7 downto 4);
          lcd_drive <= out_port(3);
          lcd_rs <= out_port(2);
          lcd_rw_control <= out_port(1);
          lcd_e <= out_port(0);
        end if;
      end if;
    end if; 
  end process output_ports;

  ----------------------------------------------------------------------------------------------------------------------------------
  -- LCD interface  
  ----------------------------------------------------------------------------------------------------------------------------------
  --
  -- The 4-bit data port is bidirectional.
  -- lcd_rw is '1' for read and '0' for write 
  -- lcd_drive is like a master enable signal which prevents either the 
  -- FPGA outputs or the LCD display driving the data lines.
  --
  --Control of read and write signal
  lcd_rw <= lcd_rw_control and lcd_drive;

  --use read/write control to enable output buffers.
  lcd_d <= lcd_output_data when (lcd_rw_control='0' and lcd_drive='1') else "ZZZZ";
  lcd_contrast <= '0';

end Behavioral;

