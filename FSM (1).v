module WashingMachine(clk, stop, doorclosed, doorLock, dry, washOnly, start, /*filled*/, detergentfilled, rinseFinished, /*drained,*/ cycleFinished, spinFinished, motorStart, fill_value_on, drain_value_on, soap_value_on, done, soapWash, waterWash, pause, alarm, waterTemp, spinSpeed, heater_on, motor_speed, timer );

    input clk, stop, doorclosed, start, dry, washOnly, detergentfilled, /*filled, cycleFinished, rinseFinished, drained, spinFinished, */ pause;
    input [1:0] waterTemp; 
    input [1:0] spinSpeed;
    output reg doorLock, motorStart, drain_value_on, done, soapWash, waterWash, cycleFinished, rinseFinished, spinFinished, alarm; 
    output reg fill_value_on, soap_value_on;
    output reg [1:0] heater_on;
    output reg [1:0] motor_speed;
    output reg [15:0] timer;
    
    parameter check_door = 3'b000;
    parameter fill_water = 3'b001;
    parameter add_detergent = 3'b010;
    parameter cycle = 3'b011;
    parameter rinse = 3'b100;
    parameter drain_water = 3'b101;
    parameter spin = 3'b110;
    
    reg [2:0] current_state, next_state;
    
    always@(negedge clk or posedge pause)
    begin
         if (pause ==1 && stop ==0) begin
            next_state = current_state;
        end
        else 
        begin
    case(current_state)
	    check_door: begin
            if(start==1 && doorclosed==1 && detergentfilled == 1 && stop != 1)
            begin
                if (dry == 1 ) 
                begin  
                next_state = drain_water;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 1;
                soapWash = 1;
                waterWash = 1;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                alarm = 0;
                heater_on = 2'b00;
                motor_speed = 2'b00;
                end
                else
                begin
                next_state = fill_water;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 1;
                soapWash = 0;
                waterWash = 0;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;    
                alarm = 0;
                heater_on = 2'b00;
                motor_speed = 2'b00;                
                end
            end
            else if (start == 1 && doorclosed == 0 && stop != 1)
            begin
                next_state = current_state;
                alarm = 1;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 0;
                soapWash = 0;
                waterWash = 0;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                heater_on = 2'b00;
                motor_speed = 2'b00;                
            end
	    else if (detergentfilled == 0 && stop != 1)
            begin
                next_state = current_state;
                alarm = 1;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 0;
                soapWash = 0;
                waterWash = 0;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                heater_on = 2'b00;
                motor_speed = 2'b00;                
            end
           else if (start == 0)
            begin
                next_state = current_state;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 0;
                soapWash = 0;
                waterWash = 0;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                alarm = 0;
                heater_on = 2'b00;
                motor_speed = 2'b00;                
            end 
        end

            
            fill_water: begin              
            if (fill_value_on == 1 && timer > 2)
            begin
                next_state = add_detergent;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 1;
                soapWash = 0;
                waterWash = 1;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                alarm = 0;
                heater_on = 2'b00;
                motor_speed = 2'b00;                
            end
            else
            begin
                next_state = current_state;
                motorStart = 0;
                fill_value_on = 1;  // 1 then heater_on
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 1;
                soapWash = 0;
                waterWash = 0;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                alarm = 0;
                motor_speed = 2'b00;                
                case (waterTemp)
                            2'b00: heater_on = 2'b00; // Cold or off
                            2'b01: heater_on = 2'b01; // Warm
                            2'b10: heater_on = 2'b10; // Hot
                            2'b11: heater_on = 2'b11; // very Hot                           
                            default: heater_on = 2'b01;
                        endcase
            end
        end

            add_detergent: begin   
            if(detergentfilled == 1 && soap_value_on == 1 && timer > 3)
            begin
                next_state = cycle;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 1;
                waterWash = 1;                
                soapWash = 1;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                alarm = 0;
                motor_speed = 2'b00;                
                heater_on = heater_on;
            end
            /* else if (detergentfilled == 0 && soap_value_on == 1) 
            begin
                next_state = check_door;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 0;
                waterWash = 1;                
                soapWash = 0;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                alarm = 1;
                motor_speed = 2'b00;                
                heater_on = heater_on;
            end */
            else
            begin
                next_state = current_state;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 1;
                doorLock = 1;
                waterWash = 1;                
                soapWash = 0;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                alarm = 0;
                motor_speed = 2'b00;                
                heater_on = heater_on;
            end
        end

            cycle: begin
            if(timer > 5)
            begin
                next_state = rinse;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 1;
                waterWash = 1;                
                soapWash = 1;
                cycleFinished = 1;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                alarm = 0;
                motor_speed = 2'b00;                
                heater_on = heater_on;
            end
            else
            begin
                next_state = current_state;
                motorStart = 1;
                case (spinSpeed)
                            2'b00: motor_speed = 2'b00; // off
                            2'b01: motor_speed = 2'b01; // low speed
                            2'b10: motor_speed = 2'b10; // med speed
                            2'b11: motor_speed = 2'b11; // high speed
                            default: motor_speed = 2'b10; // Default speed
                        endcase              
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 1;
                waterWash = 1;                
                soapWash = 1;
                cycleFinished = 0;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                alarm = 0;
                heater_on = heater_on;
            end
        end

             rinse: begin
             if(timer > 5)
             begin
                if(washOnly == 1)
                begin
                    next_state = check_door;
                    alarm = 1;
                    motorStart = 0;
                    fill_value_on = 0;
                    drain_value_on = 0;
                    soap_value_on = 0;
                    doorLock = 0;
                    waterWash = 1;                
                    soapWash = 1;
                    cycleFinished = 1;
                    rinseFinished = 1;
                    spinFinished = 0;
                    done = 1;
                    motor_speed = 2'b00;                
                    heater_on = heater_on;
                end
                else
                begin
                next_state = drain_water;
                    motorStart = 0;
                    fill_value_on = 0;
                    drain_value_on = 0;
                    soap_value_on = 0;
                    doorLock = 1;
                    waterWash = 1;                
                    soapWash = 1;
                    cycleFinished = 1;
                    rinseFinished = 1;
                    spinFinished = 0;
                    done = 0;
                    alarm = 0;
                    motor_speed = 2'b00;                
                    heater_on = heater_on;
                end
            end
            else
            begin
                next_state = current_state;
                motorStart = 1;
                case (spinSpeed)
                            2'b00: motor_speed = 2'b00; // off
                            2'b01: motor_speed = 2'b01; // low speed
                            2'b10: motor_speed = 2'b10; // med speed
                            2'b11: motor_speed = 2'b11; // high speed
                            default: motor_speed = 2'b10; // Default speed
                        endcase                  
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 1;
                waterWash = 1;
                soapWash = 1;
                cycleFinished = 1;
                rinseFinished = 0;
                spinFinished = 0;
                done = 0;
                alarm = 0;
                heater_on = heater_on;
            end
        end

            drain_water: begin
             if(timer > 5)
             begin
                    next_state = spin;
                    motorStart = 0;
                    fill_value_on = 0;
                    drain_value_on = 0;
                    soap_value_on = 0;
                    doorLock = 1;
                    soapWash = 1;
                    waterWash = 1;
                    cycleFinished = 1;
                    rinseFinished = 1;
                    spinFinished = 0;
                    done = 0;
                    alarm = 0;
                    motor_speed = 2'b00;                
                    heater_on = heater_on;
               
            end
            else
            begin
                next_state = current_state;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 1;
                soap_value_on = 0;
                doorLock = 1;
                soapWash = 1;
                waterWash = 1;
                cycleFinished = 1;
                rinseFinished = 1;
                spinFinished = 0;
                done = 0;
                alarm = 0;
                motor_speed = 2'b00;                
                heater_on = heater_on;
            end
        end

            spin: begin
            if(timer > 5)
            begin
                next_state = check_door;
                motorStart = 0;
                fill_value_on = 0;
                drain_value_on = 0;
                soap_value_on = 0;
                doorLock = 0;
                soapWash = 1;
                waterWash = 1;
                cycleFinished = 1;
                rinseFinished = 1;
                spinFinished = 1;
                done = 1;
                alarm = 1;
                motor_speed = 2'b00;                
                heater_on = heater_on;
            end
            else
            begin
                next_state = current_state;
                motorStart = 1;
                case (spinSpeed)
                            2'b00: motor_speed = 2'b00; // off
                            2'b01: motor_speed = 2'b01; // low speed
                            2'b10: motor_speed = 2'b10; // med speed
                            2'b11: motor_speed = 2'b11; // high speed
                            default: motor_speed = 2'b11; // Default speed
                        endcase
                fill_value_on = 0;
                drain_value_on = 1;
                soap_value_on = 0;
                doorLock = 1;
                soapWash = 1;
                waterWash = 1;
                cycleFinished = 1;
                rinseFinished = 1;
                spinFinished = 0;
                done = 0;
                alarm = 0;              
                heater_on = heater_on;
            end
        end

            default: begin
                next_state = check_door;
        end
                
            endcase
        end    
    end
        
    
    always@(posedge clk or posedge stop)
    begin
        if(stop)
        begin
            current_state<=3'b000;
        end
        else
        begin
            current_state<=next_state;
        end
    end  

