function [ OD_segments ] = segment_eVOLVER( OD_data, ODset )
%segment_eVOLVER.m - break turbidostat trace according to ODset values

%Note: 
% - scrubs out segments with less than 10 data points

    % INPUTS:
    % OD_data = [time, OD]
    % ODset = [time, ODsetpoint]
    
    % OUTPUT:
    % OD_segments = { [timerange1, ODrange1] [timerange2, ODrange2] ...
    
    
OD_segments = {};
count=1;

for m=2:length(ODset(:,1))
   if (ODset(m,2) < ODset(m-1,2)) && (ODset(m,1) - ODset(m-1,1) >.1)

        % Split OD to Each Dilution Cycle
        [ODrow, ODcol] = find(OD_data(:,1)>ODset(m-1,1)  & OD_data(:,1)<ODset(m,1));
        ODx = OD_data(ODrow,1);
        ODy = OD_data(ODrow,2);
        OD_segments{count}=[ODx ODy];
        count=count+1;
   end
end

end

