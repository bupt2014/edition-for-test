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
    numberOfAreas = numberOfAreas_sqrt .^ 2;                % С������
    
    areasInLine = reshape(areas, 1, numberOfAreas, 3);      % ��ɨ����������Ϊһά�����Ա����
    areasWithVessels = find(areasInLine(1, :, 1)); % ���ڴ���С�����
    areasLatitude = areasInLine(1, :, 2);   % ȫ��С��γ������
    areasLongitude = areasInLine(1, :, 3);  % ȫ��С����������
    
    % �д�λ�õľ�γ��
    areasLatWithVessels = areasLatitude(areasWithVessels);      % ���д�С��γ������
    areasLongWithVessels = areasLongitude(areasWithVessels);    % ���д�С����������
    [elevationAngle distance_SatArea temp] = elevation(areasLatWithVessels, areasLongWithVessels, zeros(1, length(areasWithVessels)), ...
        sateLat*ones(1, length(areasWithVessels)), sateLong*ones(1, length(areasWithVessels)), ...
        sateAlt*ones(1, length(areasWithVessels))*1e3);   % �����С�������ǵ����ǺͿռ����
    clear temp;
    
    transFrequency = 161.975*1e6; % ����Ƶ��(Hz)
    c = 3*10^8;               % ����(m/s)
    
	
	%% ���ʼ���
	freeSpaceLoss_dB = -(32.44 + 20*log10(distance_SatArea/1000) + 20*log10(transFrequency/1e6));   % ���ɿռ书�����(dB)
	totalLoss_dB = freeSpaceLoss_dB;      % �ź������(dB)
	patternGain_dB = 10*log10(0.964*16/3/pi*(sin((90-elevationAngle)*pi/180)).^3 + eps*1e10);
	totalRelativeLoss_dB = totalLoss_dB-min(totalLoss_dB) + patternGain_dB;
	powerOfAreas = totalRelativeLoss_dB;      % ���д�С�����ʲ�
	
	%% Ƶƫ����
	G = 6.67*1e-11;       % ��������ϵ��
	M = 5.98*1e24;        % ��������(kg)
	R = 6371*1e3;               % ����뾶(km)
	satelliteSpeed = sqrt(G*M/(R+sateAlt*1e3));     % �����ٶ�(m/s)
	% ���������˶�������С���������ߵļн�����ֵ, �������ģ�ͷ���
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
	
	relativeAngle_cos = sum((vector_AreaSat .* vector_SatSpeed), 2)' ./ distance_SatArea ./ R;      % �����ٶȷ����봬֮��н�
	dopplerFreqShift = satelliteSpeed/(c/transFrequency) .* relativeAngle_cos;                  % ������Ƶƫ
	
	%% DOA����
	DOAOfAreas = 90 - acos(relativeAngle_cos)/pi*180;           % ������DOA
	

	%% ʱ�Ӽ���
    bitsPerSecond = 9600;           % AIS��������(bps)
    delayOfAreas = distance_SatArea ./ c;           % ��С��ʱ��(s)
    delayOfAreas_bit = bitsPerSecond * delayOfAreas;    % ��С��ʱ��(bit)
    satLocDelay = sateAlt * 1e3 ./ c;     % �������·�ʱ��(s)
    satLocDelay_bit = bitsPerSecond * satLocDelay;  % �������·�ʱ��(bit)
    delayCenterDiff = delayOfAreas_bit - satLocDelay_bit;     % ��С��ʱ�Ӳ�(bit)

    %% �ϲ����
	powDopDelayDOAOfAreas = [powerOfAreas;dopplerFreqShift;delayCenterDiff;DOAOfAreas].';
end