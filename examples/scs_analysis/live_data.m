clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

% User-defined variables:
var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases'; % Specify subscription topic.
sampling_rate = 10;                                                   % Specify sensor's sampling rate in seconds.
%-------------------------------------------------------------------------------------------------------------
% Initialization
var.start_time = all_functions.time_init(var);
var.i = 0;
while (1)
    pause(sampling_rate);
    if var.i==0
        var.i = var.i + 1;
        var.j = var.i;
    elseif var.i>0
        var.i = var.i + n;
        var.j = var.j + 1;
        var.start_time = data.datetime{end};
    end
    data.jsondecode{var.j,1} = all_functions.decode_fcn(var);
   
    for n = 1:length(data.jsondecode{end})
        data.datetime{var.i+n-1,1} = data.jsondecode{var.j,1}(n).rec;
        data.NO2(var.i+n-1,1) = data.jsondecode{var.j,1}(n).val.NO2.cnc;
        data.CO(var.i+n-1,1) = data.jsondecode{var.j,1}(n).val.CO.cnc;
        data.SO2(var.i+n-1,1) = data.jsondecode{var.j,1}(n).val.SO2.cnc;
        data.H2S(var.i+n-1,1) = data.jsondecode{var.j,1}(n).val.H2S.cnc;
        data.hmd(var.i+n-1,1) = data.jsondecode{var.j,1}(n).val.sht.hmd;
        data.tmp(var.i+n-1,1) = data.jsondecode{var.j,1}(n).val.sht.tmp;
    end
    Y_data = [data.NO2, data.CO]; % Specify parameters to plot.
    [data.t, chart] = all_functions.twoD_live_plot(var, Y_data, data);
    legend('NO2','CO')
end