function varargout = g_rate_options(varargin)
%g_rate_options.m - Calculate growth rate and generations in OD segments

    % INPUTS:
    % OD_segments = { [timerange1, ODrange1] [timerange2, ODrange2] ...
    % options = 'avg' or 'fit', defaults to 'avg'
    
    % OUTPUT:
    % g_rate = [time, growth rate]
    % gens = [time, generations]
    % c95 = [time, conf interval]
    
OD_segments = varargin{1};
if nargin >1
    options = varargin{2};
else
    options = 'avg';
end
    
g_rate = [];
gens = [];
conf =[];

%% Calculate using end/beginning of segment only
if options == 'avg'
    for m=1:numel(OD_segments)
        ODx = OD_segments{m}(:,1)-OD_segments{m}(1,1);
        ODy = OD_segments{m}(:,2);
        od_end = nanmean(ODy(end-5:end));
        od_start = nanmean(ODy(1:5));
        duration = ODx(end);

        doubs = log2(od_end/od_start); %number of doublings
        rate = doubs/duration; %doublings / time

        g_rate(m,:) = [OD_segments{m}(end,1) rate]; %set timestamp at end of each window
        if m<2
            gens(m,:) = [OD_segments{m}(end,1) doubs];
        else
            gens(m,:) = [OD_segments{m}(end,1) (gens(m-1,2)+doubs)];
        end
    end
%% Fit exponential curve on each segment
elseif options == 'fit'
    for m=1:numel(OD_segments)
        ODx = OD_segments{m}(:,1)-OD_segments{m}(1,1);
        ODy = OD_segments{m}(:,2);
        duration = ODx(end);
        
        f = fit(ODx,ODy,'exp1');

        con95 = confint(f,0.95); % 95% confidence interval
        rate = f.b;
        doubs = duration/(log(2)/rate); %duration divided by doubling time
        

        g_rate(m,:) = [OD_segments{m}(end,1) rate]; %set timestamp at end of each window
        conf(m,:)= [OD_segments{m}(end,1) con95(:,2)'];
        if m<2
            gens(m,:) = [OD_segments{m}(end,1) doubs];
        else
            gens(m,:) = [OD_segments{m}(end,1) (gens(m-1,2)+doubs)];
        end
    end
end

%% Format outputs
g_rate = real(g_rate);
gens = real(gens);

varargout{1} = g_rate;

if nargout >1
   varargout{2} = gens;
end

if nargout >2
   varargout{3} = conf;
end

