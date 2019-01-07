clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

% User-defined variables:
var.Topic_ID = 'unep/ethiopia/loc/1/particulates';
var.start_time = '2018-12-24T00:00:00Z';
var.end_time = '2018-12-24T01:00:00Z';
%--------------------------------------------------------------------------
json_decode = all_functions.decode_fcn(var);
var.sample_length = length(json_decode);

for i = 1:var.sample_length
    var.i = i;
    data.datetime{var.i,1} = json_decode(var.i).rec;
    data.PM1(var.i,1) = json_decode(var.i).val.pm1;
    data.PM2_5(var.i,1) = json_decode(var.i).val.pm2p5;
    data.PM10(var.i,1) = json_decode(var.i).val.pm10;
end

Y_data = [data.PM1, data.PM2_5, data.PM10]; % Specify parameters to plot.
[data.t, chart] = all_functions.twoD_hist_plot(var, Y_data, data);
legend('PM1', 'PM2.5', 'PM10')