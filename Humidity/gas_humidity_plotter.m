clearvars -except type 

pdf_name = 'heathrow_field_gases_2019-02-02_NO2_w30';
gasColor = [0.4353 0.1412 0.0863];
tmpColor = [0.6510 0.1686 0.0902];
hmdColor = [0.1176 0.2980 0.4863];

aH = abs_humidity(type); % (g/m^3)
fnames = fieldnames(type.data);
gas_orig = type.data.(fnames{2});
baseline_aH = 8; % (g/m^3)

w = 30;%%%%%%%%%%%%%%%%%%%%%%%%%%%
e = w * (aH - baseline_aH);
gas_corr = gas_orig + e;

err = e;
X_data = cellfun(@thirdparty_fcns.datenum8601, cellstr(type.data.datetime));
fig = figure();

subplot(2,1,1);
yyaxis left
gas_plt = plot(X_data, gas_orig);
hold on 
plot(X_data, gas_corr, 'Color', 'red', 'LineStyle', '-')
hold off
datetick('x', 'HH:MM:SS', 'keepticks','keeplimits');
ylabel('NO2 (ppb)')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylim([-200 150])
xlim([X_data(1) X_data(end)])
ax1 = gca;
ax1.YColor = [0 0 0];
ax1.OuterPosition = [0, 0.4, 1, 0.6];
gas_plt.Color = gasColor;
gas_plt.LineWidth = 1;

yyaxis right 
abs_plt = plot(X_data, aH);
ylabel('Absolute Humidity (g/m^3)')
legend('Gas_r_e_s_p', 'Gas_c_o_r_r','hmd_a_b_s')
ylim([0 15])
ax2 = gca;
ax2.YColor = [0 0 0];
abs_plt.Color = [76/255 0 153/255];
abs_plt.LineWidth = 1;
grid minor
ttle = 'Corrected electrochemical response based on absolute humidity, w=%d';
title(sprintf(ttle, w))

subplot(2,1,2);
yyaxis left
tmp_plt = plot(X_data, type.data.tmp);
datetick('x', 'HH:MM:SS', 'keepticks', 'keeplimits');
ylabel('Temperature (\circC)')
ylim([0 35])
xlim([X_data(1) X_data(end)])
ax3 = gca;
ax3.YColor = [0 0 0];
tmp_plt.Color = tmpColor;
tmp_plt.LineWidth = 1;

yyaxis right
hmd_plt = plot(X_data, type.data.hmd);
legend('tmp','hmd_r_e_l')
ylabel('Relative Humidity (%)')
ylim([0 100])
ax4 = gca;
ax4.YColor = [0 0 0];
ax4.OuterPosition = [0, 0, 1, 0.4];
hmd_plt.Color = hmdColor;
hmd_plt.LineWidth = 1;
grid minor
