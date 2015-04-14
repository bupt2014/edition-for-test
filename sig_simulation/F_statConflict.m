function [ statConflict ] = F_statConflict( timeTable, conflictNum )
    % ͳ�Ƴ�ͻ�źŵ���Ϣ
    % timeTable: ����С����ţ����ʹ��ţ�����ʱ�䣬���д�С���б��
    % conflictNum: n�س�ͻ
    % statConflict: ��¼��ͻ������Ϣ����ͻ�źŷ���С����ţ���ͻ�źŷ��ʹ��ţ���ͻ�źŷ���ʱ�䣬��ͻ�źŴ������д�С���е�С����ţ�
    global vHeight vTime vVesNum vEbNo 
%     conflictNum = 2;
%     ������
%     vHeight = 600;
%     vTime = 12;
%     vVesNum = 50; 
%     vEbNo = 20;
    conflictPath = './staConflict/';
    
%     AISDataPath = './AISData/AISData_h600_t12_v14_e20.mat';
%     load(AISDataPath);
    sigLen = 228;        %û�г���ǰ�źŵĳ���
    [timeTableRow, timeTableCol] = size(timeTable);
    recordRow = 1;           %��ǳ�ͻ�ӵڼ��п�ʼд��
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

