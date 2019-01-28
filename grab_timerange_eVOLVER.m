function [varargout] = grab_timerange_eVOLVER(varargin)
%grab_timerange_eVOLVER.m - removes data points outside trimmed time window

    % INPUTS:
    % start = start of window, in hours
    % finish = end of window, in hours
    % eVOLVER_data = cell array with datatype for all vials, e.g. 'OD_data'
    % Note: can have as many inputs as outputs
    
    % OUTPUT:
    % trimmed_eVOLVER_data
    
start=varargin{1};
finish=varargin{2};

ntypes=nargin-2;
nvials=size(varargin{3},2);

if isnumeric(start)
    start=start.*ones(1,nvials);
end
if isnumeric(finish)
    finish=finish.*ones(1,nvials);
end

data={};
for i=1:ntypes
    data=varargin{i+2};
    trimmed_data={};
    for j=1:nvials
        time=data{j}(:,1);
        vals=data{j}(:,2);
        indexes=find((time>start(j) & time<finish(j)));
        trimmed_data{j}=[time(indexes) vals(indexes)];
    end
    varargout{i}=trimmed_data;
end


end