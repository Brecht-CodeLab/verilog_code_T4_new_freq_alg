task UpdateFreq(input freqAlgStarted, input [19:0] freq, output freqAlgDone, output [19:0] newFreq);
    if(freqAlgStarted == 1 && freq < 20'hAFC8)begin
        $display("this is the wrong one");
        newFreq <= freq + 20'h32;
        freqAlgDone <= 0;
    end
    else if (freq > 20'hAFC7) begin
        freqAlgDone <= 1;
        newFreq <= freq;
    end
    else begin
        freqAlgDone <= 0;
        newFreq <= 20'h88B8; //35kHz
        $display("this is the right one");

    end
endtask


task CheckHighestADC(input [11:0] ADC, input [19:0] freq, output [19:0] bestFreq, inout [11:0] highestADC);
    if(ADC < 12'h800 && ADC > highestADC)begin
        highestADC <= ADC;
        bestFreq <= freq;
    end
    else if(ADC >= 12'h800 && 12'hFFF - ADC > highestADC)begin
        highestADC <= 12'hFFF - ADC;
        bestFreq <= freq;
    end
endtask 

