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
        2'b00:begin //Startup & questions
            case (type)
                2'b00:StartupProtocol;
                2'b01:StoreAnswerIfCorrectProtocol; //Store answer eff
                2'b10:StoreAnswerIfCorrectProtocol; //Store answer R power
                2'b11:PowerOptimizationProtocol;
            endcase
        end
        2'b01:case (type)
            2'b00:DataSuccessfullySentAndReceivedProtocol;
            2'b01:DataSuccessfullySentAndReceivedProtocol;
            2'b10:DataSuccessfullySentAndReceivedProtocol;
            2'b11:DataSuccessfullySentAndReceivedProtocol;
        endcase
        2'b10:case (type)
            2'b00:DataSuccessfullySentAndReceivedProtocol;
            2'b01:DataSuccessfullySentAndReceivedProtocol;
            2'b10:DataSuccessfullySentAndReceivedProtocol;
            2'b11:DataSuccessfullySentAndReceivedProtocol;
        endcase
        2'b11:case (type)
            2'b00:DataSuccessfullySentAndReceivedProtocol;
            2'b01:DataSuccessfullySentAndReceivedProtocol;
            2'b10:DataSuccessfullySentAndReceivedProtocol;
            2'b11:DataSuccessfullySentAndReceivedProtocol;
        endcase
        default:DataSuccessfullySentAndReceivedProtocol;
    endcase
endtask


task GetDataFromZybo;
    if(meanCurrentBuffer == 0 && getMeanCurrent)begin
        meanCurrentBuffer <= 20'hF4240;
        getMeanCurrent <= 0;
        getDataFromZybo <= 1;
        write <= 0;
    end
    else if(getMeanCurrent) begin
        meanCurrentBuffer <= meanCurrentBuffer - 1;
        getMeanCurrent <= 1;
        getDataFromZybo <= 1;
        write <= 0;
    end
    else begin
        getDataFromZybo <= 0;
        getMeanCurrent <= 0;
        write <= 1;
        case (mode)
            2'b00:dataFromZybo <= 16'b1010101010101010;
            2'b01:begin
                case (type)
                    2'b00:dataFromZybo <= SWIPT_P_TX;
                    2'b01:dataFromZybo <= SWIPT_DUTY;
                    2'b10:dataFromZybo <= SWIPT_FREQ;
                    2'b11:dataFromZybo <= SWIPT_ASCII;
                    default:dataFromZybo <= 16'b1010101010101010;
                endcase
            end
            2'b10:begin
                case (type)
                    2'b00:dataFromZybo <= ANC_MAX_HEIGHT;
                    2'b01:dataFromZybo <= ANC_MIN_HEIGHT;
                    2'b10:dataFromZybo <= 16'b1010101010101010;
                    2'b11:dataFromZybo <= 16'b1010101010101010;
                    default:dataFromZybo <= 16'b1010101010101010;
                endcase
            end
            2'b11:begin
                case (type)
                    2'b00:dataFromZybo <= COMMS_TRAJECT;
                    2'b01:dataFromZybo <= COMMS_QR_CODES;
                    2'b10:dataFromZybo <= COMMS_FLIGHT_TIME;
                    2'b11:dataFromZybo <= 16'b1010101010101010;
                    default:dataFromZybo <= 16'b1010101010101010;
                endcase
            end
            default:dataFromZybo <= 16'b1010101010101010;
        endcase
    end
endtask