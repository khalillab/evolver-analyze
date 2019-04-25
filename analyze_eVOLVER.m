clear all; close all; clc;
% Instructions for use:
% - Set parameters in initialize section (line 11), analysis section (line 35),
%   and plotting section (line 101)
% - Choose expt folder or load data (useful if combining multiple experiments)
% - Use vials to select only the vials of interest for both analysis and plotting,
%   e.g. to make overlay plot of only two vials, select just those two
% See end of document for data variable descriptions

%% Initialize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vials = [0:15];
expname = 'test';    %name used for saving variables
save_files=0; %set to 0 to not save, see end of document for variable descriptions
plot_data=1; %set to 0 to not plot, see end of document for plot descriptions

% IF IMPORTING FROM FOLDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
topfolder = 'C:\Users\username\Documents\MATLAB\Data';
folder = uigetdir(topfolder);
%folder='C:\Users\username\Documents\MATLAB\Data\WT_expt1';

disp('Loading data...')
[OD_data,T_data,ODset,pump_log]=unpack_eVOLVER(folder,vials);
if save_files
    fprintf('Saving basic variables to %s \n',[expname,'_raw.mat'])
    rawname=fullfile(topfolder,[expname,'_raw.mat']);
    save(rawname,'OD_data','T_data','ODset','pump_log')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% IF IMPORTING FROM MATLAB FILE
% load('evolverinputdata_raw.mat')

%% Choose Analysis Type and Parameters
% SET PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
timerange=[0 48];
%If defined, data is trimmed to start and end times given [t0,tF]. Set to [0] to use all data.

analysis='segmented'; 
%'single' or 'segmented'. 'single' is used for growth curve. 'segmented' for turbidostat

gr_option='fit';
%'avg' or 'fit'. 'avg' uses starting/ending OD. 'fit' uses exponential fit

ODrange=[0.05,0.25];
%OD range in which exponential fits should be calculated, only used in 'single' analysis

% CODE BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(timerange)>1
    disp('Trimming data...')
    [OD_data,T_data,ODset,pump_log]=grab_timerange_eVOLVER(timerange(1),timerange(2),OD_data,T_data,ODset,pump_log);
end

disp('Calculating growth rates...')
g_rate={};
gens={};
conf={};

%% Segmented Analysis

if strcmp(analysis,'segmented')
    for n = 1:numel(vials)
        %segment OD into windows between dilutions
        OD_segments{n}=segment_eVOLVER(OD_data{n},ODset{n});
        
        %calculate growth rate, generations, confidence for fit
        [g_rate{n} gens{n} conf{n}]=g_rate_options(OD_segments{n},gr_option);        
    end
    if plot_data
        plots_to_generate=[1:7];
    end
    clear('ODrange')
end

%% Single Analysis
if strcmp(analysis,'single')
    for n = 1:numel(vials)
        % calculate carrying capacity and area under curve
        endpoint{n}=mean(OD_data{n}(end-10:end,2)); %last 10 values
        auc{n}=trapz(OD_data{n}(:,1),OD_data{n}(:,2)); %
        
        % grab OD range for exponential fit
        OD_segments{n}=grab_ODrange_eVOLVER(ODrange(1),ODrange(2),OD_data{n});
        
        %calculate growth rate on exponential range only
        [g_rate{n} gens{n} conf{n}]=g_rate_options({OD_segments{n}},gr_option);
    end
    if plot_data
        plots_to_generate=[1,2,8,9,10,11];
    end
end

%% Save Output Variables
if save_files
    fprintf('Saving analysis to %s \n',[expname,'_output.mat'])
    fullname=fullfile(topfolder,[expname,'_output.mat']);
    save(fullname) %whole workspace, including trimmed output variables
end

%% Plotting options
% SET PLOTTING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n=1:numel(vials) 
    vial_name{n} = ['Vial ' num2str(vials(n))]; 
end
%vial_name must match number of vials, can overwrite the default "Vial N"

colors = jet(numel(vials));
%alternatively, provide matrix with RGB for each vial

timeaxis=[0 48]; %hours, range to display for timecourse plots [3,4,5,6,8]
ODaxis=[0 0.8]; %OD600 range to display for OD plots [1,8,10]
GRaxis=[0 0.75]; %Growth rate range to display for GR plots [3,5,7]

