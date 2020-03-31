function [ variable_btstrpd_day_mean_final, variable_btstrpd_day26, variable_btstrpd_day975] = bootstrap(variable,yyyy, year, nyears,mm,HH_new, monthbeg, monthfin,ndays, beghr, finhr )
%%  oeclifton
%%  Text S5 
%   takes a time series of a variable and information about time and
%   creates yearly averages, upper & lower bounds for 95% confidence
%   intervals
%   specify which months to include with monthbeg and monthfin
%   specify which hours to include with beghr and finhr 
%% create data array with shape (nyears,ndays,nhours) for bootstrapping
nhours = finhr-beghr+1;
variable4btstrp = NaN(nyears,ndays,nhours);
for y = 1:nyears
    for h = beghr:finhr
        ind = (mm >= monthbeg & mm <= monthfin) & (yyyy == year(y)) ...
            & (HH_new == h-1);   
        temp = variable(ind);
        variable4btstrp(y,1:length(temp),h-beghr+1) = temp;
    end
end
%% find mean + confidence interval for diurnal period (defined) for each year
% use bootstrap
n = 1000; %how many times do u want to sample 
% preallocate 
variable_btstrpd = NaN(nyears,n,nhours);
variable_btstrpd_day = NaN(nyears,n);
variable_btstrpd_day26 = NaN(nyears,1);
variable_btstrpd_day975 = NaN(nyears,1);
for y = 1:nyears
    for h = 1:nhours
        temp = variable4btstrp(y,:,h);          
        %filter out NaNs from temp
        temptemp = temp(temp == temp);
        %bootstat gives the mean of n distributions of
        %length(temptemp)
        if ~isempty(temptemp)
            bootstat = bootstrp(n,@mean,temptemp);
            variable_btstrpd(y,:,h) = bootstat;
            clear temp, clear temptemp, clear bootstat
        end
    end
    %create n daytime means
    for i = 1:n
        variable_btstrpd_day(y,i) = mean(variable_btstrpd(y,i,:));
    end
    %sort in ascending order
    variable_btstrpd_day(y,:) = sort(variable_btstrpd_day(y,:));
    % select 26th and 975th for 95% CI
    variable_btstrpd_day26(y) = variable_btstrpd_day(y,26);
    variable_btstrpd_day975(y) = variable_btstrpd_day(y,975);
end
%% compute mean for each year
variable_btstrpd_day_mean_final = squeeze(nanmean(variable_btstrpd_day,2));
end

