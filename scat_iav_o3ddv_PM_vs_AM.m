%% oeclifton
%% FIGURE 3C
% this script plots summertime afternoon vs. morning ozone deposition velocity
% for each year at harvard forest 
clear all;clc;clf;close all;
%% load color scheme
% this is color scheme for 1992-2000 used in Clifton et al. 2017
hf_y_color = [ 0.722,0.541,0.000;...
    0.565,0.596,0.000;0.314,0.639,0.082;0.000,0.671,0.400;...
    0.000,0.678,0.604;0.000,0.659,0.765;0.000,0.604,0.871;...
    0.569,0.514,0.902;0.784,0.427,0.843];
%% define some time variables 
beghr_AM = 8;
finhr_AM = 13;
beghr_PM = 13;
finhr_PM = 18;
nhours = finhr_PM-beghr_PM+1; % same for AM + PM
t1 = datetime(1991,10,28,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
t_hourly = t1:minutes(60):t2; clear t1 t2;
t_hourly=t_hourly';
year = unique(t_hourly.Year,'sorted');
year(1) =[]; % cut 1991
nyears = length(year);
ndays = 122;
begmonth = 6;
finmonth=9;
%% load + filter o3ddv 
[ o3ddv ] = filter_o3ddv( );
% only keep data after 10/28/1991
o3ddv = o3ddv(665*24+1:end);
%% calculate yearly June-September averages & 95% confidence intervals for AM vs. PM
[ o3ddv_AM, o3ddv_AM_day26, o3ddv_AM_day975] = bootstrap(o3ddv,...
    t_hourly.Year, year, nyears,t_hourly.Month,t_hourly.Hour, begmonth,...
    finmonth,ndays, beghr_AM, finhr_AM );
[ o3ddv_PM, o3ddv_PM_day26, o3ddv_PM_day975] = bootstrap(o3ddv,...
    t_hourly.Year, year, nyears,t_hourly.Month,t_hourly.Hour, begmonth,...
    finmonth,ndays, beghr_PM, finhr_PM );
%% plot with errorbars in x and y directions 
% i.e., errorbar(x,y,yneg,ypos,xneg,xpos)
figure(1);
subplot(3,1,3);
for y = 1:nyears
    errorbar(o3ddv_PM(y),o3ddv_AM(y),...
        o3ddv_AM_day26(y)-o3ddv_AM(y),...
        o3ddv_AM_day975(y)-o3ddv_AM(y),...
        o3ddv_PM_day26(y)-o3ddv_PM(y),...
        o3ddv_PM_day975(y)-o3ddv_PM(y),...        
         'Color', hf_y_color(y,:),'Marker','o','MarkerSize',8,...
        'MarkerFaceColor',hf_y_color(y,:)); hold on;
end
fontsize = 11;
set(gca,'FontName','Arial');
set(gca,'FontSize',fontsize);
set(gca,'linewidth',1)
xlim([0.2 1]);
ylim([0.2 1]);
ylabel('morning v_d (cm s^{-1})');
xlabel('afternoon v_d (cm s^{-1})');
text(0.05,0.9,'c)','Color','k','FontSize',16,'FontName','Arial',...
    'FontWeight','Bold', 'Units','Normalized');
