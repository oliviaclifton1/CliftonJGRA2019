function [ Ta279m, RH279m,PAR29m,wdir,VPD,ustar, eddyT, eddyQ, h2oflux, sensflux,wspd,pa,Ca,gee,PAR28m] = read_hf004()
%% oeclifton
% this function reads in meteorological data for Harvard Forest
%% read in data from hf004-01-final.csv
% Munger, J. W., & Wofsy, S. (1999). Canopy-Atmosphere Exchange of Carbon, Water and Energy at
% Harvard Forest EMS Tower since 1991. Harvard Forest Data Archive: HF004.
% https://doi.org/10.6073/pasta/dd9351a3ab5316c844848c3505a8149d
format = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
table1 = readtable('hf004-01-final.csv', 'ReadVariableNames',...
    true,'Format', format,'HeaderLines', 0, 'TreatAsEmpty','NA'); 
Ta279m = table1.Ta_27_9m_deg_C;
RH279m = table1.RH_27_9m__;
PAR29m = table1.PAR_29m_uE_m2_s;
wdir = table1.wdir_deg_true_;
eddyT = table1.eddyT_deg_C;
eddyQ = table1.eddyQ_e_3mol_mol;
h2oflux = table1.FH2O_e_3mol_m2_s;
sensflux = table1.Fheat_W_m2;
wspd = table1.wspd_m_s;
pa = table1.Pamb_Pa; 
Ca = table1.CO2_ppm;
Ta279m = Ta279m(1:80016);
RH279m = RH279m(1:80016);
PAR29m = PAR29m(1:80016);
wdir = wdir(1:80016);
eddyT = eddyT(1:80016);
eddyQ = eddyQ(1:80016);
h2oflux = h2oflux(1:80016);
sensflux = sensflux(1:80016);
wspd = wspd(1:80016);
pa = pa(1:80016);
Ca = Ca(1:80016);
%% calculate VPD 
es = 6.112.*exp(17.67.*Ta279m./(243.5 + Ta279m)); % in hectoPascals 
es = es.*100; %in pascals 
%% calculate actual vapor pressure from es and RH
ed = es.*RH279m./100; %in pascals
%% calculate VPD
VPD = es-ed; %in Pa
%convert to kPa
VPD = VPD./1000; %in kPa
%% read in data from hf004-02-filled.csv
% Munger, J. W., & Wofsy, S. (1999). Canopy-Atmosphere Exchange of Carbon, Water and Energy at
% Harvard Forest EMS Tower since 1991. Harvard Forest Data Archive: HF004.
% https://doi.org/10.6073/pasta/dd9351a3ab5316c844848c3505a8149d
format = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f';
table1 = readtable('hf004-02-filled.csv', 'ReadVariableNames', ...
    true,'Format', format, 'HeaderLines', 0, 'TreatAsEmpty','NA'); 
ustar=table1.ustar_cm_s;
gee = table1.nee_e6mol_m2_s;
PAR28m = table1.PAR_28m_e6mol_m2_s;
ustar = ustar(1:80016);
gee = gee(1:80016);
PAR28m = PAR28m(1:80016);
end
 