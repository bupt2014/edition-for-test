function [distriMat, parTable, realVesNum] = F_genParameter(sateHeight, vesNum)
global GenSigNum ratio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������ȷֲ�����������Ĺ��ʲƵƫ��ʱ�Ӳ��DOA.
%
% �������:
%   areas:                ��С����γ�ȼ������ֲ��������
%   satelliteSwath:       ����ɨ����
%	areaWidth:            С�����
%	satelliteAltitude:    ���Ǹ߶�
%	plotProb:             �Ƿ��Ǽ����������, �������������㹦�ʲƵƫ��DOA
% �������:
%	powDopDelayDOAOfAreas:	�д�С���ĸ���������, ��һ��Ϊ���ʲ�, �ڶ���Ϊ
%                           Ƶƫ, ������Ϊʱ�Ӳ�, ������ΪDOA
%	delayOfAreas_bit:       ����С���źŵ������ǵ�ʱ��, ��bitΪ��λ, ���������
%                           �����ʱ���ɸ�֡ʵ�ʽ���ʱ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global  ConflictNum
	numOfAreas_sqrt = ceil(acos(6371/(6371+sateHeight))*6371* 2/1.852/40);    % ���㸲������ֱ��
    distriMat = F_initRandDistri(10, numOfAreas_sqrt);			% ���ɴ����ֲ�����
    distriMat(:, : , 1) = zeros(72, 72);
    if ConflictNum == 1
        distriMat(36, 18, 1) = GenSigNum;
    elseif ConflictNum == 2
        distriMat(36, 18, 1) = GenSigNum;
        distriMat(12, 36, 1) = round(ratio * GenSigNum);
    elseif ConflictNum == 3
        distriMat(36, 18, 1) = GenSigNum;
        distriMat(12, 36, 1) = round(ratio * GenSigNum);
        distriMat(3, 36, 1) = round(ratio * GenSigNum);
    elseif ConflictNum == 4
        distriMat(36, 18, 1) = GenSigNum;
        distriMat(12, 36, 1) = round(ratio * GenSigNum);
        distriMat(18, 36, 1) = round(ratio * GenSigNum);
        distriMat(48, 36, 1) = round(ratio * GenSigNum);
    end

	parTable = F_calAreaPar(distriMat, sateHeight);
	realVesNum = sum(sum(distriMat(:, :, 1)));
end