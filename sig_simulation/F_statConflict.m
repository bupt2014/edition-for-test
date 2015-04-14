function [ statConflict ] = F_statConflict( timeTable, conflictNum )
    % 统计冲突信号的信息
    % timeTable: 发送小区编号，发送船号，发送时间，在有船小区中编号
    % conflictNum: n重冲突
    % statConflict: 记录冲突船舶信息（冲突信号发送小区编号，冲突信号发送船号，冲突信号发送时间，冲突信号船号在有船小区中的小区编号）
    global vHeight vTime vVesNum vEbNo 
%     conflictNum = 2;
%     测试用
%     vHeight = 600;
%     vTime = 12;
%     vVesNum = 50; 
%     vEbNo = 20;
    conflictPath = './staConflict/';
    
%     AISDataPath = './AISData/AISData_h600_t12_v14_e20.mat';
%     load(AISDataPath);
    sigLen = 228;        %没有抽样前信号的长度
    [timeTableRow, timeTableCol] = size(timeTable);
    recordRow = 1;           %标记冲突从第几行开始写入
    for row = 1: 1: timeTableRow
        [conflictRow, conflictCol] = find(abs(timeTable(:, 3) - timeTable(row, 3)) < sigLen);
        [conflictRowNum, col] = size(conflictRow);
        if conflictRowNum == conflictNum
            statConflict(recordRow, :) = timeTable(row, :);
            recordRow = recordRow + 1;
        end
    end
    
    fileName = ['AISConflict_', sprintf('h%d_t%d_v%d_e%d', vHeight, vTime, vVesNum, vEbNo), '.mat'];
    conflictDirPath = [conflictPath, '/' ,sprintf('AISConflict_h%d_t%d_v%d_e%d', vHeight, vTime, vVesNum, vEbNo)];
    mkdir(conflictDirPath);
    save([conflictDirPath, '/', fileName], 'statConflict', 'conflictNum');
end

