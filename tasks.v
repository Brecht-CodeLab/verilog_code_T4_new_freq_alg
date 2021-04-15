`timescale 1ps/1ps

task UpdateFreq();
    if(freqAlgStarted == 1 && freq < 20'hAFC8)begin
        newFreq <= freq + 20'h32;
    end
    else if (freq > 20'hAFC7) begin
        freqAlgDone <= 1;
    end
    else begin
        newFreq <= 20'h88B8; //35kHz
        freqAlgStarted <= 1;
    end
endtask


task CheckHighestADC();
    if(ADC < 12'h800 && ADC > highest)begin
        highest <= ADC;
        bestFreq <= freq;
    end
    else if(ADC >= 12'h800 && 12'hFFF - ADC > highest)begin
        highest <= 12'hFFF - ADC;
        bestFreq <= freq;
    end
endtask