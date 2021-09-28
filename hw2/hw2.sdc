create_clock -name clock100 -period 10.000 -waveform {0 5} [get_ports {clk}]
derive_clock_uncertainty
