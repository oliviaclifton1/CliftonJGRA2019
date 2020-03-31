%% oeclifton
%% FIGURE 1
% this script plots "weekly scale" ozone deposition velocity for 
% different diurnal time periods during 1997 and 1998s
% this script can be adjusted for P-M stomatal conductance with minor changes
% this script is for harvard forest
clear all;clc;clf; close all; 
%% define diurnal time period
% afternoon
% beghr = 13; %12pm
% finhr = 18; %5pm
% daytime
% beghr = 10; %9am
% finhr = 17; %4pm
% morning
beghr = 8; %6am
finhr = 13; %12pm
%% define some time variables 
may = ones(31,1)*5;
jun = ones(30,1)*6;
jul = ones(31,1)*7;
aug = ones(31,1)*8;
sep = ones(30,1)*9;
oct = ones(31,1)*10;
month = [may; jun; jul; aug; sep; oct]'; clear may jun jul aug sep oct
ndays = length(month);
days = 121:1:304; 
%number of hours allowed to have NaNs for daytime median calculation
thresholddaily = 2; 
%% load harvard forest ozone deposition velocities 
% load ozone deposition velocity calculated in calc_o3ddv_stp.m

% only keep data from 10/28/1991 onwards
o3ddv_harvard  = o3ddv(665*24+1:end);  clear o3ddv; 
% pull out data for short-term time periods 
%(i.e. corresponding to kane for 1997 and sand flats for 1998)
t1 = datetime(1991,10,28,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
t_harvard_hourly = t1:minutes(60):t2; clear t1 t2;
beg = find(t_harvard_hourly.Year == 1997 & t_harvard_hourly.Month == 4 ...
    & t_harvard_hourly.Day == 29 & t_harvard_hourly.Hour == 0 & ...
    t_harvard_hourly.Minute == 0);
fin = find(t_harvard_hourly.Year == 1997 & t_harvard_hourly.Month == 10 ...
    & t_harvard_hourly.Day == 24 & t_harvard_hourly.Hour == 23 & ...
    t_harvard_hourly.Minute == 0);
o3ddv_harvard_kane = o3ddv_harvard(beg:fin); clear beg fin 
beg = find(t_harvard_hourly.Year == 1998 & t_harvard_hourly.Month == 5 ...
    & t_harvard_hourly.Day == 12 & t_harvard_hourly.Hour == 0 & ...
    t_harvard_hourly.Minute == 0);
fin = find(t_harvard_hourly.Year == 1998 & t_harvard_hourly.Month == 10 ...
    & t_harvard_hourly.Day == 20 & t_harvard_hourly.Hour == 23 & ...
    t_harvard_hourly.Minute == 0);
o3ddv_harvard_sand = o3ddv_harvard(beg:fin); clear beg fin t_harvard_hourly  
%% filter ozone deposition velocities by growing season
o3ddv_harvard_kane(abs(o3ddv_harvard_kane)>10) = NaN;
tempstd = std(o3ddv_harvard_kane, 'omitnan');
tempmean = nanmean(o3ddv_harvard_kane); 
o3ddv_harvard_kane(o3ddv_harvard_kane > tempmean + 3*tempstd | ...
    o3ddv_harvard_kane < tempmean - 3*tempstd) = NaN;
disp(tempmean); disp(tempstd);clear tempmean; clear tempstd;
o3ddv_harvard_sand(abs(o3ddv_harvard_sand)>10) = NaN;
tempstd = std(o3ddv_harvard_sand, 'omitnan');
tempmean = nanmean(o3ddv_harvard_sand); 
o3ddv_harvard_sand(o3ddv_harvard_sand > tempmean + 3*tempstd | ...
    o3ddv_harvard_sand < tempmean - 3*tempstd) = NaN;
disp(tempmean); disp(tempstd);clear tempmean; clear tempstd;
clear o3ddv_harvard 
%% find daily medians for Harvard Forest
% calculate daytime median for harvard forest during sand flats time period
o3ddv_harvard_sand = reshape(o3ddv_harvard_sand, ...
    [24 length(o3ddv_harvard_sand)./24]);
o3ddv_daytime_harvard_sand = o3ddv_harvard_sand(beghr:finhr,:); 
%count how many nans are in daytime for each day
count = sum(isnan(o3ddv_daytime_harvard_sand));
%if greater than "threshold" NaNs
o3ddv_daytime_harvard_sand(:,count > thresholddaily) = NaN;
o3ddv_med_day_harvard_sand=median(o3ddv_daytime_harvard_sand,1,'omitnan');
%calculate daytime median for harvard forest during kane time period 
o3ddv_harvard_kane = reshape(o3ddv_harvard_kane,...
    [24 length(o3ddv_harvard_kane)./24]);
o3ddv_daytime_harvard_kane = o3ddv_harvard_kane(beghr:finhr,:); 
%count how many nans are in daytime for each day
count = sum(isnan(o3ddv_daytime_harvard_kane));
%if greater than "threshold" NaNs
o3ddv_daytime_harvard_kane(:,count > thresholddaily) = NaN;
o3ddv_med_day_harvard_kane=median(o3ddv_daytime_harvard_kane,1,'omitnan');
%% for ease of calculating running means do the following:
% complete dataset for May + October 1998
temp = NaN(1,11);
o3ddv_med_day_harvard_sand = [temp,o3ddv_med_day_harvard_sand,temp];
% remove 2 days of April for 1997
temp = NaN(1,7);
o3ddv_med_day_harvard_kane = [o3ddv_med_day_harvard_kane(3:end),temp];
%% calculate 10 day centered running means (weekly scale)
o3ddv_med_day_harvard_kane_rm = NaN(ndays,1);
o3ddv_med_day_harvard_sand_rm = NaN(ndays,1);
for i = 6:ndays-5
    % allow for 4 NaNs
    if sum(~isnan(o3ddv_med_day_harvard_kane(i-5:i+5)))>= 4
        o3ddv_med_day_harvard_kane_rm(i) = ...
            nanmean(o3ddv_med_day_harvard_kane(i-5:i+5)); 
    end
     % allow for 4 NaNs
    if sum(~isnan(o3ddv_med_day_harvard_sand(i-5:i+5)))>= 4
        o3ddv_med_day_harvard_sand_rm(i) = ...
            nanmean(o3ddv_med_day_harvard_sand(i-5:i+5)); 
    end
end
%% plot weekly scale ozone deposition velocities 
% (1 subplot for each year & diurnal time period)
panel_letter = {'a)','b)','c)','d)','e)','f)','g)','h)','i)','j)','k)'};
figure(1);
subplot(3,3,1);
plot(days, o3ddv_med_day_harvard_kane,'.',...
    'Color',[0.000,0.659,0.765],'MarkerSize',5); hold on;
plot(days, o3ddv_med_day_harvard_kane,'-',...
    'Color',[0.000,0.659,0.765],'LineWidth',0.5); hold on;
plot(days, o3ddv_med_day_harvard_kane_rm,'-',...
    'Color',[0.000,0.659,0.765],'LineWidth',3); hold on;
ylim([0 1.5]); ax = gca; ax.YTick = 0:0.5:1.5; 
ax.YColor = 'k';
xlim([152 273]); ax.XTick = 152:20:273; ax.XGrid = 'on'; 
set(gca,'fontsize',12);
set(gca, 'FontName','Arial'); set(gca,'linewidth',1);
title('1998');  
text(0.05,0.9,panel_letter{1},'Color','k','FontSize',16,...
    'FontName','Arial','FontWeight','Bold', 'Units','Normalized');    
sub_pos = get(gca,'position'); % get subplot axis position
set(gca,'position',sub_pos.*[1 1 1.04 1.04]) % stretch its width and height
subplot(3,3,2);
plot(days, o3ddv_med_day_harvard_sand,'.',...
    'Color',[0.000,0.604,0.871],'MarkerSize',5); hold on;
plot(days, o3ddv_med_day_harvard_sand,'-',...
    'Color',[0.000,0.604,0.871],'LineWidth',0.5); hold on;
plot(days, o3ddv_med_day_harvard_sand_rm,'-',...
    'Color',[0.000,0.604,0.871],'LineWidth',3); hold on;
ylim([0 1.5]); ax = gca; ax.YTick = 0:0.5:1.5; 
ax.YColor = 'k';
xlim([152 273]); ax.XTick = 152:20:273; ax.XGrid = 'on'; 
set(gca,'fontsize',12);
set(gca, 'FontName','Arial'); set(gca,'linewidth',1);
title('1998');  
text(0.05,0.9,panel_letter{2},'Color','k',...
    'FontSize',16,'FontName','Arial','FontWeight','Bold',...
    'Units','Normalized');    
sub_pos = get(gca,'position'); % get subplot axis position
set(gca,'position',sub_pos.*[1 1 1.04 1.04]) % stretch its width and height