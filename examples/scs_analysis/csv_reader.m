clearvars;

var.filename = 'PM10_NO2_tmp.csv'; % Specify file name after adding to path.
var.Topic_ID = var.filename;
reader_cmd = 'csv_reader.py %s | node.py -a';
[~, out] = system(sprintf(reader_cmd, var.filename));
jsondecode = jsondecode(out);

% Define parameters extracted from decoded data:
for n=1:length(jsondecode)
type.aggr.datetime{n,1} = jsondecode(n).datetime;
type.aggr.NO2(n,1) = jsondecode(n).NO2;
type.aggr.NO2_min(n,1) = jsondecode(n).NO2_min;
type.aggr.NO2_max(n,1) = jsondecode(n).NO2_max;
type.aggr.SO2(n,1) = jsondecode(n).SO2;
type.aggr.SO2_min(n,1) = jsondecode(n).SO2_min;
type.aggr.SO2_max(n,1) = jsondecode(n).SO2_max;
type.aggr.PM10(n,1) = jsondecode(n).PM10;
type.aggr.PM10_min(n,1) = jsondecode(n).PM10_min;
type.aggr.PM10_max(n,1) = jsondecode(n).PM10_max;
type.aggr.tmp(n,1) = jsondecode(n).tmp;
type.aggr.tmp_min(n,1) = jsondecode(n).tmp_min;
type.aggr.tmp_max(n,1) = jsondecode(n).tmp_max;
end

fig = figure();
Y_data.PM10 = []; Y_data.NO2 =[]; Y_data.tmp=[]; Y_data.SO2=[]; % Specify plotted parameters.
multiplotv2(Y_data, type, var, jsondecode, fig)