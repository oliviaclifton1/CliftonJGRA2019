%% oeclifton
%% FIGURE 3D
% this script plots summertime daytime southwest vs. northwest ozone deposition velocity
% for all years at harvard forest 
clear all;clc;clf;close all;
%% load color scheme
% this is color scheme for 1992-2000 used in Clifton et al. 2017
hf_y_color = [ 0.722,0.541,0.000;...
    0.565,0.596,0.000;0.314,0.639,0.082;0.000,0.671,0.400;...
    0.000,0.678,0.604;0.000,0.659,0.765;0.000,0.604,0.871;...
    0.569,0.514,0.902;0.784,0.427,0.843];
%% define some time variables 
beghr = 10;
finhr = 17;
nhours = finhr-beghr+1;
begmonth = 6;
finmonth = 9;
t1 = datetime(1991,10,28,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
t_hourly = t1:minutes(60):t2; clear t1 t2;
t_hourly=t_hourly';
year = unique(t_hourly.Year,'sorted');
year(1) =[];
nyears = length(year);
ndays=122;
%% load ozone deposition velocity
[ o3ddv ] = filter_o3ddv( );
% only examine 10/28/1991 onwards (when met data begins)
o3ddv = o3ddv(665*24+1:end);
%% load wind direction 
[ ~, ~,~,wdir,~,~, ~, ~, ~, ~,~,~,~,~,~] = read_hf004();
%% calculate yearly summertime daytime averages and 95% confidence intervals 
% when wind comes from northwest
o3ddv_NW = o3ddv;
o3ddv_NW(wdir<=270 | wdir~=wdir)=NaN;
[ o3ddv_NW, o3ddv_NW_day26, o3ddv_NW_day975] = bootstrap(o3ddv_NW,...
    t_hourly.Year, year, nyears,t_hourly.Month,t_hourly.Hour, begmonth, ...
    finmonth,ndays, beghr, finhr );
% when wind comes from southwest 
o3ddv_SW = o3ddv;
o3ddv_SW(wdir>270 | wdir~=wdir)=NaN;
[ o3ddv_SW, o3ddv_SW_day26, o3ddv_SW_day975] = bootstrap(o3ddv_SW,...
    t_hourly.Year, year, nyears,t_hourly.Month,t_hourly.Hour, begmonth,...
    finmonth,ndays, beghr, finhr );
%% plot with errorbars in x and y directions 
% i.e., errorbar(x,y,yneg,ypos,xneg,xpos)
figure(1);
subplot(3,1,2);
for y = 1:nyears
    errorbar(o3ddv_SW(y),o3ddv_NW(y),...
        o3ddv_NW_day26(y)-o3ddv_NW(y),...
        o3ddv_NW_day975(y)-o3ddv_NW(y),...
        o3ddv_SW_day26(y)-o3ddv_SW(y),...
        o3ddv_SW_day975(y)-o3ddv_SW(y),...        
         'Color', hf_y_color(y,:),'Marker','o','MarkerSize',8,...
        'MarkerFaceColor',hf_y_color(y,:)); hold on;
end
fontsize = 11;
set(gca,'FontName','Arial');
set(gca,'FontSize',fontsize);
set(gca,'linewidth',1)
xlim([0.2 1]);
ylim([0.2 1]);
tick = 0.2:0.2:1;
set(gca,'YTick',tick);
set(gca,'XTick',tick);
ylabel('NW v_d (cm s^{-1})');
xlabel('SW v_d (cm s^{-1})');
text(0.05,0.9,'d)','Color','k','FontSize',16,'FontName','Arial',...
    'FontWeight','Bold', 'Units','Normalized');

% plot year labels 
ymax=0.5;
years = int2str(year);
for y = 1:nyears
    if y < 4
        ycoord = ymax-(y-1)*(ymax./10);
        xcoord = 0.79-0.2;
    elseif y < 7 
        ycoord = ymax-(y-4)*(ymax./10);
        xcoord = 0.92-0.2;
    elseif y < 10
        ycoord = ymax-(y-7)*(ymax./10);
        xcoord = 1.05-0.2;
    end
    text(xcoord,ycoord,years(y,:),'Color',hf_y_color(y,:),'FontSize',9,...
        'FontName','Arial','FontWeight', 'Bold');
end
%% write some stuff to screen
NW_enhancement = o3ddv_NW./o3ddv_SW;
disp(NW_enhancement)