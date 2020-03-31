%% oeclifton
% calculating stomatal conductance according to inversion of 
% Penman-Monteith equation via Shuttleworth et al. 1984
% this script is for kane forest 
clear all;clc;clf;close all;
%% load half-hourly data from kane
% load friction velocity (ustar) in m/s - only use values >= 0.3 m/s & < 2 m/s
% load virtual temperature (Tv) and air temperature (TEMP3) in ºC
% load pressure (PRES) in hPa
% load fast water vapor concentration (H2OF) in millimole per mole
% load latent heat flux (H2OFLX) in W/m2
% load sensible heat flux (HTFLXTv) in W/m2
% load unweighted LAI (PL1_WLAI) in m2/m2
% load precipitation 
%% remove half-hourly values with precipitation
ustar(prec>0)=NaN;
%% convert everything from half-hourly to hourly 
ustar = reshape(ustar, [2 length(ustar)/2]);
ustar = mean(ustar,1)'; 
tv = reshape(tv, [2 length(tv)/2]);
tv = mean(tv,1)';
temp3 = reshape(temp3, [2 length(temp3)/2]);
temp3 = mean(temp3,1)'; 
h2oflux = reshape(h2oflux, [2 length(h2oflux)/2]);
h2oflux = mean(h2oflux,1)'; 
pa = reshape(pa, [2 length(pa)/2]);
pa = mean(pa,1)'; 
HtFLXTv = reshape(HtFLXTv, [2 length(HtFLXTv)/2]);
HtFLXTv = mean(HtFLXTv,1)'; 
H2OF = reshape(H2OF, [2 length(H2OF)/2]);
H2OF = mean(H2OF,1)';
LAI = reshape(LAI, [2 length(LAI)/2]);
LAI = mean(LAI,1)';
%% define some constants
MWH2O = 18.0; % g/mol
MWH2O = MWH2O/1000; %kg/mol
MWair = 28.96; %g/mol air 
MWair = MWair./1000; %kg/mol air
lambda = 2442; %latent heat of vaporization of water kJ/kg, at 25ºC Table A.3 Monteith and Unsworth 2007
lambda = lambda*1000; %J/kg;
R = 8.315; %joules per mole per K; J = Pa*m3
cp_dryair = 1010; %specific heat capacity of dry air at constant pressure; J K-1 kg-1 Table A.2 Monteith and Unsworth 2007
ratio_DH2O_to_DO3 = 1.51; % ratio of diffusivity of water vapor to diffusivity of ozone from Massman(1998)
%% do some conversions
pa = pa*100; %Pa
H2OF = H2OF./1000; %mole H2O/mole dry air
H2OF = H2OF.*(MWH2O/MWair); %kg H2O/kg dry air
%% calculate bowen ratio 
beta =  HtFLXTv./h2oflux; % (W/m2)/(W/m2)
beta(h2oflux == 0 & HtFLXTv ~= 0) = NaN;
%% calculate saturation specific humidity deficit
% specific humidity q = r/(1+r) where r is mixing ratio of h2o
specific_humidity = H2OF./(1+H2OF); 
% calculate saturation vapor pressure; use temperature in Celsius
es = 6.112.*exp(17.67.*temp3./(243.5+temp3)); % in hectoPascals 
es = es.*100; %in pascals 
sat_mixing_ratio = 0.622*(es./pa); % in kg H20/kg air because 1 Pa = 1 kg m-1 s-2
sat_specific_humidity = sat_mixing_ratio./(1+sat_mixing_ratio); 
specific_humidity_deficit = sat_specific_humidity-specific_humidity;  %in kg/kg
%%  calculate air density 
rho = pa./(R.*(temp3+273.15)); %mol/m3
rho = rho.*MWair; % kg/m3
%% calculate specific heat capacity, correction for moist air  
cp = cp_dryair.*(1 + 0.859.*H2OF);  % J K-1 kg-1
%% calculate slope of saturated humidity curve at mean air temperature
% use air temp in deg C
delta = 4098*(0.6108*exp(17.27*temp3./(temp3+237.3)))./((temp3+237.3).^2); % in kPa/deg C
delta = delta.*1000; %in pascals/deg C
delta = 0.622.*delta./pa; %in mass mixing ratio /deg C
delta = delta./(1+delta);
%% calculate aerodynamic resistance 
k = 0.40; %von Karman constant
g = 9.81; %gravitational acceleration in m/s^2
L = -1.*(ustar.^3)./((k*g./(tv+273.15)).*(HtFLXTv./(cp.*rho))); %in meters 
z2 = 36.4; %reference height in meters
h = 22; %mean height of canopy in meters 
% calculate d and z0 from meyers et al. 1998
z0m = h.*(0.215 - (LAI.^0.25)./10)';
d = h.*(0.1 + (LAI.^0.2)/2)';
%calculate stability functions for heat
stabilityfunction = zeros(length(L),1);
stabilityfunction(:,:) = NaN; 
for i = 1:length(L) 
    if (z2-d(i))/L(i) > 0.0 && (z2-d(i))/L(i) < 1.0 
        stabilityfunction(i) = -7.8*(z2-d(i))/L(i);  
    elseif (z2-d(i))/L(i) < 0.0 && (z2-d(i))/L(i) > -2.0 
        x = 0.95*(1-(11.6*(z2-d(i))/L(i)))^(1/2);
        stabilityfunction(i) = 2*log((1+x)/2);
    elseif (z2-d(i))/L(i) >= 1.0 || (z2-d(i))/L(i) <= - 2.0
        stabilityfunction(i) = NaN;
        L(i) = NaN; %do this just in case.
    else
        if ~isnan((z2-d(i))/L(i))
            stabilityfunction(i) = 0.0;
        end
    end
end
Ra = (1./(k.*ustar))'.*(log((z2-d)./z0m)-stabilityfunction'); %in s/m
%% calculate stomatal resistance
%(1/K)(J/kg)/(J/(K kg)) (W/m2)/(W/m2) (s/m)
firstpart = (((delta.*lambda./cp).*beta)-1).*Ra';
%(kg/m3) (J/kg) (kg/kg) / (W/m2)
secondpart = (rho.*lambda.*specific_humidity_deficit)./(0.9.*h2oflux);
rs = firstpart+secondpart;
% convert to stomatal resistance for ozone
rs = ratio_DH2O_to_DO3.*rs;
%% calculate stomatal conductance for ozone 
gs = 1./rs;
gs = gs*100; %cm/s
%% save data
save('gs_pm_kane.mat','gs');