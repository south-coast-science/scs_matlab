%% Initialization
clearvars;

rep_filename = 'alphasense_303_2018-08_2019-02_sens_aH_5min.csv';
ref_filename = 'ref_2018-08_2019-02_iso_5min.csv';
joined_filename = 'praxis-431_lhr2_2019-02-01_2019_02_27_cnc2.csv';

pollutant = 'NO2';
doc_len = 617;
N_cols = 26; 
data.aH = zeros(doc_len,4);

%loc = table([1;5],[1;29],[1;20],[1;14],[1;22], 'VariableNames', {'NO2rep';'NO2ref';'COrep';'COref';'aH'});
loc = table([1;5],[1;22],[1;14],[1;24],[1;20], 'VariableNames', {'NO2rep';'NO2ref';'NOrep';'NOref';'aH'}); % collated
data.rep_weC_sens = csvread(joined_filename, loc.NO2rep(1), loc.NO2rep(2), [loc.NO2rep(1) loc.NO2rep(2) doc_len loc.NO2rep(2)]); %rep CO
data.ref_cnc = csvread(joined_filename, loc.NO2ref(1), loc.NO2ref(2), [loc.NO2ref(1) loc.NO2ref(2) doc_len loc.NO2ref(2)]); %ref CO
data.aH(:,1) = csvread(joined_filename, loc.aH(1), loc.aH(2), [loc.aH(1) loc.aH(2) doc_len loc.aH(2)]); 
data.rec = textscan(fopen(joined_filename), ['%q' repmat('%*f', [1,N_cols-1])], 'Delimiter', ',', 'HeaderLines', 1);
data.rec = datenum(data.rec{:,1}, 'yyyy-mm-ddTHH:MM:SSZ');
data.ref_cnc(data.ref_cnc <= 0.1) = NaN; % set ref_rows less than this value to NaN

red = [206; 115; 56; 255; 255; 255; 255; 255; 205; 255];
green = [229; 250; 209; 251; 201; 169; 105; 38; 28; 64];
blue = [191; 65; 66; 0; 0; 0; 98; 0; 0; 255];
rgb = table(red, green, blue);
rgb_vec = cell(doc_len, 3);

n = 1:floor((doc_len)/10):doc_len;
for i=1:10
    if i==10
        rgb_vec(n(i):end,1) = num2cell(rgb{i,1});
        rgb_vec(n(i):end,2) = num2cell(rgb{i,2});
        rgb_vec(n(i):end,3) = num2cell(rgb{i,3});
    else
        rgb_vec(n(i):n(i+1),1) = num2cell(rgb{i,1});
        rgb_vec(n(i):n(i+1),2) = num2cell(rgb{i,2});
        rgb_vec(n(i):n(i+1),3) = num2cell(rgb{i,3});
    end
end

for i = 1:doc_len
    data.aH(i,2) = rgb_vec{i,1};
    data.aH(i,3) = rgb_vec{i,2};
    data.aH(i,4) = rgb_vec{i,3};
end
%% Linear Regression based on aH_ints(color based on rec)

rownames = cellstr(['aH__03__04'; 'aH__04__05'; 'aH__05__06'; 'aH__06__07'; 'aH__07__08'; 'aH__08__09'; 'aH__09__10'; 'aH__10__11'; 'aH__11__12'; 'aH__12__13'; 'aH__13__14'; 'aH__14__15'; 'aH__15__16'; 'aH__16__17'; 'aH__17__18'; 'aH__18__19'; 'aH__19__20']);
min_lim = [3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19]; % Set aH intervals e.g from 1-2, 3-4 (max_lim inclusive).
max_lim = [4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20];
aH_ints = table(min_lim, max_lim, 'RowNames', rownames);

model.linear_reg = cell(length(rownames),1);

for n=1:height(aH_ints)
    
idx.(rownames{n}) = find(data.aH>aH_ints.min_lim(n) & data.aH<=aH_ints.max_lim(n));
if isempty(idx.(rownames{n})) % if no indices extracted, continue to next loop
    continue
end
model.linear_reg{n} = fitlm(data.ref_cnc(idx.(rownames{n})), data.rep_weC_sens(idx.(rownames{n})));
clr_data = table(model.linear_reg{n,1}.Variables.x1, model.linear_reg{n,1}.Variables.y, data.aH(idx.(rownames{n}),2), data.aH(idx.(rownames{n}),3), data.aH(idx.(rownames{n}),4));

