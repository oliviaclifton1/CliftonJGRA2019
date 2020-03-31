%% oeclifton
%% FIGURE 8 and Text S8
% this script plots hourly ozone deposition velocity, ozone flux, ozone 
% concentraion against an exponential function of temperature 
% also performs regression for hours when wind comes from northwest
% this script is for harvard forest 
clear all;clc;clf;close all;
%% load and filter o3ddv 
[ o3ddv ] = filter_o3ddv( );
%% load o3 concentration and fluxes
[ o3mlb,fo3] = read_o3ec();
%% begin time series at 10/28/1991
o3ddv = o3ddv(665*24+1:end);
fo3 = fo3(665*24+1:end);
o3mlb = o3mlb(665*24+1:end);
%% remove corresponding to missing vd
fo3(o3ddv ~= o3ddv)=NaN;
o3mlb(o3ddv ~= o3ddv)=NaN;
%% load temperature and wind direction
[Ta279m, ~, ~, wdir] = read_hf004();
%% create exponential temperature dependence 
met = exp(0.17*(Ta279m-30));
%% create index for NW hours 
indNW = wdir>270;
%% define some time variables
t1 = datetime(1991,10,28,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
t_hourly = t1:minutes(60):t2; clear t1 t2;
t_hourly=t_hourly';
%% create indices for different time periods
% for summer (June-Sept) & daytime (9am-4pm)
ind_month_tod = t_hourly.Month >= 6 & ...
    t_hourly.Month <= 9 & ...
    t_hourly.Hour>=9 & t_hourly.Hour <= 16;
% for 1998
ind1998 = (t_hourly.Year == 1998) ; 
% for 1999
ind1999 = (t_hourly.Year == 1999) ; 
% for all years except 1998 and 1999
indother = (t_hourly.Year ~= 1998 & t_hourly.Year ~= 1999) ;  
%% plot temperature dependence vs. vd/flux/concentration
figure(1);
plottingfn(met,o3ddv,[1,4,7],indNW, indother, ind1998, ...
    ind1999, ind_month_tod, [-1 3],...
    'v_d (cm s^{-1})')
plottingfn(met, -1.*fo3, [2,5,8],indNW, indother, ind1998, ...
    ind1999, ind_month_tod, [-100 300],...
    'ozone flux (micromol m^{-2} s^{-1})')
plottingfn(met, o3mlb, [3,6,9],indNW, indother, ind1998, ...
    ind1999, ind_month_tod, [0 200],...
    'ozone (ppb)')
%% Regression for all years except 1998 and 1999
mdl = fitlm(met(indother & ind_month_tod & indNW), ...
    -1.*fo3(indother & ind_month_tod & indNW)); 
disp(mdl);
drivers = met(indother & ind_month_tod & indNW);
o3ddv_med_day_anom =-1.*fo3(indother & ind_month_tod & indNW);
ind_outliers = abs(mdl.Residuals.Standardized) > 3 | ...
    mdl.Diagnostics.CooksDistance > 0.04;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers2 = drivers; drivers2(ind_outliers,:) = NaN;
    o3ddv_med_day_anom2 = o3ddv_med_day_anom; ...
        o3ddv_med_day_anom2(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers2,o3ddv_med_day_anom2);
    disp(mdl);
end
% check for outliers influencing model 
figure(2);
subplot(2,2,1);plotResiduals(mdl,'caseorder','ResidualType',...
    'standardized');
subplot(2,2,2);plotResiduals(mdl,'fitted','ResidualType',...
    'standardized'); 
subplot(2,2,3);plotDiagnostics(mdl);
subplot(2,2,4);plotDiagnostics(mdl,'cookd');
ind_outliers =  abs(mdl.Residuals.Standardized) > 3 ;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers3 = drivers2; drivers3(ind_outliers,:) = NaN;
    o3ddv_med_day_anom3 = o3ddv_med_day_anom2; ...
        o3ddv_med_day_anom3(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers3,o3ddv_med_day_anom3);
    disp(mdl);
end
% check for outliers influencing model 
figure(3);
subplot(2,2,1);plotResiduals(mdl,'caseorder','ResidualType',...
    'standardized');
subplot(2,2,2);plotResiduals(mdl,'fitted','ResidualType',...
    'standardized'); 
subplot(2,2,3);plotDiagnostics(mdl);
subplot(2,2,4);plotDiagnostics(mdl,'cookd');
%% Regression for 1998
mdl = fitlm(met(ind1998 & ind_month_tod & indNW),...
    -1.*fo3(ind1998 & ind_month_tod & indNW)); 
disp(mdl);
drivers = met(ind1998 & ind_month_tod & indNW);
o3ddv_med_day_anom =-1.*fo3(ind1998 & ind_month_tod & indNW);
ind_outliers = abs(mdl.Residuals.Standardized) > 3 | ...
    mdl.Diagnostics.CooksDistance > 0.16 | mdl.Diagnostics.Leverage > 0.05;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers2 = drivers; drivers2(ind_outliers,:) = NaN;
    o3ddv_med_day_anom2 = o3ddv_med_day_anom; ...
        o3ddv_med_day_anom2(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers2,o3ddv_med_day_anom2);
    disp(mdl);
end
%check for outliers influencing model 
figure(5);
subplot(2,2,1); plotResiduals(mdl,'caseorder', 'ResidualType',...
    'standardized');
subplot(2,2,2); plotResiduals(mdl,'fitted', 'ResidualType',...
    'standardized'); 
subplot(2,2,3); plotDiagnostics(mdl);
subplot(2,2,4); plotDiagnostics(mdl,'cookd');
ind_outliers =  abs(mdl.Residuals.Standardized) > 3 | ...
    mdl.Diagnostics.CooksDistance > 0.06 | mdl.Diagnostics.Leverage>0.04;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers3 = drivers2; drivers3(ind_outliers,:) = NaN;
    o3ddv_med_day_anom3 = o3ddv_med_day_anom2; ...
        o3ddv_med_day_anom3(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers3,o3ddv_med_day_anom3);
    disp(mdl);
end
% check for outliers influencing model 
figure(6);
subplot(2,2,1); plotResiduals(mdl,'caseorder', 'ResidualType',...
    'standardized');
subplot(2,2,2); plotResiduals(mdl,'fitted', 'ResidualType',...
    'standardized'); 
subplot(2,2,3); plotDiagnostics(mdl);
subplot(2,2,4); plotDiagnostics(mdl,'cookd');

ind_outliers =  abs(mdl.Residuals.Standardized) > 3 | ...
    mdl.Diagnostics.CooksDistance > 0.045 | mdl.Diagnostics.Leverage>0.045;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers4 = drivers3; drivers4(ind_outliers,:) = NaN;
    o3ddv_med_day_anom4 = o3ddv_med_day_anom3; ...
        o3ddv_med_day_anom4(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers4,o3ddv_med_day_anom4);
    disp(mdl);
end
% check for outliers influencing model 
figure(7);
subplot(2,2,1); plotResiduals(mdl,'caseorder','ResidualType',...
    'standardized');
subplot(2,2,2); plotResiduals(mdl,'fitted','ResidualType',...
    'standardized'); 
subplot(2,2,3); plotDiagnostics(mdl);
subplot(2,2,4); plotDiagnostics(mdl,'cookd');
ind_outliers =  abs(mdl.Residuals.Standardized) > 3 | ...
    mdl.Diagnostics.CooksDistance > 0.04;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers5 = drivers4; drivers5(ind_outliers,:) = NaN;
    o3ddv_med_day_anom5 = o3ddv_med_day_anom4; ...
        o3ddv_med_day_anom5(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers5,o3ddv_med_day_anom5);
    disp(mdl);
end
% check for outliers influencing model 
figure(8);
subplot(2,2,1); plotResiduals(mdl,'caseorder', 'ResidualType',...
    'standardized');
subplot(2,2,2); plotResiduals(mdl,'fitted', 'ResidualType',...
    'standardized'); 
subplot(2,2,3); plotDiagnostics(mdl);
subplot(2,2,4); plotDiagnostics(mdl,'cookd');

ind_outliers =  abs(mdl.Residuals.Standardized) > 3 | ...
    mdl.Diagnostics.Leverage > 0.045;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers6 = drivers5; drivers6(ind_outliers,:) = NaN;
    o3ddv_med_day_anom6 = o3ddv_med_day_anom5; ...
        o3ddv_med_day_anom6(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers6,o3ddv_med_day_anom6);
    disp(mdl);
end
% check for outliers influencing model 
figure(9);
subplot(2,2,1); plotResiduals(mdl,'caseorder',...
    'ResidualType', 'standardized');
subplot(2,2,2); plotResiduals(mdl,'fitted',...
    'ResidualType', 'standardized'); 
subplot(2,2,3); plotDiagnostics(mdl);
subplot(2,2,4); plotDiagnostics(mdl,'cookd');

%% regression for 1999
mdl = fitlm(met(ind1999 & ind_month_tod & indNW), ...
    -1.*fo3(ind1999 & ind_month_tod & indNW)); % 'Intercept',false);
