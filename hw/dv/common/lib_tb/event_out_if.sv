//////////////////////////TB_  event_out_if ////////////////////////
//DUT interfaces
//////////////////////////////////////////////////////////////////

`ifndef EVENT_OUT_IF
`define EVENT_OUT_IF
interface event_out_if (input clk, input rst_n);
    logic 			in							;
    logic 			out							;
    int 			rise_delay = 1				;
    int 			fall_delay = 1				;
    int 			allow_proper_events			;
    int 			total_event_count=0			;
    int 			ev_pin_handshakes=0			;
    int 			monitor_events_for_timeout=0;
    int 			buffer = 3					; //3% buffer to account for network delay while checking for timeout threshold
    int 			number_of_timeouts=0		;
    int 			timeout_value				;
    logic 			timeout = 0					;
    logic 			sys_reciever_timeout = 0					;
    logic 			receiver_busy				; //Variable to track if event generation logic in receiver is busy
    logic 			event_receiver_enable		; //Variable to check if event receiver is enabeld or disabled
    logic [30:0] 	timeout_threshold 			;
    logic 			uedr_timeout_err_det_en		;
    logic 			uesr_errvld 				;
    logic [3:0] 	uesr_err_type 				;
    logic [15:0] 	uesr_err_info 				;
    logic 			ueir_timeout_irq_en 		;
    logic 			IRQ_UC 						;
    logic           ev_flag                     ; // helper flag 
    logic           sysco_attach                ; // check if sysco is in attach state
    logic           sysco_connecting            ;
    logic           sm_idle                     ;
    logic           idle_or_done                ;
    logic           sys_receiver_busy                ;
    logic           sys_rsp_valid               ;
    logic           sys_rsp_ready                ;
    logic           sys_req_event_ack;
    logic           sys_req_event_in;

    `ifdef FORCE_SENDER
    initial begin   
        sys_req_event_in = 0;
		repeat(2000) begin
		  @(posedge clk);
		end
        sys_req_event_in = 1;
         @(posedge sys_req_event_ack);
         sys_req_event_in = 0;

    end
    `endif //FORCE_SENDER

   initial begin
        out = 0;
        ev_flag = 0;
        receiver_busy = 0;
    end

	always @(posedge in) begin
		if(timeout) begin
            //FIXME : sai - try to drive out = 1 randomly to trigger a timeout when we dont drive the ack low
			repeat((timeout_threshold*4096)) begin // adding 5 cycles of buffer
				@(posedge clk);
			end
		end else if($test$plusargs("rand_event_delay")) begin
			rise_delay = $urandom_range(150 , 1);
			repeat(rise_delay)begin
				@(posedge clk);
			end
			out = 1;
			fall_delay = $urandom_range((300-rise_delay), 1);
			@(negedge in);
			repeat(fall_delay)begin
				@(posedge clk);
			end
			out= 0;
		end else if($test$plusargs("max_event_delay") && timeout_threshold<4000) begin
            rise_delay = ((timeout_threshold*4096)* (1- (buffer*0.01))) / 2.0;
			repeat(rise_delay) begin
				@(posedge clk);
			end
			out = 1;
			fall_delay = (timeout_threshold*4096) - rise_delay - 100; //adding 100 cycles buffer in case FIXME: SAI
			@(negedge in);
			repeat(fall_delay)begin
				@(posedge clk);
			end
			out = 0;
		end else begin
			out = 1;
			@(negedge in)
			out = 0;
		end
	end

   // always @(posedge in) begin
   //     if($test$plusargs("max_event_delay") && timeout_threshold < 4000) begin // FIXME : SAI
   //     end else if($test$plusargs("rand_event_delay")) begin
   //         fall_delay = $urandom_range(123,1);
   //     end
   //     $display("%t event ack rise_delay=%d", $time, rise_delay);
   //     repeat (rise_delay) begin
   //         @(posedge clk);
   //     end

   //     // In timeout tests, do not drive an ACK
   //     // Currently the design doesnt handle ACK after error - code should be modified after that - SAI
   //     if(timeout) begin
   //         // wait for event threshold number of cycles and serve next event
   //         repeat((timeout_threshold*4096)+100) begin // adding a buffer of 1000 - FIXME sai
   //             @(posedge clk);
   //         end
   //         out = 1'b0;
   //     end else begin
   //         out = 1'b1;
   //     end
   // end
   // always @(negedge in) begin
   //     if($test$plusargs("max_event_delay")) begin
   //         fall_delay = $urandom_range((((timeout_threshold*4096)* (1- (buffer*0.01)))/2.0),1);  // reduce 3% from the threshold value and divide by 2
   //     end else if($test$plusargs("rand_event_delay")) begin
   //         fall_delay = $urandom_range(123,1);
   //     end
   //     $display("%t event ack fall_delay=%d", $time, fall_delay);
   //     repeat (fall_delay) begin
   //         @(posedge clk);
   //     end
   //     out = 1'b0;
   // end

    // Below code follows the 2 way handshake and expects the event generation logic in 
    // event receiver to not be busy after the 4-way handshake
    always @(posedge in) begin //received a sysReq Event
        if(!timeout) begin
            if (!out) begin //needed to handle async assertion of ack on receiving req
            @(posedge out);// sent an Ack from this interface
            end
            @(negedge in);// ioaiu de-asserted the sysReq Event
            if (out) begin //needed to handle async deassertion of ack on deassertion of req
            @(negedge out);
            end

            // ACK is de-asserted from this interface 
            @(posedge clk); // RTL is still busy for couple of cycles which is okay
            @(posedge clk);
            receiver_busy = 0;
        end else begin
            @(negedge in);
            // we hit timeout and the req went low
            repeat(5) begin
                @(posedge clk);
            end
            receiver_busy = 0;
            timeout = 0;
        end
        ev_pin_handshakes++;
        //`uvm_info("DBG", $sformatf("ev_pin_handshakes:%0d", ev_pin_handshakes), UVM_LOW)
        monitor_events_for_timeout++;
    end

    // event timeout is enabled randomly introduce timeouts in the middle of simulation
    initial begin
        <%if((obj.fnNativeInterface != "AXI4") && (obj.fnNativeInterface != "AXI5")){%>
            if($test$plusargs("enable_ev_timeout") ) begin
                // allow_proper_events = $urandom_range(10,1);  // randomly allow 0 to 10 events before simulating timeout
                // wait(allow_proper_events == monitor_events_for_timeout);
                timeout = 1;
                sys_reciever_timeout = 1;
                monitor_events_for_timeout = 0;
            end
        <%}%>
    end

    always @(negedge timeout) begin   // ev_flag is not required when timeout is not active
        ev_flag = 0;    
        receiver_busy = 0;
    end
    // always @(posedge sm_idle) begin
    //     receiver_busy = 0;
    // end
endinterface : event_out_if
`endif //EVENT_OUT_IF
