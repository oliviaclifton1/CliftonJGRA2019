%% oeclifton
%% TEXT S4, FIGURE 2,7D 
% this script calculates stomatal conductance at Harvard Forest 
% with Lin, Medlyn et al. 2015 model
clear all; clc; clf; close all;
%% define some constants
g1=2.61; % Franks et al 2018 for QR at HF for Lin, Medlyn model (but with g0)
rat_Dwatervapor_Dcarbondioxide = 1.6;
rat_Dozone_Dwatervapor = 1./1.51; % massman (1998)
rho = 1.183; % kg/m3 from Table A.3 Monteith and Unsworth 2007 at T = 25 C
mass_atm = 28.96e-3; %jacob ch 1; kg mol-1
MWH2O = 18.0; % g/mol H2O
MWdryair = 28.96; %g/mol dry air 
%% load data 
[Ta279m, RH,~,~,VPD,~, eddyT, eddyQ, ~,~,~,~, Ca, GEE] = read_hf004();
%% use GEE as Anet
% GEE < 0 in HF observations, but Anet should be > 0
GEE = abs(GEE); %micromoles/s/m2 
%% calculate stomatal conductance 
% Ca is in ppm => dividing GEE by Ca gives moles air 
gs = rat_Dwatervapor_Dcarbondioxide .*(1 + g1./(VPD.^0.5)).*GEE./Ca; %moles/s/m2 
%% calculate gs for ozone
gs = rat_Dozone_Dwatervapor.*gs;
%% convert stomatal conductance to velocity units
n_air = rho./mass_atm; %
gs = gs./n_air;
%% convert from m/s to cm/s
gs = gs.*100;
%% save variables
save('gs_medlyn_harvard.mat','gs');