fig(n) = figure('units','normalized','outerposition',[0 0 1 1]);
h = scatter(clr_data.Var1, clr_data.Var2, 25, [clr_data.Var3 clr_data.Var4 clr_data.Var5]/255, 'filled');
hold on
col = model.linear_reg{n}.Coefficients.Estimate(2);
b = model.linear_reg{n}.Coefficients.Estimate(1);
plot(clr_data.Var1, col*clr_data.Var1 + b, 'LineWidth', 0.7, 'Color', 'r')
hold off
%plot(model.linear_reg{n}) % no  color plot
coeffs_b = uicontrol(gcf, 'Style', 'text', 'Units', 'normalized', 'Position', [0.77 0.4 0.08 0.085],...
    'HorizontalAlignment', 'left', 'BackgroundColor', 'w');
c = model.linear_reg{n}.Coefficients.Estimate(1);
i = model.linear_reg{n}.Coefficients.Estimate(2);
R_squared = model.linear_reg{n}.Rsquared.Ordinary;
A{1,1} = sprintf('m = %f', i);
A{1,2} = sprintf('b = %f', c);
A{1,3} = sprintf('R^2 = %f', R_squared);
A{1,4} = sprintf('n_points: %d', height(model.linear_reg{n}.Variables));
coeffs_b.String = sprintf('%s\n%s\n%s\n%s', A{1,1}, A{1,2}, A{1,3}, A{1,4});

aH_cmap = colormap(rgb{:,1:3}/255);
cbh = colorbar;
count=0;
for i = 1:round(length(data.rec)/(length(cbh.Ticks)-1)):length(data.rec)
    count=count+1;
    tick_lbl(count,1) = data.rec(i,1);
end
cbh.TickLabels = {datestr(tick_lbl, 'dd-mm-yyyy')};

xlabel(sprintf('%s-ref (ppb)', pollutant))
ylabel(sprintf('%s-rep (ppb)', pollutant))
ttle = title(sprintf('Linear regression of %s rep vs ref, %s', pollutant, rownames{n}));
% pdf_name = sprintf('2018-08_2019-02_alphasense_refx303_CO_5min_%s.pdf', rownames{n});
% utilities.figuretopdf(pdf_name)
end
%% Single Linear Regression (color based on rec)

% data.ref_cnc(data.ref_cnc>=3) = NaN;
% data.rep_weC_sens(data.rep_weC_sens>=2000) = NaN;
% data.rep_weC_sens(data.rep_weC_sens==0)=NaN;

model_b = fitlm(data.ref_cnc, data.rep_weC_sens);
clr_data = table(model_b.Variables.x1, model_b.Variables.y, data.aH(:,2), data.aH(:,3), data.aH(:,4));

figure('units','normalized','outerposition',[0 0 1 1]);
h = scatter(clr_data.Var1, clr_data.Var2, 25, [clr_data.Var3 clr_data.Var4 clr_data.Var5]/255, 'filled');
hold on
col = model_b.Coefficients.Estimate(2);
b = model_b.Coefficients.Estimate(1);
plot(clr_data.Var1, col*clr_data.Var1 + b, 'LineWidth', 0.7, 'Color', 'r')
hold off

coeffs_b = uicontrol(gcf, 'Style', 'text', 'Units', 'normalized', 'Position', [0.77 0.4 0.08 0.085],...
    'HorizontalAlignment', 'left', 'BackgroundColor', 'w');
c = model_b.Coefficients.Estimate(1);
i = model_b.Coefficients.Estimate(2);
R_squared = model_b.Rsquared.Ordinary;
A{1,1} = sprintf('m = %f', i);
A{1,2} = sprintf('b = %f', c);
A{1,3} = sprintf('R^2 = %f', R_squared);
A{1,4} = sprintf('n_points: %d', height(model_b.Variables));
coeffs_b.String = sprintf('%s\n%s\n%s\n%s', A{1,1}, A{1,2}, A{1,3}, A{1,4});

aH_cmap = colormap(rgb{:,1:3}/255);
cbh = colorbar;
count=0;
for i = 1:round(length(data.rec)/(length(cbh.Ticks)-1)):length(data.rec)
    count=count+1;
    tick_lbl(count,1) = data.rec(i,1);
