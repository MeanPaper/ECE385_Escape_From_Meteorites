module obstacle
				#(parameter object_num = 4)
				(input Reset, frame_clk,
				input [9:0] ball_ammo_x, ball_ammo_y, ball_ammo_size,
				input [9:0]	set_postion_x, set_position_y,
				output bullet_hit,				
				output [9:0] object_Size[object_num], //object size
				output [9:0] object_X[object_num], object_Y[object_num], //object location
				output obstacle_activate[object_num]		  //the object is on, this is important
													  //if the object hit the bottom, then
													  //it will be deactivated
				);	
					
    parameter [9:0] Obj_X_Min=5;       // Leftmost point on the X axis
    parameter [9:0] Obj_X_Max=636;     // Rightmost point on the X axis
	 parameter [9:0] Obj_X_disappear = 700;
    parameter [9:0] Obj_Y_Min=3;       // Topmost point on the Y axis
    parameter [9:0] Obj_Y_Max=476;     	// Bottommost point on the Y axis
    parameter [9:0] Obj_X_Step=1;      // Step size on the X axis
    parameter [9:0] Obj_Y_Step=1;      // Step size on the Y axis
	 parameter int speed = 2;
	 //parameter int object_num = 4;
	 
	 logic [9:0] obj_x_pos[object_num], obj_y_pos[object_num];
	 logic [4:0] obj_speed[object_num];
	 logic [9:0] x_motion, y_motion;
	 //logic obj_act[4];
	
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
			obj_speed[i] = speed;			
			//obstacle_activate[i] = obj_act[i];
		end
	 end
	 
//	 assign object_X = obj_x_pos; //9'd200;
//	 assign object_Y = obj_y_pos; //9'd200;
	 
	 
	 always_ff @(posedge Reset or posedge frame_clk)
	 begin
		if(Reset)	//the reset signal is currently related to the switch
		begin		//it need to be modified so that it is being reset due to the state
			for(int i = 0; i < object_num; i++)
			begin
				obj_x_pos[i] <= 9'd30 + (i*9'd50); //640
				obj_y_pos[i] <= i<<3;
				//obj_act[i] <= 1'b1; //initialize all the enemy
				obstacle_activate[i] <= 1'b1;
				
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
						//obj_x_pos[i] <= Obj_X_disappear;

						//obj_y_pos[i] <= i<<3; //comment this line if I were to do random
						obstacle_activate[i] <= 1'b0;
					end
			end		
				
		
			for(int i = 0; i < object_num; i++)
			begin
				
				if(obstacle_activate[i]) //obj_act
				begin
					obj_y_pos[i] <=  obj_y_pos[i] + obj_speed[i];
					if(obj_x_pos[i] > 606)
					begin
						obj_x_pos[i] <= set_postion_x; //640
					end
				end
				else
				//this part is for reactivate the asteroid
				begin
					if(obj_y_pos[i] > 481)
						obj_x_pos[i] = set_postion_x;
					
					obj_x_pos[i] <= set_postion_x; //640
					obj_y_pos[i] <= 0;
					obstacle_activate[i] <= 1'b1;
				end
			end
			
		end
		

	 end
	 
	 //mem y bit 9bit, present 1bit, speed 3bit, sprite id, size 5 bit
	 //9+1+3+5
	 


endmodule


