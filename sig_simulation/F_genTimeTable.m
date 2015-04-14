function allVesselsSendBit = F_genTimeTable(areas, delayDiffOfAreas, sateAlt)
global GenSigNum ConflictNum ratio channel_num
	transInterval = 12;
	numberOfAreas = size(areas, 1) * size(areas, 2);        % С������
	areasInLine = reshape(areas, 1, numberOfAreas, 3);      % ������ʽ�����С����Ϣ, ����ͳ�Ʒ���
	areasWithVessels = find(areasInLine(1, :, 1));          % ���ڴ���С�����
	vesselNumberOfAreas = areasInLine(1, areasWithVessels, 1);  % �д�С��������
	delayOfAreas = delayDiffOfAreas + 9600*sateAlt*1e3/3e8;

	loc = 1;
	totalVesselsBefore = 0;         % �Ѿ�������Ϣ�Ĵ���
	allVesselsSendBit = zeros(floor(sum(vesselNumberOfAreas)), 4);        % 1ΪС�����, 2Ϊ����, 3Ϊ����ʱ��, 4Ϊ���д�С���еı��
    stat = find( vesselNumberOfAreas == max(vesselNumberOfAreas), 1, 'first' );   %   �ҵ�ӵ����ബ������λ��
    slotTabOfCurArea1 = F_reservedSlots(vesselNumberOfAreas(stat), transInterval);    % Ϊ��ǰС���и��Ҵ�������䷢��ʱ϶
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Ϊ����С������ʱ϶
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    slotTabOfCurArea2 = zeros(2, GenSigNum);
    slotTabOfCurArea = zeros(2, GenSigNum * 2);
    for count = 1 : 1 : round(GenSigNum * ratio)
        temp1 = unidrnd( GenSigNum); %   ��һ�б�ʾ�Ƿ�ռ�ã�1�� ��ռ�ã� 2�� δ��ռ�ã�
        %   �ڶ��б�ʾʱ϶
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
            loc_slot = find( slotTabOfCurArea1(1, :) == 1);       % �ҵ���ǰС���ķ���ʱ϶
            slotTabOfCurArea(:, loc_slot * 2 - 1) = slotTabOfCurArea1(:, loc_slot) ;
        else
            slotTabOfCurArea = zeros(2, GenSigNum * 2);
            loc_slot = find( slotTabOfCurArea2(1, :) == 1);       
            slotTabOfCurArea(:, loc_slot * 2 - 1) = slotTabOfCurArea2(:, loc_slot) ;
        end
		%         fprintf('С����:%d\n', ii);
		transSlot = find(slotTabOfCurArea(1, :));                     % ��ǰ����ռ�õ�ʱ϶
		slotTabOfCurArea(2, transSlot) = slotTabOfCurArea(2, transSlot) + totalVesselsBefore;       % ����С�����������Ĵ��Ÿ�Ϊȫ�������
		sendBitOfCurArea = (transSlot - 1) * 256 + ceil(delayOfAreas(ii));   % ��ǰ��������֡���;���bitʱ��

		allVesselsSendBit(loc : loc + length(transSlot) - 1, 1) = areasWithVessels(ii);                % ��¼����С���ı��
		allVesselsSendBit(loc : loc + length(transSlot) - 1, 2) = slotTabOfCurArea(2, transSlot);     % ��¼���ʹ���
		allVesselsSendBit(loc : loc + length(transSlot) - 1, 3) = sendBitOfCurArea;                   % ��¼����ʱ��
		allVesselsSendBit(loc : loc + length(transSlot) - 1, 4) = ii;                                  % ��¼���д�С���еı��

		totalVesselsBefore = totalVesselsBefore + vesselNumberOfAreas(ii);   % ��ͳ�ƵĴ���
		loc = loc + length(transSlot);
	end
	[temp, index] = sort(allVesselsSendBit(:, 3));             % ���շ���ʱ�������֡��������
	allVesselsSendBit = allVesselsSendBit(index, :);        % �����д�������ʱ�����ʱ������
end
