%% oeclifton
%% FIGURE 3B
% plot the interannual variability in estimated ozone deposition velocity
% for original & tuned Massman (2004) models
% and observed ozone deposition velocity for summer (defined as June-Sept)
% this script is for Harvard Forest
clear all;clc;clf;close all;
%% define some time variables
t1 = datetime(1991,10,28,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
t_hourly = t1:minutes(60):t2; clear t1 t2;
year = 1992:1:2000; 
nyears=9;
monthbeg=6;
monthfin=9;
ndays=122;
beghr=10;
finhr=17;
%% load observed ozone deposition velocity 
[ o3ddv ] = filter_o3ddv( );
o3ddv = o3ddv(665*24+1:end); % only look at 10/28/1991 onwards 
%% load data needed for estimating ozone deposition velocity  
% load wet_soil_indicator calculated with plot_cumprec.m
load wet_soil_indicator
% load met variables 
[~,RH,~,wdir,VPD,ustar] = read_hf004();
% convert friction velocity to m/s
ustar = ustar./100; % m/s
% load LAI 
[ LAI ] = calc_lai_80016_wdir( );
% load quasilaminar resistance (rb) in s/cm calculated with calc_rb_harvard.m
load rb_harvard
% convert to s/m
rb=rb.*100; %s/m
% load aerodynamic resistance (ra) in s/m calculated with calc_ra_harvard.m
load Ra_harvard
ra = Ra; clear Ra;
% load stomatal conductance in cm/s calculated with calc_pm_gs.m
load gs_pm_harvard
% convert to m/s
gs = gs./100; % m/s
% remove hourly stomatal conductance with low VPD
gs(VPD<0.5) = NaN; 
%% calculate estimates of ozone deposition velocity
% preallocate estimates
o3ddv_estimated_new=NaN(2,nyears);
o3ddv_estimated_new_lb=NaN(2,nyears); % lower bound
o3ddv_estimated_new_ub=NaN(2,nyears); % upper bound 
% preallocate fraction cuticular deposition estimates
frac_gcut_new=NaN(2,nyears);
frac_gcut_new_lb=NaN(2,nyears); % lower bound
frac_gcut_new_ub=NaN(2,nyears); % upper bound 
% preallocate fraction soil deposition estimates
frac_ggr_new=NaN(2,nyears);
frac_ggr_new_lb=NaN(2,nyears); % lower bound
frac_ggr_new_ub=NaN(2,nyears); % upper bound 
% estimate ozone deposition velocity
for j = 1:2
    % define constants 
    if j == 1
        Rg_dry = 100; %s/m; Massman [2004]
        Rg_wet = 500; %s/m; Massman [2004] 
    else
        Rg_dry = 200; %s/m; "tuned" Massman [2004]
        Rg_wet = 10000; %s/m; "tuned" Massman [2004]
    end
    [ o3ddv_estimated, frac_gcut, ~, frac_ggr] = massman2004(ra,rb,...
        gs, ustar, LAI, Rg_dry, Rg_wet, wet_soil_indicator);
   % estimated ozone deposition velocity
    [ variable_btstrpd_day_mean_final, variable_btstrpd_day26,...
       variable_btstrpd_day975] ...
       = bootstrap(o3ddv_estimated, t_hourly.Year, year, nyears,...
       t_hourly.Month,t_hourly.Hour, monthbeg, monthfin,ndays, ...
       beghr, finhr );
    o3ddv_estimated_new(j,:)= variable_btstrpd_day_mean_final;
    o3ddv_estimated_new_lb(j,:)= variable_btstrpd_day26;
    o3ddv_estimated_new_ub(j,:)= variable_btstrpd_day975;
   % estimated fraction cuticular deposition
   [ variable_btstrpd_day_mean_final,...
       variable_btstrpd_day26, variable_btstrpd_day975] ...
       = bootstrap(frac_gcut, t_hourly.Year, year, ...
       nyears,t_hourly.Month,t_hourly.Hour, monthbeg, ...
       monthfin,ndays, beghr, finhr );
   frac_gcut_new(j,:)= variable_btstrpd_day_mean_final;
   frac_gcut_new_lb(j,:)= variable_btstrpd_day26;
   frac_gcut_new_ub(j,:)= variable_btstrpd_day975;
   % estimated fraction ground deposition 
   [ variable_btstrpd_day_mean_final, ...
       variable_btstrpd_day26, variable_btstrpd_day975] ...
       = bootstrap(frac_ggr, t_hourly.Year, year, nyears,...
       t_hourly.Month,t_hourly.Hour, monthbeg, monthfin,...
       ndays, beghr, finhr );
   frac_ggr_new(j,:)= variable_btstrpd_day_mean_final;
   frac_ggr_new_lb(j,:)= variable_btstrpd_day26;
   frac_ggr_new_ub(j,:)= variable_btstrpd_day975;
end
%% create bootstrapped daytime mean observed ozone deposition velocity
[ variable_btstrpd_day_mean_final, variable_btstrpd_day26, ...
    variable_btstrpd_day975] ...
               = bootstrap(o3ddv, t_hourly.Year, year, nyears,...
               t_hourly.Month,t_hourly.Hour, monthbeg, monthfin,ndays, ...
               beghr, finhr );
o3ddv_new= variable_btstrpd_day_mean_final;
o3ddv_new_lb= variable_btstrpd_day26;
o3ddv_new_ub= variable_btstrpd_day975;
%% plot 
figure(1);
% define colors 
orange = [1.000,0.800,0.000];
% define other plot details 
fontsize=12;
panel_letter = {'a)','b)','c)','d)','e)','f)','g)','h)','i)','j)','k)'};
subplot(3,3,1);
% plot observed ozone deposition velocity in black
errorbar(year,o3ddv_new,o3ddv_new_lb-o3ddv_new,o3ddv_new_ub-o3ddv_new,...
    'Color','k','LineWidth',1);
hold on 
for j = 1:2
    errorbar(year,squeeze(o3ddv_estimated_new(j,:)),...
        squeeze(o3ddv_estimated_new_lb(j,:)-...
        o3ddv_estimated_new(j,:)),...
        squeeze(o3ddv_estimated_new_ub(j,:)-...
        o3ddv_estimated_new(j,:)),...
        'Color',orange,'LineWidth',2)
    % calculate agreement between observed and estimated vd 
    [r,p] = corr(squeeze(o3ddv_estimated_new(j,:))',...
        o3ddv_new, 'Type', 'Pearson','rows','pairwise');
    disp({'r=' num2str(round(r,3,'significant'),...
        '%1.2f'),'p=' num2str(round(p,3,'significant'),'%1.2f')});
    % plot panel letter 
    text(0.05,0.9,panel_letter{1},'Color','k','FontSize',16,...
        'FontName','Arial','FontWeight','Bold', 'Units','Normalized');    
end
% clean up figure 
set(gca,'FontName','Arial');
set(gca,'FontSize',fontsize);
set(gca,'linewidth',1)
% clean up y-axes 
ylim([0.2 1]);
ytick = 0.2:0.2:1;
set(gca,'YTick',ytick);
    ylabel('v_d (cm s^{-1})');
% clean up x-axes 
xlim([1992 2000]);
xtick = 1992:2:2000;
set(gca,'XTick',xtick);
% make subplots closer together
sub_pos = get(gca,'position'); % get subplot axis position
set(gca,'position',sub_pos.*[1 1 1.1 1.2]) % stretch width and height
%% calculate how much deposition happening through leaf cuticles
egcut_new = frac_gcut_new.*o3ddv_estimated_new;
%% print some stuff to screen
%subtract tuned Massman (2004) estimate from original Massman (2004) estimate 
o3ddv_estimated_new(1,:)-o3ddv_estimated_new(2,:)