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
    end
endtask