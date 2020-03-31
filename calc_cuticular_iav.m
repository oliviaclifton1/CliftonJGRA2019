%% oeclifton
%% SECTION 3.3.2
% this script investigates whether dry cuticular deposition contributes to 
% interannual variability in ozone deposition velocity at Harvard Forest
% it first calculates the correlation between summertime mean relative 
% humidity and ozone deposition velocity 
% this script also calculates multiyear summertime daytime mean dry
% cuticular conductance according to Massman (2004) and Zhang et al. (2002)
clear all;clc;clf;close all;
%% define some time variables 
begmonth = 6;
finmonth = 9;
ndays = 30+31+31+30;
beghr = 10;
finhr = 17;
years = 1992:1:2000;
nyears = length(years);
t1 = datetime(1991,10,28,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
t_hourly = t1:minutes(60):t2; clear t1 t2;
%% load ozone deposition velocities
[ o3ddv ] = filter_o3ddv( );
%% calculate bootstrapped mean ozone deposition velocity for each year
[ o3ddv_btstrpd_day_mean_final, ~, ~] ...
    = bootstrap(o3ddv,t_hourly.Year, years, nyears,t_hourly.Month,t_hourly.Hour,...
    begmonth, finmonth,ndays, beghr, finhr );
%% load relative humidity (in %) and friction velocity (in cm/s)
[ ~,RH279m,~,~,~,ustar] = read_hf004();
% convert friction velocity to m/s 
ustar = ustar/100; % m/s
%% calculate bootstrapped mean relative humidity for each year 
[ RH_btstrpd_day_mean_final, ~, ~] ...
    = bootstrap(RH279m,t_hourly.Year, years, nyears,t_hourly.Month,t_hourly.Hour,...
    begmonth, finmonth,ndays, beghr, finhr );
%% calculate correlation between relative humidty and ozone deposition velocity 
[r, p] = corr(o3ddv_btstrpd_day_mean_final,RH_btstrpd_day_mean_final, 'Type', 'Pearson');
%% calculate bootstrapped mean friction velocity for each year
[ ustar_btstrpd_day_mean_final, ~, ~] ...
    = bootstrap(ustar,t_hourly.Year, years, nyears,t_hourly.Month,t_hourly.Hour,...
    begmonth, finmonth,ndays, beghr, finhr );
%% load LAI 
[ LAI ] = calc_lai_80016_wdir( );
%% calculate bootstrapped mean LAI for each year
[ LAI_btstrpd_day_mean_final, ~, ~] ...
    = bootstrap(LAI,t_hourly.Year, years, nyears,t_hourly.Month,t_hourly.Hour,...
    begmonth, finmonth,ndays, beghr, finhr );
%% average quantities across years
ustar_mm = mean(ustar_btstrpd_day_mean_final);
RH_mm = mean(RH_btstrpd_day_mean_final);
LAI_mm = mean(LAI_btstrpd_day_mean_final);
%% calculate dry cuticular conductance according to Massman(2004)
g_cut_dry_massman = LAI_mm/5000; % m/s
g_cut_dry_massman = g_cut_dry_massman*100.;
%% calculate dry cuticular conductance according to Zhang et al. (2002)
Rcut_dry0 = 6000; %s/m
g_cut_dry_zhang = 1./((Rcut_dry0.*exp(-0.03.*RH_mm).*LAI_mm.^(-0.25))./ustar_mm); % in m/s
g_cut_dry_zhang = g_cut_dry_zhang.*100.; % in cm/s 
%% calculate mean estimated dry cuticular conductance
g_cut_dry = (g_cut_dry_zhang+g_cut_dry_massman)/2.;
%% calculate range in dry cuticular conductance if assume factor of 1.8 
% variability centered on mean
g_cut_dry_max = 1.8*(2*g_cut_dry)/(1+1.8);
g_cut_dry_min = g_cut_dry_max/1.8;