clearvars;

filename = mfilename('fullpath');
[~, name, ~] = fileparts(filename);

% User-defined variables

var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases'; % Specify subscription topic.
sampling_rate = 10;                                                   % Specify sensor's sampling rate in seconds.
var.avg_interval = '**:/1:00';                                        % Specify averaging time interval in required format.
avg_interval_sec = 60;
%----------------------------------------------------------------------------------------------------------------------
sensor_datetime = 'localised_datetime.py';
[~, var.init_time] = system(sensor_datetime);
var.init_time = strtrim(var.init_time);
pause(sampling_rate);
data.jsondecode = all_functions.aggr_decode_live_init(var);
var.start_time = data.jsondecode(end).rec;

var.a = 0;
while(1)
    pause(avg_interval_sec);
    
    if var.a==0
    var.a = var.a+1;
    var.b=var.a;
    elseif var.a>0
        var.a = var.a+x;
        var.b=var.b+1;
        var.start_time = aggr.decode{end,2}(end).rec;
    end
    
    [aggr.decode{var.b,2}, aggr.decode{var.b,1}] = all_functions.aggr_decode_live(var);
    
    % Define parameters extracted from aggregated data:
    for x=1:length(aggr.decode{end,2})
        aggr.datetime{var.a+x-1,1} = aggr.decode{var.b,2}(x).rec;
        aggr.CO(var.a+x-1,1)= aggr.decode{var.b,2}(x).val.CO.cnc.mid;
        aggr.COmin(var.a+x-1,1) = aggr.decode{var.b,2}(x).val.CO.cnc.min;
        aggr.COmax(var.a+x-1,1) = aggr.decode{var.b,2}(x).val.CO.cnc.max;
    end
    
    aggr.t = cellfun(@all_functions.datenum8601, cellstr(aggr.datetime)); % Ensure aggr.t refers to the datetime parameter.
    figure(1);
    plot(aggr.t, aggr.COmax,'r:', aggr.t, aggr.CO,'r', aggr.t, aggr.COmin,'r:')
    datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
    legend('CO max', 'CO mid', 'CO min')
    title(var.Topic_ID)
    xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
    
    dcm_obj = datacursormode(gcf); 
    set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); % Updates "Data-Cursor" callback to display datetime x-values.
end