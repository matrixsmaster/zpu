--
-- this model describes the behaviour of the RENA3 ASIC
--



library ieee;
use ieee.std_logic_1164.all;



package rena3_model_package is


    type real_array is array(natural range <>) of real;

    component rena3_model is

        port (
            -- Pad Name                         Description
            -- VRI         : in  std_ulogic; -- 2V, Very low noise power supply
            -- VDDA        : in  std_ulogic; -- 5V, Analog power supply
            -- VDDA1       : in  std_ulogic; -- 5V, Low noise analog power supply #1
            -- VDDA2       : in  std_ulogic; -- 5V, Low noise analog power supply #2
            -- VDD         : in  std_ulogic; -- 5V, Digital power supply
            -- VSS         : in  std_ulogic; -- 0V, Digital ground
            -- VSSA1       : in  std_ulogic; -- 0V, Low noise analog ground
            -- VSSA        : in  std_ulogic; -- 0V, Analog ground
            TEST           : in  real;       -- +/-720mV step input to simulate signal. This signal is for testing
                                             -- channels.
            -- VGATE       : in  std_ulogic; -- 0V or ~1.5V for simple gate feedback operation. Must enable with
                                             -- FETSEL bit in channel to use this.
            -- DACREF      : in  std_ulogic; -- 2 to 3V, DAC reference level. Sets the MAX DAC output voltage to
                                             -- VREFLO + 1.5*13/16*DACREF
            -- VU          : in  std_ulogic; -- 2 � 3V sine wave, U timing signal for sampling by fast trigger
            -- VV          : in  std_ulogic; -- 2 � 3V sine wave, V timing signal for sampling by fast trigger
            -- ISET        : in  std_ulogic; -- 6.98Kohm to VDDA, Sets input FET bias current
            -- PBIAS       : in  std_ulogic; -- 33.2Kohm to ground. Sets bias current for most amplifiers
            -- FB_PBIAS    : in  std_ulogic; -- 47.5Kohm to ground, Sets feedback circuit bias current
            -- R_BIAS      : in  std_ulogic; -- 93.1Kohm to ground, Sets feedback R bias current
            -- VREFHI      : in  std_ulogic; -- 3.5V, High reference for negative going signals
            -- VREFLO      : in  std_ulogic; -- 1.5V, Low reference for positive going signals and reference for low rail
                                             -- of DAC
            DETECTOR_IN    : in  real_array(0 to 35); -- Detector inputs pins
            -- AOUTP       : in  std_ulogic; -- ?, Positive differential output
            -- AOUTN       : in  std_ulogic; -- ?, Negative differential output
            CSHIFT         : in  std_ulogic; -- Shift one bit (from Cin) into the shift register on the rising edge
            CIN            : in  std_ulogic; -- Data input. Must be valid on the rising edge of CShift
            CS             : in  std_ulogic  -- Chip Select. After shifting 41 bits, pulse this signal high to load the
                                             -- shifted data in the proper registers
            -- TS_N        : in  std_ulogic; -- Differential out, Slow trigger output, Negative output
            -- TS_P        : in  std_ulogic; -- Differential out, Slow trigger output, positive output
            -- TF_N        : in  std_ulogic; -- Differential out, Fast trigger output, Negative Output
            -- TF_P        : in  std_ulogic; -- Differential out, Fast trigger output, positive output
            -- FOUT        : in  std_ulogic; -- Fast token output for fast token register
            -- SOUT        : in  std_ulogic; -- Slow token output for slow token register
            -- TOUT        : in  std_ulogic; -- Token output from token chain. Goes high when chip is finished to pass
                                             -- token to next chip.
            -- READ        : in  std_ulogic; -- Enables output of analog signals within a channel. Turns on the analog
                                             -- driver for a channel when token is present. Also enables output buffer.
            -- TIN         : in  std_ulogic; -- Token input, Always set a 1 for first channel, or receives TOUT from
                                             -- previous chip.
            -- SIN         : in  std_ulogic; -- Slow token input. Use with SHRCLK to load bits into slow token chain.
            -- FIN         : in  std_ulogic; -- Fast token input. Use with FHRCLK to load bits into slow token chain.
            -- SHRCLK      : in  std_ulogic; -- Slow hit register clock. Loads SIN bits on rising edge
            -- FHRCLK      : in  std_ulogic; -- Fast hit register clock. Loads FIN bits on rising edge
            -- ACQUIRE_P   : in  std_ulogic; -- Positive differential input, Peak detector is active when this signal is
                                             -- asserted (high).
            -- ACQUIRE_N   : in  std_ulogic; -- Negative differential input, Peak detector is active when this signal is
                                             -- asserted (low).
            -- CLS_P       : in  std_ulogic; -- Positive differential input, Peak detector reset signal. Resets the peak
                                             -- detector when asserted (high). Also clears the token register.
            -- CLS_N       : in  std_ulogic; -- Negative differential input, Peak detector reset signal. Resets the peak
                                             -- detector when asserted (low). Also clears the token register.
            -- CLF         : in  std_ulogic; -- This signal clears the fast latch (VU and VV sample circuit) when
                                             -- asserted, (high).
            -- TCLK        : in  std_ulogic; -- This signal shifts the token from one channel to the next on the rising
                                             -- edge
            -- TST         : in  std_ulogic_vector(3 to 22)  -- Pull to VDD with 44Kohm resistor. Test signal outputs. AKA T[3-22]
        );
    end component rena3_model;

