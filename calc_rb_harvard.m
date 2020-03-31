%% oeclifton
%% TEXT S7
% calculating quasilaminar resistance (Rb) at Harvard Forest
clc;clear all;
%% read some data 
[~,~,~,~,~,ustar,~,~,~,~,~,~] = read_hf004();
%% calculate Rb according to wesely and hicks (1977)
thermaldiffAIR = 0.2; % cm2 s-1 jacob et al. (1992) 
molecdiffO3 = 0.144; %cm2 s-1 massman (1998)
vonKarman = 0.4;
rb = (2./(vonKarman.*ustar)).*(thermaldiffAIR/molecdiffO3)^(2/3);
%% save data
save('rb_harvard.mat','rb');