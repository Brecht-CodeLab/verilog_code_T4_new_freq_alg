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
	reg [19:0] startFreq = 20'h9470; //Default freq is 36kHz
	reg [19:0] freq;
	reg [11:0] l = 12'hC8; //Default duty
	wire freqAlgDone;
	wire [19:0] newFreq, bestFreq;

	///Meancurrent measurement
	reg measure;
	reg [23:0] measurementBuffer;
	wire [11:0] meanCurrent;
	wire getMeanCurrentData;

	///Data
	wire read, write, dout;
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
	wire [11:0] dutyCycle;
	wire dutyUpDownDataReady, dutyUpDownData;
//------END PARAM & VAR------//

	initial begin
		freq = startFreq;
		measurementBuffer = 23'h6ACFC0;
		freqFromComms <= 0;
		dutyFromComms <= 0;
		measure <= 0;
	end

	always @(posedge clk) begin
		if(~nrst || ~swiptAlive)begin
			program <= 2'b00;
			measurementBuffer <= 23'h6ACFC0;
			freq <= startFreq;
			l <= 12'hC8;
			measure <= 0;		
		end
		else if(controlledByComms)begin
			measurementBuffer <= 23'h6ACFC0;
			freq <= freqFromComms;
			l <= dutyFromComms;
			program <= 2'b00;
			measure <= 0;
		end
		else begin
			case (program)
				2'b00: program <= 2'b01;
				2'b01:begin //Freq optimization
					$display("this is freq zone");
					if(~freqAlgDone)begin
						freq <= newFreq;
					end
					else begin
						freq <= bestFreq;
						program <= 2'b10;
					end
				end
				2'b10:begin //Measure Current
					$display("we are now in the measurement zone");
					if(measurementBuffer == 0)begin
						program <= 2'b11;
						measurementBuffer <= 23'h6ACFC0;
						measure <= 0;
						$display("this should be the last one");
					end
					else if(measurementBuffer < 23'h1E8480) begin
						measurementBuffer <= measurementBuffer - 1;
						measure <= 1;
						$display("this should be the middle one");
					end
					else begin
						measurementBuffer <= measurementBuffer - 1;
						measure <= 0;
						$display("this should be the first one");
					end
				end
				2'b11:begin //Data & Power Optimization
					$display("this is data zone");
					measure <= getMeanCurrentData;
					if(dutyUpDownDataReady)begin
						case (dutyUpDownData)
							1'b1:begin
								if((l+l/10)<12'h1F4)begin
									l <= l+(l/10);
								end
								else begin
									l <= 12'h1F4;
								end
							end
							1'b0:begin
								if((l-l/10)>12'h32)begin
									l <= l-(l/10);
								end
								else begin
									l <= 12'h32;
								end
							end
							default:l<=l;
						endcase
					end
				end
				default:program<=2'b00;
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
		.l (dutyCycle),
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
		.l_rdy(dutyUpDownDataReady),
		.l_up_down(dutyUpDownData),
		.getMeanCurrent(getMeanCurrentData)
	);

	DutyAdjust inst_dutyadjust(
		.clk(clk),
		.nrst(nrst),
		.swiptAlive(swiptAlive),
		.program(program),
		.read(read),
		.write(write),
		.data(dout),
		.l(l),
		.dutyCycle(dutyCycle)
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
