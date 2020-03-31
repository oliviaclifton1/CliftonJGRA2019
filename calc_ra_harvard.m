%% oeclifton
%% TEXT S7
% calculate aerodynamic resistance (Ra) at Harvard Forest 
clc;clear all;
%% define some constants
z2 = 29; %reference height at Harvard Forest in meters
h = 24; %mean height of canopy at Harvard Forest in meters 
k = 0.40; %von Karman constant
g = 9.81; %gravitational acceleration in m/s^2
rho = 1.183; %kg/m3 at 25ºC from Table A.3 of Monteith and Unsworth (2007)
MWair = 28.96; %g/mol dry air 
MWH2O = 18.0; % g/mol H2O
%% data import
[Ta279m,~,~,wdir,~,ustar,eddyT,eddyQ,~,sensflux,wspd,~] = read_hf004();
%% do some conversions
% wspd in m/s, sensflux in %watts/m2 = J/(m2 s),eddyT in degC, 
% ta279m in deg C, eddyQ in  millimolePerMole
ustar = ustar./100; %in m/s
eddyT = eddyT + 273.15; %in K
Ta279m = Ta279m+273.15; %in K
eddyQ = eddyQ./1000; %mole H2O/mole dry air
eddyQ = eddyQ.*(MWH2O/MWair); %kg H2O/kg dry air
%% calculate virtual temperature 
% Tv = T(1+0.61q) where q is in units of kg h2o per kg dry air 
Tv = Ta279m.*(1+0.61.*eddyQ);
%% replace missing eddyT with virtual T calculated from Ta279m and q
eddyT(eddyT ~= eddyT) = Tv(eddyT ~= eddyT);
%% correct cp_dry air for moist air 
% specific heat capacity of dry air at constant pressure
cp_dryair = 1010; % J K-1 kg-1 Table A.2 Monteith and Unsworth 2007
cp = cp_dryair.*(1 + 0.859.*eddyQ);  % J K-1 kg-1; jacobson 2.80
%% calculate Monin Obukhov length
L = -1.*(ustar.^3)./((k*g./eddyT).*(sensflux./(cp.*rho))); %in meters 
% double check on units 11/29/2015 
% cp is in J K-1 kg-1, ustar is (m/s)^3
% m^3 s^-3 / (m s-2 K-1 J m-2 s-1 J-1 K kg kg-1 m3)
% m^3 s^-3 / (m2 s-3 ) = m 
%% calculate displacement height (d) and roughness length for momentum (z0m) 
[d, z0m] = calc_d_z0(h);
z1 = z0m; %lower bound of integrand is roughness length for momentum 
%% calculate stability functions for heat
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
        L(i) = NaN; 
    else
        if ~isnan((z2-d(i))/L(i)) 
            disp((z2-d(i))/L(i)); % these should all be zero.
            stabilityfunction(i) = 0;
        end
    end
end
%% calculate aerodynamic resistance 
Ra = (1./(k.*ustar)).*(log((z2-d)./z1)-stabilityfunction); %in s/m
%% save data
save('Ra_harvard.mat','Ra');