function test
    clear;
%     clc;
    close all;
	tic;
    global GenSigNum ConflictNum ratio channel_num vHeight vVesNum vTime vEbNo vPath sateHeight sateLon stateSize earthR nmile2km sateLat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    参数设置(可自定义修改参数)
    GenSigNum = 10; %   产生的总的信号的个数
                    %   此处的信号是各种信号的叠加
    ConflictNum = 2;    %   此处表示的是当前信号中包含的是几重冲突
    ratio = 0.4;    %   占空比： 此处表示的是冲突的信号占产生的信号的比值
                    %   （如： 总共产生了10 个信号， 其中有 4 个信号是冲突信号，那么占空比就是 0.4）
    channel_num = 2;    %   信道数，关系到接收的信号数目
    vEbNo = 20;   %   信噪比
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       以下参数不可修改
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%变量赋值%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sateHeight = 600;              %卫星高度
    sateLon = 102;                 %卫星经度
    sateLat = 31.8029;             %卫星纬度
    stateSize = 40;                %一个小区的边长为40海里
    earthR = 6371;                 %地球半径
    nmile2km = 1.852;              %Km跟海里转换       
    resultPath = './AISSig_s';
    vTime = [12];                 %观测时间  只是为了文件名统一
	vVesNum = GenSigNum;               %船舶数量
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    F_initPar;
    vHeight = sateHeight;
    vPath = resultPath;
%     vPath1 = modelPath;
            %F_genParameter里面有测试用的数据，实际生成信号时需要修改
            [areas, parTable, realVesNum] = F_genParameter(vHeight, vVesNum);		% areas为船舶分布矩阵, parTable为各船舶参数表, vesNum为实际船舶数量
            [aisData, zeroNum] = F_genAISData(realVesNum);					        % aisData为各船舶发送的二进制信息
            timeTable = F_genTimeTable(areas, parTable(:, 3), vHeight);		% timeTable为各帧信号的发送时间
            statConflict  = F_statConflict( timeTable, ConflictNum );
            F_genAISSig(aisData, zeroNum, parTable, timeTable, vTime, vPath);		% 生成AIS信号并保存在vPath下
end