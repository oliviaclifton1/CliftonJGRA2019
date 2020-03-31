%% oeclifton
%% FIGURE 6
% plot the diurnal cycles of estimated and observed ozone deposition
% velocity for each year (1992-2000), summertime averages
% distinguish contributions from stomata, cuticles, soil with colors
% this script is for Harvard Forest 
clear all;clc; clf;close all;
beghr = 10;
finhr = 17;
%% load observed ozone deposition velocity  
[ o3ddv ] = filter_o3ddv( );
% only examine 10/28/1991 onwards 
o3ddv = o3ddv(665*24+1:end);
%% define some time variables 
t1 = datetime(1991,10,28,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
time = t1:hours(1):t2; clear t1 t2;
time = time';
year = 1991:1:2000;
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
% load aerodynamic resistance (ra) calculated with calc_ra_harvard.m
load Ra_harvard
% convert to s/cm
ra=Ra./100; %s/cm
clear Ra
% load stomatal conductance in cm/s calculated with calc_pm_gs.m
load gs_pm_harvard
% remove hourly stomatal conductance with low VPD
gs(VPD<0.5) = NaN; 
%% calculate ground conductance according to Massman (2004)
Rg_dry = 200; %s/m, tuned value
Rg_wet = 10000; %s/m, tuned value
Rg = NaN(length(wet_soil_indicator),1); 
Rg(wet_soil_indicator==0)=Rg_dry;
Rg(wet_soil_indicator==1)=Rg_wet;
Rac = 25.*LAI./ustar; % s/m
Rbs = 40; % s/m
g_gr = 1./(Rac +Rbs+ Rg);
g_gr=g_gr*100; %cm/s
%% calculate cuticular conductance according to Massman (2004)
R_cut_dry = 5000./LAI; % s/m
g_cut_dry = (1./R_cut_dry)*100; % cm/s
%% calculate estimated ozone deposition velocity
r_leaf = rb + 1./(gs + g_cut_dry); 
g_leaf = 1./r_leaf;
perc_stom = gs./(gs + g_cut_dry);
r_soil = 1./g_gr;
r_canopy = 1./(1./r_leaf + 1./r_soil); 
g_canopy = 1./r_canopy;
o3ddv_estimated = 1./(ra + r_canopy );
%% calculate effective conductances 
eg_leaf_cut = (1-perc_stom).*(g_leaf./g_canopy).*o3ddv_estimated;
eg_leaf_stom = perc_stom.*(g_leaf./g_canopy).*o3ddv_estimated;
eg_gr = (g_gr./g_canopy).*o3ddv_estimated;
%% calculate diel cycles for all quanities 
[ o3ddv_mean_dc,o3ddv_ste_dc,~] = calc_mean_dc_jjas_80016(o3ddv);
[ o3ddv_estimated_mean_dc,o3ddv_estimated_ste_dc,~] = calc_mean_dc_jjas_80016(o3ddv_estimated);
[ eg_cut_dry_mean_dc,eg_cut_dry_ste_dc,~] = calc_mean_dc_jjas_80016(eg_leaf_cut);
[ eg_gr_dry_mean_dc,eg_gr_ste_dc,~] = calc_mean_dc_jjas_80016(eg_gr);
[ eg_stom_mean_dc,eg_stom_ste_dc,~] = calc_mean_dc_jjas_80016(eg_leaf_stom);
%% calculate IAV in bottom up vs, observed
o3ddv_estimated_dm = mean(o3ddv_estimated_mean_dc(beghr:finhr,:),1);
o3ddv_dm = mean(o3ddv_mean_dc(beghr:finhr,:),1);
[r,p] =corr(o3ddv_estimated_dm(2:end)',o3ddv_dm(2:end)','Type','Spearman');
% std(o3ddv_estimated_dm,0,'omitnan')/nanmean(o3ddv_estimated_dm);
% std(o3ddv_dm,0,'omitnan')/nanmean(o3ddv_dm);
% max(o3ddv_estimated_dm,[],'omitnan');
% min(o3ddv_estimated_dm,[],'omitnan');
% max(o3ddv_dm,[],'omitnan');
% min(o3ddv_dm,[],'omitnan');
%% calculate percentage ground
eg_gr_dry_dm = mean(eg_gr_dry_mean_dc(beghr:finhr,:),1);
perc_gr = eg_gr_dry_dm./o3ddv_estimated_dm;
% max(perc_gr);
% min(perc_gr);
% max(eg_gr_dry_dm);
% min(eg_gr_dry_dm);
% std(eg_gr_dry_dm,0,'omitnan')./nanmean(eg_gr_dry_dm);
%% plot diurnal cycles of observed and estimated ozone deposition velocity
% for each year, distinguish contributions from stomata, cuticles, and
% ground with colors 
color = [ 0.420,0.855,0.741;...
           0.667,0.824,0.549;...
          0.525,0.455,0.365];
panel_letter = {'a)','b)','c)','d)','e)','f)','g)','h)','i)','j)','k)'};
for y = 2:10
    subplot(4,3,y-1) ;
    temp = [eg_stom_mean_dc(:,y) eg_cut_dry_mean_dc(:,y) eg_gr_dry_mean_dc(:,y)];
    b = bar(1:1:24,temp(:,:),'stacked');
    b(1).FaceColor=color(1,:);
    b(2).FaceColor=color(2,:);
    b(3).FaceColor=color(3,:);   
    b(1).EdgeColor=[0 0 0];
    b(2).EdgeColor=[0 0 0];
    b(3).EdgeColor=[0 0 0];
    ylim([0 1.2]);
    hold on;
    h = errorbar(1:1:24+0.1, o3ddv_mean_dc(:,y),2.*o3ddv_ste_dc(:,y),'Color','k','LineWidth',1.5); hold on
    errorbar(1:1:24, o3ddv_estimated_mean_dc(:,y),2.*o3ddv_estimated_ste_dc(:,y),'.','Color','k','LineWidth',1);    
    text(15,1,num2str(year(y)),'FontName','Arial','FontWeight','Bold','FontSize',14);
    ax = gca;
    if y-1 == 1 || y-1 == 4 || y-1 == 7
        ylabel('v_d (cm s^{-1})');
        ax.YTick = 0:0.2:1.2;
    else
        ax.YTick = 0:0.2:1.2;
        ax.YTickLabel = '';      
    end   
    fontsize = 10;
    xlim([6,18]);
    if y-1 >= 7
        %define vars that are similar for all plots (i.e., x-axis)
        hourslabel = {'0';'2';'4';'6';'8';'10';'12';'14';'16';'18';'20';'22'};
        xtick = [1,3,5,7,9,11,13,15,17,19,21,23];
        set(gca,'XTick',xtick);
        set(gca,'XTickLabel',hourslabel );
        xlabel('hour of the day');
    else
        xtick = [1,3,5,7,9,11,13,15,17,19,21,23];
        set(gca,'XTick',xtick);
        set(gca,'XTickLabel','' );
    end
    set(gca,'FontName','Arial');
    set(gca,'FontSize',fontsize);
    text(0.05,0.9,panel_letter{y-1},'Color','k','FontSize',12,'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
    sub_pos = get(gca,'position'); % get subplot axis position
    set(gca,'position',sub_pos.*[1 1 1.14 1.14]) % stretch its width and height
    % set(gca,'YMinorTick','on');
    set(gca,'linewidth',1)
    hold off
    xlim([10 17]);
    if y == 9
        legend([b h],{'stomata', 'cuticles','soil','observed v_d'}, 'Box','off','FontSize',11,'Orientation','Horizontal','Location','southoutside');
    end
end