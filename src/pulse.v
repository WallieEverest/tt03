// DEBUG Design too big
// Attempting to reduce registers in reset logic

`default_nettype none

module pulse (
  input wire              apu_clk,
  input wire              qtr_clk,
  input wire              hlf_clk,
  input wire        [7:0] reg_0,
  input wire        [7:0] reg_1,
  input wire        [7:0] reg_2,
  input wire        [7:0] reg_3,
  output reg signed [4:0] pulse_out = 0
);

  // Input registers
  wire [1:0]  duty_cycle_field = reg_0[7:6];
  wire        counter_enable   = reg_0[5];
  wire        envelope_decay   = reg_0[4];
  wire [3:0]  envelope_period  = reg_0[3:0];
  wire        sweep_enable     = reg_1[7];
  wire [2:0]  sweep_period     = reg_1[6:4];
  wire        sweep_decrement  = reg_1[3];
  wire [2:0]  sweep_shift      = reg_1[2:0];
  wire [10:0] wavelength       = {reg_3[2:0], reg_2};
  wire [ 4:0] length_select    = reg_3[7:3];
  
  // Duty cycle logic
  reg [7:0] duty_cycle = 0;
  
  always @( duty_cycle_field )
  begin
    case ( duty_cycle_field )
      0: duty_cycle <= 8'b00000010;
      1: duty_cycle <= 8'b00000110;
      2: duty_cycle <= 8'b00011110;
      3: duty_cycle <= 8'b11111001;
    endcase
  end
  
  // Length counter logic
  reg [ 7:0] length_preload;

  always @( length_select )
  begin
    case ( length_select )
       0: length_preload <= 8'h0A;
       1: length_preload <= 8'hFE;
       2: length_preload <= 8'h14;
       3: length_preload <= 8'h02;
       4: length_preload <= 8'h28;
       5: length_preload <= 8'h04;
       6: length_preload <= 8'h50;
       7: length_preload <= 8'h06;
       8: length_preload <= 8'hA0;
       9: length_preload <= 8'h08;
      10: length_preload <= 8'h3C;
      11: length_preload <= 8'h0A;
      12: length_preload <= 8'h0E;
      13: length_preload <= 8'h0C;
      14: length_preload <= 8'h1A;
      15: length_preload <= 8'h0E;
      16: length_preload <= 8'h0C;
      17: length_preload <= 8'h10;
      18: length_preload <= 8'h18;
      19: length_preload <= 8'h12;
      20: length_preload <= 8'h30;
      21: length_preload <= 8'h14;
      22: length_preload <= 8'h60;
      23: length_preload <= 8'h16;
      24: length_preload <= 8'hC0;
      25: length_preload <= 8'h18;
      26: length_preload <= 8'h48;
      27: length_preload <= 8'h1A;
      28: length_preload <= 8'h10;
      29: length_preload <= 8'h1C;
      30: length_preload <= 8'h20;
      31: length_preload <= 8'h1E;
    endcase
  end
  
  reg        length_counter_reset = 0;
  reg [ 7:0] length_counter = 0;
  reg [31:0] lc_list = 0;
  // reg [4:0] lc_list = 0;
  
  always @( posedge hlf_clk ) begin
    if ( length_counter_reset ) begin
      length_counter_reset <= 0;
      length_counter       <= length_preload;
      lc_list              <= {reg_3, reg_2, reg_1, reg_0};
      // lc_list              <= length_select;
    end
    else begin
      if ( !counter_enable && (length_counter != 0) )
        length_counter <= length_counter - 1;

      if ( lc_list != {reg_3, reg_2, reg_1, reg_0} ) 
      // if ( lc_list != length_select ) 
        length_counter_reset <= 1;
    end
  end

  // Envelope unit
  reg        envelope_start = 0;
  reg [ 3:0] envlope_prescale = 0;
  reg [ 3:0] envelope_counter = 0;
  reg [ 3:0] envelope_out = 0;
  // reg [31:0] env_list = 0;
  reg [3:0] env_list = 0;

  always @( posedge qtr_clk ) begin
    if ( envelope_start ) begin
      envelope_start   <= 0;
      envlope_prescale <= envelope_period;
      envelope_counter <= ~0;
      // env_list         <= {reg_3, reg_2, reg_1, reg_0};
      env_list         <= envelope_period;
    end
    else begin
      if ( envlope_prescale == 0 ) begin
        envlope_prescale <= envelope_period;

        if ( envelope_counter != 0 ) 
          envelope_counter <= envelope_counter - 1;
        else if ( counter_enable ) 
          envelope_counter <= ~0;
      end
      else 
        envlope_prescale <= envlope_prescale - 1;
      
      if ( envelope_decay ) 
        envelope_out <= envelope_period;
      else 
        envelope_out <= envelope_counter;
      
      // if ( env_list != {reg_3, reg_2, reg_1, reg_0} ) 
      if ( env_list != envelope_period ) 
        envelope_start <= 1;
    end

  end // end always

  // Sweep unit
  reg        swp_reload = 0;
  reg [ 2:0] swp_div = 0;
  reg [10:0] timer_preload = 0;
  // reg [31:0] swp_list = 0;
  reg [23:0] swp_list = 0;

  always @( posedge hlf_clk ) begin
    if ( swp_reload ) begin
      swp_reload     <= 0;
      swp_div        <= sweep_period;
      timer_preload  <= wavelength;
      // swp_list       <= {reg_3, reg_2, reg_1, reg_0};
      swp_list       <= {reg_3, reg_2, reg_1};

      // Adjust pulse channel period
      // Eventually need to check if target period > 0x7ff
      // and other checks as well
      if ( (swp_div == 0) && sweep_enable ) 
        // Sweep down to lower frequencies
        if ( !sweep_decrement ) 
          timer_preload <= timer_preload + (wavelength >> sweep_shift);
        else  // Sweep up to higher frequencies
          timer_preload <= timer_preload - (wavelength >> sweep_shift);
    end
    else begin
      if ( swp_div != 0 ) 
        swp_div <= swp_div - 1;
      else if ( sweep_enable ) begin
        swp_div <= sweep_period;

        // Adjust pulse channel period
        // Eventually need to implement other checks as well
        if ( !sweep_decrement ) // Sweep down to lower frequencies
          timer_preload <= timer_preload + (wavelength >> sweep_shift);
        else  // Sweep up to higher frequencies
          timer_preload <= timer_preload - (wavelength >> sweep_shift);
      end

      // if ( swp_list != {reg_3, reg_2, reg_1, reg_0} ) 
      if ( swp_list != {reg_3, reg_2, reg_1} ) 
        swp_reload <= 1;
    end
  end

  // Timer & sequencer
  reg        seq_reset        = 0;
  reg [10:0] timer_counter    = 0;
  reg [ 2:0] duty_cycle_index = 0;
  reg [31:0] seq_list         = 0;

  always @( posedge apu_clk ) begin
    if ( seq_reset ) begin
      seq_reset        <= 0;
      duty_cycle_index <= 0;
      timer_counter    <= timer_preload;
      seq_list         <= {reg_3, reg_2, reg_1, reg_0};
    end
    
    if ( (timer_counter == 0) && (length_counter != 0) ) begin
      timer_counter <= timer_preload;
      duty_cycle_index <= duty_cycle_index - 1;
        
      if ( ( duty_cycle >> duty_cycle_index ) & 8'h1 ) 
        pulse_out <=  envelope_out;
      else 
        pulse_out <= -envelope_out;            
    end
    
    else if ( length_counter != 0 ) 
      timer_counter <= timer_counter - 1;
    else if ( seq_list != {reg_3, reg_2, reg_1, reg_0} )
      seq_reset <= 1;
  end
  
endmodule
