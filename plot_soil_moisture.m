%% oeclifton
%% FIGURE 5
% this script plot time series of soil moisture and indictator used for 
% determining whether soil is wet or dry in ozone deposition to soil model 
clear all;clc;clf; close all; 
%% load Harvard Forest soil moisture data 
% Davidson, E., & Savage, K. (1999). Soil Respiration, Temperature and Moisture at Harvard Forest EMS
% Tower since 1995. Harvard Forest Data Archive: HF006.
% https://doi.org/10.6073/pasta/33ba3432103297fe0644de6e0898f91f
fileID = fopen('hf006-01-soil-respiration.csv');
formatSpec = '%s %{yyyy-MM-dd}D %d %d %f %f %f %f %s %s %s';
C = textscan(fileID, formatSpec, 'HeaderLines',1,'TreatAsEmpty','NA',...
    'Delimiter',',');
site = C(1,10); site = site{1,1};
soilm = C(1,8); soilm = soilm{1,1};
date = C(1,2); year = date{1,1}.Year; 
doy = C(1,3); doy = doy{1,1};
nyears_sm = 6;
years_sm = 1995:1:2000;
%% organize variables by name of site 
[G, TID] = findgroups(site);
soilm_by_site = NaN(numel(TID),497); %497 is max # of obs for a site
year_by_site = NaN(numel(TID),497);
doy_by_site = NaN(numel(TID),497);
for i = 1:numel(TID)
    ind = G == i;
    soilm_by_site(i,1:sum(ind)) = soilm(ind);
    year_by_site(i,1:sum(ind)) = year(ind); 
    doy_by_site(i,1:sum(ind)) = doy(ind); 
end
% remove Charlton, Dry Down, Farm, Hardwood, & Montauk sites 
TID_new = TID; TID_new(1:5, :) = []; 
soilm_by_site_new = soilm_by_site;
year_by_site_new = year_by_site;
doy_by_site_new = doy_by_site;
soilm_by_site_new(1:5, :) = [];
year_by_site_new(1:5, :) = [];
doy_by_site_new(1:5, :) = [];
clear soilm_by_site year_by_site doy_by_site ind TID G C fileID ...
    formatSpec site soilm doy year
%% linearly interpolate soil moisture measurements 
soil_m_interp = zeros(nyears_sm, 365, numel(TID_new));
soil_m_interp(:,:,:) = NaN;
for y = 1:nyears_sm
    ind2 = year_by_site_new == years_sm(y) & doy_by_site_new >= 91 & ...
        doy_by_site_new <= 304 & soilm_by_site_new == soilm_by_site_new;
    for i = 1:numel(TID_new)
         % linearly interpolate soil moisture, need to remove NaNs 
         if sum(ind2(i,:)) > 1 %make sure there is data for a site + year
            soil_m_interp(y,91:304,i) = ...
                interp1(doy_by_site_new(i,ind2(i,:)),...
                soilm_by_site_new(i,ind2(i,:)),91:1:304); 
         end
    end
end
%% average soil moisture across measurement sites 
soil_m_interp_avg = mean(soil_m_interp,3);
%% average soil moisture across all measurement sites except NWF
% soil moisture at this site is much higher than elsewhere
% but does not have data for 2000
soil_m_interp(:,:,1) = [];
soil_m_interp_avg_noNWF = mean(soil_m_interp,3);
%% clean up 
clear soil_m_interp TID_new doy_by_site_new soilm_by_site_new ind2
%% load wet soil indicator calculated in plot_cumprec.m
% (actual cumulative precipitation minus linear increase)
% note this variable is for 1992 to 2000
load wet_soil_indicator
%% plot time series of soil moisture for summer
% 1 subplot for each year (1995-2000)
panel_letter = {'a)','b)','c)','d)','e)','f)','g)','h)','i)','j)','k)'};
grey = [0.733,0.733,0.733];
for y = 1:6
    figure(1);
    subplot(3,3,y);
    days = 152:1:273;
    plot(days, soil_m_interp_avg(y,152:273),'k','LineWidth',1); hold on;
    plot(days, soil_m_interp_avg_noNWF(y,152:273),'Color',grey,...
        'LineWidth',1); hold on;    
    ax = gca;  ylim([0 0.6]); ax.YColor = 'k';
    if years_sm(y)==1995 
       ylabel('volumetric soil moisture (g_{H_2O} g_{soil}^{-1})');
    end
    yyaxis right
    % plot soil moisture indicator
    plot(days, distance_from_cumprec(y+3,:),'r','LineWidth',1);
    % calculate correlation 
    [r, p] = corr(soil_m_interp_avg_noNWF(y,152:273)',...
        distance_from_cumprec(y+3,:)', 'Type', 'Pearson',...
        'rows','pairwise');
    ax=gca; ylim([-200 200]); 
    if years_sm(y)==1997 
        ylabel('distance from threshold (mm)')
    end
    ax.YColor = 'k';
    xlim([152 273]);  ax.XTick = 152:20:273;  ax.XGrid = 'on'; 
    if years_sm(y) >= 1998
        xlabel('day of year');
    else
        ax.XTickLabel  = '';
    end 
    set(gca,'fontsize',11);
    set(gca, 'FontName','Arial'); set(gca,'linewidth',1);
    title(years_sm(y));  
    text(0.05,0.9,panel_letter{y},'Color','k','FontSize',16,...
        'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
    text(0.6,0.8,{['r=' num2str(round(r,3,'significant'),'%1.2f')],...
        ['p=' num2str(round(p,3,'significant'),'%1.2f')]},'Color','k',...
        'FontSize',12,'FontName','Arial','FontWeight','Bold',...
        'Units','Normalized');    
    sub_pos = get(gca,'position'); % get subplot axis position
    set(gca,'position',sub_pos.*[1 1 1.04 1.04]) % stretch its width and height
end
legend({'soil moisture', 'soil moisture without NWF plot', ...
    'distance from cumulative precipitation threshold'}, ...
    'Orientation', 'Horizontal');