end package rena3_model_package;






library ieee;
use ieee.std_logic_1164.all;

library rena3;
use rena3.rena3_model_package.real_array;

entity rena3_model is
    port (
        -- Pad Name                         Description
        -- VRI         : in  std_ulogic; -- 2V, Very low noise power supply
        -- VDDA        : in  std_ulogic; -- 5V, Analog power supply
        -- VDDA1       : in  std_ulogic; -- 5V, Low noise analog power supply #1
        -- VDDA2       : in  std_ulogic; -- 5V, Low noise analog power supply #2
        -- VDD         : in  std_ulogic; -- 5V, Digital power supply
        -- VSS         : in  std_ulogic; -- 0V, Digital ground
        -- VSSA1       : in  std_ulogic; -- 0V, Low noise analog ground
        -- VSSA        : in  std_ulogic; -- 0V, Analog ground
        TEST           : in  real;       -- +/-720mV step input to simulate signal. This signal is for testing
                                         -- channels.
        -- VGATE       : in  std_ulogic; -- 0V or ~1.5V for simple gate feedback operation. Must enable with
                                         -- FETSEL bit in channel to use this.
        -- DACREF      : in  std_ulogic; -- 2 to 3V, DAC reference level. Sets the MAX DAC output voltage to
                                         -- VREFLO + 1.5*13/16*DACREF
        -- VU          : in  std_ulogic; -- 2 � 3V sine wave, U timing signal for sampling by fast trigger
        -- VV          : in  std_ulogic; -- 2 � 3V sine wave, V timing signal for sampling by fast trigger
        -- ISET        : in  std_ulogic; -- 6.98Kohm to VDDA, Sets input FET bias current
        -- PBIAS       : in  std_ulogic; -- 33.2Kohm to ground. Sets bias current for most amplifiers
        -- FB_PBIAS    : in  std_ulogic; -- 47.5Kohm to ground, Sets feedback circuit bias current
        -- R_BIAS      : in  std_ulogic; -- 93.1Kohm to ground, Sets feedback R bias current
        -- VREFHI      : in  std_ulogic; -- 3.5V, High reference for negative going signals
        -- VREFLO      : in  std_ulogic; -- 1.5V, Low reference for positive going signals and reference for low rail
                                         -- of DAC
        DETECTOR_IN    : in  real_array(0 to 35); -- Detector inputs pins
        -- AOUTP       : in  std_ulogic; -- ?, Positive differential output
        -- AOUTN       : in  std_ulogic; -- ?, Negative differential output
        CSHIFT         : in  std_ulogic; -- Shift one bit (from Cin) into the shift register on the rising edge
        CIN            : in  std_ulogic; -- Data input. Must be valid on the rising edge of CShift
        CS             : in  std_ulogic  -- Chip Select. After shifting 41 bits, pulse this signal high to load the
                                         -- shifted data in the proper registers
        -- TS_N        : in  std_ulogic; -- Differential out, Slow trigger output, Negative output
        -- TS_P        : in  std_ulogic; -- Differential out, Slow trigger output, positive output
        -- TF_N        : in  std_ulogic; -- Differential out, Fast trigger output, Negative Output
        -- TF_P        : in  std_ulogic; -- Differential out, Fast trigger output, positive output
        -- FOUT        : in  std_ulogic; -- Fast token output for fast token register
        -- SOUT        : in  std_ulogic; -- Slow token output for slow token register
        -- TOUT        : in  std_ulogic; -- Token output from token chain. Goes high when chip is finished to pass
                                         -- token to next chip.
        -- READ        : in  std_ulogic; -- Enables output of analog signals within a channel. Turns on the analog
                                         -- driver for a channel when token is present. Also enables output buffer.
        -- TIN         : in  std_ulogic; -- Token input, Always set a 1 for first channel, or receives TOUT from
                                         -- previous chip.
        -- SIN         : in  std_ulogic; -- Slow token input. Use with SHRCLK to load bits into slow token chain.
        -- FIN         : in  std_ulogic; -- Fast token input. Use with FHRCLK to load bits into slow token chain.
        -- SHRCLK      : in  std_ulogic; -- Slow hit register clock. Loads SIN bits on rising edge
        -- FHRCLK      : in  std_ulogic; -- Fast hit register clock. Loads FIN bits on rising edge
        -- ACQUIRE_P   : in  std_ulogic; -- Positive differential input, Peak detector is active when this signal is
                                         -- asserted (high).
        -- ACQUIRE_N   : in  std_ulogic; -- Negative differential input, Peak detector is active when this signal is
                                         -- asserted (low).
        -- CLS_P       : in  std_ulogic; -- Positive differential input, Peak detector reset signal. Resets the peak
                                         -- detector when asserted (high). Also clears the token register.
        -- CLS_N       : in  std_ulogic; -- Negative differential input, Peak detector reset signal. Resets the peak
                                         -- detector when asserted (low). Also clears the token register.
        -- CLF         : in  std_ulogic; -- This signal clears the fast latch (VU and VV sample circuit) when
                                         -- asserted, (high).
        -- TCLK        : in  std_ulogic; -- This signal shifts the token from one channel to the next on the rising
                                         -- edge
        -- TST         : in  std_ulogic_vector(3 to 22)  -- Pull to VDD with 44Kohm resistor. Test signal outputs. AKA T[3-22]
    );
