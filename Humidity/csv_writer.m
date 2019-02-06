clearvars;

var.filename = 'heathrow_field_gases_2019-02-02.csv'; % Specify file name after adding to path.
var.Topic_ID = var.filename;
reader_cmd = 'csv_reader.py %s | node.py -a';
[~, out] = system(sprintf(reader_cmd, var.filename));
jsondecode = jsondecode(out);

% Define parameters extracted from decoded data:
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
type.data.NO2(n,1) = jsondecode(n).val.NO2.cnc;
type.data.tmp(n,1) = jsondecode(n).val.sht.tmp;
type.data.hmd(n,1) = jsondecode(n).val.sht.hmd;
end

hist.data = [];
hist.last_update = [isfield(hist, 'data'); isfield(hist, 'aggr')];

% fig = figure();
% Y_data.SO2 = []; Y_data.tmp=[]; Y_data.hmd=[]; % Specify plotted parameters.
% fig = utilities.multiplot(Y_data, type, hist, var, jsondecode, fig);