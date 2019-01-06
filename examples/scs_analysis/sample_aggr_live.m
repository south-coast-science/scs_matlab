clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

% User-defined variables

var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases'; % Specify subscription topic.
sampling_rate = 10;                                                   % Specify sensor's sampling rate in seconds.
var.avg_interval = '**:/1:00';                                        % Specify averaging time interval in required format.
avg_interval_sec = 60;                                                % Specify averaging time interval in seconds.
%----------------------------------------------------------------------------------------------------------------------
var.start_time = all_functions.time_init(var);
var.i = 0;
while(1)
    pause(avg_interval_sec);
    
    if var.i==0
    var.i = var.i + 1;
    var.b = var.i;
    elseif var.i>0
        var.i = var.i + x;
        var.b = var.b + 1;
        var.start_time = aggr.decode{end}.rec;
    end
%     % "Got new val?" loop
%     check_rec = all_functions.time_init(var);
%     if check_rec == aggr.decode{var.b-1,1}
%         pause(avg_interval_sec/2)
%     end
    
    aggr.decode{var.b,1} = all_functions.decode_fcn(var);
    
    % Define parameters extracted from aggregated data:
    for x = 1:length(aggr.decode{end})
        aggr.datetime{var.i+x-1,1} = aggr.decode{var.b,1}(x).rec;
        aggr.CO(var.i+x-1,1)= aggr.decode{var.b,1}(x).val.CO.cnc.mid;
        aggr.COmin(var.i+x-1,1) = aggr.decode{var.b,1}(x).val.CO.cnc.min;
        aggr.COmax(var.i+x-1,1) = aggr.decode{var.b,1}(x).val.CO.cnc.max;
    end
    
    Y_data = [aggr.CO, aggr.COmin aggr.COmax]; % Specify parameters to plot.
    [aggr.t, chart] = all_functions.twoD_live_plot(var, Y_data, aggr);
    legend('CO', 'COmin', 'COmax')
end