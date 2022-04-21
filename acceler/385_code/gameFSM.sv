module gameFSM(input Clk, Reset, //reset the game and run the game: shouold be controlled by the button or keyboard
					input player_die,
					input [23:0] keycode,
					output start_screen,
					output game_screen,
					output game_over
					);

//these are the game states 
enum logic [1:0] {START, IN_GAME, GAME_END} gameState, next_state;

always_ff @ (posedge Clk)
begin
	if(Reset)
		gameState <= START;
	else
		gameState <= next_state;
	
end

always_comb
begin
	 next_state = gameState;
	 
	 //default output
	 start_screen = 1'b0;
	 game_screen = 1'b0;
	 game_over = 1'b0;
	 
	 //the game state transition
	 unique case(gameState)
		
		//in start state check, hit any key to start the game
		START: begin
			if(keycode)
			begin
				if(~keycode)
					next_state = IN_GAME;
			end
		end
		//in game only switch until the player die
		IN_GAME: begin
			if(player_die)
				next_state = GAME_END;
		end
		//in game_end, hit any key to go back to the start screen
		GAME_END: begin
			if(keycode)
			begin
					next_state = GAME_END;
				if(~keycode)
					next_state = START;

			end
		end	
	 endcase 	 
	 
	 
	 //control signals for each states
	 case(gameState)
	 
		START:
			begin
				start_screen = 1'b1;
			end
		IN_GAME:
			begin
				game_screen = 1'b1;
			end
		GAME_END:
			begin
				game_over = 1'b1;
			end
		
		default: ;//there is no default
	 endcase
	 
	 
	 
end



endmodule
