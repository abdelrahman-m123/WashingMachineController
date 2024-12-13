`timescale 1ns / 1ps

module WashingMachine_tb;

    // Inputs
    reg clk, stop, doorclosed, start, dry, washOnly, detergentfilled, pause;
    reg [1:0] waterTemp, spinSpeed;
    integer i;
    

    // Outputs
    wire doorLock, motorStart, fill_value_on, drain_value_on, soap_value_on, done, soapWash, waterWash, cycleFinished, rinseFinished, spinFinished, alarm;
    wire [1:0] heater_on, motor_speed;
    wire [15:0] timer;
    // Instantiate the WashingMachine module
    WashingMachine DUT (
        .clk(clk), 
        .stop(stop), 
        .doorclosed(doorclosed), 
        .start(start), 
        .dry(dry), 
        .washOnly(washOnly), 
        .detergentfilled(detergentfilled), 
        .pause(pause), 
        .waterTemp(waterTemp), 
        .spinSpeed(spinSpeed),
        .doorLock(doorLock),
        .motorStart(motorStart),
        .fill_value_on(fill_value_on),
        .drain_value_on(drain_value_on),
        .soap_value_on(soap_value_on),
        .done(done),
        .soapWash(soapWash),
        .waterWash(waterWash),
        .cycleFinished(cycleFinished),
        .rinseFinished(rinseFinished),
        .spinFinished(spinFinished),
        .alarm(alarm),
        .heater_on(heater_on),
        .motor_speed(motor_speed),
        .timer(timer)
    );

    initial begin
        $dumpfile("WashingMachine_tb.vcd");
        $dumpvars(0, WashingMachine_tb);
    end

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        stop = 0;
        doorclosed = 1;
        start = 0;
        dry = 0;
        washOnly = 0;
        pause = 0;
        waterTemp = 2'b00;
        spinSpeed = 2'b00;

        // Test cases
        run_directed_tests();
	run_constrained_random_tests();

        #10000 $finish;
    end

    // Task to run directed tests
    task run_directed_tests;
        begin       

            // Test 1: Start washing with detergent and default settings
            #10 start = 1;
            detergentfilled = 1;
            #30 waterTemp = 2'b01;
            #40 spinSpeed = 2'b10;

            #1000;

            //Test 2: Pause and resume
            #50 pause = 1;
            #60 pause = 0;

            // Test 3: Stop and restart
            #70 stop = 1;
            #80 stop = 0;

            // Test 4: Detergent not filled
	    reset_inputs();
	    detergentfilled = 0;
	    #90 start = 1;
            #1000;
	    #70 stop = 1;
            #80 stop = 0;
	    


             // Test 5: Dry-only mode
            reset_inputs();
	    #90 start = 1;
            detergentfilled = 1;
            dry = 1;
	    #1000;
            #70 stop = 1;
            #80 stop = 0; 
            

            // Test 6: Wash-only mode
            reset_inputs();
            washOnly = 1;
            detergentfilled = 1;
            start = 1;
            #20 waterTemp = 2'b01;
            #30 spinSpeed = 2'b10;
            #1000;
	    #70 stop = 1;
            #80 stop = 0;
            

	    reset_inputs();
            detergentfilled = 1;
            start = 1;
	    doorclosed = 0;
            #20 waterTemp = 2'b01;
            #30 spinSpeed = 2'b10;
            #1000;

        end
    endtask

  
    // Task to reset inputs
    task reset_inputs;
        begin
            stop = 0;
            doorclosed = 1;
            start = 0;
            dry = 0;
            washOnly = 0;
            detergentfilled = 0;
            pause = 0;
            waterTemp = 2'b00;
            spinSpeed = 2'b00;
        end
    endtask

// Task to run constrained random tests
    task run_constrained_random_tests;
        begin
            repeat (100) begin 
		    reset_inputs();               
                    #100;
		    start=1;
		    detergentfilled = $random % 2;
                    doorclosed = $random % 2;
         	    dry = $random % 2;
    		    washOnly = ~dry & ($random % 2); // Opposite or 0 if dry is 1
                    waterTemp = $random % 4;
                    spinSpeed = $random % 4;
                    pause = $random % 2;
		#1000;
                stop = 1;	
		#100;
            end
        end
    endtask
endmodule