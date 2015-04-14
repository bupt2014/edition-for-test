function powDopDelayDOAOfAreas = F_calAreaPar(areas, sateAlt)
    global hMode vPath1
	numberOfAreas_sqrt = size(areas, 1);
	mid = floor(numberOfAreas_sqrt / 2);
%     if(get(hMode, 'value') == 1)
	if exist('vPath1', 'var') && ~isempty(vPath1)
        load(vPath1);
        sateLat = sate_NS;
        sateLong = sate_EW;
    else
        sateLat = areas(mid, mid, 2);
        sateLong = areas(mid, mid, 3);
    end
    numberOfAreas = numberOfAreas_sqrt .^ 2;                % 小区总数
    
    areasInLine = reshape(areas, 1, numberOfAreas, 3);      % 将扫描区域重组为一维向量以便计算
    areasWithVessels = find(areasInLine(1, :, 1)); % 存在船的小区标号
    areasLatitude = areasInLine(1, :, 2);   % 全部小区纬度向量
    areasLongitude = areasInLine(1, :, 3);  % 全部小区经度向量
    
    % 有船位置的经纬度
    areasLatWithVessels = areasLatitude(areasWithVessels);      % 各有船小区纬度向量
    areasLongWithVessels = areasLongitude(areasWithVessels);    % 各有船小区经度向量
    [elevationAngle distance_SatArea temp] = elevation(areasLatWithVessels, areasLongWithVessels, zeros(1, length(areasWithVessels)), ...
        sateLat*ones(1, length(areasWithVessels)), sateLong*ones(1, length(areasWithVessels)), ...
        sateAlt*ones(1, length(areasWithVessels))*1e3);   % 计算各小区到卫星的仰角和空间距离
    clear temp;
    
    transFrequency = 161.975*1e6; % 发送频率(Hz)
    c = 3*10^8;               % 光速(m/s)
    
	
	%% 功率计算
	freeSpaceLoss_dB = -(32.44 + 20*log10(distance_SatArea/1000) + 20*log10(transFrequency/1e6));   % 自由空间功率损耗(dB)
	totalLoss_dB = freeSpaceLoss_dB;      % 信号总损耗(dB)
	patternGain_dB = 10*log10(0.964*16/3/pi*(sin((90-elevationAngle)*pi/180)).^3 + eps*1e10);
	totalRelativeLoss_dB = totalLoss_dB-min(totalLoss_dB) + patternGain_dB;
	powerOfAreas = totalRelativeLoss_dB;      % 各有船小区功率差
	
	%% 频偏计算
	G = 6.67*1e-11;       % 万有引力系数
	M = 5.98*1e24;        % 地球质量(kg)
	R = 6371*1e3;               % 地球半径(km)
	satelliteSpeed = sqrt(G*M/(R+sateAlt*1e3));     % 卫星速度(m/s)
	% 计算卫星运动方向与小区卫星连线的夹角余弦值, 详见报告模型分析
    % 	vector_Area_x = (R .* sin((90-areasLatWithVessels)*pi/180) .* cos((areasLongWithVessels-sateLong)*pi/180))';
    vector_Area_x = (R .* sin((90-areasLatWithVessels)*pi/180) .* cos(areasLongWithVessels * pi/180))';
    vector_Area_y = (R .* sin((90-areasLatWithVessels)*pi/180) .* sin(areasLongWithVessels * pi/180))';
    vector_Area_z = (R .* cos((90-areasLatWithVessels)*pi/180))';
    vector_Area = [vector_Area_x vector_Area_y vector_Area_z];
    %     plot3(vector_Area_x, vector_Area_y, vector_Area_z, 'o');
    % 	vector_Sat_x = (R+sateAlt*1e3) .* sin((90-sateLat)*pi/180) .* ones(length(areasWithVessels), 1);
    % 	vector_Sat_y = zeros(length(areasWithVessels), 1);
    vector_Sat_x = (R+sateAlt*1e3) .* sin((90-sateLat)*pi/180).* cos(sateLong * pi/180) .* ones(length(areasWithVessels), 1);
    vector_Sat_y = (R+sateAlt*1e3) .* sin((90-sateLat)*pi/180).* sin(sateLong * pi/180) .* ones(length(areasWithVessels), 1);
    vector_Sat_z = (R+sateAlt*1e3) .* cos((90-sateLat)*pi/180) .* ones(length(areasWithVessels), 1);
    vector_Sat = [vector_Sat_x vector_Sat_y vector_Sat_z];
    
    vector_AreaSat = vector_Sat-vector_Area;
    
    vector_SatSpeed_x = -R .* cos((90-sateLat)*pi/180) .* cos(sateLong * pi/180) .* ones(length(areasWithVessels), 1);
    vector_SatSpeed_y = -R .* cos((90-sateLat)*pi/180) .* sin(sateLong * pi/180) .* ones(length(areasWithVessels), 1);
    vector_SatSpeed_z = R .* sin((90-sateLat)*pi/180) .* ones(length(areasWithVessels), 1);
    vector_SatSpeed = [vector_SatSpeed_x vector_SatSpeed_y vector_SatSpeed_z];
	
	relativeAngle_cos = sum((vector_AreaSat .* vector_SatSpeed), 2)' ./ distance_SatArea ./ R;      % 卫星速度方向与船之间夹角
	dopplerFreqShift = satelliteSpeed/(c/transFrequency) .* relativeAngle_cos;                  % 各船舶频偏
	
	%% DOA计算
	DOAOfAreas = 90 - acos(relativeAngle_cos)/pi*180;           % 各船舶DOA
	

	%% 时延计算
    bitsPerSecond = 9600;           % AIS数据速率(bps)
    delayOfAreas = distance_SatArea ./ c;           % 各小区时延(s)
    delayOfAreas_bit = bitsPerSecond * delayOfAreas;    % 各小区时延(bit)
    satLocDelay = sateAlt * 1e3 ./ c;     % 卫星正下方时延(s)
    satLocDelay_bit = bitsPerSecond * satLocDelay;  % 卫星正下方时延(bit)
    delayCenterDiff = delayOfAreas_bit - satLocDelay_bit;     % 各小区时延差(bit)

    %% 合并输出
	powDopDelayDOAOfAreas = [powerOfAreas;dopplerFreqShift;delayCenterDiff;DOAOfAreas].';
end