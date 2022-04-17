module bullet(  
                input [9:0] bullet_X, bullet_Y, //this is for the ball location - the ball_size
                input bullet_hit,               //if bullet hit something then it disappear
                
                input Reset,                    //reset the bullets
                input frame_clk,                //clk to control the bullet

                input [24:0] space_key,          //space key is hit

                output bullet_active,           //the bullet is still active
                output [9:0] bullet_X_out, bullet_Y_out, bullet_size

            );
    parameter [9:0] bullet_X_Min=3;       // Leftmost point on the X axis
    parameter [9:0] bullet_Y_Min= 15;       // Topmost point on the Y axis
    parameter [9:0] bullet_S = 3;      // bullet size
    parameter [9:0] bullet_speed = 8;

	 //local variable for the bullet
    logic [9:0] bullet_x_pos, bullet_y_pos, y_motion;
	 //logic [9:0] x_motion; x is never used 
    
	 
    always_comb
    begin
        bullet_X_out = bullet_x_pos;
        bullet_Y_out = bullet_y_pos;
        bullet_size  = bullet_S;
    end

    

    always_ff @ (posedge frame_clk)
    begin
        if(Reset)
        begin
            bullet_x_pos <= bullet_X;
            bullet_y_pos <= bullet_Y;
            //x_motion <= 10'd0;
				bullet_active <= 1'b0;
            y_motion <= 10'd0;
        end
        else
        begin
			
				if(bullet_hit || bullet_y_pos < (bullet_Y_Min + (bullet_speed >> 2) + bullet_size ))
				begin
					bullet_active <= 1'b0;
					bullet_x_pos <= bullet_X;
					bullet_y_pos <= bullet_Y;
					y_motion <= 10'd0;
				end
				
				if(!bullet_active)
				begin	//if the space key is press
					if(space_key[23:16] == 8'h2c || space_key[15:8] == 8'h2c || space_key[7:0] == 8'h2c)
					begin	
						if(bullet_Y > bullet_Y_Min)
						begin
							bullet_active <= 1'b1;
							y_motion <= -bullet_speed;
							bullet_x_pos <= bullet_X;
							bullet_y_pos <= bullet_Y;
						end
					end
				end
				
				else 
				begin
            

					//if the bullet hit something
					//or the bullet is out of bounds


					bullet_y_pos <= bullet_y_pos + y_motion;
					
				end
        end
        
    end
    


    

endmodule


    // //check if the bullet is out of bounds
    // if(bull_x_pos < (bullet_X_Min + bullet_speed))
    // begin
    //     shoot <= 0;
    //     bullet_active <= 0;
    // end
    // parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    // parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis