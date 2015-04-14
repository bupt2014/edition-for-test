function [distriMat, parTable, realVesNum] = F_genParameter(sateHeight, vesNum)
global GenSigNum ratio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 随机均匀分布计算各船舶的功率差、频偏、时延差和DOA.
%
% 输入参数:
%   areas:                各小区经纬度及船舶分布情况矩阵
%   satelliteSwath:       卫星扫描宽度
%	areaWidth:            小区宽度
%	satelliteAltitude:    卫星高度
%	plotProb:             是否是计算概率所用, 如果是则无需计算功率差、频偏和DOA
% 输出参数:
%	powDopDelayDOAOfAreas:	有船小区的各参数矩阵, 第一列为功率差, 第二列为
%                           频偏, 第三列为时延差, 第四列为DOA
%	delayOfAreas_bit:       所有小区信号到达卫星的时延, 以bit为单位, 用来计算检
%                           测概率时生成各帧实际接收时间
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global  ConflictNum
	numOfAreas_sqrt = ceil(acos(6371/(6371+sateHeight))*6371* 2/1.852/40);    % 计算覆盖区域直径
    distriMat = F_initRandDistri(10, numOfAreas_sqrt);			% 生成船舶分布矩阵
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