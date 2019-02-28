clearvars -except type ref 

gasColor = [0.4353 0.1412 0.0863];
tmpColor = [0.6510 0.1686 0.0902];
hmdColor = [0.1176 0.2980 0.4863];
pollutant = 'NO2 (ppb)';

[aH,RH] = abs_humidity(type); % (g/m^3)
fnames = fieldnames(type.data);
gas_orig = type.data.(fnames{2});
weC = type.data.NO2_wec;
X_data = cellfun(@thirdparty_fcns.datenum8601, cellstr(type.data.datetime));

wb = -4;
ws = 4;
sens = 0.257/1000; % unique to sensor, at 20oC & aH=
baseline_corr = wb * aH; % error 1
% e = -w*RH*100; % error 2
sens_corr = sens*((aH/ws)+1); % error 3
cnc_sens_corr = weC./sens_corr;
cnc_baseline_corr = cnc_sens_corr - baseline_corr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gradient
% for n = 1:(length(gas_corr)-5)
% nn = n:(n+5);
% m = [gas_corr(nn), X_data(nn)];
% [FX{n,1}, FY{n,1}] = gradient(m);
% FYY(n,1) = mean(FY{n}(1:end,1));
% end
% X_data_grad = X_data(6:end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
pdf_name = 'chigwell_field_gases_2018-10-03_NO2_wb%d_ws%d';
pdf_name = sprintf(pdf_name, wb, ws);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fig = figure();
subplot(2,1,1);
yyaxis left
gas_plt = plot(X_data, gas_orig);
hold on 
plot(X_data, cnc_sens_corr, 'Color', 'red', 'LineStyle', '-')
hold off
r = round(length(X_data)/8);
xticks([X_data(1) X_data(r) X_data(2*r) X_data(3*r) X_data(4*r) X_data(5*r) X_data(6*r) X_data(7*r) X_data(end)])
datetick('x', 'HH:MM:SS', 'keepticks','keeplimits');
ylabel(pollutant)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
min_val = min(gas_orig, cnc_sens_corr);
max_val = max(gas_orig, cnc_sens_corr);
ylim([min(min_val) max(max_val)+5])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gradient
% min_FYY = min(FYY);
% min_gas_corr = min(gas_corr);
% min_gas_orig = min(gas_orig);
% max_FYY = max(FYY);
% max_gas_corr = max(gas_corr);
% max_gas_orig = max(gas_orig);
% 
% if min_FYY < min_gas_corr && min_FYY < min_gas_orig
%     min_val = min_FYY;
% elseif min_gas_corr < min_FYY && min_gas_corr < min_gas_orig
%     min_val = min_gas_corr;
% else
%     min_val = min_gas_orig;
% end
% 
% if max_FYY > max_gas_corr && max_FYY > max_gas_orig
%     max_val = max_FYY;
% elseif max_gas_corr > max_FYY && max_gas_corr > max_gas_orig
%     max_val = max_gas_corr;
% else
%     max_val = max_gas_orig;
% end
% ylim([min_val max_val])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlim([X_data(1) X_data(end)])
ax1 = gca;
ax1.YColor = [0 0 0];
ax1.OuterPosition = [0, 0.4, 1, 0.6];
gas_plt.Color = gasColor;
gas_plt.LineWidth = 1;

yyaxis right 
abs_plt = plot(X_data, aH);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gradient
% hold on
% plot(X_data_grad, FYY, 'Color', 'green', 'Linestyle', '-')
% hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylabel('Absolute Humidity (g/m^3)')
legend('Gas_r_e_s_p', 'Gas_c_o_r_r', 'hmd_a_b_s')
ylim([0 15])
ax2 = gca;
ax2.YColor = [0 0 0];
abs_plt.Color = [76/255 0 153/255];
abs_plt.LineWidth = 1;
grid minor
ttle = 'Corrected sensitivity, ws=%d';
title(sprintf(ttle, ws))

subplot(2,1,2);
yyaxis left
tmp_plt = plot(X_data, type.data.tmp);
xticks([X_data(1) X_data(r) X_data(2*r) X_data(3*r) X_data(4*r) X_data(5*r) X_data(6*r) X_data(7*r) X_data(end)])
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure();
subplot(2,1,1);
yyaxis left
gas_plt = plot(X_data, gas_orig);
hold on 
plot(X_data, cnc_baseline_corr, 'Color', 'red', 'LineStyle', '-')
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reference plot
% hold on
% ref_plot = plot(ref.datetime_ref, ref.NO2_ref, 'Color', 'black', 'LineStyle', '-', 'LineWidth', 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hold off
r2 = round(length(X_data)/8);
xticks([X_data(1) X_data(r2) X_data(2*r2) X_data(3*r2) X_data(4*r2) X_data(5*r2) X_data(6*r2) X_data(7*r2) X_data(end)])
datetick('x', 'HH:MM:SS', 'keepticks','keeplimits');
ylabel(pollutant)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Reference limits
% min_val = min(min(ref.NO2_ref), cnc_baseline_corr);
% max_val = max(max(ref.NO2_ref), cnc_baseline_corr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%
min_val = min(gas_orig, cnc_baseline_corr);
max_val = max(gas_orig, cnc_baseline_corr);
ylim([min(min_val) max(max_val)+5])
xlim([X_data(1) X_data(end)])
ax2 = gca;
ax2.YColor = [0 0 0];
ax2.OuterPosition = [0, 0.4, 1, 0.6];
gas_plt.Color = gasColor;
gas_plt.LineWidth = 1;

yyaxis right 
abs_plt = plot(X_data, aH);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gradient
% hold on
% plot(X_data_grad, FYY, 'Color', 'green', 'Linestyle', '-')
% hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylabel('Absolute Humidity (g/m^3)')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reference legend
%legend('Gas_r_e_s_p', 'Gas_c_o_r_r', 'Gas_r_e_f', 'hmd_a_b_s')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
legend('Gas_r_e_s_p', 'Gas_c_o_r_r', 'hmd_a_b_s')
ylim([0 15])
ax2 = gca;
ax2.YColor = [0 0 0];
abs_plt.Color = [76/255 0 153/255];
abs_plt.LineWidth = 1;
grid minor
ttle = 'Corrected Baseline & sensitivity, wb=%d, ws=%d';
title(sprintf(ttle, wb, ws))

subplot(2,1,2);
yyaxis left
tmp_plt = plot(X_data, type.data.tmp);
xticks([X_data(1) X_data(r2) X_data(2*r2) X_data(3*r2) X_data(4*r2) X_data(5*r2) X_data(6*r2) X_data(7*r2) X_data(end)])
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
ax5 = gca;
ax5.YColor = [0 0 0];
ax5.OuterPosition = [0, 0, 1, 0.4];
hmd_plt.Color = hmdColor;
hmd_plt.LineWidth = 1;
grid minor