always @(posedge clk or posedge stop) begin
    if (stop) begin
        timer <= 0;
    end else if (current_state != next_state) begin         
        timer <= 0;
    end else if (current_state == drain_water || current_state == cycle || 
                 current_state == rinse || current_state == spin || next_state == fill_water || next_state == add_detergent) begin
        timer <= timer + 1;
    end else begin
        timer <= 0;
    end
end

//psl default clock = rose(clk);

//psl property Pause_State_Hold = always(pause && stop !=1 -> (next_state == current_state));
//psl assert Pause_State_Hold;

//psl property stop_State_Hold = always(stop -> (current_state == 3'b000));
//psl assert stop_State_Hold;

// psl property LockingDoor = always((start == 1 && doorclosed == 1 && detergentfilled == 1 && stop != 1 && pause != 1 && done !=1) -> (doorLock == 1));   
//psl assert LockingDoor;

//psl property CheckDoor_To_DrainWater_Transition = always((current_state == check_door && start == 1 && doorclosed == 1 && detergentfilled == 1 && dry == 1 && stop != 1 && pause !=1) -> next(current_state == drain_water));   
//psl assert CheckDoor_To_DrainWater_Transition;

//psl property CheckDoor_To_fillWater_Transition = always((current_state == check_door && start == 1 && doorclosed == 1 && detergentfilled == 1 && dry == 0 && stop != 1 &&( pause !=1)) -> (next_state == fill_water));   
//psl assert CheckDoor_To_fillWater_Transition;

