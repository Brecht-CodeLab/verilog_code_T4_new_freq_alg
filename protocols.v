task StartupProtocol;
    if (sumChecker == 8'b11) begin
        //Succes
        type <= 11;
    end
    else if (sumChecker == 8'b0) begin
        //Need more power
        l_up_down <= 1;
        l_rdy <= 1;
        getMeanCurrent <= 1;
    end
    //Else: Something went wrong, send again
endtask


task PowerOptimizationProtocol;
    if (sumChecker == 8'b11) begin
        //Succes --> there is enough power
        mode <= 01;
        type <= 00;
    end
    else if (sumChecker == 8'b0) begin
        //Need more power
        l_up_down <= 1;
        l_rdy <= 1;
        getMeanCurrent <= 1;
    end
    else if(sumChecker == 8'b1) begin
        l_up_down <= 0;
        l_rdy <= 1;
        getMeanCurrent <= 1;
    end
    //Else: Something went wrong, send again
endtask


task DataSuccessfullySentAndReceivedProtocol;
    if (sumChecker == 8'b11) begin
        //Succes --> there is enough power
        if(mode == 2'b11 && type == 2'b11)begin
            mode <= 2'b00;
            type <= 2'b01;
        end
        else if (type == 2'b11) begin
            mode <= mode + 2'b01;
            type <= 2'b00;
        end
        else begin
            type <= type + 2'b01;
        end
    end
    //Else: Something went wrong, send again
endtask


task StoreAnswerIfCorrectProtocol;
    if(^dataIn == checkSumBit)begin
        case (type)
            01:begin
                RECEIVED_EFF <= dataIn;
                type <= 2'b10;
            end
            10:begin
                RECEIVED_POWER_RX <= dataIn;
                type <= 2'b00;
                mode <= 2'b01;
            end
        endcase
    end
endtask