% REGRESSION MODEL & PLOTTER
%
% Created 11 February 2019
%
% @author: Milton Logothetis (milton.logothetis@southcoastscience.com)
%
% DESCRIPTION 
% This script can be used to extract regression data from a csv file and
% create either a colored (init.col==1) or uncolored scatter plot (init.col==0).
% The data can be plotted as a single model or collated with respect to an external 
% parameter (usually absolute humidity). The scatter points can be colored 
% based on the external parameter (init.col_aH==1) or w.r.t the datetime values
% (init.col_aH==0).
%
% Example
% 1. Specify initialization parameters and run "Initialization" section script.
% 2. In "Single Linear Regression (color based on rec)" script specify
%    init.col==1.
% 3. Uncomment "utilities.figuretopdf(pdf_name)" to save chart as pdf.
% 4. Run section script and output regression model chart for the whole
%    dataset, colored w.r.t the datetime column.
%
% NOTES: 
% - Initialize script before running any section.
% - Wherever aH (absolute humidity) is used as a coloring
%   or collation reference it can be replaced by any other variable from the
%   imported dataset(e.g. relative humidity, temperature etc).

%% Initialization
clearvars;

joined_filename = 'alphasense_303&ref_2018-08_2019-02_sens_aH_5min.csv';

pollutant = 'CO';
doc_len = 57184;
N_cols = thirdparty_fcns.xlscol('AC');
rep_col = thirdparty_fcns.xlscol('U');
ref_col = thirdparty_fcns.xlscol('AB');
aH_col = thirdparty_fcns.xlscol('W');

ref = 'ref (ppb)';
rep = '303 (ppb)';
init.cbhr_label = 'Date (dd-mm-yyyy)'; % East colorbar label. ('Absolute Humidity (\mug/m^3)' , 'Relative Humidity (%)', 'Date (dd-mm-yyyy)')

[data, rgb, joined_filename] = humidity_fcns.reg_read_init(joined_filename, doc_len, N_cols, rep_col, ref_col, aH_col);

% % Preprocessing
data.ref_cnc(data.ref_cnc>=2) = NaN;
data.rep_weC_sens(data.rep_weC_sens>=2000) = NaN;
data.rep_weC_sens(data.rep_weC_sens==0) = NaN;
data.ref_cnc = data.ref_cnc*1000;
data.aH(data.aH(:,1)==0) = NaN; %remove any 0 aH values.

%% Single Linear Regression (color based on rec)
clearvars -except data rgb joined_filename pollutant ref rep init

init.col = 1; % Color Parameter (col==1 for color)

init.n = 1; % constant
init.col_aH = 0; % constant

model.linear_reg = fitlm(data.ref_cnc, data.rep_weC_sens);
clr_data = table(model.linear_reg.Variables.x1, model.linear_reg.Variables.y, data.aH(:,2), data.aH(:,3), data.aH(:,4));
humidity_fcns.scatter_reg_col(model, clr_data, data, init);

xlabel(sprintf('%s-%s', pollutant, ref)) %('%s-ref (%cC)', pollutant, char(176)) || ('%s-303 (%%)', pollutant) ||('%s-303 (%cg/m^3)', pollutant, char(956))
ylabel(sprintf('%s-%s', pollutant, rep))
title(sprintf('%s, %s', pollutant, joined_filename))

pdf_name = sprintf('2018-08-2019-02_6month_alphasense_refx303_%s_5min_total_col_rec.pdf', pollutant);
utilities.figuretopdf(pdf_name)

%% Single Linear Regression (color based on aH)
clearvars -except data rgb joined_filename pollutant ref rep init

init.col = 1; % Color Parameter (col==1 for color)
int_step = 0.1; % aH colouring step

init.n = 1; % constant
init.col_aH = 1; % constant

[data, aH, model.cmap] = humidity_fcns.aH_color(data, rgb, int_step);
data.aH = aH.aH_tot;
model.linear_reg = fitlm(data.ref_cnc, data.rep_weC_sens);
clr_data = table(model.linear_reg.Variables.x1, model.linear_reg.Variables.y, data.aH(:,2), data.aH(:,3), data.aH(:,4));
humidity_fcns.scatter_reg_col(model, clr_data, data, init);

xlabel(sprintf('%s-%s', pollutant, ref))%('%s-ref (%cC)', pollutant, char(176)) || ('%s-ref (%%)', pollutant) ||
ylabel(sprintf('%s-%s', pollutant, rep))
title(sprintf('%s, %s', pollutant, joined_filename))

pdf_name = sprintf('2019-02-07_2019-03-14_LHR2_refx431_%s_15min_total_col_aH.pdf', pollutant);
utilities.figuretopdf(pdf_name)

%% Linear Regression based on aH_ints

init.col = 1; % Color (col==1 for color)
init.col_aH = 0; % Color Parameter (col_aH==1 for color based on aH)
init.noemptyidx = 0;
n_ints = 16;

min_int = floor(min(data.aH(:,1)));
max_int = ceil(max(data.aH(:,1)));
collated_spacing = round((max_int-min_int)/n_ints);
min_lim = transpose(min_int :collated_spacing: max_int-collated_spacing); % Set aH intervals e.g from 1-2, 3-4 (max_lim inclusive).
max_lim = transpose(min_int+collated_spacing :collated_spacing: max_int);
for n = 1:length(min_lim)
rownames{n,1} = sprintf('aH_%d_%d', min_lim(n), max_lim(n));
end
aH_ints = table(min_lim, max_lim, 'RowNames', rownames);

init.int_step = (aH_ints.min_lim(2)-aH_ints.min_lim(1))/10;
if init.col_aH==1
   [data, aH, model.cmap] = humidity_fcns.aH_color(data, rgb, init.int_step);
   data.aH = aH.aH_int;
end

model.linear_reg = cell(length(rownames),1);

for n=1:height(aH_ints)-1
    
    fig{n,1} =  humidity_fcns.collated_reg_aH_rec(model, data, aH_ints, init, n);
    if isempty(fig{n,1})
        continue
    end
    xlabel(sprintf('%s-%s', pollutant, ref))
    ylabel(sprintf('%s-%s', pollutant, rep))
    rownames{n} = strrep(rownames{n}, '_', '-');
    ttle = title(sprintf('Linear regression of %s praxis %svs%s, %s', pollutant, ref, rep, rownames{n}));
    % pdf_name = sprintf('2018-08_2019-02_alphasense_refx303_CO_5min_%s.pdf', rownames{n});
    % utilities.figuretopdf(pdf_name)
    export_fig(sprintf('2018-08-2019-02_6month_alphasense_refx303_%s_5min_collated_col_rec.pdf', pollutant), fig{n}, '-append')
end