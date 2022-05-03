//===========================================================================
//ece385 final project: spacefighter
//date: 4/20/2022
//===========================================================================

module final385_top(
   //////////// CLOCK //////////
   input 		          		ADC_CLK_10,
   input 		          		MAX10_CLK1_50,
   input 		          		MAX10_CLK2_50,

   //////////// SEG7 //////////
   output		     [7:0]		HEX0,
   output		     [7:0]		HEX1,
   output		     [7:0]		HEX2,
   output		     [7:0]		HEX3,
   output		     [7:0]		HEX4,
   output		     [7:0]		HEX5,
	
	//////////// SDRAM //////////
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

   //////////// KEY //////////
   input 		     [1:0]		KEY,

   //////////// LED //////////
   output		     [9:0]		LEDR,

   //////////// SW //////////
   input 		     [9:0]		SW,

//   //////////// Accelerometer ports //////////
//   output		          		GSENSOR_CS_N,
//   input 		     [2:1]		GSENSOR_INT,
//   output		          		GSENSOR_SCLK,
//   inout 		          		GSENSOR_SDI,
//   inout 		          		GSENSOR_SDO,
	
	
	///////// VGA /////////
	output             VGA_HS,
	output             VGA_VS,
	output   [ 3: 0]   VGA_R,
	output   [ 3: 0]   VGA_G,
	output   [ 3: 0]   VGA_B,
	
	
	//////////// Arduino //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N
   );

//===== Declarations
   localparam SPI_CLK_FREQ  = 200;  // SPI Clock (Hz)
   localparam UPDATE_FREQ   = 1;    // Sampling frequency (Hz)

   // clks and reset
   logic Reset_h;
   logic clk, spi_clk, spi_clk_out;
	logic vssig, blank, sync, VGA_Clk;

	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
   logic [23:0] keycode_temp; //24 bit keycode, can deal with 3 keycode

	
	
   // output data
   logic data_update;
   logic [15:0] data_x, data_y;
	
	
	
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig;
	logic [7:0] Red, Blue, Green;

	
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];

// Pressing KEY0 freezes the accelerometer's output
//assign reset_n = KEY[0];

assign {Reset_h}=~ (KEY[0]);

	//=======================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
//	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
//	assign HEX4[7] = 1'b1;
//	
//	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
//	assign HEX3[7] = 1'b1;
//	
//	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
//	assign HEX1[7] = 1'b1;
//	
//	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
//	assign HEX0[7] = 1'b1;
//	
//	//fill in the hundreds digit as well as the negative sign
//	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
//	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	//HexDriver hexs [5:0](.In0(24'h111111), .Out0({HEX5[6:0], HEX4[6:0], HEX3[6:0], HEX2[6:0], HEX1[6:0], HEX0[6:0]}));
	
	//=======================================


	final_project_platform u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX and SW
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		//.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode_temp),
		.switch_export(SW),
		.random_num_export(random_number)
		);


//		assign LEDR = {Ball_die,obstacle_activate[0], obstacle_activate[1],
//							obstacle_activate[2], obstacle_activate[3]};
		assign LEDR = {left_move, right_move ,Ball_die};

// 7-segment displays HEX0-3 show data_x in hexadecimal
//HexDriver s0 (
//   .In0      (data_x[4:0]),
//   .Out0 (HEX0) );
//
//HexDriver s1 (
//   .In0      (data_x[7:5]),
//   .Out0 (HEX1) );
//
//HexDriver s2 (
//   .In0      (data_x[11:8]),
//   .Out0 (HEX2) );
//
//HexDriver s3 (
//   .In0      (data_x[15:12]),
//   .Out0 (HEX3) );

