clearvars

joined_filename = 'praxis_ref_joined.csv';
T = readtable(joined_filename); % Read file as table
tmp = T.praxis_val_sht_tmp; 
hmd = T.praxis_val_sht_hmd; 
error = T.ref_15Minute_real_Data - T.praxis_val_NO2_cnc; 

%% 3D detailed bar plot

boundary_hmd = 50:5:90;
boundary_tmp = 1:ceil(max(tmp));

y = cell(length(boundary_hmd),1);
for i = 1:length(hmd)
    for j = 1:length(boundary_hmd)
        if j==1 && hmd(i)<=boundary_hmd(j)
            y{j,1}(length(y{j})+1,1) = hmd(i);
            y{j,3}(length(y{j})+1,1) = tmp(i);
        elseif hmd(i)<= boundary_hmd(j) && hmd(i)> boundary_hmd(j-1)
            y{j,1}(length(y{j})+1,1) = hmd(i);
            y{j,3}(length(y{j})+1,1) = tmp(i);
        end
    end
end
for j = 1:length(boundary_hmd)
    y{j,2} = boundary_hmd(j);
end

z = error;

xygrid = zeros(30, 9);
for i = 1:length(x)
    xx = x(i); yy = y(i); zz = z(i);
    if abs(zz) > xygrid(xx,1)
        xygrid(xx,yy) = zz;
    end
end