end entity rena3_model;





use std.textio.all;

library ieee;
use ieee.numeric_std.all;

library tools;
use tools.fio_pkg.all;



architecture behave of rena3_model is


    ------------------------------------------
    -- definitions

    constant me_c : string := behave'path_name;


    type     gain_array_t is array(natural range <>) of real;
    constant gain_array_c : gain_array_t := (1.6, 1.8, 2.3, 5.0);

    function get_gain( g: std_ulogic_vector) return real is
    begin
        return gain_array_c( to_integer( unsigned(g)));
    end function get_gain;

    
    subtype  sel_t is real;
    type     sel_array_t is array(natural range <>) of sel_t;
    constant sel_array_c : sel_array_t := (0.29, 0.31, 0.31, 0.32, 0.35, 0.37, 0.39, 0.40, 0.71, 0.81, 0.89, 1.1, 1.9, 2.8, 4.5, 38.0);

    function get_sel( sel: std_ulogic_vector) return sel_t is
    begin
        return sel_array_c( to_integer( unsigned(sel)));
    end function get_sel;



    type channel_configuration_t is record
        -- FB_TC, Feedback time constant selection. Selects the size of the feedback
        -- resistor for the input stage. 1 Selects 1.2Gohm feedback resistance, 0
        -- Selection 200Mohm.
        fb_tc    : std_ulogic;
        -- ECAL, Enable channel calibration. Set to 1 to enable TEST signal input to
        -- channel.
        ecal     : std_ulogic;
        -- FPDWN, Set to a 1 to power down fast path circuits. This includes the fast
        -- shaper, a DAC, and the comparator for the fast path.
        fpdwn    : std_ulogic;
        -- FETSEL, Set to a 1 to use the simple FET feedback instead of the resistive
        -- multiplier circuit.
        fetsel   : std_ulogic;
        -- G[1-0], Gain selection. The gain selection following the differentiation
        -- stage has 4 selections for gain. [00] = 1.6, [01] = 1.8 [10] = 2.3 [11] = 5.0
        g        : real;
        -- PDWN, Set to a 1 to power down most of the circuits in the channel.
        -- FPDWN must still be used to power down the fast components.
        pdwn     : std_ulogic;
        -- PZSEL, Pole Zero cancellation selection. Set this bit to a 1 to enable the pole
        -- zero cancellation circuit.
        pzsel    : std_ulogic;
        -- RANGE, Sets the feedback capacitor size. Set to a 1 for 60fF feedback. Set
        -- to a 0 for 15fF feedback.
        cap_range : std_ulogic;
        -- RSEL, Reference selection for the channel. Set to a 1 to select VREFHI (for
        -- negative going signals)
        rsel     : std_ulogic;
        -- SEL[3-0], Time constant selection. All 0�s is the shortest time constant. All
        -- 1's is the longest time constant. Selections are, from shortest to longest (us):
        -- 0.29, 0.31, 0.31, 0.32, 0.35, 0.37, 0.39, 0.40, 0.71, 0.81, 0.89, 1.1, 1.9, 2.8,
        -- 4.5, 38. SEL[0] is the LSB and this goes into the shift register after SEL[3-1].
        sel      : sel_t;
        -- SIZEA, Selects the size of the input FET for noise optimization. Set to a 1
        -- for a FET of size 1000um. Set to a 0 for a size of 450um.
        sizea    : std_ulogic;
        -- DF[7-0], Fast DAC value. All 0�s gives the lowest output voltage (VREFLO
        -- - 3/16*1.5*DACREF). All 1�s are largest output voltage (VREFLO +
        -- 13/16*1.5*DACREF). DF[0] is the LSB and goes into the shift register last.
        df       : unsigned(7 downto 0);
        -- POL, Polarity selection for comparators. Select a 1 for positive going
        -- signals.
        pol      : std_ulogic;
        -- DS[7-0], Slow DAC value. All 0�s are smallest output voltage (VREFLO �
        -- 13/16*1.5*DACREF). All 1�s are largest output voltage (VREFLO +
        -- 13/16*1.5*DACREF). DS[0] is the LSB and goes into the shift register last.
        ds       : unsigned(7 downto 0);
        -- ENF, Set to a 1 to enable FAST trigger.
        enf      : std_ulogic;
        -- ENS, Set to a 1 to enable the SLOW trigger.
        ens      : std_ulogic;
        -- FM, Follower mode. Set to a one to enable peak detector to work in follower
        -- mode. It only makes sense to have a single one of these bits set at a time for
        -- all channels.
        fm       : std_ulogic;
    end record channel_configuration_t;
    constant default_channel_configuration_c : channel_configuration_t := (
        fb_tc     => '0', 
        ecal      => '0',
        fpdwn     => '0',
        fetsel    => '0',
        g         => gain_array_c(0),
        pdwn      => '0',
        pzsel     => '0',
        cap_range => '0',
        rsel      => '0',
        sel       => sel_array_c(0),
        sizea     => '0', 
        df        => "00000000",
        pol       => '0',
        ds        => "00000000",
        enf       => '0',
        ens       => '0',
        fm        => '0'
    );

    ------------------------------------------
    -- signal definitions

    type   channel_configuration_array_t is array(natural range <>) of channel_configuration_t;
    signal channel_configuration_array : channel_configuration_array_t(0 to 35);


