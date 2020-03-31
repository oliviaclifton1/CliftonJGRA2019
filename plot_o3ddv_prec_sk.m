%% oeclifton
%% FIGURE 7A
% plots summertime daytime mean ozone deposition velocity for Kane and Sand Flats 
% for various wet composites determined by precipitation + leaf wetness
clear all;clc;clf;close all;
%% define some time variables 
beghr = 10; %9am
finhr = 17; %4pm
nhours = finhr-beghr+1;
%% loop through sites 
for i = 1:2
    %% load data and define site-specific time variables 
    if i == 1 % kane
        % load half hourly precipitation (prec) and wetness from kane forest
       
        [ o3ddv ] = read_o3ec_filter_kane( );
        t1 = datetime(1997,4,29,0,0,0);
        t2 = datetime(1997,10,24,23,0,0);
        time = t1:minutes(60):t2; clear t1 t2;
        t1 = datetime(1997,4,29,12,0,0);
        t2 = datetime(1997,10,24,12,00,0);
        day = t1:days(1):t2; clear t1 t2;
        time = time';
        ndays = length(day);
        title2 ='Kane';
    else % sand flats
        % load half hourly precipitation (prec) and wetness from sand flats

        [ o3ddv ] = read_o3ec_filter_sand( );
        t1 = datetime(1998,5,12,0,0,0);
        t2 = datetime(1998,10,20,23,0,0);
        time = t1:minutes(60):t2; clear t1 t2;
        t1 = datetime(1998,5,12,12,0,0);
        t2 = datetime(1998,10,20,12,00,0);
        day = t1:days(1):t2; clear t1 t2;
        time = time';
        ndays = length(day);
        title2 = 'Sand Flats';
    end
    %% convert half-hourly data to hourly
    prec = reshape(prec, [2 length(prec)/2]);
    prec = sum(prec,1)'; %sum
    wetness = reshape(wetness, [2 length(wetness)/2]);
    wetness = mean(wetness,1)'; %average
    %% create daily total precipitation from hourly data
    prec_new = reshape(prec, [24 length(prec)/24]);
    fake_hourly_precip = sum(prec_new,1);
    fake_hourly_precip = repmat(fake_hourly_precip, [24 1]);
    today_prec = reshape(fake_hourly_precip, [1 length(prec)])';
    clear fake_hourly_precip prec_new
    %% calculate backwards running SUM of precipitation (last 24 hours)
    prec_last24hrs = zeros(length(time),1);
    prec_last24hrs(:,1) = NaN;
    for j = 24:length(time)
        prec_last24hrs(j) = sum(prec(j-23:j));
    end
    %% calculate backwards running SUM of precipitation(last 6 hours)
    prec_last6hrs = zeros(length(time),1);
    prec_last6hrs(:,1) = NaN;
    for j = 6:length(time)
        prec_last6hrs(j) = sum(prec(j-5:j));
    end
    %% calculate backwards running SUM of precipitation (last 3 hours)
    prec_last3hrs = zeros(length(time),1);
    prec_last3hrs(:,1) = NaN;
    for j = 3:length(time)
        prec_last3hrs(j) = sum(prec(j-2:j));
    end
    %% calculate bootstrapped daytime mean for each composite
    % preallocate array (ndays,nhours,ncomposites) for bootstrapping
    o3ddv4btstrp = zeros(122,nhours,5);
    o3ddv4btstrp(:,:,:) = NaN;
    for h = beghr:finhr
        %dry, daily total
        ind = (time.Month > 5 & time.Month < 10) & time.Hour == h-1 & ...
            prec_last24hrs==0;   
        temp = o3ddv(ind);
        o3ddv4btstrp(1:length(temp),h-beghr+1,1) = temp;
        %wet, daily total
        ind = (time.Month > 5 & time.Month < 10) & time.Hour == h-1 & ...
            prec_last24hrs>0 & prec==0;   
        temp = o3ddv(ind);
        o3ddv4btstrp(1:length(temp),h-beghr+1,2) = temp;
        %wet, daily total, no leaf wetness
        ind = (time.Month > 5 & time.Month < 10) & time.Hour == h-1 & ...
            prec_last24hrs>0 & prec==0 & wetness<0.1;   
        temp = o3ddv(ind);
        o3ddv4btstrp(1:length(temp),h-beghr+1,3) = temp;
        %wet, daily total, no leaf wetness
        ind = (time.Month > 5 & time.Month < 10) & time.Hour == h-1 & ...
            prec_last3hrs>0 & prec==0;   
        temp = o3ddv(ind);
        o3ddv4btstrp(1:length(temp),h-beghr+1,4) = temp;
        %wet, daily total, no leaf wetness
        ind = (time.Month > 5 & time.Month < 10) & time.Hour == h-1 & ...
            prec_last6hrs>0 & prec==0;   
        temp = o3ddv(ind);
        o3ddv4btstrp(1:length(temp),h-beghr+1,5) = temp;
    end
    %% find mean + confidence interval for daytime for each composite
    % define parameters
    n = 1000; %how many times do u want to sample 
    % preallocate 
    o3ddv_btstrpd = NaN(n,nhours,5);
    o3ddv_btstrpd_day = NaN(n,5);
    % preallocate for 95% CI 
    o3ddv_btstrpd_day26 = NaN(5,1);
    o3ddv_btstrpd_day975 = NaN(5,1);
    for h = 1:nhours
        for j = 1:5 % loop over composites
            temp = o3ddv4btstrp(:,h,j);          
            %filter out NaNs from temp
            temptemp = temp(temp == temp);
            %bootstat gives the mean of n distributions of
            %length(temptemp)
            if ~isempty(temptemp)
                bootstat = bootstrp(n,@mean,temptemp);
                o3ddv_btstrpd(:,h,j) = bootstat;
                clear temp, clear temptemp, clear bootstat
            end
        end
    end
    for j = 1:5 % loop over composites
        %create n daytime means
        for ii = 1:n
            o3ddv_btstrpd_day(ii,j) = mean(o3ddv_btstrpd(ii,:,j));
        end
        %sort in ascending order
        o3ddv_btstrpd_day(:,j) = sort(o3ddv_btstrpd_day(:,j));
        % select 26th and 975th for 95% CI
        o3ddv_btstrpd_day26(j) = o3ddv_btstrpd_day(26,j);
        o3ddv_btstrpd_day975(j) = o3ddv_btstrpd_day(975,j);
    end
    % compute mean 
    o3ddv_btstrpd_day_mean_final = squeeze(nanmean(o3ddv_btstrpd_day,1))';
    %% plot mean & CI for each composite for a given site
    color= [1.000,0.000,0.000;
              0.800,1.000,0.000;
              0.000,1.000,0.400;
              0.000,0.400,1.000;
              0.800,0.000,1.000];
    figure(1);
    if i == 2
        offset = 0.3;
        for j=1:5
            h1 = errorbar(j+offset,o3ddv_btstrpd_day_mean_final(j),...
                o3ddv_btstrpd_day26(j)-o3ddv_btstrpd_day_mean_final(j),...
                o3ddv_btstrpd_day975(j)-o3ddv_btstrpd_day_mean_final(j),...
                'Color',color(j,:),'LineWidth',3,'Marker','o',...
                'MarkerSize',10,'MarkerFaceColor',color(j,:));
            hold on
        end
    else
        offset = 0;
        for j=1:5
            h2 = errorbar(j+offset,o3ddv_btstrpd_day_mean_final(j),...
                o3ddv_btstrpd_day26(j)-o3ddv_btstrpd_day_mean_final(j),...
                o3ddv_btstrpd_day975(j)-o3ddv_btstrpd_day_mean_final(j),...
                'Color',color(j,:),'LineWidth',3,'Marker','o',...
                'MarkerSize',10);
            hold on
        end
    end
    %% clean up figure 
    fontsize = 11;
    set(gca,'FontName','Arial');
    set(gca,'FontSize',fontsize);
    set(gca,'linewidth',1)
    ylabel('v_d (cm s^{-1})','FontName','Arial','FontSize',fontsize);
    xlim([1 5.5]); 
    ax = gca;
    ax.XTick = 1.15:1:5.15;
    hourslabel = {'Dry';'R24h';'R24h,DL';'R3h';'R6h'};
    set(gca,'XTickLabel',hourslabel);
    if i==2
        plot(3,0.65,'k','Marker','o','MarkerSize',8,'LineWidth',3);
        text(3+.2,0.65,'Kane','Color','k','FontSize',11,...
            'FontName','Arial','FontWeight','Bold');
        plot(4,0.65,'k','Marker','o','MarkerSize',8,'LineWidth',3,...
            'MarkerFaceColor','k');
        text(4+.2,0.65,'Sand Flats','Color','k','FontSize',11,...
            'FontName','Arial','FontWeight','Bold');
    end
    hold on
end