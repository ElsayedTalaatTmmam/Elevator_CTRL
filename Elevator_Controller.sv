module Elevator_CTRL #(Num_Floors = 5)(
input logic   			CLK,
input logic   			RST,
input logic [Num_Floors-1:0]	i_req_ext,
input logic [Num_Floors-1:0]	i_req_inter,
input logic			i_stop,

output logic [2:0]		     o_current_floor,
output logic			     o_up,
output logic			     o_down,
output logic			     o_door
);


logic [Num_Floors-1:0]	cmp_out;

typedef enum {	Start,
		Wait,
		Stop,
		Ideal,
		Moving_up,
		Moving_down
} Elevator ;

     Elevator next_s,current_s;


always @(posedge CLK or negedge RST or posedge i_stop)
begin 
	if(!RST) begin
		current_s <= Start;
		end
	else if (i_stop)begin
		current_s <= Stop;
		end
	else 	begin
		current_s <= next_s;
		end
end


always @(*)
begin
		o_door = 0;
		o_up   = 0;
		o_down = 0;
		cmp_out= cmp_out;
  case(current_s)
	Start: begin
		o_door = 0;
		o_up   = 0;
		o_down = 0;
		cmp_out= 5'b1;
		next_s = Ideal;
		end

	Ideal: begin

		if(i_req_inter == 0 && i_req_ext == 0)begin
					next_s = Ideal;
					o_door = 1;
					o_up   = 0;
					o_down = 0;
					cmp_out= cmp_out;
				end

		else if (i_req_inter > cmp_out || i_req_ext > cmp_out) begin
				
					next_s = Moving_up;
					o_door = 0;
					o_up   = 1;
					o_down = 0;
					cmp_out= cmp_out;

				end
		else if (i_req_inter < cmp_out || i_req_ext < cmp_out) begin
					next_s = Moving_down;
					o_door = 0;
					o_up   = 0;
					o_down = 1;
					cmp_out= cmp_out;
				end
		else  		begin
					next_s = Ideal;
					o_door = 1;
					o_up   = 0;
					o_down = 0;
					cmp_out= cmp_out;
				end
		end

	Moving_up: begin
		o_door = 0;
		o_up   = 1;
		o_down = 0;
		cmp_out= (cmp_out << 1);

				    if(i_req_inter == cmp_out || i_req_ext == cmp_out) begin
					next_s = Wait;
					     end
	   			   else begin
					next_s = Ideal;
					    end
	     end

	Moving_down: begin
		o_door = 0;
		o_up   = 0;
		o_down = 1;
		cmp_out= (cmp_out >> 1);

				    if(i_req_inter == cmp_out || i_req_ext == cmp_out) begin
					next_s = Wait;
					     end
	   			   else begin
					next_s = Ideal;
					    end
	    end

	Wait: begin
		o_door = 1;
		o_up   = 0;
		o_down = 0;
		cmp_out= cmp_out;

				    if(i_req_inter == cmp_out || i_req_ext == cmp_out) begin
					next_s = Wait;
					     end
	   			   else begin
					next_s = Ideal;
					    end
	    end

	Stop: begin
		o_door = 0;
		o_up   = 0;
		o_down = 0;
	    if(i_stop) begin
		next_s = Stop;
			end
	    else begin
		next_s = Ideal;
			end
		end
	default: begin
		o_door = 0;
		o_up   = 0;
		o_down = 0;
		cmp_out= cmp_out;
		next_s = Stop;
	    end 
endcase
end

//assign cmp_out =='b00000 ? cmp_out = 1 : cmp_out = cmp_out;

always @(*)
begin
  case(cmp_out)
	5'b00001: begin o_current_floor = 3'b001; end
	5'b00010: begin o_current_floor = 3'b010; end
	5'b00100: begin o_current_floor = 3'b011; end
	5'b01000: begin o_current_floor = 3'b100; end
	5'b10000: begin o_current_floor = 3'b101; end
	default: begin o_current_floor = 3'b0; end
  endcase
end
endmodule
