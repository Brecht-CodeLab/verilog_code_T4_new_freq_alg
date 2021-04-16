`timescale 1ps/1ps

module DutyAdjust(
    input wire clk,
	input wire nrst,
	input wire swiptAlive,
    input wire [1:0] program,
    input wire read,
    input wire write,
    input wire data,
    input wire [11:0] l,
    output reg [11:0] dutyCycle,
);
    reg [19:0] cnt_pos_d = 20'h0;
	reg [19:0] cnt_neg_d = 20'h0;

	always @(posedge data)begin
		cnt_pos_d <= 20'h3000;
		cnt_neg_d <= 0;
	end

	always @(negedge data)begin
		cnt_pos_d <= 0;
		cnt_neg_d <= 20'h3000;
	end

    always @(posedge clk) begin
        if(~nrst || ~swiptAlive)begin
            
        end
        else begin
            case (program)
                00:dutyCycle<=l;
                01:dutyCycle<=l;
                10:dutyCycle<=l;
                11:begin
                    if(write && ~read)begin
                        case (data)
                            0:begin
								if(cnt_pos_d == 20'h0)begin
                                    if((l+l/2) < 20'h1F4)begin
                                        dutyCycle <= l+l/2;
                                    end
                                    else if((l+l/3) < 20'h1F4)begin
                                        dutyCycle <= l+l/3;
                                    end
                                    else if((l+l/4) < 20'h1F4)begin
                                        dutyCycle <= l+l/4;
                                    end
                                    else begin
                                        dutyCycle <= 20'h1F4;
                                    end
                                end
                                else begin
                                    cnt_pos_d <= cnt_pos_d - 1;
                                    dutyCycle <= 20'h1F4;
                                end
                                
							end
                            1:begin
                                if(cnt_neg_d == 20'h0)begin
                                    if(20'h1F4 - l < l/5)begin
                                        dutyCycle <= 2*l - 20'h1F4;
                                    end
                                    else begin
                                        dutyCycle <= l/3; 
                                    end
                                end
                                else begin
                                    cnt_neg_d <= cnt_neg_d - 1;
                                    dutyCycle <= 20'h0;
                                end
                            end
                            default:dutyCycle <= l;
                        endcase
                    end
                    else dutyCycle <= l;
                end
                default:dutyCycle<=l;
            endcase
        end
    end
endmodule