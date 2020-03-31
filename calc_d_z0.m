function [d, z0m] = calc_d_z0(h)
%% oeclifton
% this function calculates zero plane displacement height (d) and
% roughness length for momentum (z0m) according to Meyers et al. 1988
[ LAI ] = calc_lai_80016_wdir( );
z0m = h.*(0.215 - (LAI.^0.25)./10)';
d = h.*(0.1 + (LAI.^0.2)/2)';

end