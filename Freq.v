`timescale 1ps/1ps

module Freq(
    input wire clk,
    input wire nrst,
    input wire swiptAlive,
    input wire freqAlgGo,
    input wire [11:0] ADC,
    input wire [19:0] freq,

    output reg [19:0] newFreq,
    output reg [19:0] bestFreq,
    output reg freqAlgDone
);
    
    reg [23:0] startupBuffer, freqSwitchBuffer;
    reg [11:0] highestADC;
    reg freqAlgStarted;


    initial begin
        startupBuffer = 24'h30D40; //2ms
        freqSwitchBuffer = 24'h30D40; //2ms
        newFreq = freq;
        bestFreq = freq;
        highestADC = 12'h0;
        freqAlgStarted = 0;
        freqAlgDone = 0;
    end
    
    `include "tasks.v"

    always @(posedge clk) begin
        if (~nrst || ~swiptAlive) begin
            startupBuffer <= 24'h30D40;
            freqSwitchBuffer <= 24'h30D40;
            newFreq <= freq;
            bestFreq <= freq;
            highestADC <= 12'h0;
            freqAlgStarted <= 0;
            freqAlgDone <= 0;
        end
        else if (~freqAlgGo) begin
            startupBuffer <= 24'h30D40;
            freqSwitchBuffer <= 24'h30D40;
            newFreq <= freq;
            bestFreq <= freq;
            highestADC <= 12'h0;
            freqAlgStarted <= 0;
        end
        else if (startupBuffer == 0) begin
            if (freqSwitchBuffer == 0) begin
                freqSwitchBuffer <= 24'h30D40;
                UpdateFreq(freqAlgStarted, freq, freqAlgDone, newFreq);
            end
            else begin
                freqSwitchBuffer <= freqSwitchBuffer - 1;
            end
            CheckHighestADC(ADC, freq, bestFreq, highestADC);
        end
        else begin
            startupBuffer <= startupBuffer - 1;
        end
    end
endmodule