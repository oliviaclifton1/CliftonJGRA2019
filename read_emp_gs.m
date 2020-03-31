function [ gs_empirical ] = read_emp_gs()
%% oeclifton
%% TEXT S4, FIGURE 2,7C 
% this function reads in the empirical stomatal conductance estimate from 
% Wehr and Saleska (2015) ("W15")
%% read empirical stomatal conductance (gs_empirical) and time variable (t) 
% script used to calculate this estimate is available from Rick Wehr 

%% missing values are -9999; set to NaNs
gs_empirical(gs_empirical < -8999) = NaN;
%% convert to cm/s from mol/m2/s
mass_atm = 28.96e-3; %jacob ch 1 in kg mol-1
rho = 1.183; % kg/m3 from Table A.3 Monteith and Unsworth 2007 at T = 25 C
n_air = rho./mass_atm; 
gs_empirical = gs_empirical./n_air;
gs_empirical = gs_empirical.*100;
%% only get data for 10/28/1991 to 12/12/2000
begind = find(t.Year == 1991 & t.Month == 10 & t.Day == 28 & t.Hour == 0);
finind = find(t.Year == 2000 & t.Month == 12 & t.Day == 12 & t.Hour == 23);
gs_empirical = gs_empirical(begind:finind);
%% convert from stomatal conductance for H2O to for ozone
gs_empirical = gs_empirical.*(1./1.51);
%% remove near-zero values that happen when driving variables are NaNs
[ Ta279m, RH,~,~,~,~, ~, ~, ~, ~,~,pa,~,~,PAR28m] = read_hf004();
gs_empirical(PAR28m ~= PAR28m | RH ~=RH | Ta279m ~= Ta279m | pa ~=pa)=NaN;
end

