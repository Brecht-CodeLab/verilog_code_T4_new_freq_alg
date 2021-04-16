`timescale 1ps/1ps

module UnderstandData (
	input wire clk,
	input wire nrst,
    input wire swiptAlive,
    input wire [1:0] program,
    input wire readDataIn,
    input wire din,
    input wire [1:0] mode,
    input wire [1:0] type,
    output reg dataInReady,
    output reg [7:0] dataIn,
    output reg [7:0] sumChecker,
    output reg checkSumBit
);
    reg startReadOut;
    reg [19:0] counter;
    reg [35:0] dataStreamIn;

    initial begin
        startReadOut = 0;
        dataIn = 8'b0;
        counter = 20'h186A0;
        dataStreamIn = 36'h0;
        sumChecker = 8'h0;
        checkSumBit = 0;
    end
    
    `include "taskAnalyseData.v"

    always @(posedge clk) begin
        if(~nrst || ~swiptAlive || program != 2'b11 || ~readDataIn)begin
            startReadOut <= 0;
            dataIn <= 36'b0;
            counter <= 20'h186A0;
            dataStreamIn <= 36'h0;
            sumChecker <= 8'h0;
            checkSumBit <= 0;
        end
        else if(startReadOut && counter == 0)begin
            dataStreamIn <= {dataStreamIn << 1} + din;
            counter <= 20'h30D40;
            sumChecker <= sumChecker + din;
        end
        else if (startReadOut) begin
            counter <= counter - 1;
        end

        case (mode)
            00:case (type)
                00:DataReceivedConfirmation;
                01:AnswerToQuestion;
                10:AnswerToQuestion;
                11:DataReceivedConfirmation;
            endcase
            01:DataReceivedConfirmation;
            10:DataReceivedConfirmation;
            11:DataReceivedConfirmation;
        endcase
    end

    always @(posedge din or negedge readDataIn) begin
        if(~readDataIn)begin
            startReadOut <= 0;
        end
        else if (readDataIn && din) begin
            startReadOut <= 1;
        end
    end
endmodule