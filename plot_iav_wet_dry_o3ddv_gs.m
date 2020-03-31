%% oeclifton
%% FIGURE 7B,C,D
% this script plots interannual variability in observed ozone deposition 
% velocity on rainy and dry days
% also plot interannual variability in W15 and L15 stomatal conductance
% estimates (W15=gs_empirical, L15=gs_medlyn)
% this script is for Harvard Forest 
clear all;clc;
%% ATTN need to re-run the script to plot a different variable
%% select the following
% select the variable to plot
% choices for variables are: o3ddv, gs_empirical, gs_medlyn
var = 'gs_medlyn';
% select whether you want to remove low light conditions
% lowlight=0 means do not include hours w/ PAR < 500 micromol m-2 s-1
lowlight = 0; 
%% define some time variables 
beghr = 10;
finhr = 17;
nhours = finhr-beghr+1;
t1 = datetime(1991,10,28,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
t_hourly = t1:minutes(60):t2; clear t1 t2;
year = 1992:1:2000;
nyears = length(year);
ndays=122;
month1 = 6;
month2 = 9;
%% load data
[ ~, ~,~,~,VPD,~, ~, ~, ~, ~,~,~,~,~,PAR28m] = read_hf004();
from_1990=0;
[~,fake_hourly_precip,~] = read_prec(from_1990 );
if strcmp(var,'gs_empirical') == 1 
    [ gs_empirical ] = read_emp_gs();
    variable = gs_empirical; clear gs_empirical
elseif strcmp(var,'gs_medlyn') == 1 
    % load stomatal conductance in cm/s calculated with calc_medlyn_gs.m
    load gs_medlyn_harvard
    % remove values with very low VPD
    gs(VPD < 0.02) = NaN;
    variable = gs; clear gs  
elseif strcmp(var,'o3ddv') == 1 
    [ variable ] = filter_o3ddv( );
    % only retain data after 10/28/1991
    variable=variable(665*24+1:end);   
end
% filter for low light conditions if lowlight==0 
if lowlight == 0  
    variable(PAR28m<500)=NaN;
end
%% calculate summertime daytime averages for each year on rainy vs dry days 
% use bootstrap technique 
var_dry = variable;
var_dry(fake_hourly_precip~=0)= NaN;
[ var_dry, var_dry_day26, var_dry_day975] = bootstrap(var_dry,...
    t_hourly.Year, year, nyears,t_hourly.Month,t_hourly.Hour, month1,...
    month2,ndays, beghr, finhr );
var_rainy = variable;
var_rainy(fake_hourly_precip==0 | ...
    fake_hourly_precip~=fake_hourly_precip)=NaN;
[ var_rainy, var_rainy_day26,var_rainy_day975] = bootstrap(var_rainy,...
    t_hourly.Year, year, nyears,t_hourly.Month,t_hourly.Hour, month1,...
    month2, ndays, beghr, finhr );
%% print some numbers to screen
% print difference between rainy and dry days for each year 
var_rainy-var_dry
% print multiyear mean difference
nanmean(var_rainy-var_dry)
%% plot time series of summertime mean ozone deposition velocity or 
% or stomatal condcutance on rainy (black) and dry (pink) days 
pink = [0.616,0.400,0.502];
figure(1);
if strcmp(var,'o3ddv') == 1
    subplot(3,2,1);
elseif strcmp(var,'gs_empirical') == 1
    subplot(3,2,2);
elseif strcmp(var,'gs_medlyn') == 1
    subplot(3,2,4);
end
if lowlight ~= 1
    linestyle = ':';
    year_mod = year+0.05;
else
    linestyle = '-';
    year_mod = year;
end
errorbar(year_mod,var_dry,var_dry_day26-var_dry,...
    var_dry_day975-var_dry,'Color',pink,'LineWidth',1,...
    'LineStyle',linestyle);
hold on
errorbar(year_mod,var_rainy,var_rainy_day26-var_rainy,...
    var_rainy_day975-var_rainy,'Color','k','LineWidth',1,...
    'LineStyle',linestyle);
hold on
%% clean up figure 
fontsize = 11;
set(gca,'FontName','Arial');
set(gca,'FontSize',fontsize);
set(gca,'linewidth',1);
ylim([0.3 1.1]);
ytick = 0.4:0.2:1;
set(gca,'YTick',ytick);
xlim([1992 2000])
xtick = 1992:2:2000;
set(gca,'XTick',xtick);
if strcmp(var,'o3ddv') == 1
    ylabel('v_d (cm s^{-1})');
    text(0.05,0.9,'a)','Color','k','FontSize',16,...
        'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
elseif strcmp(var,'gs_empirical') == 1
    ylabel('W15 g_s (cm s^{-1})');
    text(0.05,0.9,'b)','Color','k','FontSize',16,...
        'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
elseif strcmp(var,'gs_medlyn') == 1
    ylabel('L15 g_s (cm s^{-1})');
    text(0.05,0.9,'d)','Color','k','FontSize',16,...
        'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
end