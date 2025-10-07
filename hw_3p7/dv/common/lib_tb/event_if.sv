///////////////////////////////
// EVent Requester Interface
// Author: Cyrille ludwig
//////////////////////////////
`ifndef <%=obj.BlockId%>_EVENT_IF
`define <%=obj.BlockId%>_EVENT_IF

interface <%=obj.BlockId%>_event_if #(bit IF_MASTER=1) ();

  import <%=obj.BlockId%>_event_agent_pkg::*;
  
  logic clk;
  logic rst_n;
  longint cycle_counter;

  logic req; 
  logic ack;

  event_pkt pkt_sender;
  event_pkt pkt_receiver;
 
  semaphore master_token = new(1);
  semaphore slave_token = new(1);

  modport master (
		  output req,
		  input ack
  );
   modport slave (
		  input req,
		  output ack
  );

// INITIALIZATION
initial 
   begin
		   if (IF_MASTER) begin
				   req=0;
		   end else begin 
				   ack=0;
		   end
   end 

//----------------------------------------------------------------------- 
// Reset master  event interface signals
//----------------------------------------------------------------------- 

  task automatic master_async_reset_event();
      if (IF_MASTER) begin
          req          <= 'b0;
      end 
  endtask : master_async_reset_event

//----------------------------------------------------------------------- 
// Reset slave  event interface signals
//----------------------------------------------------------------------- 

  task automatic slave_async_reset_event();
     if (IF_MASTER == 0) begin
          ack          <= 'b0;
     end
  endtask : slave_async_reset_event

//----------------------------------------------------------------------- 
// slave receiver
//----------------------------------------------------------------------- 
task automatic drive_slave();
     slave_token.get();
          @(posedge req);
          ack = 1;   
          @(negedge req);
          ack = 0; 
	slave_token.put();
endtask:drive_slave

task automatic collect_slave(ref event_pkt pkt);
     bit done = 0;
     if (IF_MASTER == 0) begin
          do begin
               @(posedge clk);
              if (rst_n == 0) begin
	          pkt.cycle_counter = 0;
                   return;
               end
               if (req==1) begin
                  pkt.req   = req;
                  pkt.ack   = ack ;
                  pkt.cycle_counter = pkt.cycle_counter + 1;
                  done      = 1;
               end
          end while (!done);
     end
endtask:collect_slave

//----------------------------------------------------------------------- 
// Master sender
//-----------------------------------------------------------------------
task automatic drive_master();
	master_token.get();
         //add some delay to wait all sysco attach and reset before sending sys_req event
          repeat(6000) begin
		  @(posedge clk);
		end 
          for (int i=0;i<4;i++) begin
               req <= 1;
               @(posedge ack);        
               req <= 0; 
               repeat(100) begin
		       @(posedge clk);
		     end                
          end
	master_token.put();
endtask:drive_master
// drive master for handshake error
//force not sending ack to issue hadshak timeout error
task automatic drive_master_hds_error();
	master_token.get();
         //add some delay to wait all sysco attach and reset before sending sys_req event
          repeat(6000) begin
		  @(posedge clk);
		end 

          req = 1;

          repeat(4162) begin ///wait 4250 clock cycle to be sure to hit 4K timeout
		  @(posedge clk);
		end

          if (ack == 1)  begin      
               req = 0; 
          end
          req = 0;
	master_token.put();
endtask:drive_master_hds_error

task automatic collect_master(ref event_pkt pkt );
     bit done = 0;
     if (IF_MASTER) begin
          do begin
               @(posedge clk);
              if (rst_n == 0) begin
	          pkt.cycle_counter = 0;
                   return;
               end
               if (req==0 ) begin
	          pkt.cycle_counter = 0;
               end
               if (req==1 || ack==1) begin
                  pkt.req   = req;
                  pkt.ack   = ack ;
                  pkt.cycle_counter = pkt.cycle_counter + 1;
                  done      = 1;
               end
          end while (!done);
     end
endtask:collect_master
                                          
endinterface: <%=obj.BlockId%>_event_if


`endif