begin



    ----------------------------------------
    -- channel configuration
    channel_configuration: block
      
        -- time constants for time checker
        constant Tsrh  : time := 10 ns; -- CShift high        
        constant Tsrl  : time := 10 ns; -- CShift low         
        constant Tsds  : time := 9  ns; -- CIN setup time     
        constant Tsdh  : time := 9  ns; -- CIN hold time      
        constant Tchcs : time := 20 ns; -- CShift to CS delay 
        constant Tsh   : time := 20 ns; -- CS high            
        constant Tcsch : time := 20 ns; -- CS to Cshift       
        
        
        -- 6-bit control register address (MSB goes in first) Address 0 is at the top of
        -- the chip; Address 35 is at the bottom. This address points to the channel.
        -- Use CS to load the following 35 bits into the channel selected.
        signal channel_configuration : std_ulogic_vector(40 downto 0); 


    begin
      
        shift_in: process
        begin
            wait until rising_edge(CShift);
            channel_configuration <= channel_configuration(39 downto 0) & CIN;
        end process;

        update_reg: process
            variable address               : natural range 0 to 35;
        begin
            wait until rising_edge(CS);
            address                    := to_integer(unsigned(channel_configuration(40 downto 35)));
            channel_configuration_array(address).fb_tc     <= channel_configuration(34);
            channel_configuration_array(address).ecal      <= channel_configuration(33);
            channel_configuration_array(address).fpdwn     <= channel_configuration(32);
            channel_configuration_array(address).fetsel    <= channel_configuration(31);
            channel_configuration_array(address).g         <= get_gain(channel_configuration(30 downto 29));
            channel_configuration_array(address).pdwn      <= channel_configuration(28);
            channel_configuration_array(address).pzsel     <= channel_configuration(27);
            channel_configuration_array(address).cap_range <= channel_configuration(26);
            channel_configuration_array(address).rsel      <= channel_configuration(25);
            channel_configuration_array(address).sel       <= get_sel(channel_configuration(24 downto 21));
            channel_configuration_array(address).sizea     <= channel_configuration(20);
            channel_configuration_array(address).df        <= unsigned(channel_configuration(19 downto 12));
            channel_configuration_array(address).pol       <= channel_configuration(11);
            channel_configuration_array(address).ds        <= unsigned(channel_configuration(10 downto  3));
            channel_configuration_array(address).enf       <= channel_configuration( 2);
            channel_configuration_array(address).ens       <= channel_configuration( 1);
            channel_configuration_array(address).fm        <= channel_configuration( 0);
        end process update_reg;

        -- TODO check the config
        -- only follower mode supported
        -- only testmode supported
        print_reg: process (channel_configuration_array)
            variable address               : natural range 0 to 35;
            variable l                     : line;
            variable i                     : integer;
            variable s                     : line;
        begin
            address                    := to_integer(unsigned(channel_configuration(40 downto 35)));
            fprint( output, l, "-------------- %30s --------------\n", me_c);
            fprint( output, l, "update internal register at address : %d\n", fo( address));
            
            fprint( output, l, "%20s %b    ", "fb_tc",      fo( channel_configuration_array(address).fb_tc));
            if channel_configuration_array(address).fb_tc = '1' then 
                fprint( output, l, "(1.2Gohm feedback resistance)\n"); 
            else 
                fprint( output, l, "(200Mohm feedback resistance)\n"); 
            end if;
            
            fprint( output, l, "%20s %b    ", "ecal",       fo( channel_configuration_array(address).ecal));
            if channel_configuration_array(address).ecal = '1' then 
                fprint( output, l, "(channel calibration, TEST signal on input)\n");
            else 
                fprint( output, l, "\n");
            end if;
            
            fprint( output, l, "%20s %b    ", "fpdwn",      fo( channel_configuration_array(address).fpdwn));
            if channel_configuration_array(address).fpdwn = '1' then 
                fprint( output, l, "(power down fast circuits)\n"); 
            else 
                fprint( output, l, "\n");
            end if;
            
            fprint( output, l, "%20s %b    ", "fetsel",     fo( channel_configuration_array(address).fetsel));
            if channel_configuration_array(address).fetsel = '1' then 
                fprint( output, l, "(simple FET feedback)\n"); 
            else 
                fprint( output, l, "(resistive multipier circuit)\n"); 
            end if;

            i := integer(channel_configuration_array(address).g*10.0);
            fprint( output, l, "%20s %d.%d  (gain)\n",  "g",          fo(i / 10), fo(i mod 10));

            fprint( output, l, "%20s %b    ", "pdwn",       fo( channel_configuration_array(address).pdwn));
            if channel_configuration_array(address).pdwn = '1' then 
                fprint( output, l, "(power down enabled)\n");
            else 
                fprint( output, l, "\n");
            end if;
            
            fprint( output, l, "%20s %b    ", "pzsel",      fo( channel_configuration_array(address).pzsel));
            if channel_configuration_array(address).pzsel = '1' then 
                fprint( output, l, "(pole zero cancellation enabled)\n");
            else 
                fprint( output, l, "\n");
            end if;

            fprint( output, l, "%20s %b    ", "cap_range",  fo( channel_configuration_array(address).cap_range));
            if channel_configuration_array(address).cap_range = '1' then 
                fprint( output, l, "(60 fF feedback cap)\n"); 
            else 
                fprint( output, l, "(15 fF feedback cap)\n"); 
            end if;

            fprint( output, l, "%20s %b    ", "rsel",       fo( channel_configuration_array(address).rsel));
            if channel_configuration_array(address).rsel = '1' then 
                fprint( output, l, "(select VREFHI)\n"); 
            else 
                fprint( output, l, "(select VREFLO?)\n"); 
            end if;

            i := integer(channel_configuration_array(address).sel*100.0);
            fprint( output, l, "%20s %d.%2d (time constant in us)\n", "sel",        fo(i / 100), fo(i mod 100));

            fprint( output, l, "%20s %b    ", "sizea",      fo( channel_configuration_array(address).sizea));
            if channel_configuration_array(address).sizea = '1' then 
                fprint( output, l, "(1000 um input FET)\n"); 
            else 
                fprint( output, l, "(450 um input FET)\n"); 
            end if;

            fprint( output, l, "%20s %d\n",     "df",         fo( channel_configuration_array(address).df));

            fprint( output, l, "%20s %b    ", "pol",        fo( channel_configuration_array(address).pol));
            if channel_configuration_array(address).pol = '1' then 
                fprint( output, l, "(positive polarity)\n"); 
            else 
                fprint( output, l, "(negative polarity)\n"); 
            end if;

            fprint( output, l, "%20s %d\n",     "ds",         fo( channel_configuration_array(address).ds));

            fprint( output, l, "%20s %b    ", "enf",        fo( channel_configuration_array(address).enf));
            if channel_configuration_array(address).enf = '1' then 
                fprint( output, l, "(fast trigger enabled)\n"); 
            else 
                fprint( output, l, "\n");
            end if;

            fprint( output, l, "%20s %b    ", "ens",        fo( channel_configuration_array(address).ens));
            if channel_configuration_array(address).ens = '1' then 
                fprint( output, l, "(slow trigger enabled)\n");
            else 
                fprint( output, l, "\n");
            end if;

            fprint( output, l, "%20s %b    ", "fm",         fo( channel_configuration_array(address).fm));
            if channel_configuration_array(address).fm = '1' then 
                fprint( output, l, "(follower mode)\n");
            else 
                fprint( output, l, "\n");
            end if;

            fprint( output, l, "%60{-}\n");
        end process;

        time_check_cin_setup: process
            variable data_change: time;
        begin
            wait until CIN'event;
            data_change := now;
            wait until rising_edge(CShift);

            assert (now - data_change) >= Tsds
                report   me_c & " Cin setup time to short"
                severity error;
        end process;

        time_check_cin_hold: process
            variable data_change: time;
        begin
            wait until rising_edge(CShift);
            data_change := now;
            wait until CIN'event;

            assert (now - data_change) >= Tsdh
                report   me_c & " Cin hold time to short"
                severity error;
        end process;

        time_check_cshift_low: process
            variable change: time;
        begin
            wait until rising_edge(CShift);
            change := now;
            wait until falling_edge(CShift);

            assert (now - change) >= Tsrl
                report   me_c & " Cshift low time to short"
                severity error;
        end process;
    
        time_check_cshift_high: process
            variable change: time;
        begin
            wait until falling_edge(CShift);
            change := now;
            wait until rising_edge(CShift);

            assert (now - change) >= Tsrh
                report   me_c & " Cshift high time to short"
                severity error;
        end process;
    
        time_check_cshift_to_cs_delay: process
            variable change: time;
        begin
            wait until falling_edge(CShift);
            change := now;
            wait until rising_edge(CS);

            assert (now - change) >= Tchcs
                report   me_c & " CShift to CS delay is to short"
                severity error;
        end process;
    
        time_check_cs_high: process
            variable change: time;
        begin
            wait until rising_edge(CS);
            change := now;
            wait until falling_edge(CS);

            assert (now - change) >= Tsh
                report   me_c & " CS high time to short"
                severity error;
        end process;
    
        time_check_cs_to_cshift: process
            variable change: time;
        begin
            wait until falling_edge(CS);
            change := now;
            wait until rising_edge(CShift);

            assert (now - change) >= Tcsch
                report   me_c & " CS to CShift is to short"
                severity error;
        end process;
    
    end block channel_configuration;


end architecture behave;