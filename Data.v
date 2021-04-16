`timescale 1ns/1ps

module Data (
	input wire clk,
	input wire nrst,
	input wire swiptAlive,
    input wire [1:0] program,
	input wire [11:0] ADC,
	input wire [11:0] meanCurrent,
    input wire [15:0] SWIPT_P_TX,
    input wire [15:0] SWIPT_DUTY,
    input wire [15:0] SWIPT_FREQ,
    input wire [15:0] SWIPT_ASCII,
    input wire [15:0] ANC_MAX_HEIGHT,
    input wire [15:0] ANC_MIN_HEIGHT,
    input wire [15:0] COMMS_TRAJECT,
    input wire [15:0] COMMS_QR_CODES,
    input wire [15:0] COMMS_FLIGHT_TIME,
    output reg [7:0] RECEIVED_EFF,
    output reg [7:0] RECEIVED_POWER_RX,
	output reg read,
	output reg write,
	output reg dout,
	output reg l_rdy,
	output reg l_up_down,
	output reg getMeanCurrent
	);
    
    wire din, dataInReady, checkSumBit;
    wire [7:0] dataIn, sumChecker;

    reg getDataFromZybo, readDataIn;
    reg [1:0] mode, type;
    reg [7:0]streamCounter;
    reg [15:0] dataFromZybo;
	reg [19:0] writeBuffer, blindBuffer, meanCurrentBuffer;
    reg [19:0] writeBuffer_default = 20'h30D40;
	reg [23:0] readBuffer; //2 500 000 clk cycli == 25ms wait time for answer
    reg [35:0] dataStream;

    `include "protocols.v"
    `include "taskData.v"

    initial begin
        mode = 2'b00;
        type = 2'b00;
        write = 0;
        read = 0;
        dataStream = 36'b0;
        streamCounter = 8'h23;
        getMeanCurrent = 0;
        dout = 0;
        writeBuffer = 20'h30D40;
        readBuffer = 24'h989680;
        blindBuffer = 20'hF4240;
        meanCurrentBuffer = 20'hF4240;
        readDataIn = 0;
        GetDataFromZybo;
    end


    always @(posedge clk) begin
        if(~nrst || ~swiptAlive || program != 2'b11)begin
            mode <= 2'b00;
            type <= 2'b00;
            getDataFromZybo <= 0;
            write <= 0;
            read <= 0;
            streamCounter <= 8'h23;
            getMeanCurrent <= 0;
            dout <= 0;
        end
        else if(getDataFromZybo) begin
            readDataIn <= 0;
            l_rdy <= 0;
            write <= 1;
            read <= 0;
            streamCounter <= 8'h23;
            GetDataFromZybo;
        end
        else if(write && writeBuffer == 0)begin
            dataStream <= {6'b101010, mode, type, dataFromZybo, ^dataFromZybo, 4'b0101};
            dout <= dataStream[streamCounter];
            writeBuffer <= writeBuffer_default;
            getMeanCurrent <= 0;
			NextBitWrite;
        end
        else if(write)begin
            writeBuffer <= writeBuffer - 1;
            getMeanCurrent <= 0;
        end
        else if(read && readBuffer == 0)begin
            readDataIn <= 0;
            getDataFromZybo <= 1;
            blindBuffer <= 20'hF4240;
            readBuffer <= 24'h989680;
            ProcessIncomingData;
        end
        else if(read)begin
            readBuffer <= readBuffer - 1;
            
            if(dataInReady)begin
                readDataIn <= 0;
                getDataFromZybo <= 1;
                blindBuffer <= 20'hF4240;
                readBuffer <= 24'h989680;
                ProcessIncomingData;
            end

            if(blindBuffer == 20'b0)begin
                readDataIn <= 1;
            end
            else begin
                blindBuffer <= blindBuffer - 1;
            end
		end      
    end


    ReadData inst_readdata(
        .clk (clk),
		.nrst (nrst),
	    .swiptAlive (swiptAlive),
        .program(program),
        .readDataIn (readDataIn),
        .ADC (ADC),
        .mean_def (meanCurrent),
        .din (din)
    );

    AnalyseData inst_analysedata(
        .clk(clk),
        .nrst(nrst),
        .swiptAlive(swiptAlive),
        .program(program),
        .readDataIn(readDataIn),
        .din(din),
        .mode(mode),
        .type(type),
        .dataInReady(dataInReady),
        .dataIn(dataIn),
        .sumChecker(sumChecker),
        .checkSumBit(checkSumBit)
    );


endmodule