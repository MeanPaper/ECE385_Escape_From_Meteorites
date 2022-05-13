module obstacle
				#(parameter object_num = 4)
				(input frame_clk,
				input keycode,
				input game_over, start_screen,
				input [9:0] ball_ammo_x, ball_ammo_y, ball_ammo_size,
				input [9:0]	set_position_x, 
				//set_position_x_2, set_position_x_3,
				input [4:0] x_speed, y_speed,	//
				input sign,
				output bullet_hit,				
				output [9:0] object_Size[object_num], //object size
				output [9:0] object_X[object_num], object_Y[object_num], //object location
				output obstacle_activate[object_num],		  //the object is on
				output [23:0] score
													  //if the object hit the bottom, then
													  //it will be deactivated
				);	
	
	 //default parameters
    parameter [9:0] Obj_X_Min=5;       // Leftmost point on the X axis
    parameter [9:0] Obj_X_Max=636;     // Rightmost point on the X axis
	 parameter [9:0] Obj_X_disappear = 700;
    parameter [9:0] Obj_Y_Min=3;       // Topmost point on the Y axis
    parameter [9:0] Obj_Y_Max=476;     	// Bottommost point on the Y axis
    parameter [9:0] Obj_pos_Step = 1;      // Step size on the X axis
    parameter [9:0] Obj_neg_Step = -1;      // Step size on the Y axis
	 parameter int speed = 2;
	 //parameter int object_num = 4;
	 
	 logic [9:0] obj_x_pos[object_num], obj_y_pos[object_num];
	 logic [9:0] obj_y_speed[object_num], obj_x_speed[object_num];
	 //logic [9:0] new_x_speed, new_y_speed;

	
	 //logic [3:0] all_die;
	 //assign all_die = {obstacle_activate[3],obstacle_activate[2],obstacle_activate[1],obstacle_activate[0]};
	 //default position, use for testing
	 always_comb
	 begin
		for(int i = 0; i < object_num; i++)
		begin
			object_Size[i] = 30;
			object_X[i] = obj_x_pos[i];
			object_Y[i] = obj_y_pos[i];
			//obj_speed[i] = speed;			
			//obstacle_activate[i] = obj_act[i];
		end
	 end
	 
	 logic Reset;
	 assign Reset = game_over || start_screen;
	 
	 
	 always_ff @(posedge Reset or posedge frame_clk)
	 begin
	 

		if(Reset)	//the reset signal is currently related to the switch
		begin		//it need to be modified so that it is being reset due to the state
			for(int i = 0; i < object_num; i++)
			begin
				obj_x_pos[i] <= 9'd10 + i*(9'd35);
