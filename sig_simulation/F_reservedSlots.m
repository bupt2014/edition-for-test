% This function assigns transmission slots to all vessels within an
% organized area
% 为一个小区内的每艘船分配传输时隙
function reserved = F_reservedSlots(NumberOfVessels, TransmissionInterval)
global GenSigNum
    TotalNumberOfSlots = GenSigNum;     % 观测时间内的时隙总数
    % 若小区内船数小于等于最大船数, 则开始为所有船分配时隙
        reserved = zeros( 2, TotalNumberOfSlots);    %   第一行表示是否被占用（1： 被占用， 2： 未被占用）
                                                    %   第二行表示时隙
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