%% 3D Surface
clearvars
joined_filename = 'praxis_ref_joined_climate_ts3h_rpoly.csv';
T = readtable(joined_filename);

tmp = T.climate_val_tmp_p2h;
rH = T.climate_val_hmd_m3h;
mT = (0.0844 * rH) - 6.7187;
cT = (-1.0479 * rH) + 98.792;
correction = (mT .* tmp) + cT;

% Averaging vectors
j = 0;
n = 10; % averaging factor
for i = n:n:length(tmp) 
    j=j+1;
    if i==n
            x(j,1)= mean(tmp(1:i,1));
            y(j,1)= mean(rH(1:i,1));
    else
        x(j,1)= mean(tmp(i-n-1:i,1));
        y(j,1)= mean(rH(i-n-1:i,1));
    end
end
% linear
mT = (0.0844 * y) - 6.7187;
cT = (-1.0479 * y) + 98.792;
% polynomial for T+2, rH-3
mT_poly = -0.0009*y.^2 + 0.1231*y -4.3593;
cT_poly = -0.0123*y.^2 + 1.9361*y - 55.81;
%%
%[X,Y] = meshgrid(tmp, rH);
[X,Y] = meshgrid(x,y);
Z = X.*mT_poly + cT_poly;

figure();
h = surf(X,Y,Z);

shading interp
colormap spring
cbh = colorbar;
ylabel(cbh, 'Correction (ppb)')

title('Surface of correction = (mT.*tmp) + cT')
xlabel('Temperature (\circC)')
ylabel('Relative Humidity (%)')
zlabel('Correction (ppb)')


%% 3D bar chart
clearvars 

data = csvread('grid2 rH.csv');

figure();
b = bar3(data, 0.5);

for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end
colorbar()
colormap(spring)

title('Error due to rH and T')
yticklabels(32.5:5:87.5)
xticklabels(5:5:30)
xlabel('Temperature (\circC)')
ylabel('Relative Humidity (%)')
zlabel('Error (ppb)')