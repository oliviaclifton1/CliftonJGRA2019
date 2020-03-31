%% oeclifton
%% FIGURE 1
% this script plots "weekly scale" ozone deposition velocity and
% P-M stomatal conductance for 
% different diurnal time periods during 1997 and 1998s
% this script is for kane and sand flats
clear all;clc;clf;close all; 
%% define some time variables
%number of hours allowed to have NaNs for daytime median calculation
thresholddaily = 2;
month1 = 5;
month2 = 10;
days = 121:1:304;
ndays = length(days); 
%% loop over sites 
for j = 1:2
    if j == 1
        site = 'kane';
        subplot_no = [1,3,5];
        [ o3ddv ] = read_o3ec_filter_kane( );
        % load stomatal conductance for kane in cm/s calculated in
        % calc_pm_gs_kane.m 
        load gs_pm_kane
        t1 = datetime(1997,4,29,0,0,0);
        t2 = datetime(1997,10,24,23,0,0);
        t_hourly = t1:minutes(60):t2; clear t1 t2;
    elseif j == 2
        site = 'sand';
        subplot_no = [2,4,6];
        [ o3ddv ] = read_o3ec_filter_sand( );
        % load stomatal conductance for kane in cm/s calculated in
        % calc_pm_gs_sand.m 
        load gs_pm_sand
        t1 = datetime(1998,5,12,0,0,0);
        t2 = datetime(1998,10,20,23,0,0);
        t_hourly = t1:minutes(60):t2; clear t1 t2;
    end
    ndays1 = length(t_hourly)/24;
    time_in_days = reshape(t_hourly,[24 ndays1]);
    time_in_days = time_in_days(1,:)';
    %% loop over time periods 
    for k = 1:3 
        if k == 1
            beghr = 10; %9am
            finhr = 17; %4pm
        elseif k == 2
            beghr=8; %7am
            finhr=13; %12pm
        elseif k == 3
            beghr=13; %12pm
            finhr=18; %5pm
        end
        %% calculate daytime medians 
        o3ddv_med_day=create_daytime_med_sk(o3ddv,ndays1,beghr,finhr,thresholddaily);
        gs_med_day=create_daytime_med_sk(gs,ndays1,beghr,finhr,thresholddaily);
        %% define time period for daytime medians
        ind = time_in_days.Month >= month1 & time_in_days.Month <= month2;
        ind = ind';
        o3ddv_med_day = o3ddv_med_day(ind);
        gs_med_day = gs_med_day(ind);
        %% for ease of calculating running means do the following
        % make may & october complete
        if strcmp(site,'sand') 
            temp = NaN(1,11);
            o3ddv_med_day = [temp,o3ddv_med_day,temp];
            gs_med_day = [temp,gs_med_day,temp];
        elseif strcmp(site,'kane')
            temp = NaN(1,7);
            o3ddv_med_day = [o3ddv_med_day,temp];
            gs_med_day = [gs_med_day,temp];
        end
        %% calculate 10 day running averages centered on current day
        % require number of nans to be less than 4
        o3ddv_med_day_rm = NaN(1,ndays);
        gs_med_day_rm = NaN(1,ndays);
        for i = 6:ndays-5
            if sum(~isnan(o3ddv_med_day(i-5:i+5)))>= 4
                o3ddv_med_day_rm(i) = nanmean(o3ddv_med_day(i-5:i+5)); 
            end
            if sum(~isnan(gs_med_day(i-5:i+5)))>= 4
                gs_med_day_rm(i) = nanmean(gs_med_day(i-5:i+5)); 
            end
        end
        %% plot weekly scale ozone deposition velocity and P-M stomatal conductance 
        figure(1);
        subplot(3,2,subplot_no(k));
        plot(days, o3ddv_med_day_rm,'-', 'Color','b','LineWidth',1); hold on;
        plot(days, gs_med_day_rm,'-', 'Color','r','LineWidth',1); hold on;
        ylim([0 1.5]); ax = gca; 
        ax.YTick = 0:0.5:1.5; 
        ylabel('v_d or P-M g_{s} (cm s^{-1})');
        ax.YColor = 'k';
        ax.XTick = 152:20:273;     
        xlim([152 273]);    ax.XGrid = 'on';
        set(gca,'fontsize',11);
        set(gca, 'FontName','Arial'); set(gca,'linewidth',1);  
        sub_pos = get(gca,'position'); % get subplot axis position
        set(gca,'position',sub_pos.*[1 1 1.15 1.1]) % stretch its width and height
    end
end