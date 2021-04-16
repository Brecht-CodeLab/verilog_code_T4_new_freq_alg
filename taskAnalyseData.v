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