clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

% User-defined variables:
%var.Topic_ID = 'unep/ethiopia/loc/1/particulates';
var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases';
var.start_time = '2019-01-14T10:00:00Z';
var.end_time = '2019-01-15T10:00:00Z';
var.avg_interval = '**:/5:00';
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
%     type.aggr.NO2_min(i,1) = jsondecode(i).val.NO2.cnc.min;
%     type.aggr.NO2(i,1) = jsondecode(i).val.NO2.cnc.mid;
%     type.aggr.NO2_max(i,1) = jsondecode(i).val.NO2.cnc.max;
    type.aggr.tmp_min(i,1) = jsondecode(i).val.sht.tmp.min;
    type.aggr.tmp(i,1) = jsondecode(i).val.sht.tmp.mid;
    type.aggr.tmp_max(i,1) = jsondecode(i).val.sht.tmp.max;
end

aggr_fig = figure('Name', 'Aggregated Historic Data');
Y_data_Aggr.tmp = [];  % Specify plotted parameters.
multiplot(Y_data_Aggr, type, var, jsondecode, aggr_fig); 
%legend('PM2.5 mid', 'PM2.5 min', 'PM2.5 max', 'PM10 mid', 'PM10 min', 'PM10 max')