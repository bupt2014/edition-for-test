function test
    clear;
%     clc;
    close all;
	tic;
    global GenSigNum ConflictNum ratio channel_num vHeight vVesNum vTime vEbNo vPath sateHeight sateLon stateSize earthR nmile2km sateLat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    ��������(���Զ����޸Ĳ���)
    GenSigNum = 10; %   �������ܵ��źŵĸ���
                    %   �˴����ź��Ǹ����źŵĵ���
    ConflictNum = 2;    %   �˴���ʾ���ǵ�ǰ�ź��а������Ǽ��س�ͻ
    ratio = 0.4;    %   ռ�ձȣ� �˴���ʾ���ǳ�ͻ���ź�ռ�������źŵı�ֵ
                    %   ���磺 �ܹ�������10 ���źţ� ������ 4 ���ź��ǳ�ͻ�źţ���ôռ�ձȾ��� 0.4��
    channel_num = 2;    %   �ŵ�������ϵ�����յ��ź���Ŀ
    vEbNo = 20;   %   �����
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       ���²��������޸�
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%������ֵ%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sateHeight = 600;              %���Ǹ߶�
    sateLon = 102;                 %���Ǿ���
    sateLat = 31.8029;             %����γ��
    stateSize = 40;                %һ��С���ı߳�Ϊ40����
    earthR = 6371;                 %����뾶
    nmile2km = 1.852;              %Km������ת��       
    resultPath = './AISSig_s';
    vTime = [12];                 %�۲�ʱ��  ֻ��Ϊ���ļ���ͳһ
	vVesNum = GenSigNum;               %��������
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    F_initPar;
    vHeight = sateHeight;
    vPath = resultPath;
%     vPath1 = modelPath;
            %F_genParameter�����в����õ����ݣ�ʵ�������ź�ʱ��Ҫ�޸�
            [areas, parTable, realVesNum] = F_genParameter(vHeight, vVesNum);		% areasΪ�����ֲ�����, parTableΪ������������, vesNumΪʵ�ʴ�������
            [aisData, zeroNum] = F_genAISData(realVesNum);					        % aisDataΪ���������͵Ķ�������Ϣ
            timeTable = F_genTimeTable(areas, parTable(:, 3), vHeight);		% timeTableΪ��֡�źŵķ���ʱ��
            statConflict  = F_statConflict( timeTable, ConflictNum );
            F_genAISSig(aisData, zeroNum, parTable, timeTable, vTime, vPath);		% ����AIS�źŲ�������vPath��
end