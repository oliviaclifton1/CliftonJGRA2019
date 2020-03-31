function [med_day, med_day_anom] = calc_daily_deseasonalize_remove_iav_RM(metvar, thresholddaily,threshold_monthly,beghr, finhr, month)
%% oeclifton 
%% TABLE 1, FIGURE 2, TEXT S6
% creates daily median data, then de-seasonalizes & takes out IAV with 30
% day running mean for hourly data
% thresholddaily is the number of hours you will allow to have missing data
% in the calculation of the daytime median
% this is for harvard forest data (needs to be 80016x1 or 1x80016)
% this is the length of time series from 10/28/1991 to 12/12/2000

ndays = length(month);
ind = month ~= month(1);
ndays_minusfirstmonth = sum(ind);
ndays_first_month = ndays-ndays_minusfirstmonth;

if length(metvar) ~= 80016
    disp('length of metvar is not 80016!, returning');
    return
else
    year = 1992:1:2000;
    nyears = length(year);
    t1 = datetime(1991,10,28,0,0,0);
    t2 = datetime(2000,12,12,23,0,0);
    t_hourly = t1:minutes(60):t2; clear t1 t2;

    %called amjjaso but whatever months you want
    amjjaso = zeros(nyears,ndays*24); 
    amjjaso(:,:) = NaN; 
    for y = 1:nyears
        beg = find(t_hourly.Year == year(y) & t_hourly.Month == month(1) & t_hourly.Day == 1 & t_hourly.Hour == 0);
        fin = find(t_hourly.Year == year(y) & t_hourly.Month == month(end) & t_hourly.Day == sum(month == month(1,end)) & t_hourly.Hour == 23);
        amjjaso(y,:) = metvar(beg:fin);  
        clear beg fin
    end
    % find daily medians 
    med_day = zeros(nyears,ndays);
    med_day(:,:) = NaN;
    for y = 1:nyears
        temp = reshape(amjjaso(y,:), [24 ndays]); 
        daytime = temp(beghr:finhr,:);
        %count how many nans are in daytime for each day
        count = sum(isnan(daytime));
        %if greater than "threshold" NaNs
        daytime(:,count > thresholddaily) = NaN;
        med_day(y,:) =  median(daytime,1,'omitnan');clear temp daytime count 
    end
    % calculate 30 day backwards running mean
    med_day_30rm = NaN(nyears,ndays);
    for y = 1:nyears
        for i = 30:ndays
            if sum(~isnan(med_day(y,i-29:i))) >= threshold_monthly
                med_day_30rm(y,i) = nanmean(med_day(y,i-29:i)); 
            end
        end
    end
    med_day_anom = med_day-med_day_30rm; %calc anomaly
    med_day_anom(:,1:ndays_first_month)=[]; % cut first month
    med_day_anom = reshape(med_day_anom',[1 nyears*ndays_minusfirstmonth]);
end
