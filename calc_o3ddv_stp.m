%% oeclifton
%% TEXT S1
% this script calculates ozone deposition velocity at Harvard Forest
clear all; clc;
rho = 1.183; % kg m-3, at 25ºC Table A.3 Monteith and Unsworth 2007
mass_atm = 28.96e-3; % kg mol-1 jacob ch 1
n_air = rho./28.96e-3;
[ o3mlb,o3ecflux] = read_o3ec();
n_o3 = o3mlb.*(1e-9).*n_air; %number density of o3 in moles O3/m3
o3ddv = -1.*o3ecflux.*(1e-6)./n_o3; %in m/hr
%convert to standard units for dry deposition velocity 
o3ddv = o3ddv.*100.*(1/60).*(1/60); %in cm/s
o3ddv(o3mlb == 0 & o3ecflux ~= 0) = NaN;
%% remove ozone deposition velocity when there are missing sensible heat + latent heat fluxes 
% as per suggestion of bill munger
% there are only sensible and latent heat fluxes from 10/28/1991
% keep 1/1/1990 to 10/27/1991 ozone deposition velocities and just filter
% from 10/28/1991
o3ddv_temp = o3ddv(665*24 + 1:end);
[~,~,~,~,~,~,~,~,h2oflux,sensflux] = read_hf004();
ind = h2oflux ~= h2oflux & sensflux ~= sensflux;
o3ddv_temp(ind) = NaN;
o3ddv(665*24 + 1:end) = o3ddv_temp;