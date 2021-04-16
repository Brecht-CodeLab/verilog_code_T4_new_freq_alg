`timescale 1ps/1ps

module GetMeanCurrent (
	input wire clk,
	input wire nrst,
	input wire swiptAlive,
	input wire measure,
	input wire [11:0] ADC,
	output reg [11:0] mean_curr
	);
	///Description
	//In this module, the mean current mesurement over x ms is given;
	//-----------------------
	reg [15:0] numberMeasurements = 0;
	reg [19:0] clk_cycles = 20'h9C40;
	reg [11:0] highest = 20'h0;
	reg [11:0] mean_curr_reg = 12'h0;
	
	`include "taskGetMeanCurrent.v"

	always @(posedge clk)begin
		if(~nrst || ~swiptAlive)begin
			numberMeasurements <= 0;
			clk_cycles <= 20'h9C40;
			highest <= 20'h0;
			mean_curr_reg <= 11'h0;
			mean_curr <= 0;
		end
		else if(measure)begin
			GetMeanCurrentTask;
			mean_curr <= mean_curr_reg;
		end
		else begin
			highest <= 11'h0;
			mean_curr_reg <= 11'h0;
		end
	end
endmodule

