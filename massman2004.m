function [ vd_bottomup, frac_gcut_dep,g_gr, frac_ggr ] = massman2004(ra,rb, gs, ustar, LAI, Rg_dry, Rg_wet, wet_soil_indicator )
%% oeclifton 
%% TEXT S7
% calculates ozone deposition velocity
% with massman (2004) nonstomatal deposition model
% ATTN: resistances/conductances need to come in with units of m/s or s/m, 
% but conductances exit code as cm/s
%% calculate deposition to the ground
Rac = 25.*LAI./ustar; % s/m
Rbs = 40; % s/m
Rg = NaN(length(wet_soil_indicator),1); 
Rg(wet_soil_indicator==0)=Rg_dry; % s/m
Rg(wet_soil_indicator==1)=Rg_wet; % s/m
g_gr = 1./(Rac +Rbs+ Rg);
%% calculate leaf deposition
% calculate cuticular deposition
R_cut_dry = 5000./LAI; % s/m
g_cut_dry = (1./R_cut_dry);
% calculate leaf (cuticular & stomatal deposition)
r_leaf = rb + 1./(gs + g_cut_dry); % gs & g_cut added in parallel, sum added in series with rb
g_leaf = 1./r_leaf;
frac_gcut_leaf = g_cut_dry./(gs+g_cut_dry);
%% calculate ozone deposition velocity 
r_soil = 1./g_gr;
r_canopy = 1./(1./r_leaf + 1./r_soil); % added in parallel 
frac_leaf = g_leaf.*r_canopy;
frac_gcut_dep=frac_gcut_leaf.*frac_leaf;
frac_ggr = r_canopy./r_soil;
vd_bottomup = 1./(ra + r_canopy);
vd_bottomup = vd_bottomup*100; % cm/s
end

