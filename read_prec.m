function [ prec, fake_hourly_prec, time ] = read_prec(from_1990 )
%% oeclifton
% creates vector of daily precipitation for 10/28/1991 to 12/12/2000
% also creates vector of hourly data for this same time period
% (daily values are repeated for every hour)

%% load precipitation data
% Boose, E., & Gould, E. (2004). Shaler Meteorological Station at Harvard 
% Forest 1964-2002. Harvard Forest Data Archive: HF000. 
% https://doi.org/10.6073/pasta/84cf303ea3331fb47e8791aa61aa91b2
table = readtable('hf000-01-daily-m.csv','ReadVariableNames', false,'Format', ...
'%{yyyy-MM-dd}D%f%s%f%s%f%s%f%s','HeaderLines', 1,'Delimiter', ',','TreatAsEmpty','NA');
prec = table.Var8;
time = table.Var1;
%% pull out desired time period 
fin = find(time.Year == 2000 & time.Month==12 & time.Day==12);
% discard data from 1/1/1990 to 10/28/1991 if from_1990 == 0
if from_1990 == 0 
    beg = find(time.Year == 1991 & time.Month==10 & time.Day==28);
    prec = prec(beg:fin);
    time = time(beg:fin);
else
    prec = prec(1:fin);
    time = time(1:fin);
end
%% make vector of hourly data with daily precipitation data
% (daily values are repeated for every hour)
% this is used to index hourly values for rainy days 
temp=repmat(prec, [1 24]);
fake_hourly_prec = reshape(temp', [1 length(prec)*24])';
end

