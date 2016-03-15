%% Project 2 - A quick visualization tool for spatial cells

% This script will generate a figure for each cell in the "batch_path"
% folder, allowing for a quick visualization of the spatial and temporal
% tuning properties of cells recorded from the rodent limbic spatial
% processing circuit. Each figure contains:

% Path + spike plot
% Firing rate heat map (raw or smoothed)
% Firing rate x head direction plot (full session, 1st half and 2nd half)
% ISI histogram
% Autocorrelation

% This script written by Mehlman, with some functions pilfered from others
% (see comments below). March 2016.

%% Add paths

addpath(pwd);
addpath('/Users/maxmehlman/Documents/MATLAB/Projects/Project_2/Functions');
addpath('/Users/maxmehlman/Documents/MATLAB/Projects/Project_2/Functions/export_fig');
addpath('/Users/maxmehlman/Documents/MATLAB/Projects/Project_2/Functions/FindFiles');

%% Set path for batch analysis

batch_path = '/Users/maxmehlman/Documents/Course data/Project_2_data_lowFR';

%% Set parameters

Font_size = 14; % font size for all plots
bins_HD = 0:6:354; % bins for FR x HD plots
number_bins_xy = 25; % number of bins per axis for firing rate heat map
bin_size_ISI = 0.001; % bin size for ISI histogram (in seconds)

%% Find files
% FindFiles() function and associated code from Redish (MClust 3.0)

batch_data_trackingspikes = FindFiles('*.read','StartingDirectory',batch_path); % find files containing tracking data and spikes (60 Hz sampling rate)
batch_data_ts = FindFiles('*.txt','StartingDirectory',batch_path); % find files containg spike timestamps (in microseconds)

%% Begin loop

