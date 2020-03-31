%% oeclifton
%% TEXT S2
% plot lai for each year (1998-2015) at each measurement plot (distinguish 
% wind sectors with colors and black is difference between them), and plot
% muliyear means for averaging across all measurement plots in a given wind 
% sector 
% this script is for harvard forest 
clc;clear all;clf;close all;
%% read in data
% Munger, J. W., & Wofsy, S. (1999a). Biomass Inventories at Harvard Forest EMS Tower since 1993.
% Harvard Forest Data Archive: HF069.
% https://doi.org/10.6073/pasta/37ff12d47894a73ddd9d86c1225e2dc8
input = 'hf069-01-LAI-plot';
table1 = readtable(strcat(input,'.csv'), 'ReadVariableNames', false,...
    'Format','%s%d%d%s%f%f','HeaderLines', 1, 'TreatAsEmpty','NA'); 
year = table1.Var2;
doy = table1.Var3;
whichplot = table1.Var4;
lai = table1.Var5;
se = table1.Var6; 
%% get rid of "X" plots and "PAR plot", & G3, H3, & H4 plots, 
% which are only used for 1998 + 1999 and have very low LAI 
plot_number = char(whichplot);
ind0 = plot_number(:,1) == 'X' | plot_number(:,1) == 'P' | ...
    (plot_number(:,1) == 'G' & plot_number(:,2) == '3') | ...
    (plot_number(:,1) == 'H' & (plot_number(:,2) == '3'| ...
    plot_number(:,2) == '4'));
year(ind0) = [];
doy(ind0) = [];
whichplot(ind0) = [];
lai(ind0) = [];
se(ind0) = [];
plot_number(ind0,:) = [];
clear ind0 input table1
%% average across NW & SW plots each year, linearly interpolate to daily
% also plot each plot for each year
years = unique(year);
nyears = numel(years);

laiq_sw_avg = zeros(nyears,365); laiq_sw_avg(:,:) = NaN;
laiq_nw_avg = zeros(nyears,365); laiq_nw_avg(:,:) = NaN;

