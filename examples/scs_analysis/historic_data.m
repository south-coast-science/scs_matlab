clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

% User-defined variables:
var.Topic_ID = 'unep/ethiopia/loc/1/particulates';
var.start_time = '2018-12-24T00:00:00Z';
var.end_time = '2018-12-24T01:00:00Z';
%--------------------------------------------------------------------------
jsondecode = utilities.decode_fcn(var);
var.sample_length = length(jsondecode);

for i = 1:var.sample_length
    var.i = i;
    type.data.datetime{var.i,1} = jsondecode(var.i).rec;
    type.data.PM1(var.i,1) = jsondecode(var.i).val.pm1;
    type.data.PM2p5(var.i,1) = jsondecode(var.i).val.pm2p5;
    type.data.PM10(var.i,1) = jsondecode(var.i).val.pm10;
end

live_fig = figure('Name', 'Historic Data');
Y_data.PM10 = []; Y_data.PM2p5 = []; Y_data.PM1 = []; % Specify parameters to plot.
multiplot(Y_data, type, var, jsondecode, live_fig);
legend('PM1', 'PM2.5', 'PM10')