// A few statements just to light some LEDs
//HexDriver s4 ( .In0(SW[5:2]), .Out0(HEX4) );
//HexDriver s5 ( .In0(SW[9:6]), .Out0(HEX5) );
//assign LEDR = {SW[9:8], data_x[7:0]};


	logic [31:0] random_number;

	//vga module
	vga_controller vga (
					.Clk(MAX10_CLK1_50),
					.Reset(Reset_h),
					.hs(VGA_HS),
					.vs(VGA_VS),
					.pixel_clk(VGA_Clk),
					.blank,
					.sync,
					.DrawX(drawxsig),
					.DrawY(drawysig)
	
	);
	
	//all the game signals
	logic start_screen, game_screen, game_over;
	
	//this is the game state machine
	gameFSM	state_machine(
					.Clk(MAX10_CLK1_50), 
					.Reset(Reset_h), //reset the game and run the game: shouold be controlled by the button or keyboard
					.player_die(Ball_die),
					.keycode(keycode_temp),		//use to activate the game
					.start_screen,
					.game_screen,
					.game_over
					);
	
	//this parameter control the number of asteroid
	parameter num_obstacle = 17;	
	
	//var for ball_two aka the player
	logic [9:0] Ball_W, Ball_H;
	logic Ball_die;
	logic left_move, right_move;
	//ball module 
	ball_two #(.obj_num(num_obstacle)) player //takes in a parameter called num_obstacle
					
					( 	//input
					.Reset(start_screen || game_over), 
					.frame_clk(VGA_VS),
					//.data_x,
					//.data_y,
					.enemy_x(object_X), 
					.enemy_y(object_Y), 
					.enemy_size(object_Size),
					.keycode(keycode_temp),
					.enermy_alive(obstacle_activate),
					//.mode_sw(SW[0]),
					
					//output
					.BallX(ballxsig),
					.BallY(ballysig), 
					.Ball_W,
					.Ball_H,
					.left_move,
					.right_move,
					.Ball_die
	);
	
	
	//local vars for the asteroids
	logic [9:0] object_Size[num_obstacle], object_X[num_obstacle], object_Y[num_obstacle];
	logic obstacle_activate[num_obstacle];
	logic [9:0] set_x_pos, set_x_pos_2, set_x_pos_3;
	//logic [2:0] x_speed, y_speed;
	logic [2:0] new_x_speed, new_y_speed;
	logic sign;
	
	//asteroid module
	obstacle	#(.object_num(num_obstacle)) //takes in a parameter called num_obstacle
			obj
				(   
					//input
					.game_over,
					.start_screen,
					.keycode(keycode_temp),
					//.Reset(start_screen || game_over), 
					//.clearScore(start_screen || (keycode && game_over)), //start_screen clear the score, also clear the score when restart
					.frame_clk(VGA_VS),
					.ball_ammo_x(bullet_X_out),
					.ball_ammo_y(bullet_Y_out),
					.ball_ammo_size(bullet_size),
					.set_position_x(random_number[9:0]),
					//.set_position_x_2(set_x_pos_2),
					//.set_position_x_3(set_x_pos_3),
					//setting the random speed
					.x_speed({3'b0,random_number[5:4]}), 
					.y_speed({3'b0,random_number[8:7]}),	//
					.sign(random_number[0]),
					//output
					
					.score,
					.bullet_hit,   // bullet hit the object
					.object_Size, //object size
					.object_X, 
					.object_Y,   //, //object location
					.obstacle_activate		  //the object is on
				);
		

	//bullet local variable
	logic [9:0] bullet_X_out, bullet_Y_out, bullet_size;
	logic bullet_active, bullet_hit;
	//bullet module 
	bullet	ammo(  	
					//input
					.game_over,
					.start_screen,
               .bullet_X(ballxsig), //the bullet appears at the tip of the plane 
					.bullet_Y(ballysig), //this is for the ball location - the ball_size
					.bullet_hit,               //if bullet hit something then it disappear
               .Reset(start_screen || game_over),                    //reset the bullets
               .frame_clk(VGA_VS),                //clk to control the bullet
               .space_key(keycode_temp),          //space key is hit

					//output
					//.score,
               .bullet_active,           //the bullet is still active
               .bullet_X_out, 
					.bullet_Y_out, 
					.bullet_size
            	);
					
					
	parameter score_digit = 3;
	
	//the lower decimal,tenth decimal, hundred decimal
	logic [23:0] tenth, lower, hun;
	//this way is not recommanded
	assign tenth = (score / 10);
	assign hun = (tenth / 10);

	
	logic [23:0] score;
	//HexDriver hexs [5:0](.In0(24'h111111), .Out0({HEX5[6:0], HEX4[6:0], HEX3[6:0], HEX2[6:0], HEX1[6:0], HEX0[6:0]}));
	HexDriver hex1(.In0(score_display[2]), .Out0(HEX0));
	HexDriver hex2(.In0(score_display[1]), .Out0(HEX1));
	HexDriver hex3(.In0(score_display[0]), .Out0(HEX2));
	HexDriver hex4(.In0(4'b0001), .Out0(HEX3));
	//HexDriver hex3(.In0(), .Out0(HEX2));
	
	logic [3:0] score_display[score_digit];
	
	//a nice way to display the score
	assign score_display[0] = hun[3:0] % 10;
	assign score_display[1] = tenth[3:0] % 10;
	assign score_display[2] = score % 10;
	
	
	//color mapper module
	color_mapper #(.obj_num(num_obstacle),
						.score_num(score_digit))
	
					color0(
					.ram_clk(MAX10_CLK1_50),
					.Reset(Reset_h),
					//come from the state machine, used for screen switching 
					.start_screen,
					.game_screen,
					.game_over,
					.left_motion(left_move),
					.right_motion(right_move),
					.score_display,
					//x position drawing and y position drawing
					.DrawX(drawxsig), 
					.DrawY(drawysig), 
					.blank,
					.pixel_clk(VGA_Clk),
					.vs(VGA_VS),
					.hs(VGA_HS),
					//player
					.BallX(ballxsig), 
					.BallY(ballysig), 
					.BallWidth(Ball_W),
					.BallHeight(Ball_H),
					
					//obstacle
					.Obj_X(object_X), 
					.Obj_Y(object_Y), 
					.Obj_Size(object_Size),
					.Obj_act(obstacle_activate),
					
					//bullet data
					.bullet_x(bullet_X_out),
					.bullet_y(bullet_Y_out),
					.bullet_size,
					.bullet_activate(bullet_active),
					
					//color display
					.Red, 
					.Green, 
					.Blue 
	);

	


endmodule
//keycode should be 21 bit to accept two direction key and a shooting key 


//random number generator section
//	random_generater rd(	.Clk(MAX10_CLK1_50), 
//								.Reset(Reset_h),		
//								.new_obj_x(set_x_pos_2),	//new position of the objects
//								);
//								
//	LFSR_v1	rand_gen2(
//					.Clk(MAX10_CLK1_50), 
//					.Reset(Reset_h),
//					.random_position(set_x_pos_3)
//				);

//	counter_rand    rand_gen(	.Clk(MAX10_CLK1_50),
//							.frame_Clk(VGA_VS),
//							.Reset(Reset_h),
//							.new_pos(set_x_pos_2),
//							.x_speed(new_x_speed),
//							.y_speed(new_y_speed),
//							.sign
//						  );