nth=5; %plot every n-th point for full traces [1,2,8]

sp=[4,4]; %subplot arrangement, rows, columns [1,2]

fig_size=[100 200 1000 600]; %[x,y,width,height]
font_size=8;

%SPECIFIC PLOTS ONLY

temprange=[15 35]; %Temperature range to display for Temp plot [2]
gr_box_vals=10; %Maximum number of growth rate vals to use for boxplot calculations [7]

% CODE BELOW %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('off','MATLAB:legend:IgnoringExtraEntries')
if plot_data
    fprintf('Plotting figures %s ... \n',sprintf('%d',plots_to_generate))
    for p = plots_to_generate
        for n = 1:numel(vials)

            %% OD for each vial
            if p==1
                figure(1)
                set(gcf,'Position',fig_size)
                subplot(sp(1),sp(2),n)
                plot(OD_data{n}(1:nth:end,1),smooth(OD_data{n}(1:nth:end,2))) 
                title(vial_name{n})
                set(gca,'FontSize',font_size)
                xlabel('Time (Hours)')
                ylabel('Optical Density')
                xlim(timeaxis)
                ylim(ODaxis)
            end

            %% Temperature for each vial
            if p==2
                figure(2)
                set(gcf,'Position',fig_size)
                subplot(sp(1),sp(2),n)
                plot(T_data{n}(1:nth:end,1),T_data{n}(1:nth:end,2))
                title(vial_name{n},'FontSize',font_size)
                xlabel('Time (Hours)','FontSize',font_size)
                ylabel('Temperature','FontSize',font_size)
                xlim(timeaxis)
                ylim(temprange)
            end

            %% Growth Rate over time for each vial
            if p==3
                figure(3)
                set(gcf,'Position',fig_size)
                subplot(sp(1),sp(2),n)
                scatter(g_rate{n}(:,1),g_rate{n}(:,2),5)
                set(gca,'FontSize',font_size)
                title(vial_name{n})
                xlabel('Time (Hours)')
                ylabel('Growth Rate (1/Hr)')
                xlim(timeaxis)
                ylim(GRaxis)
            end

            %% Generations over time for each vial
            if p==4
                figure(4)
                set(gcf,'Position',fig_size)
                subplot(sp(1),sp(2),n)
                set(gca,'FontSize',font_size)
                plot(gens{n}(:,1),gens{n}(:,2),'.-')
                title(vial_name{n})
                xlabel('Time (Hours)')
                ylabel('Cumulative Generations')
                xlim(timeaxis)
            end

            %% Growth rate overlay
            if p==5
                figure(5)
                set(gcf,'Position',fig_size)
                plot(g_rate{n}(:,1),g_rate{n}(:,2),'o','Color',colors(n,:)); hold on
                plot(g_rate{n}(:,1),smooth(g_rate{n}(:,2)),'-','Color',colors(n,:)); hold on
                xlabel('Time (Hours)')
                ylabel('Growth Rate (1/Hr)')
                xlim(timeaxis)
                ylim(GRaxis)
                legend(repelem(vial_name,2))
                set(gca,'FontSize',font_size)
            end

            %% Generations overlay
            if p==6
                figure(6)
                set(gcf,'Position',fig_size)
                plot(gens{n}(:,1),gens{n}(:,2),'.-'); hold on
                set(gca,'FontSize',font_size)
                xlabel('Time (Hours)')
                ylabel('Cumulative Generations')
                xlim(timeaxis)
                legend(vial_name)
            end

            %% Mean Growth Rate Boxplot
            if p==7
                figure(7)
                set(gcf,'Position',fig_size)
                if length(g_rate{n})<2
                    notBoxPlot(g_rate{n}(:,2),n,'style','sdline');
                elseif length(g_rate{n})<(gr_box_vals+1)
                    notBoxPlot(g_rate{n}(2:end,2),n,'style','sdline');
                else 
                    notBoxPlot(g_rate{n}(2:gr_box_vals+1,2),n,'style','sdline');
                end
                hold on
                set(gca,'FontSize',font_size)
                title(sprintf('Mean Growth Rate from %g measurements \n Red: Mean  Pink: 95 S.E.M. Blue: S.D.',gr_box_vals))
                xlabel('Vial')
                ylabel('Growth Rate (1/Hr)')
                ylim(GRaxis)
                %legend(repelem(vial_name,4))
            end

            %% OD overlay
            if p==8
                figure(8)
                set(gcf,'Position',fig_size)
                plot(OD_data{n}(1:nth:end,1),smooth(OD_data{n}(1:nth:end,2)),'Color',colors(n,:)); hold on
                set(gca,'FontSize',font_size)
                xlabel('Time (Hours)')
                ylabel('Optical Density')
                xlim(timeaxis)
                ylim(ODaxis)
                legend(vial_name{n})
            end


            %% Growth rate bar
            if p==9
                figure(9)
                set(gcf,'Position',fig_size)
                gplot=g_rate{n}(:,2);
                bar(vials(n),gplot); hold on
                if ~isempty(conf{n})
                    cplot1=conf{n}(2);
                    cplot2=conf{n}(3);
                    errorbar(vials(n),gplot,(cplot1-gplot),(gplot-cplot2),'Color','k'); hold on
                end
                title(sprintf('Growth rate over OD range: [%g to %g]',ODrange(1),ODrange(2)))
                ylabel('Growth Rate (1/Hr)')
                ylim(GRaxis)
                xlabel('Vial')
                xticks(vials)
                set(gca,'FontSize',font_size)
                %legend(repelem(vial_name,2))
            end

            %% Endpoint : Carrying capacity bar
            if p==10
                figure(10)
                set(gca,'FontSize',font_size)
                set(gcf,'Position',fig_size)
                bar(vials(n),endpoint{n}); hold on;
                title('Endpoint Optical Denisty : Carrying Capacity')
                ylabel('Optical Density')
                ylim(ODaxis)
                xlabel('Vial')
                xticks(vials)
                %legend(vial_name)
            end

            %% Area Under Curve bar
            if p==11
                figure(11)
                set(gca,'FontSize',font_size)
                set(gcf,'Position',fig_size)
                bar(vials(n),auc{n}); hold on;
                title('Area Under Growth Curve')
                ylabel('AUC')
                xlabel('Vial')
                xticks(vials)
                %legend(vial_name)
            end

        end %vial loop

    end %plot loop
