`timescale 1ps/1ps

module Freq(
    input wire clk,
    input wire nrst,
    input wire swiptAlive,
    input wire [1:0] program,
    input wire [11:0] ADC,
    input wire [19:0] freq,

    output reg [19:0] newFreq,
    output reg [19:0] bestFreq,
    output reg [0:0] freqAlgDone
);
    
    reg [23:0] startupBuffer, freqSwitchBuffer;
    reg [11:0] highestADC;
    reg [0:0] freqAlgStarted;


    initial begin
        startupBuffer = 24'h30D40; //2ms
        freqSwitchBuffer = 24'h186A0; //1ms
        newFreq = freq;
        bestFreq = freq;
        highestADC = 12'h0;
        freqAlgStarted = 1'b0;
        freqAlgDone = 1'b0;
    end
    
    `include "tasks.v"

    always @(posedge clk) begin
        if (~nrst || ~swiptAlive) begin
            startupBuffer <= 24'h30D40;
            freqSwitchBuffer <= 24'h186A0;
            newFreq <= freq;
            bestFreq <= freq;
            highestADC <= 12'h0;
            freqAlgStarted <= 1'b0;
            freqAlgDone <= 1'b0;
        end
        else if (program != 2'b01) begin
            startupBuffer <= 24'h30D40;
            freqSwitchBuffer <= 24'h186A0;
            newFreq <= freq;
            bestFreq <= freq;
            highestADC <= 12'h0;
            freqAlgStarted <= 1'b0;
        end
        else if (startupBuffer == 0) begin
            if (freqSwitchBuffer == 0) begin
                freqSwitchBuffer <= 24'h186A0;
                UpdateFreq;
                freqAlgStarted <= 1'b1;
            end
            else begin
                freqSwitchBuffer <= freqSwitchBuffer - 1;
            end
            CheckHighestADC;
        end
        else begin
            startupBuffer <= startupBuffer - 1;
        end
    end
endmodule