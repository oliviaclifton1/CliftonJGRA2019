%% oeclifton
%% TABLE 1 and Text S6
% multiple linear regression for Harvard Forest
% regress vd on P-M gs & RH 
clc; clear all;clf; close all;
%% define some time variables 
%define daytime hours 
beghr = 10; %9am
finhr = 17; %4pm
nhours = finhr-beghr+1;
thresholddaily = 2; %how many NaNs are there allowed to be in daytime mean + median calcs 
threshold_monthly = 7; %how many reals do there have to be in monthly RM
may = ones(31,1)*5;
jun = ones(30,1)*6;
jul = ones(31,1)*7;
aug = ones(31,1)*8;
sep = ones(30,1)*9; 
month = [ may;jun; jul; aug; sep]'; clear jun jul aug sep may
ndays = length(month);
%% load data 
% load ozone deposition velocity
[ o3ddv ] = filter_o3ddv( );
% only use data from 10/28/1991 onwards 
o3ddv = o3ddv(665*24+1:end);
% load relative humidity and atmospheric vapor pressure deficit
[ ~,RH,~,~,VPD] = read_hf004();
% load stomatal conductance calculated from calc_pm_gs.m
load gs_pm_harvard
% remove hourly stomatal conductances with low VPD 
gs(VPD<0.5) = NaN;  clear VPD
%% calculate daytime median
[~, o3ddv_med_day_anom ] = calc_daily_deseasonalize_remove_iav_RM(o3ddv, thresholddaily,threshold_monthly,beghr, finhr, month); clear o3ddv
[~, gs_med_day_anom ] = calc_daily_deseasonalize_remove_iav_RM(gs, thresholddaily,threshold_monthly,beghr, finhr, month); clear gs
[~, RH_med_day_anom ] = calc_daily_deseasonalize_remove_iav_RM(RH, thresholddaily,threshold_monthly,beghr, finhr, month); clear RH
%% determine actual drivers for MLR
drivers =  [ RH_med_day_anom' gs_med_day_anom'];  
%% check for collinearity 
[r,p] = corrcoef(drivers,'rows','pairwise');
VIF = diag(inv(r))'; 
%% MLR
drivers_label4fitlm = {'RH','PM gs','v_d'};
mdl = fitlm(drivers, o3ddv_med_day_anom,'VarNames',drivers_label4fitlm');
disp(mdl);
% check for outliers influencing model 
figure(1);subplot(2,2,1); plotResiduals(mdl,'caseorder', 'ResidualType', 'standardized');
figure(1);subplot(2,2,2); plotResiduals(mdl,'fitted', 'ResidualType', 'standardized'); 
figure(1);subplot(2,2,3); plotDiagnostics(mdl);
figure(1);subplot(2,2,4); plotDiagnostics(mdl,'cookd');
% remove outliers & re-run fitlm
ind_outliers = abs(mdl.Residuals.Standardized) > 3 | mdl.Diagnostics.CooksDistance > 0.065| ...
    mdl.Diagnostics.Leverage > 0.06;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers2 = drivers; drivers2(ind_outliers,:) = NaN;
    o3ddv_med_day_anom2 = o3ddv_med_day_anom; o3ddv_med_day_anom2(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers2,o3ddv_med_day_anom2,'VarNames',drivers_label4fitlm');
    disp(mdl);
end
% check for outliers influencing model 
figure(2);subplot(2,2,1); plotResiduals(mdl,'caseorder', 'ResidualType', 'standardized');
figure(2);subplot(2,2,2); plotResiduals(mdl,'fitted', 'ResidualType', 'standardized'); 
figure(2);subplot(2,2,3); plotDiagnostics(mdl);
figure(2);subplot(2,2,4); plotDiagnostics(mdl,'cookd');
ind_outliers =  abs(mdl.Residuals.Standardized) > 3 | mdl.Diagnostics.CooksDistance > 0.06 ;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers3 = drivers2; drivers3(ind_outliers,:) = NaN;
    o3ddv_med_day_anom3 = o3ddv_med_day_anom2; o3ddv_med_day_anom3(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers3,o3ddv_med_day_anom3,'VarNames',drivers_label4fitlm');
    disp(mdl);
end
% check for outliers influencing model 
figure(3);subplot(2,2,1); plotResiduals(mdl,'caseorder', 'ResidualType', 'standardized');
figure(3);subplot(2,2,2); plotResiduals(mdl,'fitted', 'ResidualType', 'standardized'); 
figure(3);subplot(2,2,3); plotDiagnostics(mdl);
figure(3);subplot(2,2,4); plotDiagnostics(mdl,'cookd');
ind_outliers =  abs(mdl.Residuals.Standardized) > 3 | mdl.Diagnostics.CooksDistance > 0.05 ;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers4 = drivers3; drivers4(ind_outliers,:) = NaN;
    o3ddv_med_day_anom4 = o3ddv_med_day_anom3; o3ddv_med_day_anom4(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers4,o3ddv_med_day_anom4,'VarNames',drivers_label4fitlm');
    disp(mdl);
end
% check for outliers influencing model 
figure(4);subplot(2,2,1); plotResiduals(mdl,'caseorder', 'ResidualType', 'standardized');
figure(4);subplot(2,2,2); plotResiduals(mdl,'fitted', 'ResidualType', 'standardized'); 
figure(4);subplot(2,2,3); plotDiagnostics(mdl);
figure(4);subplot(2,2,4); plotDiagnostics(mdl,'cookd');