//				if(i > (object_num >> 1))
//				begin
//					obj_y_pos[i] <= 30*i - 30*(object_num - i);
//				end
//				else
				//begin
				obj_y_pos[i] <= 20*i;
				//end
				obj_y_speed[i] <= 2;			
				obj_x_speed[i] <= 0;
				
				//obj_act[i] <= 1'b1; //initialize all the enemy
				obstacle_activate[i] <= 1'b1;
				
				if(start_screen || (game_over && keycode))
				begin
					score <= 0;
				end
				
			end
		end
		
		else
		begin
			bullet_hit <= 1'b0;
		
			for(int i = 0; i < object_num ; i++)
			begin
					if( //obj_act[i] && 
					obstacle_activate[i] && 
					(ball_ammo_y) < (obj_y_pos[i] + object_Size[i])
					&& ball_ammo_y > obj_y_pos[i]//if ammo hit the bottom edge of the objec											 //if ammo false in the range
					&& ball_ammo_x > obj_x_pos[i] 
					&& ball_ammo_x < (obj_x_pos[i] + object_Size[i])) //if ammo in the x range of the object
					begin
						bullet_hit <= 1'b1;
						obstacle_activate[i] <= 1'b0;
						score <= score + 1;		
					end
			end		
				
			
			for(int i = 0; i < object_num; i++)
			begin
				
				//check if the object is active
				if(obstacle_activate[i]) 
				begin
					obj_y_pos[i] <=  obj_y_pos[i] + obj_y_speed[i];
					obj_x_pos[i] <= obj_x_pos[i] + obj_x_speed[i];
					
					//if active object pass the x limit
					if(obj_x_pos[i] > 605 || obj_x_pos[i] < 10)
					begin
						
						//make a random position for the out of bounds object
						obj_x_pos[i] <= set_position_x; 
						obj_y_speed[i] <= 2 + y_speed;
						obj_y_pos[i] <= 510;
						
						//x_speed: choose a random direction to move 
						if(sign && set_position_x > 250 || set_position_x > 550)
							obj_x_speed[i] <= -x_speed[0];
						else
							obj_x_speed[i] <= x_speed[0];
					end

					//if active object pass the y limit
					//if(obj_y_pos[i] > 481)
					else if(obj_y_pos[i] > 481 && obj_y_pos[i] < 500)
					begin
						
						//reset the position 
						obj_y_pos[i] <= 510;
						obj_x_pos[i] <= set_position_x;
						obj_y_speed[i] <= 2 + y_speed;
						
						//x_speed: choose a random direction to move
						if(sign && set_position_x > 300 || set_position_x > 550)
							obj_x_speed[i] <= -x_speed[0];
						else
							obj_x_speed[i] <= x_speed[0];
							
					end
	
				end
				else
				//this part is for reactivate the asteroid
				begin
					if(obj_y_pos[i] > 482 && obj_y_pos[i] < 500)
					begin
						obj_x_pos[i] <= set_position_x; 
					end
					
					if(obj_x_pos[i] > 605 || obj_x_pos[i] < 10)
					begin
						obj_x_pos[i] <= set_position_x; 
					end
					
						obj_y_pos[i] <= 510;
						obstacle_activate[i] <= 1'b1;
						obj_y_speed[i] <= 2 + y_speed;
						
						
						if(sign && set_position_x > 300 ||  set_position_x > 550)
							obj_x_speed[i] <= -x_speed[0];
						else
							obj_x_speed[i] <= x_speed[0];
							
				end
			end
			
		end
		

	 end


endmodule

//						if(set_position_x > 300) 
//						begin
//							obj_x_speed[i] <= 0 - x_speed;
//						end
//						else
//						begin
//							obj_x_speed[i] <= 0 + x_speed;
//						end
						
						
						//x_speed
//						if(sign && obj_x_pos[i] > 300)
//							obj_x_speed[i] <= 0 - x_speed;
//						else
//							obj_x_speed[i] <= 0 + x_speed;
//					if(sign)
//						begin
//							if(obj_x_pos[i] > 300) 
//							begin
//								obj_x_speed[i] <= 0 - x_speed;
//							end
//							else
//							begin
//								obj_x_speed[i] <= 0 + x_speed;
//							end
//						end
//						else
//						begin
//							if(obj_x_pos[i] > 450)
//							begin
//								obj_x_speed[i] <= 0 - x_speed;
//							end
//							else
//							begin
//								obj_x_speed[i] <= 0 + x_speed;
//							end
//						end

//						if(sign)
//						begin
//							if(obj_x_pos[i] > 300) 
//							begin
//								obj_x_speed[i] <= 0 - x_speed;
//							end
//							else
//							begin
//								obj_x_speed[i] <= 0 + x_speed;
//							end
//						end
//						else
//						begin
//							if(obj_x_pos[i] > 450)
//							begin
//								obj_x_speed[i] <= 0 - x_speed;
//							end
//							else
//							begin
//								obj_x_speed[i] <= 0 + x_speed;
//							end
//						end
//							if(set_position_x > 300) 
//							begin
//								obj_x_speed[i] <= 0 - x_speed;
//							end
//							else
//							begin
//								obj_x_speed[i] <= 0 + x_speed;
//							end

