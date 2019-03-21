% CSV READER & PLOTTER
%
% Created 20 December 2018
%
%@author Milton Logothetis (milton.logothetis@southcoastscience.com)
%
% DESCRIPTION
% This script utilises the scs_analysis csv_reader.py tool in order to read
% and plot data directly from a csv file.
%
% EXAMPLE
% 1. Add csv file to path and specify filename (var.filename).
% 2. Specify parameters to be decoded:
% 
% fmt: {type.data."parameter_name"{var.i,1} = jsondecode(var.i)."JSON_field"}
% 
% 3. Specify which parameters to plot within Y_data structure:
%
% fmt (2D): {Y_data."decoded_parameter_name"}
%
% 4. Choose plot type
%
% SEE ALSO
% utilities.multiplot (multiple 2D plot)
% utilities.ddd_bar_plot (single 3D bar plot)
% utilities.ddd_surf_plot (single 3D weekly surface plot)

clearvars;

% Specify csv filename:
var.filename = 'senegal_aircon_gases_2019-01-03_morning-s6.csv';

% Initialization
var.Topic_ID = var.filename;
hist.last_update = [1;0]; % Indicate data type ([1;0]==raw | [0;1]==aggregated).

% Call csv_reader.py
reader_cmd = 'csv_reader.py %s | node.py -a';
[~, out] = system(sprintf(reader_cmd, var.filename));
jsondecode = jsondecode(out);

% Decode parameters from JSON format:
for n=1:length(jsondecode)
% type.aggr.datetime{n,1} = jsondecode(n).datetime;
% type.aggr.NO2(n,1) = jsondecode(n).NO2;
% type.aggr.NO2_min(n,1) = jsondecode(n).NO2_min;
% type.aggr.NO2_max(n,1) = jsondecode(n).NO2_max;
% type.aggr.SO2(n,1) = jsondecode(n).SO2;
% type.aggr.SO2_min(n,1) = jsondecode(n).SO2_min;
% type.aggr.SO2_max(n,1) = jsondecode(n).SO2_max;
% type.aggr.PM10(n,1) = jsondecode(n).PM10;
% type.aggr.PM10_min(n,1) = jsondecode(n).PM10_min;
% type.aggr.PM10_max(n,1) = jsondecode(n).PM10_max;
% type.aggr.tmp(n,1) = jsondecode(n).tmp;
% type.aggr.tmp_min(n,1) = jsondecode(n).tmp_min;
% type.aggr.tmp_max(n,1) = jsondecode(n).tmp_max;
type.data.datetime{n,1} = jsondecode(n).rec;
type.data.SO2(n,1) = jsondecode(n).val.SO2.cnc;
type.data.tmp(n,1) = jsondecode(n).val.sht.tmp;
type.data.hmd(n,1) = jsondecode(n).val.sht.hmd;
end

% Specify parameters and type of plot:
fig = figure();
Y_data.SO2 = []; Y_data.tmp=[]; Y_data.hmd=[];
fig = utilities.multiplot(Y_data, type, hist, var, jsondecode, fig);