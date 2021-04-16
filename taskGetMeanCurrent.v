task GetMeanCurrentTask;
    if(clk_cycles == 20'h0)begin
        clk_cycles <= 20'h9C40;
        highest <= 20'h0;
        numberMeasurements <= numberMeasurements + 1;
        mean_curr_reg <= ((numberMeasurements*mean_curr_reg)+(highest))/(numberMeasurements + 1);
    end
    else begin
        clk_cycles <= clk_cycles - 1;
        if(ADC < 12'h800 && ADC > highest)begin
            highest <= ADC;
        end
        else if(ADC >= 12'h800 && 12'hFFF - ADC > highest)begin
            highest <= 12'hFFF - ADC;
        end
    end
endtask