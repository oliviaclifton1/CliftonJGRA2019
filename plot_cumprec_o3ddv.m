%% oeclifton
%% FIGURE 3A
% plot summertime cumulative precipitation and ozone deposition velocity
% and calculate correlation coefficent between the
% this script is for Harvard Forest 
clc; clear all;close all;clf;
%% define some time variables 
begmonth = 6;
finmonth = 9;
ndays = 30+31+31+30;
nnans_threshold = 0.75;
beghr = 10;
finhr = 17;
years = 1990:1:2000;
nyears = length(years);
t1 = datetime(1990,1,1,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
t_hourly = t1:minutes(60):t2; clear t1 t2;
%% load precipitation data 
from_1990 = 1;
[ prec, ~, t_daily ] = read_prec(from_1990 );
%% replace days w/ missing precip with multiyear monthly mean precip
% create monthly mean prec
prec_mm = NaN(12,1);
for m = 1:12
    ind = t_daily.Month == m;
    prec_mm(m) = nanmean(prec(ind));
end
clear ind 
% find missing prec
ind_missing = prec ~= prec;
% replace with multiyear mean for the month
temp = t_daily.Month;
m = temp(ind_missing);

prec_filler= NaN(length(m),1);
for i = 1:  length(m)
    prec_filler(i) = prec_mm(m(i));
end
prec(ind_missing) = prec_filler;
%% calculate cumulative sum, prec JJAS
prec_cumsum = NaN(11,ndays); 
for y = 1:11
    ind = t_daily.Year == years(y) & t_daily.Month >= begmonth & t_daily.Month <= finmonth;
    prec_cumsum(y,:) = cumsum(prec(ind));
end
prec_cumsum_iav = sum(prec_cumsum,2);
clear t_daily ind ind_missing prec_filler prec table
%% load ozone deposition velocities
[ o3ddv ] = filter_o3ddv( );
%% calculate bootstrapped mean + CIs
[ o3ddv_btstrpd_day_mean_final, o3ddv_btstrpd_day26, o3ddv_btstrpd_day975] ...
    = bootstrap(o3ddv,t_hourly.Year, years, nyears,t_hourly.Month,t_hourly.Hour,...
    begmonth, finmonth,ndays, beghr, finhr );
%% plot yearly progression of cumulative precipitation and ozone deposition
% velocity on same figure 
figure(1);
linestyle = '-';
plot(years,prec_cumsum_iav,'*-','Color','r', 'LineWidth',1, 'LineStyle',linestyle);
ylabel('cumulative precipitation (mm)');
set(gca, 'YDir','reverse');
yyaxis right
errorbar(years,o3ddv_btstrpd_day_mean_final,o3ddv_btstrpd_day26-o3ddv_btstrpd_day_mean_final,...
    o3ddv_btstrpd_day975-o3ddv_btstrpd_day_mean_final,'Color','k', 'LineWidth',1, 'LineStyle',linestyle);
%% clean up figure 
ylim([0.2 1.0]);
ytick = 0.2:0.2:1.0;
set(gca,'YTick',ytick);
ax = gca;
ax.YColor = 'k';
ylabel('v_d (cm s^{-1})');
fontsize = 11;
set(gca,'FontName','Arial');
set(gca,'FontSize',fontsize);
set(gca,'linewidth',1);
xlim([1990 2000])
xtick = 1990:2:2000;
set(gca,'XTick',xtick);
%% calculate correlation
[r, p] = corr(o3ddv_btstrpd_day_mean_final,prec_cumsum_iav, 'Type', 'Pearson');