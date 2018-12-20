clearvars;

% User-defined variables:
var.Topic_ID = 'unep/ethiopia/loc/1/particulates';
var.start_time = '2018-12-12T12:00:00Z';
var.end_time = '2018-12-12T14:00:00Z';
%--------------------------------------------------------------------------
json_decode = all_functions.decode_hist(var);
sample_length = length(json_decode);

for i = 1:sample_length
    data.datetime{i,1} = json_decode(i).rec;
    data.PM1(i,1) = json_decode(i).val.pm1;
    data.PM2_5(i,1) = json_decode(i).val.pm2p5;
    data.PM10(i,1) = json_decode(i).val.pm10;
end

Y_data = [data.PM1, data.PM2_5, data.PM10];
[data.t, aggr.t] = all_functions.twoD_hist_plot(var, Y_data, data);
legend('PM1', 'PM2.5', 'PM10')
