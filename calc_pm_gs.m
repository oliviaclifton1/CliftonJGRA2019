%% oeclifton
% calculating stomatal conductance according to inversion of 
% Penman-Monteith equation via Shuttleworth et al. 1984
% this script is for harvard forest 
clear all; clc; 
%% list of all constants
MWH2O = 18.0; % g/mol
MWH2O = MWH2O/1000; %kg/mol
MWair = 28.96; %g/mol air 
MWair = MWair./1000; %kg/mol air
R = 8.315; %J mole-1 K-1
ratio_DH2O_to_DO3 = 1.51; % ratio of diffusivity of water vapor to diffusivity of ozone from Massman(1998)
lambda = 2442; %latent heat of vaporization of water at 25ºC (kJ/kg) from Table A.3 of Monteith and Unsworth (2007)
cp_dryair = 1010; %specific heat capacity of dry air at constant pressure(J K-1 kg-1) from Table A.2 of Monteith and Unsworth (2007)
%% data import
[ Ta279m, ~,~,~,~,ustar, eddyT, eddyQ, h2oflux, sensflux,~,pa] = read_hf004();
% notes on units 
% wspd in m/s, h2oflux  in millimolePerMeterSquaredPerSecond, 
% sensflux in %watts/m2 = J/(m2 s), eddyT in degC, ta279m in deg C, 
% eddyQ in  millimolePerMole, ustar in cm/s, pa in pascals
%% do some conversions
ustar = ustar./100; %m/s
sensflux = sensflux./1000; %kJ/ (m2 s)
h2oflux = h2oflux./1000 ; %mole H2O/(m2 s)
h2oflux = h2oflux.*MWH2O; % kg H2O/(m2 s)
latentflux = h2oflux.*lambda; % in kJ/(m2 s)
eddyQ = eddyQ./1000; %mole H2O/mole dry air
eddyQ = eddyQ.*(MWH2O/MWair); %kg H2O/kg dry air
clear h2oflux
%% replace missing eddyT with virtual T calculated from Ta279m and eddyQ; and vice versa 
Tv = Ta279m.*(1+0.61.*eddyQ); %in deg C
Ta = eddyT./(1+0.61.*eddyQ);
eddyT(eddyT ~= eddyT) = Tv(eddyT ~= eddyT);
Ta279m(Ta279m ~= Ta279m) = Ta(Ta279m ~= Ta279m);
%% calculate bowen ratio (sensible heat flux/latent heat flux)
beta =  sensflux./latentflux; % (in kJ/(m2 s))/(kJ/(m2 s))
%take out when latent flux is zero but sensflux is not 
beta(latentflux == 0 & sensflux ~= 0) = NaN;
%% remove evaporation part of latent heat flux 
% subcanopy evaporation estimated to be 10% of ecosystem ET at harvard forest 
% sources: moore et al. (1996), wehr et al. (2017)
latentflux = 0.9.*latentflux; 
%% calculate saturation specific humidity deficit
% specific humidity (q) is q = r/(1+r) where r is mixing ratio of h2o
specific_humidity = eddyQ./(1+eddyQ); 
% calculate saturation vapor pressure (es), use temperature in Celsius, from Bolton (1980) equation
es = 6.112.*exp(17.67.*Ta279m./(243.5+Ta279m)); % in hectoPascals 
es = es.*100; %in pascals 
% calculate saturation mixing ratio using Wallace and Hobbs equation 3.63
sat_mixing_ratio = 0.622.*(es./pa); % in kg H20/kg air because 1 Pa = 1 kg m-1 s-2
sat_specific_humidity = sat_mixing_ratio./(1+sat_mixing_ratio);   
specific_humidity_deficit = sat_specific_humidity-specific_humidity;  %in kg/kg
%% calculate air density 
rho = pa./(R.*(Ta279m+273.15)); %mol/m3
% convert to kg/m3 
rho = rho.*MWair; % kg/m3
%% calculate specific heat capacity, correction for moist air  
cp = cp_dryair.*(1 + 0.859.*eddyQ);  % J K-1 kg-1 jacobson 2.80
cp = cp/1000; % kJ K-1 kg-1
%% calculate slope of saturated specific humidity curve at mean air temperature
% use air temp in deg C
% assumption that slope of specifc humidity curve is the same as that of saturation vapor pressure
% likely a fine assumption because q=w/(1+w) and w is small. but do need to
% convert slope to mass mixing ratio
delta_sat_vapor_pressure = 4098*(0.6108*exp(17.27*Ta279m./(Ta279m+237.3)))./((Ta279m+237.3).^2); % in kPa/deg C
delta_sat_vapor_pressure = delta_sat_vapor_pressure.*1000; %in pascals/deg C
delta_sat_mixing_ratio = 0.622.*delta_sat_vapor_pressure./pa; %in mass mixing ratio /deg C; 1 PA = 1 KG S-2 M-1
delta_sat_specific_humidity = delta_sat_mixing_ratio./(1+delta_sat_mixing_ratio);
%% load aerodynamic resistance in s/m calculated from calc_ra_harvard.m 
load Ra_harvard.mat
%% calculate stomatal resistance
%(((kg/kg)/K) (kJ/kg) /(kJ K-1 kg-1))* s/m = s/m
firstpart = (((delta_sat_specific_humidity.*lambda./cp).*beta)-1).*Ra; 
%(kg/m3 kJ/kg kg/kg)/kJ/(m2 s) = s/m
secondpart = (rho.*lambda.*specific_humidity_deficit)./latentflux;
rs = firstpart+secondpart;
% convert to stomatal resistance for ozone 
rs = ratio_DH2O_to_DO3.*rs;
% convert to conductance
gs = 1./rs;
gs = gs*100; %cm/s
%% save data
save('gs_pm_harvard.mat','gs');