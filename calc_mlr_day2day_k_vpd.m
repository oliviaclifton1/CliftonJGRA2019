%% oeclifton
%% see Text S6
% multiple linear regression on ozone deposition velocity for Kane when we 
% remove P-M stomatal conductance with hourly VPD < 0.5 kPa
clear all; clc;clf; close all;
%% define some time variables 
beghr = 10; %9am
finhr = 17; %4pm
thresholddaily = 2; %how many NaNs are there allowed to be in daytime median calculation 
t1 = datetime(1997,4,29,0,0,0);
t2 = datetime(1997,10,24,23,0,0);
time = t1:minutes(60):t2; clear t1 t2;
%% load data from Kane Experimental Forest 
% load half-hourly relative humidity and atmospheric vapor pressure deficit 

% load ozone deposition velocity
[ o3ddv ] = read_o3ec_filter_kane( );
% load stomatal conductance calculated from calc_pm_gs_kane.m
load gs_pm_kane
%% convert half-hourly data to hourly 
VPD = reshape(VPD, [2 length(VPD)/2]);
VPD = mean(VPD,1); 
rh = reshape(rh, [2 length(rh)/2]);
rh = mean(rh,1); 
%% filter stomatal conductance for low VPD 
gs(VPD<0.5)=NaN;clear VPD
%% calculate deseasonalized daytime medians 
o3ddv_med_day = calc_daily_deseasonalize_remove_iav_RM_sk(time, ...
    o3ddv, thresholddaily,beghr,finhr);
rh_med_day = calc_daily_deseasonalize_remove_iav_RM_sk(time, ...
    rh, thresholddaily,beghr,finhr);
gs_med_day = calc_daily_deseasonalize_remove_iav_RM_sk(time, ...
    gs, thresholddaily,beghr,finhr);
%% only examine June-September 
ndays = length(time)/24;
time_in_days = reshape(time,[24 ndays]);
time_in_days = time_in_days(1,:);
ind = time_in_days.Month > 5 & time_in_days.Month < 10;
o3ddv_med_day = o3ddv_med_day(ind);
rh_med_day= rh_med_day(ind);
gs_med_day = gs_med_day(ind);
%% calculate correlation between stomatal conductance & RH
[r,p] = corrcoef(gs_med_day,rh_med_day,'rows','pairwise');
%% MLR
actual_drivers =  [rh_med_day' gs_med_day'];  
drivers_label4fitlm = {'rh', 'gs','vd'};
mdl = fitlm(actual_drivers,o3ddv_med_day,'VarNames',drivers_label4fitlm');
disp(mdl);
%% calculate variance inflation factor
R0 = corrcoef(actual_drivers,'rows','pairwise');
VIF = diag(inv(R0))';
%% residual analysis 
% see what residuals look like
figure(1);subplot(3,2,1); plotResiduals(mdl,'caseorder',...
    'ResidualType','standardized');
figure(1);subplot(3,2,2); qqplot(mdl.Residuals.Standardized);
figure(1);subplot(3,2,3); plotResiduals(mdl,'fitted',...
    'ResidualType','standardized'); 
figure(1);subplot(3,2,4); plotDiagnostics(mdl);
figure(1);subplot(3,2,5); plotDiagnostics(mdl,'cookd');
% remove outliers and re-run model
ind_outliers = abs(mdl.Residuals.Standardized) > 3 | ...
    mdl.Diagnostics.CooksDistance > 0.08 ;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    actual_drivers2 = actual_drivers; 
    actual_drivers2(ind_outliers,:) = NaN;
    o3ddv_med_day(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(actual_drivers2,o3ddv_med_day,...
        'VarNames',drivers_label4fitlm');
    disp(mdl);
end
% see what residuals look like
figure(2);subplot(3,2,1); plotResiduals(mdl,'caseorder',...
    'ResidualType','standardized');
figure(2);subplot(3,2,2); qqplot(mdl.Residuals.Standardized);
figure(2);subplot(3,2,3); plotResiduals(mdl,'fitted',...
    'ResidualType','standardized'); 
figure(2);subplot(3,2,4); plotDiagnostics(mdl);
figure(2);subplot(3,2,5); plotDiagnostics(mdl,'cookd');
% remove outliers and re-run model
ind_outliers = abs(mdl.Residuals.Standardized) > 3 |...
    mdl.Diagnostics.CooksDistance > 0.1 ;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    actual_drivers3 = actual_drivers2; 
    actual_drivers3(ind_outliers,:) = NaN;
    o3ddv_med_day(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(actual_drivers3,o3ddv_med_day,...
        'VarNames',drivers_label4fitlm');
    disp(mdl);
end
% see what residuals look like
figure(3);subplot(3,2,1); plotResiduals(mdl,'caseorder',...
    'ResidualType','standardized');
figure(3);subplot(3,2,2); qqplot(mdl.Residuals.Standardized);
figure(3);subplot(3,2,3); plotResiduals(mdl,'fitted',...
    'ResidualType','standardized'); 
figure(3);subplot(3,2,4); plotDiagnostics(mdl);
figure(3);subplot(3,2,5); plotDiagnostics(mdl,'cookd');
