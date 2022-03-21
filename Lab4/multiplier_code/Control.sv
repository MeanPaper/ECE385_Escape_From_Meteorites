//Two-always example for state machine

module control (input  logic Clk, Reset, Run,
                output logic Shift_En, 
									  Add, 
									  Minus,//
									  cleara //clear A signal for consecutive run
									  );
							

    // Declare signals curr_state, next_state of type enum
    // with enum values of A, B, ..., F as the state values
	 // Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
	 
	 
    enum logic [5:0] {start, hold,
								 
								 //s_h,
								 
								 a0, s0,
								 a1, s1,
								 a2, s2,
								 a3, s3,
								 a4, s4,
								 a5, s5,
								 a6, s6,
								 s7,
								pause, cont,//two extra states
								minus}   curr_state, next_state; //change
	 

	//updates flip flop, current state is the only one
    always_ff @ (posedge Clk)  
    begin
        if (Reset)
            curr_state <= start;
        else 
            curr_state <= next_state;
    end
	 
	 
	 

    // Assign outputs based on state
	always_comb
		begin
		  next_state  = curr_state;	//required because I haven't enumerated all possibilities below
        unique case (curr_state) 

            start :	if (Run)
									next_state = a0;//s_h;
									
				//add and shift 1
            a0 : next_state = s0;
				s0 : next_state = a1;
				
				//add and shift 2				
            a1 : next_state = s1;
            s1 : next_state = a2;
				
				//add and shift 3				
            a2 : next_state = s2;
            s2 : next_state = a3;
				
				//add and shift 4				
            a3 : next_state = s3;
            s3 : next_state = a4;
				
				//add and shift 5					
            a4 : next_state = s4;
            s4 : next_state = a5;
				
				//add and shift 6
            a5 : next_state = s5;
            s5 : next_state = a6;
				
				//add and shift 7
            a6 : next_state = s6;
            s6 : next_state = minus;

				//minus and shift 8									
				minus: 		next_state = s7;
				s7 :	  next_state = hold;
				
				//state 
				hold:		if(~Run)		
								next_state = pause; //new states
				
				//pause for consecutive run
				//maybe it can combine to start to reduce the states
				pause: 	if(Run)
								next_state = cont; //new states
								
				cont	: next_state = a0; //start new multiplication  (new change)
				
							  
        endcase
   
	
	
		  // Assign outputs based on ‘state’
        case (curr_state) 
			
			
				a0, 
				a1, 
				a2, 
				a3, 
				a4, 
				a5, 
				a6: //add state
		      begin
					//provide add
                Add = 1'b1;
					 Minus = 1'b0;
                Shift_En = 1'b0;
					 cleara = 1'b0;
					


		      end
				
				
				s0, s1, s2, s3, 
				s4, s5, s6, s7: //shift state
					begin
						Add = 1'b0;
						Minus = 1'b0;
						//provide shift in signal
						Shift_En = 1'b1;
						cleara = 1'b0;					 
					end
				
				
				minus: //doing subtract
					begin
						//activate adder subtract mode
						Add = 1'b1;
						Minus = 1'b1;
						Shift_En = 1'b0;
					   cleara = 1'b0;
						
					end
					
				
			  cont: //consecutive multiplication
					begin
						Add = 1'b0;
						Minus = 1'b0;
						Shift_En = 1'b0;
						cleara = 1'b1;
					end
					
					
	   	  default:  //start and hold and pause
					begin 
						Add = 1'b0;
						Minus = 1'b0;
						Shift_En = 1'b0;
						cleara = 1'b0;
						
					end
        endcase
    end

endmodule



