`timescale 1ps/1ps


module toplevel ();
//------BEGIN SETUP------//
	//--GIVEN INPUTS AND OUTPUTS (for now they are not perfectly right)--//
	reg clk = 2'b1;
	reg nrst = 1'b0;
	reg swiptONHeartbeat = 1'b1;
	wire [11:0] ADC_in;


	wire SWIPT_OUT0;
	wire SWIPT_OUT1;
	wire SWIPT_OUT2;
	wire SWIPT_OUT3;
	//--GIVEN INPUTS AND OUTPUTS (for now they are not perfectly right)--//

	//--DEFINITION OF CLK, NRST AND SWIPTONHEARTBEAT--//
	always #5000 clk = ~clk;
	always #900000 swiptONHeartbeat <= ~swiptONHeartbeat;

	// Reset
	initial begin
		#1000000000 nrst = 1'b1;
	end	
	//--DEFINITION OF CLK, NRST AND SWIPTONHEARTBEAT--//

//------END SETUP------//

//------BEGIN PARAM & VAR------//
	///Parameters for algorithms given by TA's///
	wire swiptAlive;
	
	///ADC_in
	wire ADC0;
	wire ADC1;
	wire ADC2;
	wire ADC3;
	wire ADC4;
	wire ADC5;
	wire ADC6;
	wire ADC7;
	wire ADC8;
	wire ADC9;
	wire ADC10;
	wire ADC11;

	///Frequency Default
	reg [19:0] freq = 20'h9C40; //Default freq is 40kHz
	reg [11:0] l = 12'hC8;
	reg freqAlgGo = 0;
	wire freqAlgDone;
	wire [19:0] newFreq, bestFreq;	
//------END PARAM & VAR------//	

	always @(posedge clk) begin
		if(swiptAlive && nrst && ~freqAlgDone)begin
			freqAlgGo <= 1;
			freq <= newFreq;
		end
		else if (swiptAlive && nrst && freqAlgDone) begin
			freqAlgGo <= 0;
			freq <= bestFreq;
		end
		else begin
			freqAlgGo <= 0;
			freq <= 20'h9C40;
		end
	end
	
//------BEGIN MODULES------//
	//set swipt alive
	Heartbeat inst_heartbeat (
			.clk (clk),
			.nrst (nrst),
			.swiptONHeartbeat (swiptONHeartbeat),
			.swipt (swiptAlive)
			);

	SwiptOut inst_swiptout (
			.clk (clk),
			.nrst (nrst),
			.freq (freq),
			.l (l),
			.SWIPT_OUT0 (SWIPT_OUT0),
			.SWIPT_OUT1 (SWIPT_OUT1),
			.SWIPT_OUT2 (SWIPT_OUT2),
			.SWIPT_OUT3 (SWIPT_OUT3)
			);

	
	ANALOG_NETWORK inst_ANALOG_NETWORK (
			.SWIPT_OUT0	(SWIPT_OUT0),
			.SWIPT_OUT1	(SWIPT_OUT1),
			.SWIPT_OUT2 (SWIPT_OUT2),
			.SWIPT_OUT3 (SWIPT_OUT3),
			.ACOUT0 (ADC11),
			.ACOUT1 (ADC10),
			.ACOUT2 (ADC9),
			.ACOUT3 (ADC8),
			.ACOUT4 (ADC7),
			.ACOUT5 (ADC6),
			.ACOUT6 (ADC5),
			.ACOUT7 (ADC4),
			.ACOUT8 (ADC3),
			.ACOUT9 (ADC2),
			.ACOUT10 (ADC1),
			.ACOUT11 (ADC0)
			);

	Freq inst_freq(
		.clk(clk),
		.nrst(nrst),
		.swiptAlive(swiptAlive),
		.freqAlgGo(freqAlgGo),
		.ADC(ADC_in),
		.freq(freq),
		.newFreq(newFreq),
		.bestFreq(bestFreq),
		.freqAlgDone(freqAlgDone)
	);


//------END MODULES------//

//------BEGIN ASSIGNMENT------//

	assign ADC_in[11] = ADC11;
	assign ADC_in[10] = ADC10;
	assign ADC_in[9] = ADC9;
	assign ADC_in[8] = ADC8;
	assign ADC_in[7] = ADC7;
	assign ADC_in[6] = ADC6;
	assign ADC_in[5] = ADC5;
	assign ADC_in[4] = ADC4;
	assign ADC_in[3] = ADC3;
	assign ADC_in[2] = ADC2;
	assign ADC_in[1] = ADC1;
	assign ADC_in[0] = ADC0;

//------END ASSIGNMENT------//
endmodule
