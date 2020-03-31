%% oeclifton
%% FIGURE 2
% this script plots daily anomalies of stomatal conductance vs. daily
% anomalies of ozone deposition velocities at Harvard Forest
clf;close all;clear all;clc;
%% define some time variables
may = ones(31,1)*5;
jun = ones(30,1)*6;
jul = ones(31,1)*7;
aug = ones(31,1)*8;
sep = ones(30,1)*9;
month = [may;jun; jul; aug; sep]'; clear may jun jul aug sep 
ndays = length(month);
% define daytime hours
beghr = 10; %9am
finhr = 17; %4pm
%how many reals do there have to be in running mean
threshold_monthly = 7; 
%number of hours allowed to have NaNs for daytime median 
thresholddaily = 2; 
%% load data
% load ozone deposition velocity
[ o3ddv ] = filter_o3ddv( );
% only keep data from 10/28/1991 onwards 
o3ddv = o3ddv(665*24+1:end);
% load wind direction and atmospheric vapor pressure deficit 
[~,~,~,wdir,VPD] = read_hf004();
% load L15 stomatal conductance from calc_medlyn_gs.m 
load gs_medlyn_harvard
gs_medlyn = gs; clear gs
% remove hourly values with very low VPD 
gs_medlyn(VPD < 0.02) = NaN;
% ATTN: select whether you would like to remove values with wind from northwest 
% gs_medlyn(wdir>270)=NaN;
% load P-M stomatal conductance from calc_pm_gs.m 
load gs_pm_harvard
gs_pm = gs; clear gs;
% remove hourly values with low VPD
gs_pm(VPD < 0.5) = NaN; clear VPD
% load stomatal conductance from W15 
[ gs_empirical ] = read_emp_gs();
%% deseasonalize and detrend so you have daily anomalies 
[~, o3ddv_med_day_anom ] = calc_daily_deseasonalize_remove_iav_RM(o3ddv,...
    thresholddaily,threshold_monthly,beghr, finhr, month); clear o3ddv
[~, gs_pm_med_day_anom ] = calc_daily_deseasonalize_remove_iav_RM(gs_pm,...
    thresholddaily,threshold_monthly,beghr, finhr, month); clear gs_pm
[~, gs_emp_med_day_anom ] = calc_daily_deseasonalize_remove_iav_RM(...
    gs_empirical, thresholddaily,threshold_monthly,beghr, finhr, month);
    clear gs_empirical
[~, gs_medlyn_med_day_anom ] = calc_daily_deseasonalize_remove_iav_RM(...
    gs_medlyn, thresholddaily,threshold_monthly,beghr, finhr, month); 
    clear gs_medlyn
%% plot stomatal conductance vs. ozone deposition velocity anomalies 
fontsize=11;
symsize=20;
panel_letter = {'a)','b)','c)','d)','e)','f)','g)','h)'};
figure(1);
subplot(3,1,1);
scatter(gs_pm_med_day_anom,o3ddv_med_day_anom,symsize,'k'); hold on
    [r,p] = corrcoef(gs_pm_med_day_anom,o3ddv_med_day_anom,...
        'rows','pairwise');
    nobs = sum(gs_pm_med_day_anom == gs_pm_med_day_anom & ...
        o3ddv_med_day_anom==o3ddv_med_day_anom);
    text(0.01,0.2, {['r=' num2str(round(r(1,2),3,'significant'),...
        '%1.2f')],['p=' num2str(round(p(1,2),3,'significant'),'%1.2f')],...
        ['n=' num2str(nobs)]},'Color','k','FontSize',fontsize,...
        'FontName','Arial','FontWeight','Bold','Units','Normalized');
xlabel('P-M g_s anomaly (cm s^{-1})');
ylabel('v_d anomaly (cm s^{-1})');
ax=gca; ax.FontSize = fontsize; ax.FontName = 'Arial'; 
set(gca,'YMinorTick','on');set(gca,'XMinorTick','on');
xlim([-1 1]); ylim([-1 1]);    
ytick = -1:0.5:1; set(gca,'YTick',ytick);
xtick = -1:0.5:1; set(gca,'XTick',xtick);
set(gca,'linewidth',1)
text(0.05,0.9,panel_letter{1},'Color','k','FontSize',16,...
    'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
box on
subplot(3,1,2);
scatter(gs_emp_med_day_anom,o3ddv_med_day_anom,symsize,'k'); hold on
    [r,p] = corrcoef(gs_emp_med_day_anom,o3ddv_med_day_anom,...
        'rows','pairwise');
    nobs = sum(gs_emp_med_day_anom == gs_emp_med_day_anom & ...
        o3ddv_med_day_anom==o3ddv_med_day_anom);
    text(0.01,0.2, {['r=' num2str(round(r(1,2),3,'significant'),...
        '%1.2f')],['p=' num2str(round(p(1,2),3,'significant'),'%1.2f')],...
        ['n=' num2str(nobs)]},'Color','k','FontSize',fontsize,...
        'FontName','Arial','FontWeight','Bold','Units','Normalized');
xlabel('W15 g_s anomaly (cm s^{-1})');
ylabel('v_d anomaly (cm s^{-1})');
ax=gca; ax.FontSize = fontsize; ax.FontName = 'Arial'; 
set(gca,'YMinorTick','on');set(gca,'XMinorTick','on');
xlim([-1 1]); ylim([-1 1]);
ytick = -1:0.5:1; set(gca,'YTick',ytick);
xtick = -1:0.5:1; set(gca,'XTick',xtick);
set(gca,'linewidth',1)
text(0.05,0.9,panel_letter{2},'Color','k','FontSize',16,...
    'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
box on
subplot(3,1,3);
scatter(gs_medlyn_med_day_anom,o3ddv_med_day_anom,symsize,'k'); hold on
    [r,p] = corrcoef(gs_medlyn_med_day_anom,o3ddv_med_day_anom,...
        'rows','pairwise');
    nobs = sum(gs_medlyn_med_day_anom == gs_medlyn_med_day_anom ...
        & o3ddv_med_day_anom==o3ddv_med_day_anom);
    text(0.01,0.2, {['r=' num2str(round(r(1,2),3,'significant'),...
        '%1.2f')],['p=' num2str(round(p(1,2),3,'significant'),'%1.2f')],...
        ['n=' num2str(nobs)]},'Color','k','FontSize',fontsize,...
        'FontName','Arial','FontWeight','Bold','Units','Normalized');
xlabel('L15 g_s anomaly (cm s^{-1})');
ylabel('v_d anomaly (cm s^{-1})');
ax=gca; ax.FontSize = fontsize; ax.FontName = 'Arial'; 
set(gca,'XMinorTick','on');set(gca,'YMinorTick','on');
xlim([-1 1]); ylim([-1 1]);
ytick = -1:0.5:1; set(gca,'YTick',ytick);
xtick = -2:1:2; set(gca,'XTick',xtick);
set(gca,'linewidth',1)
text(0.05,0.9,panel_letter{3},'Color','k','FontSize',16,...
    'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
box on