disp(mdl);
drivers = met(ind1999 & ind_month_tod & indNW);
o3ddv_med_day_anom =-1.*fo3(ind1999 & ind_month_tod & indNW);
ind_outliers = abs(mdl.Residuals.Standardized) > 3 | ...
    mdl.Diagnostics.CooksDistance > 0.1 | mdl.Diagnostics.Leverage>0.018;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers2 = drivers; drivers2(ind_outliers,:) = NaN;
    o3ddv_med_day_anom2 = o3ddv_med_day_anom; ...
        o3ddv_med_day_anom2(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers2,o3ddv_med_day_anom2);
    disp(mdl);
end
% check for outliers influencing model 
figure(8);
subplot(2,2,1); plotResiduals(mdl,'caseorder','ResidualType',...
    'standardized');
subplot(2,2,2); plotResiduals(mdl,'fitted','ResidualType',...
    'standardized'); 
subplot(2,2,3); plotDiagnostics(mdl);
subplot(2,2,4); plotDiagnostics(mdl,'cookd');
ind_outliers =  abs(mdl.Residuals.Standardized) > 3 | ...
    mdl.Diagnostics.CooksDistance > 0.05 ;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers3 = drivers2; drivers3(ind_outliers,:) = NaN;
    o3ddv_med_day_anom3 = o3ddv_med_day_anom2; ...
        o3ddv_med_day_anom3(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers3,o3ddv_med_day_anom3);
    disp(mdl);
