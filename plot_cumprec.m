%% oeclifton
%% FIGURE 4
% calculation of cumulative precipitation at Harvard Forest over summer
% (defined as June-September)
% plot cumulative precipitation for each year, as well as linear increase
% in precipitation used to indicate whether soil is wet or dry
% also here calculate distance from linear indicator that is used in soil
% moisture figure & binary wet soil indicator 
clc;clear all;close all;clf;
%% create years array
years = 1992:1:2000; % years with O3 EC & corresponding meteorology
%% load precipitation data 
from_1990 = 1;
[ prec, ~, time ] = read_prec(from_1990 );
%% replace days w/ missing prec with multiyear monthly mean 1990-2000
% create monthly mean precipitation 
prec_mm = NaN(12,1);
for m = 1:12
    ind = time.Month == m;
    prec_mm(m) = nanmean(prec(ind));
end
clear ind 
% find missing precipitation values
ind_missing = prec ~= prec;
% replace with multiyear mean for the month
temp = time.Month;
m = temp(ind_missing);
prec_filler= NaN(length(m),1);
for i = 1:  length(m)
    prec_filler(i) = prec_mm(m(i));
end
prec(ind_missing) = prec_filler;
%% calculate cumulative sum
prec_cumsum= NaN(9,122); 
for y = 1:9
    ind = time.Year == years(y) & time.Month >= 6 & time.Month <= 9;
    prec_cumsum(y,:) = cumsum(prec(ind));
end
%% create linear increase in precipitation from june 1 to sept 30
% based on total precip of 450 mm at the end
prec_cumsum_mm = cumsum(ones(1,122).*(450/122));
%% plot cumulative precipitation and linear increase for 1992 to 2000  
figure(1);
panel_letter = {'a)','b)','c)','d)','e)','f)','g)','h)','i)','j)','k)'};
for y = 1:9
    ind = time.Year == years(y) & time.Month >= 6 & time.Month <= 9;
    ind_missing_new = ind_missing(ind);
    subplot(4,3,y)
    if y == 1 || y == 5 || y == 9
        days4label = 153:1:274;
    else 
        days4label = 152:1:273;
    end
    plot(days4label,prec_cumsum(y,:),'LineWidth',1.5); hold on 
    plot(days4label,prec_cumsum_mm,'k','LineWidth',2); hold on;
    plot(days4label(ind_missing_new),prec_cumsum(y,ind_missing_new),'r^');
    title(years(y))
    ylim([0 600]);
    xlim([days4label(1) days4label(end)]);
    if y == 4
        ylabel('precipitation since June 1 (mm)');
    end
    set(gca,'FontName','Arial');
    set(gca,'FontSize',10);
    ax = gca;
    if y == 1 || y == 4|| y == 7     
        ax.YTick = 0:200:600;
    else
        ax.YTick = '';
    end
    text(0.05,0.9,panel_letter{y},'Color','k','FontSize',16,'FontName','Arial','FontWeight','Bold', 'Units','Normalized');
    hourslabel = {'160';'180';'200';'220';'240';'260'};
    xtick = [160,180,200,220,240,260];
    set(gca,'XTick',xtick);
    set(gca,'XTickLabel',hourslabel );
    sub_pos = get(gca,'position'); % get subplot axis position
    set(gca,'position',sub_pos.*[0.9 1.0 1.04 0.95]) % stretch its width and height
end
%% calculate distance from indicator 
distance_from_cumprec = prec_cumsum-prec_cumsum_mm;
%% calculate wet soil indictor 
wet_soil_indicator=NaN(9,122);
wet_soil_indicator(distance_from_cumprec>0)=1;
wet_soil_indicator(distance_from_cumprec<0)=0;
t1 = datetime(1991,10,28,0,0,0);
t2 = datetime(2000,12,12,23,0,0);
t_80016_daily = t1:days(1):t2;clear t1 t2;
temp=NaN(3334,1);
for y = 1:9
    beg = find(t_80016_daily.Year == years(y) & t_80016_daily.Month == 6 & t_80016_daily.Day == 1);
    fin = find(t_80016_daily.Year == years(y) & t_80016_daily.Month == 9 & t_80016_daily.Day == 30);
    temp(beg:fin) = wet_soil_indicator(y,:);
end
wet_soil_indicator = reshape(repmat(temp',[24 1]),[80016 1]);
%% save data
save('wet_soil_indicator.mat','wet_soil_indicator');