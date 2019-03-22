%NOT FULLY OPERATIONAL
clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

% User-defined variables

var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases'; % Specify subscription topic.
sampling_rate = 10;                                                   % Specify sensor's sampling rate in seconds.
var.avg_interval = '**:/1:00';                                        % Specify averaging time interval in required format.
avg_interval_sec = 60;                                                % Specify averaging time interval in seconds.
%----------------------------------------------------------------------------------------------------------------------
var.start_time = utilities.time_init(var);
var.i = 0;
while(1)
    pause(avg_interval_sec);
    
    if var.i==0
    var.i = var.i + 1;
    var.b = var.i;
    elseif var.i>0
        var.i = var.i + x;
        var.b = var.b + 1;
        var.start_time = jsondecode{end,1}(end).rec;
    end

    jsondecode{var.b,1} = utilities.decode_fcn(var);
    
    % Define parameters extracted from aggregated data:
    for x = 1:length(jsondecode.decode{end})
        type.aggr.datetime{var.i+x-1,1} = jsondecode{var.b,1}(x).rec;
        type.aggr.CO(var.i+x-1,1)= jsondecode{var.b,1}(x).val.CO.cnc.mid;
        type.aggr.CO_min(var.i+x-1,1) = jsondecode{var.b,1}(x).val.CO.cnc.min;
        type.aggr.CO_max(var.i+x-1,1) = jsondecode{var.b,1}(x).val.CO.cnc.max;
        type.aggr.NO2(var.i+x-1,1)= jsondecode{var.b,1}(x).val.NO2.cnc.mid;
        type.aggr.NO2_min(var.i+x-1,1) = jsondecode{var.b,1}(x).val.NO2.cnc.min;
        type.aggr.NO2_max(var.i+x-1,1) = jsondecode{var.b,1}(x).val.NO2.cnc.max;
    end
    
    if var.i==1
        aggr_fig = figure('Name', 'Aggregated Live Data');
    end
    Y_data.CO = []; Y_data.NO2 = []; % Specify parameters to plot.
    multiplot(Y_data, type, var, jsondecode, aggr_fig);
end