end
% check for outliers influencing model 
figure(9);
subplot(2,2,1); plotResiduals(mdl,'caseorder','ResidualType',...
    'standardized');
subplot(2,2,2); plotResiduals(mdl,'fitted','ResidualType',...
    'standardized'); 
subplot(2,2,3); plotDiagnostics(mdl);
subplot(2,2,4); plotDiagnostics(mdl,'cookd');
ind_outliers =  abs(mdl.Residuals.Standardized) > 3 | ...
    mdl.Diagnostics.CooksDistance > 0.03 | mdl.Diagnostics.Leverage>0.027;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers4 = drivers3; drivers4(ind_outliers,:) = NaN;
    o3ddv_med_day_anom4 = o3ddv_med_day_anom3; ...
        o3ddv_med_day_anom4(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers4,o3ddv_med_day_anom4);
    disp(mdl);
end
% check for outliers influencing model 
figure(10);
subplot(2,2,1); plotResiduals(mdl,'caseorder','ResidualType',...
    'standardized');
subplot(2,2,2); plotResiduals(mdl,'fitted','ResidualType',...
    'standardized'); 
subplot(2,2,3); plotDiagnostics(mdl);
subplot(2,2,4); plotDiagnostics(mdl,'cookd');
ind_outliers =  abs(mdl.Residuals.Standardized) > 3  | ...
    mdl.Diagnostics.Leverage>0.029;
if sum(ind_outliers) > 0
    disp({'n outliers',sum(ind_outliers)});
    drivers5 = drivers4; drivers5(ind_outliers,:) = NaN;
    o3ddv_med_day_anom5 = o3ddv_med_day_anom4; ...
        o3ddv_med_day_anom5(ind_outliers) = NaN;
    clear mdl
    mdl = fitlm(drivers5,o3ddv_med_day_anom5);
    disp(mdl);
end
% check for outliers influencing model 
figure(11);
subplot(2,2,1); plotResiduals(mdl,'caseorder','ResidualType',...
    'standardized');
subplot(2,2,2); plotResiduals(mdl,'fitted', 'ResidualType',...
    'standardized'); 
subplot(2,2,3); plotDiagnostics(mdl);
subplot(2,2,4); plotDiagnostics(mdl,'cookd');
%% this function plots the temperature dependence vs. vd/flux/concentration
% for a given index
function [ ] = plottingfn( met,o3ddv, subplot_no, indNW, indother, ...
    ind1998, ind1999, ind_month_tod,ylimits, ytitle )
panel_letter = {'a)','b)','c)','d)','e)','f)','g)','h)','i)','j)'};
blue = [0.541,0.675,0.922];
fontsize = 12;
subplot(3,3,subplot_no(1));
scatter(met(indother & ind_month_tod),o3ddv(indother & ind_month_tod),...
    25,'k','filled'); hold on 
title('all years except 1998 and 1999');
ylim(ylimits);
ylabel(ytitle);
xlim([0 2]);
ax=gca; ax.FontSize = fontsize; ax.FontName = 'Arial'; 
set(gca,'XMinorTick','on');set(gca,'YMinorTick','on');
text(0.05,0.9,panel_letter{subplot_no(1)},'Color','k','FontSize',16,...
    'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
box on
subplot(3,3,subplot_no(2));
scatter(met(ind1998 & ind_month_tod),o3ddv(ind1998 & ind_month_tod),25,...
    'k','filled'); hold on
scatter(met(ind1998 & indNW & ind_month_tod),o3ddv(ind1998 & indNW & ...
    ind_month_tod),25,blue,'filled'); hold on
title('1998');
ylim(ylimits);
ylabel(ytitle);
xlim([0 2]);
ax=gca; ax.FontSize = fontsize; ax.FontName = 'Arial'; 
set(gca,'XMinorTick','on');set(gca,'YMinorTick','on');
text(0.05,0.9,panel_letter{subplot_no(2)},'Color','k','FontSize',16,...
    'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
box on
subplot(3,3,subplot_no(3));
scatter(met(ind1999 & ind_month_tod),o3ddv(ind1999 & ind_month_tod),25,...
    'k','filled'); hold on
scatter(met(ind1999 & indNW & ind_month_tod),o3ddv(ind1999 & indNW & ...
    ind_month_tod),25,blue,'filled'); hold on
title('1999');
ylim(ylimits);
ylabel(ytitle);
xlim([0 2]);
xlabel('e^{0.17*(T-30)}');
text(0.05,0.9,panel_letter{subplot_no(3)},'Color','k','FontSize',16,...
    'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
ax=gca; ax.FontSize = fontsize; ax.FontName = 'Arial'; 
set(gca,'XMinorTick','on');set(gca,'YMinorTick','on');
box on
end
