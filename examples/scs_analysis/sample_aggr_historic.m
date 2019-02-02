clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

% User-defined variables:
%var.Topic_ID = 'unep/ethiopia/loc/1/particulates';
%var.Topic_ID = 'south-coast-science-demo/brighton/loc/1/particulates';
var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases';
var.start_time = '2019-01-14T10:00:00Z';
var.end_time = '2019-01-15T10:00:00Z';
var.avg_interval = '**:/15:00';
var.sampling_rate_sec = 15*60;
%--------------------------------------------------------------------------
jsondecode = utilities.decode_fcn(var);
var.sample_length = length(jsondecode);

for i = 1:var.sample_length
    var.a = i;
    type.aggr.datetime{i,1} = jsondecode(i).rec;
%     type.aggr.PM2p5_min(i,1) = jsondecode(i).val.pm2p5.min;
%     type.aggr.PM2p5(i,1) = jsondecode(i).val.pm2p5.mid;
%     type.aggr.PM2p5_max(i,1) = jsondecode(i).val.pm2p5.max;
%     type.aggr.PM10_min(i,1) = jsondecode(i).val.pm10.min;
%     type.aggr.PM10(i,1) = jsondecode(i).val.pm10.mid;
%     type.aggr.PM10_max(i,1) = jsondecode(i).val.pm10.max;
%     type.aggr.tmp_min(i,1) = jsondecode(i).val.pm1.min;
%     type.aggr.tmp(i,1) = jsondecode(i).val.pm1.mid;
%     type.aggr.tmp_max(i,1) = jsondecode(i).val.pm1.max;
type.aggr.SO2_min(i,1) = jsondecode(i).val.SO2.cnc.min;
type.aggr.SO2(i,1) = jsondecode(i).val.SO2.cnc.mid;
type.aggr.SO2_max(i,1) = jsondecode(i).val.SO2.cnc.max;
%     type.aggr.NO2_min(i,1) = jsondecode(i).val.NO2.cnc.min;
%     type.aggr.NO2(i,1) = jsondecode(i).val.NO2.cnc.mid;
%     type.aggr.NO2_max(i,1) = jsondecode(i).val.NO2.cnc.max;
%     type.aggr.tmp_min(i,1) = jsondecode(i).val.sht.tmp.min;
%     type.aggr.tmp(i,1) = jsondecode(i).val.sht.tmp.mid;
%     type.aggr.tmp_max(i,1) = jsondecode(i).val.sht.tmp.max;
end

aggr_fig = figure('Name', 'Aggregated Historic Data');
Y_data_Aggr.PM10 = []; Y_data_Aggr.PM2p5 = []; Y_data_Aggr.tmp = [];  % Specify parameters for 2D plot.
Z_data = type.aggr.PM2p5; % Specify a single parameter for 3D plot.

multiplot(Y_data_Aggr, type, var, jsondecode, aggr_fig); 
%ddd_handle = utilities.ddd_bar_plot(type,var, Z_data);