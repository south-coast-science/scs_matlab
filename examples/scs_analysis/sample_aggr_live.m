clearvars;

filename = mfilename('fullpath');
[~, name, ~] = fileparts(filename);

% User-defined variables
Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases'; % Specify subscription topic.
sampling_rate = 10;                                               % Specify sensor's sampling rate in seconds.
avg_interval = '**:/1:00';                                        % Specify averaging time interval in required format.
%----------------------------------------------------------------------------------------------------------------------
sensor_datetime = 'localised_datetime.py';
[~, start_time] = system(sensor_datetime);
start_time = strtrim(start_time);
pause(sampling_rate);
data.jsondecode = all_functions.aggr_decode_live_init(Topic_ID, start_time, avg_interval);
end_time = data.jsondecode(end).rec;

a = 0;
while(1)
    pause(6*sampling_rate);
    
    if a==0
    a = a+1;
    b=a;
    elseif a>0
        a = a+x;
        b=b+1;
        end_time = aggr.decode{end,2}(end).rec;
    end
    
    [aggr.decode{b,2}, aggr.decode{b,1}] = all_functions.aggr_decode_live(Topic_ID, end_time, avg_interval, b);
    
    % Define parameters extracted from aggregated data:
    for x=1:length(aggr.decode{end,2})
        aggr.datetime{a+x-1,1} = aggr.decode{b,2}(x).rec;
        aggr.CO(a+x-1,1)= aggr.decode{b,2}(x).val.CO.cnc.mid;
        aggr.COmin(a+x-1,1) = aggr.decode{b,2}(x).val.CO.cnc.min;
        aggr.COmax(a+x-1,1) = aggr.decode{b,2}(x).val.CO.cnc.max;
    end
    
    aggr.t = cellfun(@all_functions.datenum8601, cellstr(aggr.datetime)); % Ensure aggr.t refers to the datetime parameter.
    figure(1);
    plot(aggr.t, aggr.COmax,'r:', aggr.t, aggr.CO,'r', aggr.t, aggr.COmin,'r:')
    datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
    legend('CO max', 'CO mid', 'CO min')
    title(Topic_ID)
    xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
    
    dcm_obj = datacursormode(gcf); 
    set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); % Updates "Data-Cursor" callback to display datetime x-values.
end