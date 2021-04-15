task UpdateFreq;
    if(freqAlgStarted == 1'b1 && freq < 20'hAFC8)begin
        $display("this is the wrong one");
        newFreq <= freq + 20'h32;
    end
    else if (freq > 20'hAFC7) begin
        freqAlgDone <= 1;
        newFreq <= freq;
        $display("this is definitely not the right one");
    end
    else begin
        newFreq <= 20'h88B8; //35kHz
        freqAlgDone <= 0;
        $display("this is the right one");
    end
    //$display("UPDATEFREQ");
endtask


task CheckHighestADC;
    if(ADC < 12'h800 && ADC > highestADC)begin
        highestADC <= ADC;
        bestFreq <= freq;
    end
    else if(ADC >= 12'h800 && 12'hFFF - ADC > highestADC)begin
        highestADC <= 12'hFFF - ADC;
        bestFreq <= freq;
    end
endtask 