for iCell = 1:length(batch_data_trackingspikes);
    
    % load celli data
    celli = importdata(batch_data_trackingspikes{iCell});
    celli_ts = importdata(batch_data_ts{iCell});
    
    % remove nondetects
    session_length = length(celli.data(:,1)); % save session length prior to removing nondetects
    nondetects = find_nondetects(celli); % function written by Mehlman
    celli.data(nondetects,:) = [];
    
    % PATH + SPIKE PLOT
    
    figure('Position',[200 200 1400 700]);
    
    % plot path
    subplot('Position',[0.01 0.55 0.2 0.4]);
    
    plot(celli.data(:,2),celli.data(:,3),'LineWidth',1,'Color','k');
    set(gca,'Fontsize',Font_size,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
    axis([0 255 0 255]);

    % find spike locations
    spikes = find(celli.data(:,6) >= 1);
    x_spikes = celli.data(spikes,2);
    y_spikes = celli.data(spikes,3);

    % plot spike locations
    hold on;
    scatter(x_spikes,y_spikes,20,'r','filled');
    title('Path + spikes');

    % FIRING RATE (FR) HEAT MAP

    % set bins
    y_min = min(celli.data(:,3));
    y_max = max(celli.data(:,3));
    x_min = min(celli.data(:,2));
    x_max = max(celli.data(:,2));
    edges{1} = linspace(y_min,y_max,number_bins_xy+1);
    edges{2} = linspace(x_min,x_max,number_bins_xy+1);
    
    % occupancy histogram
    occupancy_yx = [celli.data(:,3),celli.data(:,2)];
    occupancy_hist = hist3(occupancy_yx,'Edges',edges);
    occupancy_hist(end,:) = []; % remove last row
    occupancy_hist(:,end) = []; % remove last column
    occupancy_hist = occupancy_hist/60; % divide by sampling rate (60 Hz)
    
    % spike histogram
    spike_yx = [y_spikes,x_spikes];
    spike_hist = hist3(spike_yx,'Edges',edges);
    spike_hist(end,:) = []; % remove last row
    spike_hist(:,end) = []; % remove last column
    
    % FR heat map
    firing_rate = spike_hist ./ occupancy_hist;
    
    % plot raw FR heat map
    %subplot('Position',[0.01 0.06 0.2 0.4]);
    
    %pcolor(firing_rate);
    %set(gca,'Fontsize',Font_size);
    %shading flat;
    %axis off;
    %axis square;
    %title('Firing rate');
    
    % plot smoothed FR heat map
    % smooth() function from Clark and Winter
    firing_rate(isnan(firing_rate)) = 0; % remove NaN
    firing_rate(isinf(firing_rate)) = 0; % remove +Inf and -Inf
    firing_rate_smooth = smooth(firing_rate,1,5,1,5); % 5 x 5 point window with 1 point steps
    
    subplot('Position',[0.01 0.06 0.2 0.4]);
    
    pcolor(firing_rate_smooth);
    set(gca,'Fontsize',Font_size);
    shading flat;
    axis off;
    axis square;
    title('Firing rate - smoothed');
    
    % FR x HEAD DIRECTION (HD) PLOT - FULL SESSION

    % convert HD from radians to degrees
    celli.data(:,10) = celli.data(:,10) * (360/(2*pi));
    
    % HD occupancy histogram
    [HD_n,HD_x] = hist(celli.data(:,10),bins_HD);
    HD_occupancy_hist = HD_n/60; % divide by sampling rate (60 Hz)
    
    % vector of HD during each spike
    HD_spikes = find_HD_spikes(celli); % function written by Mehlman
    
    % spike histogram
    [spikes_n,spikes_x] = hist(HD_spikes,bins_HD);
    
    % FR
    HD_firing_rate = spikes_n ./ HD_occupancy_hist;
    
    % set ymax
    if max(HD_firing_rate) > 10
        ymax = max(HD_firing_rate);
    else
        ymax = 10; % if peak firing rate < 10 Hz, set ymax to 10 Hz
    end
    
    % plot
    subplot('Position',[0.25 0.55 0.39 0.4]);
    
    plot(HD_x,HD_firing_rate,'LineWidth',1,'Color','k');
    set(gca,'Fontsize',Font_size,'XTick',[],'XTickLabel',[]);
    axis([0 354 0 ymax]);
    xlabel('HD');
    ylabel('FR');
    
    % plot title = cell ID
    [file_path,file_name] = fileparts(batch_data_trackingspikes{iCell});
    title(file_name);
    
    % FR x HD PLOT - 1st HALF
    
    % samples no longer continuous after removing nondetects
    first_half_samples = find(celli.data(:,1) >= 1 & celli.data(:,1) <= session_length/2);
    
    % restrict to first half
    first_half.data = celli.data(first_half_samples,:);
    
    % HD occupancy histogram
    [HD_n,HD_x] = hist(first_half.data(:,10),bins_HD);
    HD_occupancy_hist = HD_n/60; % divide by sampling rate (60 Hz)
    
    % vector of HD during each spike
    HD_spikes = find_HD_spikes(first_half); % function written by Mehlman
    
    % spike histogram
    [spikes_n,spikes_x] = hist(HD_spikes,bins_HD);
    
    % FR
    HD_firing_rate = spikes_n ./ HD_occupancy_hist;
    
    % set ymax
    if max(HD_firing_rate) > 10
        ymax = max(HD_firing_rate);
    else
        ymax = 10; % if peak firing rate < 10 Hz, set ymax to 10 Hz
    end
    
    % plot
    subplot('Position',[0.25 0.06 0.175 0.4]);
    
    plot(HD_x,HD_firing_rate,'LineWidth',1,'Color','k');
    set(gca,'Fontsize',Font_size,'XTick',[],'XTickLabel',[]);
    axis([0 354 0 ymax]);
    title('FR x HD - 1st half');
    
    % FR x HD PLOT - 2nd HALF
    
    % samples no longer continuous after removing nondetects
    second_half_samples = find(celli.data(:,1) > session_length/2 & celli.data(:,1) <= session_length);
    
    % restrict to second half
    second_half.data = celli.data(second_half_samples,:);
    
    % HD occupancy histogram
    [HD_n,HD_x] = hist(second_half.data(:,10),bins_HD);
    HD_occupancy_hist = HD_n/60; % divide by sampling rate (60 Hz)
    
    % vector of HD during each spike
    HD_spikes = find_HD_spikes(second_half); % function written by Mehlman
    
    % spike histogram
    [spikes_n,spikes_x] = hist(HD_spikes,bins_HD);
    
    % FR
    HD_firing_rate = spikes_n ./ HD_occupancy_hist;
    
    % set ymax
    if max(HD_firing_rate) > 10
        ymax = max(HD_firing_rate);
    else
        ymax = 10; % if peak firing rate < 10 Hz, set ymax to 10 Hz
    end
    
    % plot
    subplot('Position',[0.465 0.06 0.175 0.4]);
    
    plot(HD_x,HD_firing_rate,'LineWidth',1,'Color','k');
    set(gca,'Fontsize',Font_size,'XTick',[],'XTickLabel',[]);
    axis([0 354 0 ymax]);
    title('FR x HD - 2nd half');
    
    % ISI HISTOGRAM
    
    % convert timestamps from microseconds to seconds
    celli_ts_sec = celli_ts / 1000000;
    
    % compute ISIs
    ISI = diff(celli_ts_sec);
    
    % set bins
    ISI_bins = 0:bin_size_ISI:1;
    
    % ISI histogram
    [ISI_n,ISI_x] = hist(ISI,ISI_bins);
    
    % plot
    subplot('Position',[0.68 0.55 0.3 0.4]);
    
    bar(ISI_x(1:end-1),ISI_n(1:end-1),'k'); % ignore last bin
    set(gca,'Fontsize',Font_size);
    axis([0 1 0 max(ISI_n(1:end-1))]);
    xlabel('ISI (sec)');
    ylabel('Count');
    title('ISI histogram');
    
    % AUTOCORRELATION

    % compute autocorrelation
    % acf_mvdm() function from van der Meer
    [auto_corr,x_bin] = acf_mvdm(celli_ts_sec,0.01,1);
    
    % plot
    subplot('Position',[0.68 0.06 0.3 0.4]);
    
    plot(x_bin,auto_corr,'LineWidth',1,'Color','k');
    set(gca,'Fontsize',Font_size);
    xlabel('Lag (sec)');
    ylabel('Correlation');
    title('Autocorrelation');
    
    % SAVE FIGURE
    % export_fig() function and associated code from Altman (MATLAB File Exchange)
    cd(batch_path);
    export_fig(sprintf(file_name), '-jpg');
    
    % prepare for next iteration
    close(figure(1));
    clearvars -except batch_data_trackingspikes batch_data_ts batch_path iCell Font_size bins_HD number_bins_xy bin_size_ISI
    
end