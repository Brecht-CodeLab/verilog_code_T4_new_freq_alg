task UpdateFreq;
    if(freqAlgStarted == 1'b1 && freq < 20'hA410)begin
        $display("frequency upgrade");
        newFreq <= freq + 20'h32;
    end
    else if (freq > 20'hA40F) begin
        freqAlgDone <= 1;
        newFreq <= freq;
        $display("we're done");
    end
    else begin
        newFreq <= 20'h88B8; //35kHz
        freqAlgDone <= 0;
        $display("start freq opt");
    end
endtask


task CheckHighestADC;
    if(ADC < 12'h800 && ADC > highestADC && freqAlgStarted)begin
        highestADC <= ADC;
        bestFreq <= freq;
    end
    else if(ADC >= 12'h800 && 12'hFFF - ADC > highestADC && freqAlgStarted)begin
        highestADC <= 12'hFFF - ADC;
        bestFreq <= freq;
    end
endtask 