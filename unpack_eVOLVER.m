function [OD_data,T_data,ODset,pump_log] = unpack_eVOLVER(folder,vials)
%unpack_eVOLVER.m - extracts data from eVOLVER experiment folder, saving to
%different arrays for each requested vial.

%Notes:
% - follows PC filepath scheme, need to be adapted for Mac filepaths
% - scrubs OD files to remove NaNs

    % INPUTS:
    % folder = expt_folder path
    % vials = []
    
    % OUTPUT:
    % OD_data = [time OD];
    % T_data = [time temperature];
    % ODset = [time ODsetpoints];
    % pump_log = [time pump_events];

for n = 1:numel(vials)
    % READ TEXT FILES
    od_file = sprintf( ['%s\\OD\\vial%d_OD.txt'],folder, vials(n));
    odset_file = sprintf(['%s\\ODset\\vial%d_ODset.txt'],folder, vials(n));
    temp_file = sprintf(['%s\\temp\\vial%d_temp.txt'],folder, vials(n));
    pump_file = sprintf(['%s\\pump_log\\vial%d_pump_log.txt'],folder, vials(n));
    
    od_file_open = fopen(od_file);
    odraw = textscan(od_file_open,'%f %f','Headerlines',0,'delimiter',',');
    fclose(od_file_open);
    
    odset_file_open = fopen(odset_file);
    odset = textscan(odset_file_open,'%f %f','Headerlines',1,'delimiter',',');
    fclose(odset_file_open);
    
    temp_file_open = fopen(temp_file);
    tempdat = textscan(temp_file_open,'%f %f','Headerlines',1,'delimiter',',');
    fclose(temp_file_open);
    
    pump_file_open = fopen(pump_file);
    pumps = textscan(pump_file_open,'%f %f','Headerlines',1,'delimiter',',');
    fclose(pump_file_open);

    % CELL ARRAYS WITH ALL THE DATA
    OD_data{n} = [odraw{1}(~isnan(odraw{2})) odraw{2}(~isnan(odraw{2}))];
    ODset{n} = [odset{1} odset{2}];
    T_data{n} = [tempdat{1} tempdat{2}];
    pump_log{n} = [pumps{1} pumps{2}];
end