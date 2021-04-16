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

	///Program variable
	reg controlledByComms = 0;
	reg [19:0] freqFromComms;
	reg [11:0] dutyFromComms;
	reg [1:0] program = 2'b00;

	///Frequency Default
	reg [19:0] startFreq = 20'h88B8; //Default freq is 35kHz
	reg [19:0] freq;
	reg [11:0] l = 12'hC8;
	wire freqAlgDone;
	wire [19:0] newFreq, bestFreq;

	///Meancurrent measurement
	reg measure;
	reg [19:0] measurementBuffer;
	wire [11:0] meanCurrent;
	wire getMeanCurrentData;

	///Data
	reg [15:0] SWIPT_P_TX = 16'b1001100110011001;
    reg [15:0] SWIPT_DUTY = 16'b1001100110011001;
    reg [15:0] SWIPT_FREQ = 16'b1001100110011001;
    reg [15:0] SWIPT_ASCII = 16'b1001100110011001;
    reg [15:0] ANC_MAX_HEIGHT = 16'b1001100110011001;
    reg [15:0] ANC_MIN_HEIGHT = 16'b1001100110011001;
    reg [15:0] COMMS_TRAJECT = 16'b1001100110011001;
    reg [15:0] COMMS_QR_CODES = 16'b1001100110011001;
    reg [15:0] COMMS_FLIGHT_TIME = 16'b1001100110011001;
	wire [7:0] RECEIVED_EFF, RECEIVED_POWER_RX;
//------END PARAM & VAR------//

	initial begin
		freq = startFreq;
		measurementBuffer = 20'hF4240;
		freqFromComms <= 0;
		dutyFromComms <= 0;
	end

	always @(posedge clk) begin
		if(~nrst || ~swiptAlive)begin
			program <= 2'b00;
			measurementBuffer <= 20'hF4240;
			freq <= startFreq;
			l <= 12'hC8;			
		end
		else if(controlledByComms)begin
			measurementBuffer <= 20'hF4240;
			freq <= freqFromComms;
			l <= dutyFromComms;
			program <= 2'b00;
		end
		else begin
			case (program)
				00: program <= 2'b01;
				01:begin //Freq optimization
					if(~freqAlgDone)begin
						freq <= newFreq;
					end
					else begin
						freq <= bestFreq;
						program <= 2'b10;
					end
				end
				10:begin //Measure Current
					if(measurementBuffer == 0)begin
						program <= 2'b11;
						measurementBuffer <= 20'hF4240;
						measure <= 0;
					end
					else begin
						measurementBuffer <= measurementBuffer - 1;
						measure <= 1;
					end
				end
				11:begin //Data & Power Optimization
					measure <= getMeanCurrentData;
				end
			endcase
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
		.program(program),
		.ADC(ADC_in),
		.freq(freq),
		.newFreq(newFreq),
		.bestFreq(bestFreq),
		.freqAlgDone(freqAlgDone)
	);

	GetMeanCurrent inst_getmeancurrent(
		.clk(clk),
		.nrst(nrst),
		.swiptAlive(swiptAlive),
		.measure(measure),
		.ADC(ADC_in),
		.mean_curr(meanCurrent)
	);

	Data inst_data(
		.clk(clk),
		.nrst(nrst),
		.swiptAlive(swiptAlive),
		.program(program),
		.ADC(ADC_in),
		.meanCurrent(meanCurrent),
		.SWIPT_P_TX(SWIPT_P_TX),
		.SWIPT_DUTY(SWIPT_DUTY),
		.SWIPT_FREQ(SWIPT_FREQ),
		.SWIPT_ASCII(SWIPT_ASCII),
		.ANC_MAX_HEIGHT(ANC_MAX_HEIGHT),
		.ANC_MIN_HEIGHT(ANC_MIN_HEIGHT),
		.COMMS_TRAJECT(COMMS_TRAJECT),
		.COMMS_QR_CODES(COMMS_QR_CODES),
		.COMMS_FLIGHT_TIME(COMMS_FLIGHT_TIME),
		.RECEIVED_EFF(RECEIVED_EFF),
		.RECEIVED_POWER_RX(RECEIVED_POWER_RX),
		.read(read),
		.write(write),
		.dout(dout),
		.l_rdy(l_rdy_data),
		.l_up_down(l_up_down_data),
		.getMeanCurrent(getMeanCurrentData)
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
