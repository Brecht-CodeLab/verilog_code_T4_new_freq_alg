`include "protocols.v"

task UpdateFreq;
    if(freqAlgStarted == 1'b1 && freq < 20'hA7F8)begin
        $display("frequency upgrade");
        newFreq <= freq + 20'h32;
    end
    else if (freq > 20'hA7F7) begin
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


task NextBitWrite;
    if (streamCounter == 0)begin
        write <= 0;
        read <= 1;
        streamCounter <= 8'h23;
    end
    else begin
        streamCounter <= streamCounter - 1;
    end
endtask


task ProcessIncomingData;
    case (mode)
        00:begin //Startup & questions
            case (type)
                00:StartupProtocol;
                01:StoreAnswerIfCorrectProtocol; //Store answer eff
                10:StoreAnswerIfCorrectProtocol; //Store answer R power
                11:PowerOptimizationProtocol;
            endcase
        end
        01:case (type)
            00:DataSuccessfullySentAndReceivedProtocol;
            01:DataSuccessfullySentAndReceivedProtocol;
            10:DataSuccessfullySentAndReceivedProtocol;
            11:DataSuccessfullySentAndReceivedProtocol;
        endcase
        10:case (type)
            00:DataSuccessfullySentAndReceivedProtocol;
            01:DataSuccessfullySentAndReceivedProtocol;
            10:DataSuccessfullySentAndReceivedProtocol;
            11:DataSuccessfullySentAndReceivedProtocol;
        endcase
        11:case (type)
            00:DataSuccessfullySentAndReceivedProtocol;
            01:DataSuccessfullySentAndReceivedProtocol;
            10:DataSuccessfullySentAndReceivedProtocol;
            11:DataSuccessfullySentAndReceivedProtocol;
        endcase
    endcase
endtask


task GetDataFromZybo;
    if(meanCurrentBuffer == 0 && getMeanCurrent)begin
        meanCurrentBuffer <= 20'hF4240;
        getMeanCurrent <= 0;
        getDataFromZybo <= 0;
    end
    else if(getMeanCurrent) begin
        meanCurrentBuffer <= meanCurrentBuffer - 1;
        getMeanCurrent <= 1;
    end
    else begin
        getDataFromZybo <= 0;
        getMeanCurrent <= 0;
    end

    case (mode)
        00:dataFromZybo <= 16'b1010101010101010;
        01:begin
            case (type)
                00:dataFromZybo <= SWIPT_P_TX;
                01:dataFromZybo <= SWIPT_DUTY;
                10:dataFromZybo <= SWIPT_FREQ;
                11:dataFromZybo <= SWIPT_ASCII;
                default:dataFromZybo <= 16'b1010101010101010;
            endcase
        end
        10:begin
            case (type)
                00:dataFromZybo <= ANC_MAX_HEIGHT;
                01:dataFromZybo <= ANC_MIN_HEIGHT;
                10:dataFromZybo <= 16'b1010101010101010;
                11:dataFromZybo <= 16'b1010101010101010;
                default:dataFromZybo <= 16'b1010101010101010;
            endcase
        end
        11:begin
            case (type)
                00:dataFromZybo <= COMMS_TRAJECT;
                01:dataFromZybo <= COMMS_QR_CODES;
                10:dataFromZybo <= COMMS_FLIGHT_TIME;
                11:dataFromZybo <= 16'b1010101010101010;
                default:dataFromZybo <= 16'b1010101010101010;
            endcase
        end
        default:dataFromZybo <= 16'b1010101010101010;
    endcase
endtask


task AnswerToQuestion;
    if((dataStreamIn[35:30] == 6'b101010) && (dataStreamIn[3:0] == 4'b0101))begin
        dataInReady <= 1;
        dataIn <= {dataStreamIn[20], dataStreamIn[18], dataStreamIn[16], dataStreamIn[14], dataStreamIn[12], dataStreamIn[10], dataStreamIn[8], dataStreamIn[6]}
        checkSumBit <= dataStreamIn[4];
    end
    else begin
        dataInReady <= 0;
    end
endtask

task DataReceivedConfirmation;
    if(sumChecker == 8'b11)begin
        dataInReady <= 1;
    end
endtask