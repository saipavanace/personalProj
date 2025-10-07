parameter N_CCP_WAYS = <%=obj.DutInfo.nWays%>;

function void ccp_plru_predictor (input logic [N_CCP_WAYS-1:0] valid_ways, input logic [N_CCP_WAYS-1:0] hit_way, input logic [N_CCP_WAYS-2:0] curr_state, output logic [N_CCP_WAYS-1:0] victim_way, output logic [N_CCP_WAYS-2:0] nxt_state);
  logic [N_CCP_WAYS-2:0] state;
  logic [N_CCP_WAYS-2:0] ovr_state;
  logic [N_CCP_WAYS-1:0] victim;
  logic [N_CCP_WAYS-1:0] MRU;
  logic hit;

  hit  = {|hit_way};

  <% if(obj.DutInfo.nWays==2) { %> 
         ovr_state[0] = (valid_ways[0] == 0) ? 1 :
                        (valid_ways[1] == 0) ? 0 : curr_state[0];
         
         state = (hit) ? curr_state : ovr_state;

         casex (state)
            0 : victim = 2'b01;
            1 : victim = 2'b10;
            default : victim = 2'b01;
         endcase //(state)

         MRU = (hit) ? hit_way : victim;
         
         case (MRU)
            01: nxt_state = 1'b1;
            10: nxt_state = 1'b0;
         endcase //(MRU)

         victim_way = (valid_ways === 2'b0) ? 2'b0: MRU;

  <% } %>
  <% if(obj.DutInfo.nWays==4) { %> 
         ovr_state[0] = (valid_ways[1:0] == 00) ? 1 :
                        (valid_ways[3:2] == 00) ? 0 : curr_state[0];
         ovr_state[1] = (valid_ways[1:0] == 00) ? curr_state[1]:
                        (valid_ways[0]   == 0)  ? 1 :
                        (valid_ways[1]   == 0)  ? 0 : curr_state[1];
         ovr_state[2] = (valid_ways[3:2] == 00) ? curr_state[2]:
                        (valid_ways[2]   == 0)  ? 1 :
                        (valid_ways[3]   == 0)  ? 0 : curr_state[2];

         state = (hit) ? curr_state : ovr_state;

         casex (state)
            3'bx00 : victim = 4'b0001;
            3'bx10 : victim = 4'b0010;
            3'b0x1 : victim = 4'b0100;
            3'b1x1 : victim = 4'b1000;
            default : victim = 4'b0001;
         endcase //(state)

         MRU = (hit) ? hit_way : victim;

         case (MRU)
            4'b0001 : nxt_state = {state[2], 1'b1, 1'b1};
            4'b0010 : nxt_state = {state[2], 1'b0, 1'b1};
            4'b0100 : nxt_state = {1'b1, state[1], 1'b0};
            4'b1000 : nxt_state = {1'b0, state[1], 1'b0};
         endcase //(MRU)

         victim_way = (valid_ways === 4'b0) ? 4'b0: MRU;
  <% } %>

  <% if(obj.DutInfo.nWays==6) { %> 
         ovr_state[0] = valid_ways[2:0] == 3'b000 ? 1'b1 :
                    valid_ways[5:3] == 3'b000 ? 1'b0 : curr_state[0];

         ovr_state[1] = valid_ways[2:0] == 3'b000 ? curr_state[1] :
                    valid_ways[1:0] == 2'b00 ? 1'b1 :
                    valid_ways[2]   == 1'b0  ? 1'b0 : curr_state[1];

         ovr_state[2] = valid_ways[5:3] == 3'b000 ? curr_state[2] :
                    valid_ways[4:3] == 2'b00 ? 1'b1 :
                    valid_ways[5]   == 1'b0  ? 1'b0 : curr_state[2];

         ovr_state[3] = valid_ways[1:0] == 2'b00 ? curr_state[3] :
                    valid_ways[0]   == 1'b0 ? 1'b1 :
                    valid_ways[1]   == 1'b0 ? 1'b0 : curr_state[3];

         ovr_state[4] = valid_ways[4:3] == 2'b00 ? curr_state[4] :
                    valid_ways[3]   == 1'b0 ? 1'b1 :
                    valid_ways[4]   == 1'b0 ? 1'b0 : curr_state[4];
         
         state = (hit) ? curr_state : ovr_state;

         casex (state)
            5'bx_0x00 : victim = 6'b00_0001;   
            5'bx_1x00 : victim = 6'b00_0010;               
            5'bx_xx10 : victim = 6'b00_0100;              
            5'b0_x0x1 : victim = 6'b00_1000;             
            5'b1_x0x1 : victim = 6'b01_0000;             
            5'bx_x1x1 : victim = 6'b10_0000;
            default: victim = 6'b00_0001;     
         endcase //(state)

         MRU = (hit) ? hit_way : victim;

         case (MRU)
            6'b000001 : nxt_state = {state[4], 1'b1, state[2], 1'b1, 1'b1};
            6'b000010 : nxt_state = {state[4], 1'b0, state[2], 1'b1, 1'b1};
            6'b000100 : nxt_state = {state[4], state[3], state[2], 1'b0, 1'b1};
            6'b001000 : nxt_state = {1'b1, state[3], 1'b1, state[1], 1'b0};
            6'b010000 : nxt_state = {1'b0, state[3], 1'b1, state[1], 1'b0};
            6'b100000 : nxt_state = {state[4], state[3], 1'b0, state[1], 1'b0};
         endcase //(MRU)

         victim_way = (valid_ways === 6'b0) ? 6'b0: MRU;
  <% } %>
  <% if(obj.DutInfo.nWays==8) { %> 
         ovr_state[0] = valid_ways[3:0] == 4'b0000 ? 1'b1 :
                        valid_ways[7:4] == 4'b0000 ? 1'b0 : curr_state[0];

         ovr_state[1] = valid_ways[3:0] == 4'b0000 ? curr_state[1] :
                        valid_ways[1:0] == 2'b00 ? 1'b1 :
                        valid_ways[3:2] == 2'b00 ? 1'b0 : curr_state[1];

         ovr_state[2] = valid_ways[7:4] == 4'b0000 ? curr_state[2] :
                        valid_ways[5:4] == 2'b00 ? 1'b1 :
                        valid_ways[7:6] == 2'b00 ? 1'b0 : curr_state[2];

         ovr_state[3] = valid_ways[1:0] == 2'b00 ? curr_state[3] :
                        valid_ways[0]   == 1'b0 ? 1'b1 :
                        valid_ways[1]   == 1'b0 ? 1'b0 : curr_state[3];

         ovr_state[4] = valid_ways[3:2] == 2'b00 ? curr_state[4] :
                        valid_ways[2]   == 1'b0 ? 1'b1 :
                        valid_ways[3]   == 1'b0 ? 1'b0 : curr_state[4];

         ovr_state[5] = valid_ways[5:4] == 2'b00 ? curr_state[5] :
                        valid_ways[4]   == 1'b0 ? 1'b1 :
                        valid_ways[5]   == 1'b0 ? 1'b0 : curr_state[5];

         ovr_state[6] = valid_ways[7:6] == 2'b00 ? curr_state[6] :
                        valid_ways[6]   == 1'b0 ? 1'b1 :
                        valid_ways[7]   == 1'b0 ? 1'b0 : curr_state[6];

         state = (hit) ? curr_state : ovr_state;
         
         casex (state)
            7'bxxx_0x00 : victim = 8'b0000_0001;
            7'bxxx_1x00 : victim = 8'b0000_0010;
            7'bxx0_xx10 : victim = 8'b0000_0100;
            7'bxx1_xx10 : victim = 8'b0000_1000;
            7'bx0x_x0x1 : victim = 8'b0001_0000;
            7'bx1x_x0x1 : victim = 8'b0010_0000;
            7'b0xx_x1x1 : victim = 8'b0100_0000;
            7'b1xx_x1x1 : victim = 8'b1000_0000;
            default: victim = 8'b0000_0001;
         endcase //(state)
         
         MRU = (hit) ? hit_way : victim;

         case (MRU)
            8'b00000001 : nxt_state = {state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            8'b00000010 : nxt_state = {state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            8'b00000100 : nxt_state = {state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            8'b00001000 : nxt_state = {state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            8'b00010000 : nxt_state = {state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            8'b00100000 : nxt_state = {state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            8'b01000000 : nxt_state = {1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            8'b10000000 : nxt_state = {1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
         endcase //(MRU)

         victim_way = (valid_ways === 8'b0) ? 8'b0: MRU;
  <% } %>

  <% if(obj.DutInfo.nWays==12) { %> 
         ovr_state[0] = valid_ways[5:0]  == 6'b000000 ? 1'b1 :
                  valid_ways[11:6] == 6'b000000 ? 1'b0 : curr_state[0];
         ovr_state[1] = valid_ways[5:0]  == 6'b000000 ? curr_state[1] :
                           valid_ways[2:0]  == 3'b000 ? 1'b1 :
                           valid_ways[5:3]  == 3'b000 ? 1'b0 : curr_state[1];
         ovr_state[2] = valid_ways[11:6] == 6'b000000 ? curr_state[2] :
                           valid_ways[8:6]  == 3'b000 ? 1'b1 :
                           valid_ways[11:9] == 3'b000 ? 1'b0 : curr_state[2];
         ovr_state[3] = valid_ways[2:0] == 3'b000 ? curr_state[3] :
                           valid_ways[1:0] == 2'b00 ? 1'b1 :
                           valid_ways[2]   == 1'b0  ? 1'b0 : curr_state[3];
         ovr_state[4] = valid_ways[5:3] == 3'b000   ? curr_state[4] :
                           valid_ways[4:3] == 2'b00 ? 1'b1 :
                           valid_ways[5]   == 1'b0  ? 1'b0 : curr_state[4];
         ovr_state[5] = valid_ways[8:6] == 3'b000 ? curr_state[5] :
                           valid_ways[7:6] == 2'b00 ? 1'b1 :
                           valid_ways[8]   == 1'b0  ? 1'b0 : curr_state[5];
         ovr_state[6] = valid_ways[11:9] == 3'b000   ? curr_state[6] :
                           valid_ways[10:9] == 2'b00 ? 1'b1 :
                           valid_ways[11]   == 1'b0  ? 1'b0 : curr_state[6];
         ovr_state[7] =  valid_ways[1:0] == 2'b00 ? curr_state[7] :
                           valid_ways[0] == 1'b0 ? 1'b1 :
                           valid_ways[1] == 1'b0 ? 1'b0 : curr_state[7];
         ovr_state[8] =  valid_ways[4:3] == 2'b00 ? curr_state[8] :
                           valid_ways[3] == 1'b0 ? 1'b1 :
                           valid_ways[4] == 1'b0 ? 1'b0 : curr_state[8];
         ovr_state[9] =  valid_ways[7:6] == 2'b00 ? curr_state[9] :
                           valid_ways[6] == 1'b0 ? 1'b1 :
                           valid_ways[7] == 1'b0 ? 1'b0 : curr_state[9];
         ovr_state[10] = valid_ways[10:9] == 2'b00 ? curr_state[10] :
                           valid_ways[9]  == 1'b0 ? 1'b1 :
                           valid_ways[10] == 1'b0 ? 1'b0 : curr_state[10];

         state = (hit) ? curr_state : ovr_state;
         
         casex (state)
            11'bxxx0xxx0x00 : victim = 12'b000000000001;
            11'bxxx1xxx0x00 : victim = 12'b000000000010;
            11'bxxxxxxx1x00 : victim = 12'b000000000100;
            11'bxx0xxx0xx10 : victim = 12'b000000001000;
            11'bxx1xxx0xx10 : victim = 12'b000000010000;
            11'bxxxxxx1xx10 : victim = 12'b000000100000;
            11'bx0xxx0xx0x1 : victim = 12'b000001000000;
            11'bx1xxx0xx0x1 : victim = 12'b000010000000;
            11'bxxxxx1xx0x1 : victim = 12'b000100000000;
            11'b0xxx0xxx1x1 : victim = 12'b001000000000;
            11'b1xxx0xxx1x1 : victim = 12'b010000000000;
            11'bxxxx1xxx1x1 : victim = 12'b100000000000;
            default: victim = 12'b000000000001;
         endcase //(state)
         
         MRU = (hit) ? hit_way : victim;

         case (MRU)
            12'b000000000001 : nxt_state = {state[10], state[9], state[8], 1'b1, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            12'b000000000010 : nxt_state = {state[10], state[9], state[8], 1'b0, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            12'b000000000100 : nxt_state = {state[10], state[9], state[8], state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            12'b000000001000 : nxt_state = {state[10], state[9], 1'b1, state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            12'b000000010000 : nxt_state = {state[10], state[9], 1'b0, state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            12'b000000100000 : nxt_state = {state[10], state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            12'b000001000000 : nxt_state = {state[10], 1'b1, state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            12'b000010000000 : nxt_state = {state[10], 1'b0, state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            12'b000100000000 : nxt_state = {state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            12'b001000000000 : nxt_state = {1'b1, state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            12'b010000000000 : nxt_state = {1'b0, state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            12'b100000000000 : nxt_state = {state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
         endcase //(MRU)

         victim_way = (valid_ways === 12'b0) ? 12'b0: MRU;
  <% } %>
  <% if(obj.DutInfo.nWays==16) { %> 
         ovr_state[0] = valid_ways[ 7:0] == 8'b0000_0000 ? 1'b1 :
                        valid_ways[15:8] == 8'b0000_0000 ? 1'b0 : curr_state[0];
         ovr_state[1] = valid_ways[ 7:0] == 8'b0000_0000 ? curr_state[1] :
                        valid_ways[ 3: 0] == 4'b0000 ? 1'b1 :
                        valid_ways[ 7: 4] == 4'b0000 ? 1'b0 : curr_state[1];
         ovr_state[2] = valid_ways[15:8] == 8'b0000_0000 ? curr_state[2] :
                        valid_ways[11: 8] == 4'b0000 ? 1'b1 :
                        valid_ways[15:12] == 4'b0000 ? 1'b0 : curr_state[2];
         ovr_state[3] = valid_ways[ 3: 0] == 4'b0000 ? curr_state[3] :
                        valid_ways[ 1: 0] == 2'b00   ? 1'b1 :
                        valid_ways[ 3: 2] == 2'b00   ? 1'b0 : curr_state[3];
         ovr_state[4] = valid_ways[ 7: 4] == 4'b0000 ? curr_state[4] :
                        valid_ways[ 5: 4] == 2'b00   ? 1'b1 :
                        valid_ways[ 7: 6] == 2'b00   ? 1'b0 : curr_state[4];
         ovr_state[5] = valid_ways[11: 8] == 4'b0000 ? curr_state[5] :
                        valid_ways[ 9: 8] == 2'b00   ? 1'b1 :
                        valid_ways[11:10] == 2'b00   ? 1'b0 : curr_state[5];
         ovr_state[6] = valid_ways[15:12] == 4'b0000 ? curr_state[6] :
                        valid_ways[13:12] == 2'b00   ? 1'b1 :
                        valid_ways[15:14] == 2'b00   ? 1'b0 : curr_state[6];
         ovr_state[7] = valid_ways[ 1: 0] == 2'b00   ? curr_state[7] :
                        valid_ways[ 0] == 1'b0  ? 1'b1 :
                        valid_ways[ 1] == 1'b0  ? 1'b0 : curr_state[7];
         ovr_state[8] = valid_ways[ 3: 2] == 2'b00   ? curr_state[8] :
                        valid_ways[ 2] == 1'b0  ? 1'b1 :
                        valid_ways[ 3] == 1'b0  ? 1'b0 : curr_state[8];
         ovr_state[9] = valid_ways[ 5: 4] == 2'b00   ? curr_state[9] :
                        valid_ways[ 4] == 1'b0  ? 1'b1 :
                        valid_ways[ 5] == 1'b0  ? 1'b0 : curr_state[9];
         ovr_state[10] = valid_ways[ 7: 6] == 2'b00   ?  curr_state[10] :
                        valid_ways[ 6] == 1'b0  ? 1'b1 :
                        valid_ways[ 7] == 1'b0  ? 1'b0 : curr_state[10];
         ovr_state[11] = valid_ways[ 9: 8] == 2'b00   ? curr_state[11] :
                        valid_ways[ 8] == 1'b0  ? 1'b1 :
                        valid_ways[ 9] == 1'b0  ? 1'b0 : curr_state[11];
         ovr_state[12] = valid_ways[11:10] == 2'b00   ? curr_state[12] :
                        valid_ways[10] == 1'b0  ? 1'b1 :
                        valid_ways[11] == 1'b0  ? 1'b0 : curr_state[12];
         ovr_state[13] = valid_ways[13:12] == 2'b00   ? curr_state[13] :
                        valid_ways[12] == 1'b0  ? 1'b1 :
                        valid_ways[13] == 1'b0  ? 1'b0 : curr_state[13];
         ovr_state[14] = valid_ways[15:14] == 2'b00   ? curr_state[14] :
                        valid_ways[14] == 1'b0  ? 1'b1 :
                        valid_ways[15] == 1'b0  ? 1'b0 : curr_state[14];

         state = (hit) ? curr_state : ovr_state;
         
         casex (state)
            15'bxxx_xxxx_0xxx_0x00 : victim = 16'b0000_0000_0000_0001;
            15'bxxx_xxxx_1xxx_0x00 : victim = 16'b0000_0000_0000_0010;
            15'bxxx_xxx0_xxxx_1x00 : victim = 16'b0000_0000_0000_0100;
            15'bxxx_xxx1_xxxx_1x00 : victim = 16'b0000_0000_0000_1000;
            15'bxxx_xx0x_xxx0_xx10 : victim = 16'b0000_0000_0001_0000;
            15'bxxx_xx1x_xxx0_xx10 : victim = 16'b0000_0000_0010_0000;
            15'bxxx_x0xx_xxx1_xx10 : victim = 16'b0000_0000_0100_0000;
            15'bxxx_x1xx_xxx1_xx10 : victim = 16'b0000_0000_1000_0000;
            15'bxxx_0xxx_xx0x_x0x1 : victim = 16'b0000_0001_0000_0000;
            15'bxxx_1xxx_xx0x_x0x1 : victim = 16'b0000_0010_0000_0000;
            15'bxx0_xxxx_xx1x_x0x1 : victim = 16'b0000_0100_0000_0000;
            15'bxx1_xxxx_xx1x_x0x1 : victim = 16'b0000_1000_0000_0000;
            15'bx0x_xxxx_x0xx_x1x1 : victim = 16'b0001_0000_0000_0000;
            15'bx1x_xxxx_x0xx_x1x1 : victim = 16'b0010_0000_0000_0000;
            15'b0xx_xxxx_x1xx_x1x1 : victim = 16'b0100_0000_0000_0000;
            15'b1xx_xxxx_x1xx_x1x1 : victim = 16'b1000_0000_0000_0000;
            default: victim = 16'b0000_0000_0000_0001;
         endcase //(state)

         MRU = (hit) ? hit_way : victim;

         case (MRU)
            16'b0000000000000001 : nxt_state = {state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b1, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            16'b0000000000000010 : nxt_state = {state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b0, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            16'b0000000000000100 : nxt_state = {state[14], state[13], state[12], state[11], state[10], state[9], 1'b1, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            16'b0000000000001000 : nxt_state = {state[14], state[13], state[12], state[11], state[10], state[9], 1'b0, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            16'b0000000000010000 : nxt_state = {state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            16'b0000000000100000 : nxt_state = {state[14], state[13], state[12], state[11], state[10], 1'b0, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            16'b0000000001000000 : nxt_state = {state[14], state[13], state[12], state[11], 1'b1, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            16'b0000000010000000 : nxt_state = {state[14], state[13], state[12], state[11], 1'b0, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            16'b0000000100000000 : nxt_state = {state[14], state[13], state[12], 1'b1, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            16'b0000001000000000 : nxt_state = {state[14], state[13], state[12], 1'b0, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            16'b0000010000000000 : nxt_state = {state[14], state[13], 1'b1, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            16'b0000100000000000 : nxt_state = {state[14], state[13], 1'b0, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            16'b0001000000000000 : nxt_state = {state[14], 1'b1, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            16'b0010000000000000 : nxt_state = {state[14], 1'b0, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            16'b0100000000000000 : nxt_state = {1'b1, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            16'b1000000000000000 : nxt_state = {1'b0, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
         endcase //(MRU)

         victim_way = (valid_ways === 16'b0) ? 16'b0: MRU;

  <% } %>
  <% if(obj.DutInfo.nWays==20) { %> 
         ovr_state[0] = valid_ways[ 9: 0] == 10'b00_0000_0000 ? 1'b1 :
                           valid_ways[19:10] == 10'b00_0000_0000 ? 1'b0 : curr_state[0];
         ovr_state[1] = valid_ways[ 9: 0] == 10'b00_0000_0000 ? curr_state[1] :
                           valid_ways[ 4: 0] == 5'b0_0000 ? 1'b1 :
                           valid_ways[ 9: 5] == 5'b0_0000 ? 1'b0 : curr_state[1];
         ovr_state[2] = valid_ways[19:10] == 10'b00_0000_0000 ? curr_state[2] :
                           valid_ways[14:10] == 5'b0_0000 ? 1'b1 :
                           valid_ways[19:15] == 5'b0_0000 ? 1'b0 : curr_state[2];
         ovr_state[3] = valid_ways[ 4: 0] == 5'b0_0000 ? curr_state[3] :
                           valid_ways[ 2: 0] == 3'b000 ? 1'b1 :
                           valid_ways[ 4: 3] == 2'b00  ? 1'b0 : curr_state[3];
         ovr_state[4] = valid_ways[ 9: 5] == 5'b0_0000 ? curr_state[4] :
                           valid_ways[ 7: 5] == 3'b000 ? 1'b1 :
                           valid_ways[ 9: 8] == 2'b00  ? 1'b0 : curr_state[4];
         ovr_state[5] = valid_ways[14:10] == 5'b0_0000 ? curr_state[5] :
                           valid_ways[12:10] == 3'b000 ? 1'b1 :
                           valid_ways[14:13] == 2'b00  ? 1'b0 : curr_state[5];
         ovr_state[6] = valid_ways[19:15] == 5'b0_0000 ? curr_state[6] :
                           valid_ways[17:15] == 3'b000 ? 1'b1 :
                           valid_ways[19:18] == 2'b00  ? 1'b0 : curr_state[6];
         ovr_state[7]  = valid_ways[ 2: 0] == 3'b000 ? curr_state[7] :
                           valid_ways[1:0]   == 2'b00 ? 1'b1 :
                           valid_ways[2]     == 1'b0  ? 1'b0 : curr_state[7];
         ovr_state[8]  = valid_ways[ 4: 3] == 2'b00  ? curr_state[8] :
                           valid_ways[3]     == 1'b0  ? 1'b1 :
                           valid_ways[4]     == 1'b0  ? 1'b0 : curr_state[8];
         ovr_state[9]  = valid_ways[ 7: 5] == 3'b000 ? curr_state[9] :
                           valid_ways[6:5]   == 2'b00 ? 1'b1 :
                           valid_ways[7]     == 1'b0  ? 1'b0 : curr_state[9];
         ovr_state[10] = valid_ways[ 9: 8] == 2'b00  ? curr_state[10] :
                           valid_ways[8]     == 1'b0  ? 1'b1 :
                           valid_ways[9]     == 1'b0  ? 1'b0 : curr_state[10];
         ovr_state[11] = valid_ways[12:10] == 3'b000 ? curr_state[11] :
                           valid_ways[11:10] == 2'b00 ? 1'b1 :
                           valid_ways[12]    == 1'b0  ? 1'b0 : curr_state[11];
         ovr_state[12] = valid_ways[14:13] == 2'b00  ? curr_state[12] :
                           valid_ways[13]    == 1'b0  ? 1'b1 :
                           valid_ways[14]    == 1'b0  ? 1'b0 : curr_state[12];
         ovr_state[13] = valid_ways[17:15] == 3'b000 ? curr_state[13] :
                           valid_ways[16:15] == 2'b00 ? 1'b1 :
                           valid_ways[17]    == 1'b0  ? 1'b0 : curr_state[13];
         ovr_state[14] = valid_ways[19:18] == 2'b00  ? curr_state[14] :
                           valid_ways[18]    == 1'b0  ? 1'b1 :
                           valid_ways[19]    == 1'b0  ? 1'b0 : curr_state[14];
         ovr_state[15] = valid_ways[1:0]   == 2'b00 ? curr_state[15] :
                           valid_ways[0]  == 1'b0 ? 1'b1 :
                           valid_ways[1]  == 1'b0 ? 1'b0 : curr_state[15];
         ovr_state[16] = valid_ways[6:5]   == 2'b00 ? curr_state[16] :
                           valid_ways[5]  == 1'b0 ? 1'b1 :
                           valid_ways[6]  == 1'b0 ? 1'b0 : curr_state[16];
         ovr_state[17] = valid_ways[11:10] == 2'b00 ? curr_state[17] :
                           valid_ways[10] == 1'b0 ? 1'b1 :
                           valid_ways[11] == 1'b0 ? 1'b0 : curr_state[17];
         ovr_state[18] = valid_ways[16:15] == 2'b00 ? curr_state[18] :
                           valid_ways[15] == 1'b0 ? 1'b1 :
                           valid_ways[16] == 1'b0 ? 1'b0 : curr_state[18];
         
         state = (hit) ? curr_state : ovr_state;

         casex(state)
            19'bxxx_0xxx_xxxx_0xxx_0x00 : victim = 20'b0000_0000_0000_0000_0001;
            19'bxxx_1xxx_xxxx_0xxx_0x00 : victim = 20'b0000_0000_0000_0000_0010;
            19'bxxx_xxxx_xxxx_1xxx_0x00 : victim = 20'b0000_0000_0000_0000_0100;
            19'bxxx_xxxx_xxx0_xxxx_1x00 : victim = 20'b0000_0000_0000_0000_1000;
            19'bxxx_xxxx_xxx1_xxxx_1x00 : victim = 20'b0000_0000_0000_0001_0000;
            19'bxx0_xxxx_xx0x_xxx0_xx10 : victim = 20'b0000_0000_0000_0010_0000;
            19'bxx1_xxxx_xx0x_xxx0_xx10 : victim = 20'b0000_0000_0000_0100_0000;
            19'bxxx_xxxx_xx1x_xxx0_xx10 : victim = 20'b0000_0000_0000_1000_0000;
            19'bxxx_xxxx_x0xx_xxx1_xx10 : victim = 20'b0000_0000_0001_0000_0000;
            19'bxxx_xxxx_x1xx_xxx1_xx10 : victim = 20'b0000_0000_0010_0000_0000;
            19'bx0x_xxxx_0xxx_xx0x_x0x1 : victim = 20'b0000_0000_0100_0000_0000;
            19'bx1x_xxxx_0xxx_xx0x_x0x1 : victim = 20'b0000_0000_1000_0000_0000;
            19'bxxx_xxxx_1xxx_xx0x_x0x1 : victim = 20'b0000_0001_0000_0000_0000;
            19'bxxx_xxx0_xxxx_xx1x_x0x1 : victim = 20'b0000_0010_0000_0000_0000;
            19'bxxx_xxx1_xxxx_xx1x_x0x1 : victim = 20'b0000_0100_0000_0000_0000;
            19'b0xx_xx0x_xxxx_x0xx_x1x1 : victim = 20'b0000_1000_0000_0000_0000;
            19'b1xx_xx0x_xxxx_x0xx_x1x1 : victim = 20'b0001_0000_0000_0000_0000;
            19'bxxx_xx1x_xxxx_x0xx_x1x1 : victim = 20'b0010_0000_0000_0000_0000;
            19'bxxx_x0xx_xxxx_x1xx_x1x1 : victim = 20'b0100_0000_0000_0000_0000;
            19'bxxx_x1xx_xxxx_x1xx_x1x1 : victim = 20'b1000_0000_0000_0000_0000;
            default: victim = 20'b0000_0000_0000_0000_0001;
         endcase //(state)

         MRU = (hit) ? hit_way : victim;

         case (MRU)
            20'b00000000000000000001 : nxt_state = {state[18], state[17], state[16], 1'b1, state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b1, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            20'b00000000000000000010 : nxt_state = {state[18], state[17], state[16], 1'b0, state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b1, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            20'b00000000000000000100 : nxt_state = {state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b0, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            20'b00000000000000001000 : nxt_state = {state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b1, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            20'b00000000000000010000 : nxt_state = {state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b0, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            20'b00000000000000100000 : nxt_state = {state[18], state[17], 1'b1, state[15], state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            20'b00000000000001000000 : nxt_state = {state[18], state[17], 1'b0, state[15], state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            20'b00000000000010000000 : nxt_state = {state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b0, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            20'b00000000000100000000 : nxt_state = {state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b1, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            20'b00000000001000000000 : nxt_state = {state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b0, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            20'b00000000010000000000 : nxt_state = {state[18], 1'b1, state[16], state[15], state[14], state[13], state[12], 1'b1, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            20'b00000000100000000000 : nxt_state = {state[18], 1'b0, state[16], state[15], state[14], state[13], state[12], 1'b1, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            20'b00000001000000000000 : nxt_state = {state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b0, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            20'b00000010000000000000 : nxt_state = {state[18], state[17], state[16], state[15], state[14], state[13], 1'b1, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            20'b00000100000000000000 : nxt_state = {state[18], state[17], state[16], state[15], state[14], state[13], 1'b0, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            20'b00001000000000000000 : nxt_state = {1'b1, state[17], state[16], state[15], state[14], 1'b1, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            20'b00010000000000000000 : nxt_state = {1'b0, state[17], state[16], state[15], state[14], 1'b1, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            20'b00100000000000000000 : nxt_state = {state[18], state[17], state[16], state[15], state[14], 1'b0, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            20'b01000000000000000000 : nxt_state = {state[18], state[17], state[16], state[15], 1'b1, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            20'b10000000000000000000 : nxt_state = {state[18], state[17], state[16], state[15], 1'b0, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
         endcase //(MRU)

         victim_way = (valid_ways === 20'b0) ? 20'b0: MRU;

  <% } %>
  <% if(obj.DutInfo.nWays==24) { %> 
         ovr_state[0] = valid_ways[11: 0] == 12'b0000_0000_0000 ? 1'b1 :
                  valid_ways[23:12] == 12'b0000_0000_0000 ? 1'b0 : curr_state[0];
         ovr_state[1] = valid_ways[11: 0] == 12'b0000_0000_0000 ? curr_state[1] :
                           valid_ways[5 : 0] == 6'b00_0000 ? 1'b1 :
                           valid_ways[11: 6] == 6'b00_0000 ? 1'b0 : curr_state[1];
         ovr_state[2] = valid_ways[23:12] == 12'b0000_0000_0000 ? curr_state[2] :
                           valid_ways[17:12] == 6'b00_0000 ? 1'b1 :
                           valid_ways[23:18] == 6'b00_0000 ? 1'b0 : curr_state[2];
         ovr_state[3] = valid_ways[5 : 0] == 6'b00_0000 ? curr_state[3] :
                           valid_ways[ 2:0]  == 3'b000 ? 1'b1 :
                           valid_ways[ 5:3]  == 3'b000 ? 1'b0 : curr_state[3];
         ovr_state[4] = valid_ways[11: 6] == 6'b00_0000 ? curr_state[4] :
                           valid_ways[ 8:6]  == 3'b000 ? 1'b1 :
                           valid_ways[11:9]  == 3'b000 ? 1'b0 : curr_state[4];
         ovr_state[5] = valid_ways[17:12] == 6'b00_0000 ? curr_state[5] :
                           valid_ways[14:12] == 3'b000 ? 1'b1 :
                           valid_ways[17:15] == 3'b000 ? 1'b0 : curr_state[5];
         ovr_state[6] = valid_ways[23:18] == 6'b00_0000 ? curr_state[6] :
                           valid_ways[20:18] == 3'b000 ? 1'b1 :
                           valid_ways[23:21] == 3'b000 ? 1'b0 : curr_state[6];
         ovr_state[7]  = valid_ways[ 2:0]  == 3'b000 ? curr_state[7] :
                           valid_ways[ 1: 0] == 2'b00 ? 1'b1 :
                           valid_ways[ 2   ] == 1'b0  ? 1'b0 : curr_state[7];
         ovr_state[8]  = valid_ways[ 5:3]  == 3'b000 ? curr_state[8] :
                           valid_ways[ 4: 3] == 2'b00 ? 1'b1 :
                           valid_ways[ 5   ] == 1'b0  ? 1'b0 : curr_state[8];
         ovr_state[9]  = valid_ways[ 8:6]  == 3'b000 ? curr_state[9] :
                           valid_ways[ 7: 6] == 2'b00 ? 1'b1 :
                           valid_ways[ 8   ] == 1'b0  ? 1'b0 : curr_state[9];
         ovr_state[10] = valid_ways[11:9]  == 3'b000 ? curr_state[10] :
                           valid_ways[10: 9] == 2'b00 ? 1'b1 :
                           valid_ways[11   ] == 1'b0  ? 1'b0 : curr_state[10];
         ovr_state[11] = valid_ways[14:12] == 3'b000 ? curr_state[11] :
                           valid_ways[13:12] == 2'b00 ? 1'b1 :
                           valid_ways[14   ] == 1'b0  ? 1'b0 : curr_state[11];
         ovr_state[12] = valid_ways[17:15] == 3'b000 ? curr_state[12] :
                           valid_ways[16:15] == 2'b00 ? 1'b1 :
                           valid_ways[17   ] == 1'b0  ? 1'b0 : curr_state[12];
         ovr_state[13] = valid_ways[20:18] == 3'b000 ? curr_state[13] :
                           valid_ways[19:18] == 2'b00 ? 1'b1 :
                           valid_ways[20   ] == 1'b0  ? 1'b0 : curr_state[13];
         ovr_state[14] = valid_ways[23:21] == 3'b000 ? curr_state[14] :
                           valid_ways[22:21] == 2'b00 ? 1'b1 :
                           valid_ways[23   ] == 1'b0  ? 1'b0 : curr_state[14];
         ovr_state[15] = valid_ways[ 1: 0] == 2'b00 ? curr_state[15] :
                           valid_ways[0]  == 1'b0 ? 1'b1 :
                           valid_ways[1]  == 1'b0 ? 1'b0 : curr_state[15];
         ovr_state[16] = valid_ways[ 4: 3] == 2'b00 ? curr_state[16] :
                           valid_ways[3]  == 1'b0 ? 1'b1 :
                           valid_ways[4]  == 1'b0 ? 1'b0 : curr_state[16];
         ovr_state[17] = valid_ways[ 7: 6] == 2'b00 ? curr_state[17] :
                           valid_ways[6]  == 1'b0 ? 1'b1 :
                           valid_ways[7]  == 1'b0 ? 1'b0 : curr_state[17];
         ovr_state[18] = valid_ways[10: 9] == 2'b00 ? curr_state[18] :
                           valid_ways[9]  == 1'b0 ? 1'b1 :
                           valid_ways[10] == 1'b0 ? 1'b0 : curr_state[18];
         ovr_state[19] = valid_ways[13:12] == 2'b00 ? curr_state[19] :
                           valid_ways[12] == 1'b0 ? 1'b1 :
                           valid_ways[13] == 1'b0 ? 1'b0 : curr_state[19];
         ovr_state[20] = valid_ways[16:15] == 2'b00 ? curr_state[20] :
                           valid_ways[15] == 1'b0 ? 1'b1 :
                           valid_ways[16] == 1'b0 ? 1'b0 : curr_state[20];
         ovr_state[21] = valid_ways[19:18] == 2'b00 ? curr_state[21] :
                           valid_ways[18] == 1'b0 ? 1'b1 :
                           valid_ways[19] == 1'b0 ? 1'b0 : curr_state[21];
         ovr_state[22] = valid_ways[22:21] == 2'b00 ? curr_state[22] :
                           valid_ways[21] == 1'b0 ? 1'b1 :
                           valid_ways[22] == 1'b0 ? 1'b0 : curr_state[22];

         state = (hit) ? curr_state : ovr_state;

         casex(state)
            23'bxxxxxxx0xxxxxxx0xxx0x00  : victim = 24'b0000_0000_0000_0000_0000_0001;
            23'bxxxxxxx1xxxxxxx0xxx0x00  : victim = 24'b0000_0000_0000_0000_0000_0010; 
            23'bxxxxxxxxxxxxxxx1xxx0x00  : victim = 24'b0000_0000_0000_0000_0000_0100;
            23'bxxxxxx0xxxxxxx0xxxx1x00  : victim = 24'b0000_0000_0000_0000_0000_1000;
            23'bxxxxxx1xxxxxxx0xxxx1x00  : victim = 24'b0000_0000_0000_0000_0001_0000;
            23'bxxxxxxxxxxxxxx1xxxx1x00  : victim = 24'b0000_0000_0000_0000_0010_0000;
            23'bxxxxx0xxxxxxx0xxxx0xx10  : victim = 24'b0000_0000_0000_0000_0100_0000;
            23'bxxxxx1xxxxxxx0xxxx0xx10  : victim = 24'b0000_0000_0000_0000_1000_0000;
            23'bxxxxxxxxxxxxx1xxxx0xx10  : victim = 24'b0000_0000_0000_0001_0000_0000;
            23'bxxxx0xxxxxxx0xxxxx1xx10  : victim = 24'b0000_0000_0000_0010_0000_0000;
            23'bxxxx1xxxxxxx0xxxxx1xx10  : victim = 24'b0000_0000_0000_0100_0000_0000;
            23'bxxxxxxxxxxxx1xxxxx1xx10  : victim = 24'b0000_0000_0000_1000_0000_0000;
            23'bxxx0xxxxxxx0xxxxx0xx0x1  : victim = 24'b0000_0000_0001_0000_0000_0000;
            23'bxxx1xxxxxxx0xxxxx0xx0x1  : victim = 24'b0000_0000_0010_0000_0000_0000;
            23'bxxxxxxxxxxx1xxxxx0xx0x1  : victim = 24'b0000_0000_0100_0000_0000_0000;
            23'bxx0xxxxxxx0xxxxxx1xx0x1  : victim = 24'b0000_0000_1000_0000_0000_0000; 
            23'bxx1xxxxxxx0xxxxxx1xx0x1  : victim = 24'b0000_0001_0000_0000_0000_0000;
            23'bxxxxxxxxxx1xxxxxx1xx0x1  : victim = 24'b0000_0010_0000_0000_0000_0000;
            23'bx0xxxxxxx0xxxxxx0xxx1x1  : victim = 24'b0000_0100_0000_0000_0000_0000;
            23'bx1xxxxxxx0xxxxxx0xxx1x1  : victim = 24'b0000_1000_0000_0000_0000_0000;
            23'bxxxxxxxxx1xxxxxx0xxx1x1  : victim = 24'b0001_0000_0000_0000_0000_0000;
            23'b0xxxxxxx0xxxxxxx1xxx1x1  : victim = 24'b0010_0000_0000_0000_0000_0000;
            23'b1xxxxxxx0xxxxxxx1xxx1x1  : victim = 24'b0100_0000_0000_0000_0000_0000;
            23'bxxxxxxxx1xxxxxxx1xxx1x1  : victim = 24'b1000_0000_0000_0000_0000_0000;
            default: victim = 24'b0000_0000_0000_0000_0000_0001;
         endcase //(state)

         MRU = (hit) ? hit_way : victim;

         case (MRU)
            24'b000000000000000000000001 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], state[16], 1'b1, state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b1, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            24'b000000000000000000000010 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], state[16], 1'b0, state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b1, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            24'b000000000000000000000100 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b0, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            24'b000000000000000000001000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], 1'b1, state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b1, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            24'b000000000000000000010000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], 1'b0, state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b1, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            24'b000000000000000000100000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b0, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            24'b000000000000000001000000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], 1'b1, state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            24'b000000000000000010000000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], 1'b0, state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            24'b000000000000000100000000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b0, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            24'b000000000000001000000000 : nxt_state = {state[22], state[21], state[20], state[19], 1'b1, state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b1, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            24'b000000000000010000000000 : nxt_state = {state[22], state[21], state[20], state[19], 1'b0, state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b1, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            24'b000000000000100000000000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b0, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            24'b000000000001000000000000 : nxt_state = {state[22], state[21], state[20], 1'b1, state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b1, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            24'b000000000010000000000000 : nxt_state = {state[22], state[21], state[20], 1'b0, state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b1, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            24'b000000000100000000000000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b0, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            24'b000000001000000000000000 : nxt_state = {state[22], state[21], 1'b1, state[19], state[18], state[17], state[16], state[15], state[14], state[13], 1'b1, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            24'b000000010000000000000000 : nxt_state = {state[22], state[21], 1'b0, state[19], state[18], state[17], state[16], state[15], state[14], state[13], 1'b1, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            24'b000000100000000000000000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], 1'b0, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            24'b000001000000000000000000 : nxt_state = {state[22], 1'b1, state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b1, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            24'b000010000000000000000000 : nxt_state = {state[22], 1'b0, state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b1, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            24'b000100000000000000000000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b0, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            24'b001000000000000000000000 : nxt_state = {1'b1, state[21], state[20], state[19], state[18], state[17], state[16], state[15], 1'b1, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            24'b010000000000000000000000 : nxt_state = {1'b0, state[21], state[20], state[19], state[18], state[17], state[16], state[15], 1'b1, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            24'b100000000000000000000000 : nxt_state = {state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], 1'b0, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
         endcase //(MRU)

         victim_way = (valid_ways === 24'b0) ? 24'b0: MRU;
  <% } %>
  <% if(obj.DutInfo.nWays==28) { %> 
         ovr_state[0] = valid_ways[13: 0] == 14'b00_0000_0000_0000 ? 1'b1 :
                  valid_ways[27:14] == 14'b00_0000_0000_0000 ? 1'b0 : curr_state[0];
         ovr_state[1] = valid_ways[13: 0] == 14'b00_0000_0000_0000 ? curr_state[1] :
                           valid_ways[ 6: 0] == 7'b000_0000 ? 1'b1 :
                           valid_ways[13: 7] == 7'b000_0000 ? 1'b0 : curr_state[1];
         ovr_state[2] = valid_ways[27:14] == 14'b00_0000_0000_0000 ? curr_state[2] :
                           valid_ways[20:14] == 7'b000_0000 ? 1'b1 :
                           valid_ways[27:21] == 7'b000_0000 ? 1'b0 : curr_state[2];
         ovr_state[3] = valid_ways[ 6: 0] == 7'b000_0000 ? curr_state[3] :
                           valid_ways[ 3: 0] == 4'b0000 ? 1'b1 :
                           valid_ways[ 6: 4] == 3'b000  ? 1'b0 : curr_state[3];
         ovr_state[4] = valid_ways[13: 7] == 7'b000_0000 ? curr_state[4] :
                           valid_ways[10: 7] == 4'b0000 ? 1'b1 :
                           valid_ways[13:11] == 3'b000  ? 1'b0 : curr_state[4];
         ovr_state[5] = valid_ways[20:14] == 7'b000_0000 ? curr_state[5] :
                           valid_ways[17:14] == 4'b0000 ? 1'b1 :
                           valid_ways[20:18] == 3'b000  ? 1'b0 : curr_state[5];
         ovr_state[6] = valid_ways[27:21] == 7'b000_0000 ? curr_state[6] :
                           valid_ways[24:21] == 4'b0000 ? 1'b1 :
                           valid_ways[27:25] == 3'b000  ? 1'b0 : curr_state[6];
         ovr_state[7]  = valid_ways[ 3: 0] == 4'b0000 ? curr_state[7] :
                           valid_ways[ 1: 0] == 2'b00 ? 1'b1 :
                           valid_ways[ 3: 2] == 2'b00 ? 1'b0 : curr_state[7];
         ovr_state[8]  = valid_ways[ 6: 4] == 3'b000  ? curr_state[8] :
                           valid_ways[ 5: 4] == 2'b00 ? 1'b1 :
                           valid_ways[    6] == 1'b0  ? 1'b0 : curr_state[8];
         ovr_state[9]  = valid_ways[10: 7] == 4'b0000 ? curr_state[9] :
                           valid_ways[ 8: 7] == 2'b00 ? 1'b1 :
                           valid_ways[10: 9] == 2'b00 ? 1'b0 : curr_state[9];
         ovr_state[10] = valid_ways[13:11] == 3'b000  ? curr_state[10] :
                           valid_ways[12:11] == 2'b00 ? 1'b1 :
                           valid_ways[   13] == 1'b0  ? 1'b0 : curr_state[10];
         ovr_state[11] = valid_ways[17:14] == 4'b0000 ? curr_state[11] :
                           valid_ways[15:14] == 2'b00 ? 1'b1 :
                           valid_ways[17:16] == 2'b00 ? 1'b0 : curr_state[11];
         ovr_state[12] = valid_ways[20:18] == 3'b000  ? curr_state[12] :
                           valid_ways[19:18] == 2'b00 ? 1'b1 :
                           valid_ways[   20] == 1'b0  ? 1'b0 : curr_state[12];
         ovr_state[13] = valid_ways[24:21] == 4'b0000 ? curr_state[13] :
                           valid_ways[22:21] == 2'b00 ? 1'b1 :
                           valid_ways[24:23] == 2'b00 ? 1'b0 : curr_state[13];
         ovr_state[14] = valid_ways[27:25] == 3'b000  ? curr_state[14] :
                           valid_ways[26:25] == 2'b00 ? 1'b1 :
                           valid_ways[   27] == 1'b0  ? 1'b0 : curr_state[14];
         ovr_state[15] = valid_ways[ 1: 0] == 2'b00 ? curr_state[15] :
                           valid_ways[0]  == 1'b0 ? 1'b1 :
                           valid_ways[1]  == 1'b0 ? 1'b0 : curr_state[15];
         ovr_state[16] = valid_ways[ 3: 2] == 2'b00 ? curr_state[16] :
                           valid_ways[2]  == 1'b0 ? 1'b1 :
                           valid_ways[3]  == 1'b0 ? 1'b0 : curr_state[16];
         ovr_state[17] = valid_ways[ 5: 4] == 2'b00 ? curr_state[17] :
                           valid_ways[4]  == 1'b0 ? 1'b1 :
                           valid_ways[5]  == 1'b0 ? 1'b0 : curr_state[17];
         ovr_state[18] = valid_ways[ 8: 7] == 2'b00 ? curr_state[18] :
                           valid_ways[7]  == 1'b0 ? 1'b1 :
                           valid_ways[8]  == 1'b0 ? 1'b0 : curr_state[18];
         ovr_state[19] = valid_ways[10: 9] == 2'b00 ? curr_state[19] :
                           valid_ways[9]  == 1'b0 ? 1'b1 :
                           valid_ways[10] == 1'b0 ? 1'b0 : curr_state[19];
         ovr_state[20] = valid_ways[12:11] == 2'b00 ? curr_state[20] :
                           valid_ways[11] == 1'b0 ? 1'b1 :
                           valid_ways[12] == 1'b0 ? 1'b0 : curr_state[20];
         ovr_state[21] = valid_ways[15:14] == 2'b00 ? curr_state[21] :
                           valid_ways[14] == 1'b0 ? 1'b1 :
                           valid_ways[15] == 1'b0 ? 1'b0 : curr_state[21];
         ovr_state[22] = valid_ways[17:16] == 2'b00 ? curr_state[22] :
                           valid_ways[16] == 1'b0 ? 1'b1 :
                           valid_ways[17] == 1'b0 ? 1'b0 : curr_state[22];
         ovr_state[23] = valid_ways[19:18] == 2'b00 ? curr_state[23] :
                           valid_ways[18] == 1'b0 ? 1'b1 :
                           valid_ways[19] == 1'b0 ? 1'b0 : curr_state[23];
         ovr_state[24] = valid_ways[22:21] == 2'b00 ? curr_state[24] :
                           valid_ways[21] == 1'b0 ? 1'b1 :
                           valid_ways[22] == 1'b0 ? 1'b0 : curr_state[24];
         ovr_state[25] = valid_ways[24:23] == 2'b00 ? curr_state[25] :
                           valid_ways[23] == 1'b0 ? 1'b1 :
                           valid_ways[24] == 1'b0 ? 1'b0 : curr_state[25];
         ovr_state[26] = valid_ways[26:25] == 2'b00 ? curr_state[26] :
                           valid_ways[25] == 1'b0 ? 1'b1 :
                           valid_ways[26] == 1'b0 ? 1'b0 : curr_state[26];

         state = (hit) ? curr_state : ovr_state;

         casex(state)

            27'bxxxxxxxxxxx0xxxxxxx0xxx0x00 : victim = 28'b0000_0000_0000_0000_0000_0000_0001;
            27'bxxxxxxxxxxx1xxxxxxx0xxx0x00 : victim = 28'b0000_0000_0000_0000_0000_0000_0010;
            27'bxxxxxxxxxx0xxxxxxxx1xxx0x00 : victim = 28'b0000_0000_0000_0000_0000_0000_0100;
            27'bxxxxxxxxxx1xxxxxxxx1xxx0x00 : victim = 28'b0000_0000_0000_0000_0000_0000_1000;
            27'bxxxxxxxxx0xxxxxxxx0xxxx1x00 : victim = 28'b0000_0000_0000_0000_0000_0001_0000;
            27'bxxxxxxxxx1xxxxxxxx0xxxx1x00 : victim = 28'b0000_0000_0000_0000_0000_0010_0000;
            27'bxxxxxxxxxxxxxxxxxx1xxxx1x00 : victim = 28'b0000_0000_0000_0000_0000_0100_0000;
            27'bxxxxxxxx0xxxxxxxx0xxxx0xx10 : victim = 28'b0000_0000_0000_0000_0000_1000_0000;
            27'bxxxxxxxx1xxxxxxxx0xxxx0xx10 : victim = 28'b0000_0000_0000_0000_0001_0000_0000;
            27'bxxxxxxx0xxxxxxxxx0xxxx0xx10 : victim = 28'b0000_0000_0000_0000_0010_0000_0000;
            27'bxxxxxxx1xxxxxxxxx0xxxx0xx10 : victim = 28'b0000_0000_0000_0000_0100_0000_0000;
            27'bxxxxxx0xxxxxxxxx0xxxxx1xx10 : victim = 28'b0000_0000_0000_0000_1000_0000_0000;
            27'bxxxxxx1xxxxxxxxx0xxxxx1xx10 : victim = 28'b0000_0000_0000_0001_0000_0000_0000;
            27'bxxxxxxxxxxxxxxxx1xxxxx1xx10 : victim = 28'b0000_0000_0000_0010_0000_0000_0000;
            27'bxxxxx0xxxxxxxxx0xxxxx0xx0x1 : victim = 28'b0000_0000_0000_0100_0000_0000_0000;
            27'bxxxxx1xxxxxxxxx0xxxxx0xx0x1 : victim = 28'b0000_0000_0000_1000_0000_0000_0000;
            27'bxxxx0xxxxxxxxxx1xxxxx0xx0x1 : victim = 28'b0000_0000_0001_0000_0000_0000_0000;
            27'bxxxx1xxxxxxxxxx1xxxxx0xx0x1 : victim = 28'b0000_0000_0010_0000_0000_0000_0000;
            27'bxxx0xxxxxxxxxx0xxxxxx1xx0x1 : victim = 28'b0000_0000_0100_0000_0000_0000_0000;
            27'bxxx1xxxxxxxxxx0xxxxxx1xx0x1 : victim = 28'b0000_0000_1000_0000_0000_0000_0000;
            27'bxxxxxxxxxxxxxx1xxxxxx1xx0x1 : victim = 28'b0000_0001_0000_0000_0000_0000_0000;
            27'bxx0xxxxxxxxxx0xxxxxx0xxx1x1 : victim = 28'b0000_0010_0000_0000_0000_0000_0000;
            27'bxx1xxxxxxxxxx0xxxxxx0xxx1x1 : victim = 28'b0000_0100_0000_0000_0000_0000_0000;
            27'bx0xxxxxxxxxxx1xxxxxx0xxx1x1 : victim = 28'b0000_1000_0000_0000_0000_0000_0000;
            27'bx1xxxxxxxxxxx1xxxxxx0xxx1x1 : victim = 28'b0001_0000_0000_0000_0000_0000_0000;
            27'b0xxxxxxxxxxx0xxxxxxx1xxx1x1 : victim = 28'b0010_0000_0000_0000_0000_0000_0000;
            27'b1xxxxxxxxxxx0xxxxxxx1xxx1x1 : victim = 28'b0100_0000_0000_0000_0000_0000_0000;
            27'bxxxxxxxxxxxx1xxxxxxx1xxx1x1 : victim = 28'b1000_0000_0000_0000_0000_0000_0000;
            default : victim = 28'b0000_0000_0000_0000_0000_0000_0001;
         endcase //(state)

         MRU = (hit) ? hit_way : victim;

         case (MRU)
            28'b0000000000000000000000000001 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], 1'b1, state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b1, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            28'b0000000000000000000000000010 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], 1'b0, state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b1, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            28'b0000000000000000000000000100 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], 1'b1, state[15], state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b0, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            28'b0000000000000000000000001000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], 1'b0, state[15], state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b0, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            28'b0000000000000000000000010000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], 1'b1, state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b1, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            28'b0000000000000000000000100000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], 1'b0, state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b1, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            28'b0000000000000000000001000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b0, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            28'b0000000000000000000010000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], 1'b1, state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            28'b0000000000000000000100000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], 1'b0, state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            28'b0000000000000000001000000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], 1'b1, state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            28'b0000000000000000010000000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], 1'b0, state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            28'b0000000000000000100000000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], 1'b1, state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b1, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            28'b0000000000000001000000000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], 1'b0, state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b1, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            28'b0000000000000010000000000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b0, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            28'b0000000000000100000000000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], 1'b1, state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b1, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            28'b0000000000001000000000000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], 1'b0, state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b1, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            28'b0000000000010000000000000000 : nxt_state = {state[26], state[25], state[24], state[23], 1'b1, state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b0, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            28'b0000000000100000000000000000 : nxt_state = {state[26], state[25], state[24], state[23], 1'b0, state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b0, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            28'b0000000001000000000000000000 : nxt_state = {state[26], state[25], state[24], 1'b1, state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], 1'b1, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            28'b0000000010000000000000000000 : nxt_state = {state[26], state[25], state[24], 1'b0, state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], 1'b1, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            28'b0000000100000000000000000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], 1'b0, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            28'b0000001000000000000000000000 : nxt_state = {state[26], state[25], 1'b1, state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b1, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            28'b0000010000000000000000000000 : nxt_state = {state[26], state[25], 1'b0, state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b1, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            28'b0000100000000000000000000000 : nxt_state = {state[26], 1'b1, state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b0, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            28'b0001000000000000000000000000 : nxt_state = {state[26], 1'b0, state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b0, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            28'b0010000000000000000000000000 : nxt_state = {1'b1, state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], 1'b1, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            28'b0100000000000000000000000000 : nxt_state = {1'b0, state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], 1'b1, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3],1'b0, state[1], 1'b0};
            28'b1000000000000000000000000000 : nxt_state = {state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], 1'b0, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};

         endcase //(MRU)

         victim_way = (valid_ways === 28'b0) ? 28'b0: MRU;
  <% } %>
  <% if(obj.DutInfo.nWays==32) { %> 
         ovr_state[0] = valid_ways[15: 0] == 16'b0000_0000_0000_0000 ? 1'b1 :
                        valid_ways[31:16] == 16'b0000_0000_0000_0000 ? 1'b0 : curr_state[0];
         ovr_state[1] = valid_ways[15: 0] == 16'b0000_0000_0000_0000 ? curr_state[1] :
                           valid_ways[ 7: 0] == 8'b0000_0000 ? 1'b1 :
                           valid_ways[15: 8] == 8'b0000_0000 ? 1'b0 : curr_state[1];
         ovr_state[2] = valid_ways[31:16] == 16'b0000_0000_0000_0000 ? curr_state[2] :
                           valid_ways[23:16] == 8'b0000_0000 ? 1'b1 :
                           valid_ways[31:24] == 8'b0000_0000 ? 1'b0 : curr_state[2];
         ovr_state[3] = valid_ways[ 7: 0] == 8'b0000_0000 ? curr_state[3] :
                           valid_ways[ 3: 0] == 4'b0000 ? 1'b1 :
                           valid_ways[ 7: 4] == 4'b0000 ? 1'b0 : curr_state[3];
         ovr_state[4] = valid_ways[15: 8] == 8'b0000_0000 ? curr_state[4] :
                           valid_ways[11: 8] == 4'b0000 ? 1'b1 :
                           valid_ways[15:12] == 4'b0000 ? 1'b0 : curr_state[4];
         ovr_state[5] = valid_ways[23:16] == 8'b0000_0000 ? curr_state[5] :
                           valid_ways[19:16] == 4'b0000 ? 1'b1 :
                           valid_ways[23:20] == 4'b0000 ? 1'b0 : curr_state[5];
         ovr_state[6] = valid_ways[31:24] == 8'b0000_0000 ? curr_state[6] :
                           valid_ways[27:24] == 4'b0000 ? 1'b1 :
                           valid_ways[31:28] == 4'b0000 ? 1'b0 : curr_state[6];
         ovr_state[7]  = valid_ways[ 3: 0] == 4'b0000 ? curr_state[7] :
                           valid_ways[ 1: 0] == 2'b00 ? 1'b1 :
                           valid_ways[ 3: 2] == 2'b00 ? 1'b0 : curr_state[7];
         ovr_state[8]  = valid_ways[ 7: 4] == 4'b0000 ? curr_state[8] :
                           valid_ways[ 5: 4] == 2'b00 ? 1'b1 :
                           valid_ways[ 7: 6] == 2'b00 ? 1'b0 : curr_state[8];
         ovr_state[9]  = valid_ways[11: 8] == 4'b0000 ? curr_state[9] :
                           valid_ways[ 9: 8] == 2'b00 ? 1'b1 :
                           valid_ways[11:10] == 2'b00 ? 1'b0 : curr_state[9];
         ovr_state[10] = valid_ways[15:12] == 4'b0000 ? curr_state[10] :
                           valid_ways[13:12] == 2'b00 ? 1'b1 :
                           valid_ways[15:14] == 2'b00 ? 1'b0 : curr_state[10];
         ovr_state[11] = valid_ways[19:16] == 4'b0000 ? curr_state[11] :
                           valid_ways[17:16] == 2'b00 ? 1'b1 :
                           valid_ways[19:18] == 2'b00 ? 1'b0 : curr_state[11];
         ovr_state[12] = valid_ways[23:20] == 4'b0000 ? curr_state[12] :
                           valid_ways[21:20] == 2'b00 ? 1'b1 :
                           valid_ways[23:22] == 2'b00 ? 1'b0 : curr_state[12];
         ovr_state[13] = valid_ways[27:24] == 4'b0000 ? curr_state[13] :
                           valid_ways[25:24] == 2'b00 ? 1'b1 :
                           valid_ways[27:26] == 2'b00 ? 1'b0 : curr_state[13];
         ovr_state[14] = valid_ways[31:28] == 4'b0000 ? curr_state[14] :
                           valid_ways[29:28] == 2'b00 ? 1'b1 :
                           valid_ways[31:30] == 2'b00 ? 1'b0 : curr_state[14];
         ovr_state[15] = valid_ways[ 1: 0] == 2'b00 ? curr_state[15] :
                           valid_ways[0]  == 1'b0 ? 1'b1 :
                           valid_ways[1]  == 1'b0 ? 1'b0 : curr_state[15];
         ovr_state[16] = valid_ways[ 3: 2] == 2'b00 ? curr_state[16] :
                           valid_ways[2]  == 1'b0 ? 1'b1 :
                           valid_ways[3]  == 1'b0 ? 1'b0 : curr_state[16];
         ovr_state[17] = valid_ways[ 5: 4] == 2'b00 ? curr_state[17] :
                           valid_ways[4]  == 1'b0 ? 1'b1 :
                           valid_ways[5]  == 1'b0 ? 1'b0 : curr_state[17];
         ovr_state[18] = valid_ways[ 7: 6] == 2'b00 ? curr_state[18] :
                           valid_ways[6]  == 1'b0 ? 1'b1 :
                           valid_ways[7]  == 1'b0 ? 1'b0 : curr_state[18];
         ovr_state[19] = valid_ways[ 9: 8] == 2'b00 ? curr_state[19] :
                           valid_ways[8]  == 1'b0 ? 1'b1 :
                           valid_ways[9]  == 1'b0 ? 1'b0 : curr_state[19];
         ovr_state[20] = valid_ways[11:10] == 2'b00 ? curr_state[20] :
                           valid_ways[10] == 1'b0 ? 1'b1 :
                           valid_ways[11] == 1'b0 ? 1'b0 : curr_state[20];
         ovr_state[21] = valid_ways[13:12] == 2'b00 ? curr_state[21] :
                           valid_ways[12] == 1'b0 ? 1'b1 :
                           valid_ways[13] == 1'b0 ? 1'b0 : curr_state[21];
         ovr_state[22] = valid_ways[15:14] == 2'b00 ? curr_state[22] :
                           valid_ways[14] == 1'b0 ? 1'b1 :
                           valid_ways[15] == 1'b0 ? 1'b0 : curr_state[22];
         ovr_state[23] = valid_ways[17:16] == 2'b00 ? curr_state[23] :
                           valid_ways[16] == 1'b0 ? 1'b1 :
                           valid_ways[17] == 1'b0 ? 1'b0 : curr_state[23];
         ovr_state[24] = valid_ways[19:18] == 2'b00 ? curr_state[24] :
                           valid_ways[18] == 1'b0 ? 1'b1 :
                           valid_ways[19] == 1'b0 ? 1'b0 : curr_state[24];
         ovr_state[25] = valid_ways[21:20] == 2'b00 ? curr_state[25] :
                           valid_ways[20] == 1'b0 ? 1'b1 :
                           valid_ways[21] == 1'b0 ? 1'b0 : curr_state[25];
         ovr_state[26] = valid_ways[23:22] == 2'b00 ? curr_state[26] :
                           valid_ways[22] == 1'b0 ? 1'b1 :
                           valid_ways[23] == 1'b0 ? 1'b0 : curr_state[26];
         ovr_state[27] = valid_ways[25:24] == 2'b00 ? curr_state[27] :
                           valid_ways[24] == 1'b0 ? 1'b1 :
                           valid_ways[25] == 1'b0 ? 1'b0 : curr_state[27];
         ovr_state[28] = valid_ways[27:26] == 2'b00 ? curr_state[28] :
                           valid_ways[26] == 1'b0 ? 1'b1 :
                           valid_ways[27] == 1'b0 ? 1'b0 : curr_state[28];
         ovr_state[29] = valid_ways[29:28] == 2'b00 ? curr_state[29] :
                           valid_ways[28] == 1'b0 ? 1'b1 :
                           valid_ways[29] == 1'b0 ? 1'b0 : curr_state[29];
         ovr_state[30] = valid_ways[31:30] == 2'b00 ? curr_state[30] :
                           valid_ways[30] == 1'b0 ? 1'b1 :
                           valid_ways[31] == 1'b0 ? 1'b0 : curr_state[30];

         state = (hit) ? curr_state : ovr_state;

         casex (state)

            31'bxxxxxxxxxxxxxxx0xxxxxxx0xxx0x00 : victim = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
            
            31'bxxxxxxxxxxxxxxx1xxxxxxx0xxx0x00 : victim = 32'b0000_0000_0000_0000_0000_0000_0000_0010;
               
            31'bxxxxxxxxxxxxxx0xxxxxxxx1xxx0x00 : victim = 32'b0000_0000_0000_0000_0000_0000_0000_0100;
               
            31'bxxxxxxxxxxxxxx1xxxxxxxx1xxx0x00 : victim = 32'b0000_0000_0000_0000_0000_0000_0000_1000;
               
            31'bxxxxxxxxxxxxx0xxxxxxxx0xxxx1x00 : victim = 32'b0000_0000_0000_0000_0000_0000_0001_0000;
               
            31'bxxxxxxxxxxxxx1xxxxxxxx0xxxx1x00 : victim = 32'b0000_0000_0000_0000_0000_0000_0010_0000;
               
            31'bxxxxxxxxxxxx0xxxxxxxxx1xxxx1x00 : victim = 32'b0000_0000_0000_0000_0000_0000_0100_0000;
               
            31'bxxxxxxxxxxxx1xxxxxxxxx1xxxx1x00 : victim = 32'b0000_0000_0000_0000_0000_0000_1000_0000;
               
            31'bxxxxxxxxxxx0xxxxxxxxx0xxxx0xx10 : victim = 32'b0000_0000_0000_0000_0000_0001_0000_0000;
               
            31'bxxxxxxxxxxx1xxxxxxxxx0xxxx0xx10 : victim = 32'b0000_0000_0000_0000_0000_0010_0000_0000;
               
            31'bxxxxxxxxxx0xxxxxxxxxx1xxxx0xx10 : victim = 32'b0000_0000_0000_0000_0000_0100_0000_0000;
               
            31'bxxxxxxxxxx1xxxxxxxxxx1xxxx0xx10 : victim = 32'b0000_0000_0000_0000_0000_1000_0000_0000;
            
            31'bxxxxxxxxx0xxxxxxxxxx0xxxxx1xx10 : victim = 32'b0000_0000_0000_0000_0001_0000_0000_0000;
            
            31'bxxxxxxxxx1xxxxxxxxxx0xxxxx1xx10 : victim = 32'b0000_0000_0000_0000_0010_0000_0000_0000;
               
            31'bxxxxxxxx0xxxxxxxxxxx1xxxxx1xx10 : victim = 32'b0000_0000_0000_0000_0100_0000_0000_0000;
               
            31'bxxxxxxxx1xxxxxxxxxxx1xxxxx1xx10 : victim = 32'b0000_0000_0000_0000_1000_0000_0000_0000;
               
            31'bxxxxxxx0xxxxxxxxxxx0xxxxx0xx0x1 : victim = 32'b0000_0000_0000_0001_0000_0000_0000_0000;
               
            31'bxxxxxxx1xxxxxxxxxxx0xxxxx0xx0x1 : victim = 32'b0000_0000_0000_0010_0000_0000_0000_0000;
               
            31'bxxxxxx0xxxxxxxxxxxx1xxxxx0xx0x1 : victim = 32'b0000_0000_0000_0100_0000_0000_0000_0000;
               
            31'bxxxxxx1xxxxxxxxxxxx1xxxxx0xx0x1 : victim = 32'b0000_0000_0000_1000_0000_0000_0000_0000;
               
            31'bxxxxx0xxxxxxxxxxxx0xxxxxx1xx0x1 : victim = 32'b0000_0000_0001_0000_0000_0000_0000_0000;
               
            31'bxxxxx1xxxxxxxxxxxx0xxxxxx1xx0x1 : victim = 32'b0000_0000_0010_0000_0000_0000_0000_0000;
               
            31'bxxxx0xxxxxxxxxxxxx1xxxxxx1xx0x1 : victim = 32'b0000_0000_0100_0000_0000_0000_0000_0000;
               
            31'bxxxx1xxxxxxxxxxxxx1xxxxxx1xx0x1 : victim = 32'b0000_0000_1000_0000_0000_0000_0000_0000;
               
            31'bxxx0xxxxxxxxxxxxx0xxxxxx0xxx1x1 : victim = 32'b0000_0001_0000_0000_0000_0000_0000_0000;
               
            31'bxxx1xxxxxxxxxxxxx0xxxxxx0xxx1x1 : victim = 32'b0000_0010_0000_0000_0000_0000_0000_0000;
               
            31'bxx0xxxxxxxxxxxxxx1xxxxxx0xxx1x1 : victim = 32'b0000_0100_0000_0000_0000_0000_0000_0000;
               
            31'bxx1xxxxxxxxxxxxxx1xxxxxx0xxx1x1 : victim = 32'b0000_1000_0000_0000_0000_0000_0000_0000;
               
            31'bx0xxxxxxxxxxxxxx0xxxxxxx1xxx1x1 : victim = 32'b0001_0000_0000_0000_0000_0000_0000_0000;
               
            31'bx1xxxxxxxxxxxxxx0xxxxxxx1xxx1x1 : victim = 32'b0010_0000_0000_0000_0000_0000_0000_0000;
               
            31'b0xxxxxxxxxxxxxxx1xxxxxxx1xxx1x1 : victim = 32'b0100_0000_0000_0000_0000_0000_0000_0000;
               
            31'b1xxxxxxxxxxxxxxx1xxxxxxx1xxx1x1 : victim = 32'b1000_0000_0000_0000_0000_0000_0000_0000;
            
            default: victim = 32'b0000_0000_0000_0000_0000_0000_0000_0001;
         endcase //(state)

         MRU = (hit) ? hit_way : victim;

         case (MRU)
            32'b00000000000000000000000000000001 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], 1'b1, state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b1, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            32'b00000000000000000000000000000010 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], 1'b0, state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b1, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            32'b00000000000000000000000000000100 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], 1'b1, state[15], state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b0, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            32'b00000000000000000000000000001000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], 1'b0, state[15], state[14], state[13], state[12], state[11], state[10], state[9], state[8], 1'b0, state[6], state[5], state[4], 1'b1, state[2], 1'b1, 1'b1};
            32'b00000000000000000000000000010000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], 1'b1, state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b1, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            32'b00000000000000000000000000100000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], 1'b0, state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b1, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            32'b00000000000000000000000001000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], 1'b1, state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b0, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            32'b00000000000000000000000010000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], 1'b0, state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], state[9], 1'b0, state[7], state[6], state[5], state[4], 1'b0, state[2], 1'b1, 1'b1};
            32'b00000000000000000000000100000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], 1'b1, state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            32'b00000000000000000000001000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], 1'b0, state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b1, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            32'b00000000000000000000010000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], 1'b1, state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b0, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            32'b00000000000000000000100000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], 1'b0, state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], state[10], 1'b0, state[8], state[7], state[6], state[5], 1'b1, state[3], state[2], 1'b0, 1'b1};
            32'b00000000000000000001000000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], 1'b1, state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b1, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            32'b00000000000000000010000000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], 1'b0, state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b1, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            32'b00000000000000000100000000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], 1'b1, state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b0, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            32'b00000000000000001000000000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], state[23], 1'b0, state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], state[11], 1'b0, state[9], state[8], state[7], state[6], state[5], 1'b0, state[3], state[2], 1'b0, 1'b1};
            32'b00000000000000010000000000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], 1'b1, state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b1, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            32'b00000000000000100000000000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], state[24], 1'b0, state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b1, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            32'b00000000000001000000000000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], 1'b1, state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b0, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            32'b00000000000010000000000000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], state[25], 1'b0, state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], state[12], 1'b0, state[10], state[9], state[8], state[7], state[6], 1'b1, state[4], state[3], 1'b1, state[1], 1'b0};
            32'b00000000000100000000000000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], 1'b1, state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], 1'b1, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            32'b00000000001000000000000000000000 : nxt_state = {state[30], state[29], state[28], state[27], state[26], 1'b0, state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], 1'b1, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            32'b00000000010000000000000000000000 : nxt_state = {state[30], state[29], state[28], state[27], 1'b1, state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], 1'b0, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            32'b00000000100000000000000000000000 : nxt_state = {state[30], state[29], state[28], state[27], 1'b0, state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], state[13], 1'b0, state[11], state[10], state[9], state[8], state[7], state[6], 1'b0, state[4], state[3], 1'b1, state[1], 1'b0};
            32'b00000001000000000000000000000000 : nxt_state = {state[30], state[29], state[28], 1'b1, state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b1, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            32'b00000010000000000000000000000000 : nxt_state = {state[30], state[29], state[28], 1'b0, state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b1, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            32'b00000100000000000000000000000000 : nxt_state = {state[30], state[29], 1'b1, state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b0, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            32'b00001000000000000000000000000000 : nxt_state = {state[30], state[29], 1'b0, state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], state[14], 1'b0, state[12], state[11], state[10], state[9], state[8], state[7], 1'b1, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            32'b00010000000000000000000000000000 : nxt_state = {state[30], 1'b1, state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], 1'b1, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            32'b00100000000000000000000000000000 : nxt_state = {state[30], 1'b0, state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], 1'b1, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            32'b01000000000000000000000000000000 : nxt_state = {1'b1, state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], 1'b0, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
            32'b10000000000000000000000000000000 : nxt_state = {1'b0, state[29], state[28], state[27], state[26], state[25], state[24], state[23], state[22], state[21], state[20], state[19], state[18], state[17], state[16], state[15], 1'b0, state[13], state[12], state[11], state[10], state[9], state[8], state[7], 1'b0, state[5], state[4], state[3], 1'b0, state[1], 1'b0};
         endcase //(MRU)

         victim_way = (valid_ways === 32'b0) ? 32'b0 : MRU;
  <% } %>
   //$display("CCP_PLRU_Predictor:: current_state: %0b, valid_ways: %0b, override_state: %0b, victim_way: %0b, next_state: %0b", curr_state, valid_ways, ovr_state, victim_way, nxt_state);
endfunction : ccp_plru_predictor