for y = 1:nyears
    if y < 9
        figure(1);
        subplot(4,2,y);
    else
        figure(2);
        subplot(4,2,y-8);
    end
    
    %calculate lai average for SW 
    ind_sw = year == years(y) & (plot_number(:,1) == 'A' | ...
        plot_number(:,1) == 'B'| plot_number(:,1) == 'C' | ...
        plot_number(:,1) == 'D');
    doy_sw_thisyear = doy(ind_sw); 
    days_sw_thisyear = unique(doy_sw_thisyear);clear ind_sw doy_sw_thisyear
    lai_sw_avg = zeros(numel(days_sw_thisyear),1); lai_sw_avg(:,:) = NaN;
    % if there are measurements for a given day, then average across them
    % assumption is that there is more than one site with measurements
    for d = 1:numel( days_sw_thisyear)
            ind_sw = doy == days_sw_thisyear(d) & year == years(y) & ...
                (plot_number(:,1) == 'A' | plot_number(:,1) == 'B'|  ...
                plot_number(:,1) == 'C' | plot_number(:,1) == 'D');
            lai_sw_avg(d) = nanmean(lai(ind_sw));
    end
    
    %calculate lai average for NW 
    ind_nw = year == years(y) & (plot_number(:,1) == 'E' | ...
        plot_number(:,1) == 'F'| plot_number(:,1) == 'G' | ...
        plot_number(:,1) == 'H');
    doy_nw_thisyear = doy(ind_nw); 
    days_nw_thisyear = unique(doy_nw_thisyear);clear ind_nw doy_nw_thisyear
    lai_nw_avg = zeros(numel( days_nw_thisyear),1); lai_nw_avg(:,:) = NaN;
    % if there are measurements for a given day, then average across them
    % assumption is that there is more than one site with measurements
    for d = 1:numel( days_nw_thisyear)
            ind_nw = doy == days_nw_thisyear(d) & year == years(y) & ...
                (plot_number(:,1) == 'E' | plot_number(:,1) == 'F'| ...
                plot_number(:,1) == 'G' | plot_number(:,1) == 'H');
            lai_nw_avg(d) = nanmean(lai(ind_nw));
    end
    
    %figure out latest start date out of all years, and earliest end date
    if y == 1
        temp_nw_start = days_nw_thisyear(1);
        temp_sw_start = days_sw_thisyear(1);
        temp_nw_end = days_nw_thisyear(end);
        temp_sw_end = days_sw_thisyear(end);
    else
        if  days_nw_thisyear(1) > temp_nw_start
            temp_nw_start = days_nw_thisyear(1);
        end
        if  days_sw_thisyear(1) > temp_sw_start
            temp_sw_start = days_sw_thisyear(1);
        end
        if  days_nw_thisyear(end) < temp_nw_end
            temp_nw_end = days_nw_thisyear(end);
        end
        if  days_sw_thisyear(end) < temp_sw_end
            temp_sw_end = days_sw_thisyear(end);
        end
    end
    days_nw_thisyear = double(days_nw_thisyear);
    days_sw_thisyear = double(days_sw_thisyear);

    % linearly interpolate lai_sw_avg + lai_nw_avg to daily
    xx = (days_nw_thisyear(1):1:days_nw_thisyear(end));
    temp_interpd = interp1(days_nw_thisyear,lai_nw_avg,xx,'linear');
    laiq_nw_avg(y,xx(1):xx(end)) = temp_interpd';

    xx = (days_sw_thisyear(1):1:days_sw_thisyear(end));
    temp_interpd = interp1(days_sw_thisyear,lai_sw_avg,xx,'linear');
    laiq_sw_avg(y,xx(1):xx(end)) = temp_interpd';

    % plot individual plot's LAI, SW in red, NW in blue
    ind1 = year == years(y);
    plots_yearly = unique(whichplot(ind1));

    for p = 1:numel(plots_yearly)
        ind2 = strcmp(whichplot, plots_yearly(p)) & ind1 == 1;
        temp = char(plots_yearly(p));
        if temp(1) == 'A' || temp(1) == 'B' || temp(1) == 'C' || ...
                temp(1) == 'D'
            errorbar(doy(ind2),lai(ind2),2.*se(ind2),'r'); hold on;
        elseif temp(1) == 'E' || temp(1) == 'F' || temp(1) == 'G' || ...
                temp(1) == 'H'
            errorbar(doy(ind2),lai(ind2),2.*se(ind2),'b'); hold on;  
        end
        if y < 3 && sum(lai(ind2) < 3) == numel(lai(ind2))
            disp(year(y));
            disp(plots_yearly(p));
            disp(doy(ind2));
        end
    end
    h1 = plot(days_sw_thisyear, lai_sw_avg, 'r','LineWidth',3); hold on;
    h2 = plot(days_nw_thisyear, lai_nw_avg, 'b','LineWidth',3); hold on;
    if numel(days_nw_thisyear) == numel(days_sw_thisyear) 
        if days_nw_thisyear == days_sw_thisyear
            plot(days_nw_thisyear, lai_nw_avg-lai_sw_avg, 'k',...
                'LineWidth',3); hold on;
        end
    end
    legend([h1, h2], 'SW','NW');
    xlim([100 340]);
    ylim([0 8]); ylabel('lai');
    title(years(y));
    set(gca,'YMinorTick','on');    set(gca,'XMinorTick','on');
    ax.XGrid = 'on';    ax.YGrid = 'on'; 
    set(gca,'fontsize',10);set(gca,'FontWeight','Bold');
    set(gca, 'FontName','Arial'); set(gca,'linewidth',1);
end

%% average linearly-interpolated daily LAI for NW & SW for multiyear mean
nnans_nw = sum(laiq_nw_avg~=laiq_nw_avg);
nnans_sw = sum(laiq_sw_avg~=laiq_sw_avg);

laiq_nw_avg_mm = nanmean(laiq_nw_avg,1);
laiq_sw_avg_mm = nanmean(laiq_sw_avg,1);

laiq_nw_avg_mm(nnans_nw > 5) = NaN;
laiq_sw_avg_mm(nnans_sw > 5) = NaN;
%% figure out interannual variability
iav_lai_sw = std(laiq_sw_avg,0,1,'omitnan')./laiq_sw_avg_mm;
iav_lai_nw = std(laiq_nw_avg,0,1,'omitnan')./laiq_nw_avg_mm;
%% print some stuff to screen
% average difference between NW and SW
nanmean(laiq_nw_avg_mm-laiq_sw_avg_mm)
%% plot multiyear mean
figure(3);
plot(laiq_nw_avg_mm,'b','LineWidth',3);
hold on;
plot(laiq_sw_avg_mm,'r','LineWidth',3);
xlim([125 300]); xlabel('day of year');
set(gca,'YMinorTick','on');set(gca,'XMinorTick','on');
ax.XGrid = 'on';ax.YGrid = 'on'; 
set(gca,'fontsize',14);set(gca,'FontWeight','Bold');
set(gca, 'FontName','Arial'); set(gca,'linewidth',1);
legend('NW','SW');ylabel('leaf area index (m^2 m^{-2})');

%% save variables
save('lai_harvard.mat','laiq_nw_avg_mm','laiq_sw_avg_mm');