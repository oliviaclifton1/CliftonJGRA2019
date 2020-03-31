function [ variable_med_day ] = create_daytime_med_sk( variable,ndays,beghr,finhr,threshold )
%% oeclifton
% calculates daytime median in time series for a given diurnal period
% defined by beghr and finhr for Kane or Sand Flats

%convert vector into matrix: nhours in a day x nday
variable = reshape(variable, [24 ndays]);
variable_daytime = variable(beghr:finhr,:); 
%count how many nans are in daytime for each day
count = sum(isnan(variable_daytime));
%if the number of NaNs is greater than threshold, then say they are all NaNs
variable_daytime(:,count > threshold) = NaN;
%calculate daytime median 
variable_med_day =  median(variable_daytime,1,'omitnan');

end