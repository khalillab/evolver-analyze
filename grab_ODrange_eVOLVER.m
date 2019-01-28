function [ trimmed_data ] = grab_ODrange_eVOLVER(ODmin, ODmax, OD_data)
%grab_ODrange_eVOLVER.m - finds time window where OD is between ODstart and ODend

% Notes:
% - To prevent spurious inclusion, OD is smoothed for grab_ODrange, unlike in grab_timerange

    % INPUTS:
    % OD_data = [time, OD]
    % ODmin = OD to start window at
    % ODmax = OD to end window at
    
    % OUTPUT:
    % trimmed_Data = [time, OD]
    
    
trimmed_data = [];

%split data
time=OD_data(:,1);
OD=smooth(OD_data(:,2));
indexes=find((OD>ODmin & OD<ODmax));
trimmed_data=[time(indexes) OD(indexes)];
end