%% oeclifton 
%% FIGURE 3E,F
% this script plots daily and weekly ozone deposiion velocity during
% summers 1998 and 1999
% identifies which days have mostly wind coming from northwest
% and shows the weekly mean if all hours are excluded when wind comes from
% the northwest 
clear all;clc;clf;close all; 
%% define some time variables 
begmonth=5;
finmonth=10;
ndays_fin_month=31;
days = 121:1:304;
ndays = length(days);
beghr = 10; %9am
finhr = 17; %4pm
thresholddaily = 2; %number of hours allowed to have NaNs for daytime median calc
years = 1992:1:2000;
nyears = length(years);
t1 = datetime(1991,10,28,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
t_hourly = t1:minutes(60):t2; clear t1 t2;
t_hourly=t_hourly';
%% load data
% load ozone deposition velocities and filter them
[ o3ddv ] = filter_o3ddv( );
% only select 10/28/1991 onwards 
o3ddv = o3ddv(665*24+1:end);
% load wind direction 
[~,~,~,wdir] = read_hf004();
%% calculate how many hours in daytime when wind comes from NW 
wdir1 = wdir(t_hourly.Year > 1991 & t_hourly.Month >= begmonth & t_hourly.Month <= finmonth);
wdir_day = reshape(wdir1',[24 numel(wdir1)/24]); 
wdir_daytime = wdir_day(beghr:finhr,:); 
ind = wdir_daytime > 270; 
nNW = sum(ind,1); 
nNW = reshape(nNW, [ndays 9]);
clear ind wdir1 wdir_day wdir_daytime
%% create another o3ddv variable that has NaNs for hourly NW wind 
o3ddv_noNW = o3ddv;
o3ddv_noNW(wdir>270)=NaN; clear wdir_new
%% calculate daytime median 
[o3ddv_med_day] = calc_daytime_median(o3ddv, thresholddaily, beghr, finhr,begmonth,finmonth, ndays_fin_month, ndays); clear o3ddv
[o3ddv_noNW_med_day] = calc_daytime_median(o3ddv_noNW, thresholddaily, beghr, finhr,begmonth,finmonth, ndays_fin_month, ndays); clear o3ddv_noNW
%% calculate weekly averages 
o3ddv_med_day_rm = NaN(ndays,nyears);
o3ddv_noNW_med_day_rm = NaN(ndays,nyears);
for y = 1:nyears
    for i = 6:ndays-5
        if sum(~isnan(o3ddv_med_day(i-5:i+5,y)))>= 4
            o3ddv_med_day_rm(i,y) = nanmean(o3ddv_med_day(i-5:i+5,y)); 
        end
        if sum(~isnan(o3ddv_noNW_med_day(i-5:i+5,y)))>= 4
            o3ddv_noNW_med_day_rm(i,y) = nanmean(o3ddv_noNW_med_day(i-5:i+5,y)); 
        end        
    end
end
%% plot daytime medians and weekly averages for 1998 and 1999
blue = [0.541,0.675,0.922];
figure(1);
for y = nyears-2:nyears-1
    subplot(4,3,y);
    plot(days, o3ddv_med_day(:,y),'.-', 'Color','k','MarkerSize',8,'LineWidth',0.2); hold on;
    temp =  o3ddv_med_day(:,y);
    ind = nNW(:,y)>5;
    plot(days(ind), temp(ind),'ro','MarkerSize',5); hold on;
    plot(days, o3ddv_med_day_rm(:,y),'-', 'Color','k','LineWidth',3); hold on;
    plot(days, o3ddv_noNW_med_day_rm(:,y),'.-', 'Color',blue,'LineWidth',3); hold on;
    ylim([0 1.5]); ax = gca; 
    ax.YTick = 0:0.5:1.5;     
    ylabel('v_d (cm s^{-1})');
    ax.YColor = 'k';
    ax.XTick = 152:20:273;     
    xlabel('day of year');
    xlim([152 273]);    ax.XGrid = 'on'; 
    set(gca,'fontsize',11);
    set(gca, 'FontName','Arial'); set(gca,'linewidth',1);
    title(years(y));  
    if y == nyears-1
        legend('daily v_d','majority NW','weekly v_d','no hours with NW wind','Orientation','Horizontal');
    end
    sub_pos = get(gca,'position'); % get subplot axis position
    set(gca,'position',sub_pos.*[1 1 1.15 1.1]) % stretch its width and height
end
