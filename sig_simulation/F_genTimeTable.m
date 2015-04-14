function allVesselsSendBit = F_genTimeTable(areas, delayDiffOfAreas, sateAlt)
global GenSigNum ConflictNum ratio channel_num
	transInterval = 12;
	numberOfAreas = size(areas, 1) * size(areas, 2);        % 小区数量
	areasInLine = reshape(areas, 1, numberOfAreas, 3);      % 向量形式储存的小区信息, 便于统计分析
	areasWithVessels = find(areasInLine(1, :, 1));          % 存在船的小区标号
	vesselNumberOfAreas = areasInLine(1, areasWithVessels, 1);  % 有船小区船数量
	delayOfAreas = delayDiffOfAreas + 9600*sateAlt*1e3/3e8;

	loc = 1;
	totalVesselsBefore = 0;         % 已经发送信息的船数
	allVesselsSendBit = zeros(floor(sum(vesselNumberOfAreas)), 4);        % 1为小区编号, 2为船号, 3为发送时间, 4为在有船小区中的编号
    stat = find( vesselNumberOfAreas == max(vesselNumberOfAreas), 1, 'first' );   %   找到拥有最多船舶数的位置
    slotTabOfCurArea1 = F_reservedSlots(vesselNumberOfAreas(stat), transInterval);    % 为当前小区中各艘船随机分配发送时隙
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   为其他小区分配时隙
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    slotTabOfCurArea2 = zeros(2, GenSigNum);
    slotTabOfCurArea = zeros(2, GenSigNum * 2);
    for count = 1 : 1 : round(GenSigNum * ratio)
        temp1 = unidrnd( GenSigNum); %   第一行表示是否被占用（1： 被占用， 2： 未被占用）
        %   第二行表示时隙
        if slotTabOfCurArea2( 1, temp1) == 1
            locate = find( slotTabOfCurArea2(1, :) ==0);
            temp1 = locate( unidrnd( size( locate, 1)));
        end
        slotTabOfCurArea2(1, temp1) = 1;
        slotTabOfCurArea2(2, temp1) = count;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	for ii = 1 : 1 : length(areasWithVessels)
        if ii == stat
            slotTabOfCurArea = zeros(2, GenSigNum * 2);
            loc_slot = find( slotTabOfCurArea1(1, :) == 1);       % 找到当前小区的发射时隙
            slotTabOfCurArea(:, loc_slot * 2 - 1) = slotTabOfCurArea1(:, loc_slot) ;
        else
            slotTabOfCurArea = zeros(2, GenSigNum * 2);
            loc_slot = find( slotTabOfCurArea2(1, :) == 1);       
            slotTabOfCurArea(:, loc_slot * 2 - 1) = slotTabOfCurArea2(:, loc_slot) ;
        end
		%         fprintf('小区号:%d\n', ii);
		transSlot = find(slotTabOfCurArea(1, :));                     % 当前区域被占用的时隙
		slotTabOfCurArea(2, transSlot) = slotTabOfCurArea(2, transSlot) + totalVesselsBefore;       % 将各小区单独计数的船号改为全区域计数
		sendBitOfCurArea = (transSlot - 1) * 256 + ceil(delayOfAreas(ii));   % 当前区域所有帧发送具体bit时间

		allVesselsSendBit(loc : loc + length(transSlot) - 1, 1) = areasWithVessels(ii);                % 记录发送小区的编号
		allVesselsSendBit(loc : loc + length(transSlot) - 1, 2) = slotTabOfCurArea(2, transSlot);     % 记录发送船号
		allVesselsSendBit(loc : loc + length(transSlot) - 1, 3) = sendBitOfCurArea;                   % 记录发送时间
		allVesselsSendBit(loc : loc + length(transSlot) - 1, 4) = ii;                                  % 记录在有船小区中的编号

		totalVesselsBefore = totalVesselsBefore + vesselNumberOfAreas(ii);   % 已统计的船数
		loc = loc + length(transSlot);
	end
	[temp, index] = sort(allVesselsSendBit(:, 3));             % 按照发送时间对所有帧进行排序
	allVesselsSendBit = allVesselsSendBit(index, :);        % 将所有船舶发送时间矩阵按时间排序
end
