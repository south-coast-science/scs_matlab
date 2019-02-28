%% Join

clearvars;
curr_dir = pwd; % starting directory

rep_name = 'test.csv';
ref_path = '..\alphasense shed gases';
ref_name = 'ref_2018-08_2018-09_iso_5min.csv';
joined_out_name = 'alphasense_303_2018-08_2018-09_joined.csv';
collated_out_name = 'test_joined_aH';

cd('g:\My Drive\Data Interpretation\Humidity\Regression_data');
g_drive = pwd;
csv_join_cmd = 'csv_join.py -i -v -l praxis rec %s -r ref rec "%s"\\ref\\%s | csv_writer.py %s';
[~,joined_out] = system(sprintf(csv_join_cmd, rep_name, ref_path, ref_name, joined_out_name));

[~,aH_min] = system('csv_reader.py test_joined.csv | sample_min.py praxis.val.sht.hmd.aH');
aH_min = jsondecode(aH_min);
aH_min = aH_min.praxis.val.sht.hmd.aH;
[~,aH_max] = system('csv_reader.py test_joined.csv | sample_max.py praxis.val.sht.hmd.aH');
aH_max = jsondecode(aH_max);
aH_max = aH_max.praxis.val.sht.hmd.aH;
[~,collated_out] = system(sprintf('csv_reader.py test_joined.csv | csv_collator.py -v -l %s -u %s -d 1 -f collated/%s praxis.val.sht.hmd.aH', aH_min, aH_max, collated_out_name));
cd(curr_dir);

%% Data pre-processor
cd('g:\My Drive\Data Interpretation\Humidity\Regression_data\collated')
collated_dir = pwd;

filename = 'test_joined_ah_11p0_12p0.csv';
doc_len = 1197;
data.aH = zeros(doc_len,4);

data.rep_weC_sens = csvread(filename, 1, 20, [1 20 doc_len 20]); 
data.ref_cnc = csvread(filename, 1, 37, [1 37 doc_len 37]); 
data.aH(:,1) = csvread(filename, 1, 22, [1 22 doc_len 22]); 
data.rec = textscan(fopen(filename), '%q %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f', 'Delimiter', ',', 'HeaderLines', 1);
data.rec = datenum(data.rec{:,1}, 'yyyy-mm-ddTHH:MM:SSZ');
data.ref_cnc(data.ref_cnc <= 0.1) = NaN;

red = [206; 115; 56; 255; 255; 255; 255; 255; 205; 255];
green = [229; 250; 209; 251; 201; 169; 105; 38; 28; 64];
blue = [191; 65; 66; 0; 0; 0; 98; 0; 0; 255];
rgb = table(red, green, blue);

out = humidity_fcns.rgb_assign(data, doc_len, rgb);
clr_data = table(data.rec, out(:,1), out(:,2), out(:,3));

%% Linear reg plotter
model.linear_reg = fitlm(data.ref_cnc, data.rep_weC_sens);

fig = figure('units','normalized','outerposition',[0 0 1 1]);
h = scatter(model.linear_reg.Variables.x1, model.linear_reg.Variables.y, 25, [clr_data.Var2 clr_data.Var3 clr_data.Var4]/255, 'filled');
hold on
m = model.linear_reg.Coefficients.Estimate(2);
b = model.linear_reg.Coefficients.Estimate(1);
plot(model.linear_reg.Variables.x1, m*model.linear_reg.Variables.x1 + b, 'LineWidth', 0.7, 'Color', 'r')
hold off
% h = plot(model.linear_reg);
coeffs = uicontrol(gcf, 'Style', 'text', 'Units', 'normalized', 'Position', [0.77 0.4 0.13 0.07],...
    'HorizontalAlignment', 'left', 'BackgroundColor', 'w');
c = model.linear_reg.Coefficients.Estimate(1);
i = model.linear_reg.Coefficients.Estimate(2);
R_squared = model.linear_reg.Rsquared.Ordinary;
A{1,1} = sprintf('Slope = %f', i);
A{1,2} = sprintf('Intercept = %f', c);
A{1,3} = sprintf('R_squared = %f', R_squared);
coeffs.String = sprintf('%s\n%s\n%s', A{1,1}, A{1,2}, A{1,3});

xlabel('CO_ref (ppb)')
ylabel('CO_rep (ppb)')
ttle = title(sprintf('Linear regression of CO rep vs ref, %s', filename));
% pdf_name = sprintf('2018-08_2019-02_alphasense_refx303_CO_5min_%s.pdf', rownames{n});
% utilities.figuretopdf(pdf_name)


