clearvars;

% User-defined variables:
var.Topic_ID = 'unep/ethiopia/loc/1/particulates';
var.start_time = '2018-12-12T12:00:00Z';
var.end_time = '2018-12-13T12:00:00Z';
var.avg_interval = '**:/5:00';
%--------------------------------------------------------------------------
json_decode = all_functions.aggr_decode_hist(var);
sample_length = length(json_decode);

for i = 1:sample_length
    aggr.datetime{i,1} = json_decode(i).rec;
    aggr.PM2p5_min(i,1) = json_decode(i).val.pm2p5.min;
    aggr.PM2p5(i,1) = json_decode(i).val.pm2p5.mid;
    aggr.PM2p5_max(i,1) = json_decode(i).val.pm2p5.max;
end

Y_data = [aggr.PM2p5_min, aggr.PM2p5, aggr.PM2p5_max];
[aggr.t, chart] = all_functions.twoD_hist_plot(var, Y_data, aggr);
legend('PM10 min', 'PM10 mid', 'PM10 max')