//psl property FillWater_To_AddDetergent_Transition = always(((current_state == fill_water) && (timer > 2 ) && (stop !=1)) -> (next_state == add_detergent));    
//psl assert FillWater_To_AddDetergent_Transition;

//psl property AddDetergent_To_Cycle_Transition = always(((current_state == add_detergent) && (timer > 3) && (detergentfilled == 1) && ( stop !=1 ) ) -> (next_state == cycle));    
//psl assert AddDetergent_To_Cycle_Transition;

//psl property Cycle_To_Rinse_Transition = always((current_state == cycle && timer > 5 && stop !=1) -> (next_state == rinse));    
//psl assert Cycle_To_Rinse_Transition;

//psl property Rinse_To_CheckDoor_WashOnly = always((current_state == rinse && timer > 5 && washOnly == 1 && stop !=1) -> (next_state == check_door));    
//psl assert Rinse_To_CheckDoor_WashOnly;

//psl property Rinse_To_drain_water = always((current_state == rinse && timer > 5 && washOnly == 0 && stop !=1) -> (next_state == drain_water));    
//psl assert Rinse_To_drain_water;

//psl property DrainWater_To_Spin = always((current_state == drain_water && timer > 5 && stop !=1) -> (next_state == spin)); 
//psl assert DrainWater_To_Spin;

//psl property Spin_To_CheckDoor = always((current_state == spin && timer > 5  && pause!=1 ) -> (next_state == check_door));
//psl assert Spin_To_CheckDoor;

//psl property Alarm_Set_Condition = always((done == 1 && stop !=1) -> (alarm == 1));
//psl assert Alarm_Set_Condition;

//psl property finishing = always(((current_state == rinse && next_state == check_door) || (current_state == spin && next_state == check_door) ) -> (done == 1));
//psl assert finishing;

//psl property check = always((detergentfilled == 0 && stop !=1) -> (alarm == 1));
//psl assert check;

//psl property check2 = always((doorclosed == 0 && stop !=1) -> (alarm == 1));
//psl assert check2;
endmodule