end
cbh.TickLabels = {datestr(tick_lbl, 'dd-mm-yyyy')};

xlabel(sprintf('%s-ref (ppb)', pollutant))
ylabel(sprintf('%s-rep (ppb)', pollutant))
title(sprintf('%s, %s', pollutant, joined_filename))

%pdf_name = sprintf('2019_02-27_heathrow_refx431_NO2_1hr_total.pdf');
%utilities.figuretopdf(joined_filename)

%% Single Linear Regression (color based on aH)
clear aH_cmap tick_lbl

model_c = fitlm(data.ref_cnc, data.rep_weC_sens);

d = max(data.aH(:,1)) - min(data.aH(:,1));
int = round(d/height(rgb),1);
int_step = 0.1;
int_len = int/int_step;
aH_cmap(:,1) = min(data.aH(:,1)):int_step:max(data.aH(:,1));

n = 1:int_len:length(aH_cmap);
for i = 1:10
    for col = 1:3
        if i==10
            aH_cmap(n(i):end,col+1) = rgb{i,col}/255;
        elseif (rgb{i+1,col}-rgb{i,col})==0
            aH_cmap(n(i):n(i+1),col+1) = rgb{i,col}/255;
        else
            rgb_int = (rgb{i,col}:(rgb{i+1,col}-rgb{i,col})/(int_len):rgb{i+1,col})/255;
            aH_cmap(n(i):n(i+1),col+1) = rgb_int(1:length(n(i):n(i+1)));
        end
    end
end

idx = cell(length(aH_cmap),1);
for i = 1:length(aH_cmap)
    if i==length(aH_cmap)
        idxn = find(data.aH(:,1)==aH_cmap(i,1));
    else
        idxn = find(data.aH(:,1)>=aH_cmap(i,1) & data.aH(:,1)<aH_cmap(i+1,1));
    end
    idx{i,1} = idxn;
end

for i = 1:length(aH_cmap)
    for n = 1:length(idx{i,1})
        data.aH(idx{i,1}(n),2) = aH_cmap(i,2);
        data.aH(idx{i,1}(n),3) = aH_cmap(i,3);
        data.aH(idx{i,1}(n),4) = aH_cmap(i,4);
    end
end
clr_data = table(model_c.Variables.x1, model_c.Variables.y, data.aH(:,2), data.aH(:,3), data.aH(:,4));

figure('units','normalized','outerposition',[0 0 1 1]);
h = scatter(clr_data.Var1, clr_data.Var2, 25, [clr_data.Var3 clr_data.Var4 clr_data.Var5], 'filled');
hold on
col = model_c.Coefficients.Estimate(2);
b = model_c.Coefficients.Estimate(1);
plot(clr_data.Var1, col*clr_data.Var1 + b, 'LineWidth', 0.7, 'Color', 'r')
hold off

coeffs_b = uicontrol(gcf, 'Style', 'text', 'Units', 'normalized', 'Position', [0.77 0.4 0.08 0.085],...
    'HorizontalAlignment', 'left', 'BackgroundColor', 'w');
c = model_c.Coefficients.Estimate(1);
i = model_c.Coefficients.Estimate(2);
R_squared = model_c.Rsquared.Ordinary;
A{1,1} = sprintf('m = %f', i);
A{1,2} = sprintf('b = %f', c);
A{1,3} = sprintf('R^2 = %f', R_squared);
A{1,4} = sprintf('n_points: %d', height(model_c.Variables));
coeffs_b.String = sprintf('%s\n%s\n%s\n%s', A{1,1}, A{1,2}, A{1,3}, A{1,4});

colormap(aH_cmap(:,2:4));
cbh = colorbar;
count=0;
for i = 1:round(length(aH_cmap)/(length(cbh.Ticks)-1)):length(aH_cmap)
    count=count+1;
    tick_lbl(count,1) = aH_cmap(i,1);
end
tick_lbl(end+1,1) = aH_cmap(end,1);
cbh.TickLabels = tick_lbl;

xlabel(sprintf('%s-ref (ppb)', pollutant))
ylabel(sprintf('%s-rep (ppb)', pollutant))
title(sprintf('%s, %s', pollutant, joined_filename))

% pdf_name = sprintf('praxis-431_lhr2_2019-02-01_2019_02_27_total_NO2_col_aH.pdf');
% utilities.figuretopdf(pdf_name)