end %plot if
disp('Done!')

%% DESCRIPTION OF DATA VARIABLES

% BASIC VARIABLES (unpacked from expt folder, stored in both _raw.mat and _output.mat)
% OD_data: cell array containing [timepoint OD] data for each vial, output is
% trimmed to timerange. Note that OD is recorded more frequently than updated 
% 
% T_data: cell array containing [timepoint temperature] data for
% each vial, output is trimmed to timerange. Note that temperature is
% recorded more frequently than updated
% 
% ODset: cell array containing [timepoint ODsetpoint] data for each vial, used
% for segmenting turbidostat data, output is trimmed to timerange
% 
% pump_log: cell array containing [timepoint pump_duration] data for each vial,
% usually not used, output is trimmed to timerange
% 
% OUTPUT VARIABLES (generated by analysis, stored in _output.mat only) 
% OD_segments: cell array containing [timepoint OD] data used to calculate
% growth rate for each vial. For 'segmented' analysis, this is every turbidostat window,
% while for 'single' analysis, this is the expected exponential range selected in ODrange
% 
% g_rate: cell array containing [timepoint growth rate] data for each vial, 
% timepoint is set as the end of the time window over which g_rate was calculated
% 
% gens: cell array containing [timepoint generations] data for each vial,
% generations are cumulative since start of timerange
% 
% conf: cell array containing [timepoint low high] 95% confidence interval
% growth rate data for each vial if using 'fit'. Not defined for 'avg'
% 
% endpoint: cell array containing [timepoint OD] data for endpoint OD in
% 'single' analysis. If timerange is defined such that cultures have
% reached equilibrium, then endpoint is an esitmate of carrying capacity.
% Note that high OD values are sbuject to limitations of the calibration
% curve for each smart sleeve.
%
% auc: cell array containing [timepoint AUC] data for area under the OD
% curve in 'single' analyis. This is the trapezoidal area under the OD_data
% curve for each vial.
% 
% Chris Mancuso, Boston University, Khalil Lab, 2019

