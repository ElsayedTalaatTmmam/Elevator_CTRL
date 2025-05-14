`timescale 1ns/1ps

module Elevator_CTRL_tb;

  // Parameters
  localparam Num_Floors = 5;

  // Inputs
  logic CLK;
  logic RST;
  logic [Num_Floors-1:0] i_req_ext;
  logic [Num_Floors-1:0] i_req_inter;
  logic i_stop;

  // Outputs
  logic [2:0] o_current_floor;
  logic o_up;
  logic o_down;
  logic o_door;

  // Instantiate DUT
  Elevator_CTRL #(Num_Floors) dut (
    .CLK(CLK),
    .RST(RST),
    .i_req_ext(i_req_ext),
    .i_req_inter(i_req_inter),
    .i_stop(i_stop),
    .o_current_floor(o_current_floor),
    .o_up(o_up),
    .o_down(o_down),
    .o_door(o_door)
  );

  // Clock Generation
  initial begin
    CLK = 0;
    forever #10 CLK = ~CLK; // 50MHz clock
  end

  // Test sequence
  initial begin
    // Initialize
    RST = 1;
    i_req_ext = 5'b00000;
    i_req_inter = 5'b00000;
    i_stop = 0;

    // Apply Reset
    #10;
    RST = 0;
    #10;
    RST = 1;
    #20;

    // External request to Floor 4 (cmp_out -> 5'b01000)
    i_req_ext = 5'b01000;
    #200;

    // External request to Floor 2 (cmp_out -> 5'b00010)
    i_req_ext = 5'b00010;
    #150;

    // Internal request to Floor 5 (cmp_out -> 5'b10000)
    i_req_inter = 5'b10000;
    i_req_ext = 5'b00000;
    #300;

    i_req_inter = 5'b00000;
    i_req_ext = 5'b00100;
    #30;
    // Issue a stop
    i_stop = 1;
    #50;
    i_stop = 0;
    #150;

    // No requests (should stay idle)
    i_req_ext = 5'b00001;
    i_req_inter = 5'b00000;
    #150;

    i_req_ext = 5'b00000;
    i_req_inter = 5'b10000;
    #150;
    i_req_ext = 5'b10000;
    i_req_inter = 5'b00000;
    #150;

    i_req_ext = 5'b00000;
    i_req_inter = 5'b00001;
    #250;
    $stop;
  end


endmodule

