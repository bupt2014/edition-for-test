% This function assigns transmission slots to all vessels within an
% organized area
% Ϊһ��С���ڵ�ÿ�Ҵ����䴫��ʱ϶
function reserved = F_reservedSlots(NumberOfVessels, TransmissionInterval)
global GenSigNum
    TotalNumberOfSlots = GenSigNum;     % �۲�ʱ���ڵ�ʱ϶����
    % ��С���ڴ���С�ڵ��������, ��ʼΪ���д�����ʱ϶
        reserved = zeros( 2, TotalNumberOfSlots);    %   ��һ�б�ʾ�Ƿ�ռ�ã�1�� ��ռ�ã� 2�� δ��ռ�ã�
                                                    %   �ڶ��б�ʾʱ϶
        for i = 1: 1: TotalNumberOfSlots
            firstslot = unidrnd( TotalNumberOfSlots );
            if reserved( 1, firstslot) == 1
                locate = find( reserved(1, :) ==0);
                firstslot = locate( unidrnd( size( locate, 1)));
            end
            reserved( 1, firstslot) = 1;
            reserved( 2, firstslot) = i;
        end
end