clearvars;

%User-defined variables
Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases';
sampling_rate = 10; % sensor's sampling rate in seconds
avg_interval = '**:/1:00';
%------------------------------------------------------------------------------
sensor_datetime = 'localised_datetime.py';
[~, data.init.datetime] = system(sensor_datetime);
data.init.datetime = strtrim(data.init.datetime);
pause(sampling_rate);
hist_cmd = 'aws_topic_history.py %s -s %s | node.py -a';
[~, data.init.dataout] = system(sprintf(hist_cmd, Topic_ID, data.init.datetime));
data.init.jsondecode = jsondecode(data.init.dataout);
data.init.jsondecode.rec_val = data.init.jsondecode(end).rec;

a = 0;
while(1)
    pause(6*sampling_rate);
    
    if a==0
    a = a+1;
    b=a;
    elseif a>0
        a = a+x;
        b=b+1;
        data.init.jsondecode.rec_val = aggr.decode{end,2}(end).rec;
    end
    
    aggr_cmd = 'aws_topic_history.py %s -s %s | sample_aggregate.py -m -c %s val.CO.cnc 1 | node.py -a';
    [~, aggr.decode{b,1}] = system(sprintf(aggr_cmd, Topic_ID, data.init.jsondecode.rec_val, avg_interval));
    aggr.decode{b,2} = jsondecode(aggr.decode{b,1});
   
    doc_num = length(aggr.decode{end,2});
    for x=1:doc_num
        aggr.datetime{a+x-1,1} = aggr.decode{b,2}(x).rec;
        aggr.t = cellfun(@all_functions.datenum8601, cellstr(aggr.datetime));
        aggr.CO(a+x-1,1)= aggr.decode{b,2}(x).val.CO.cnc.mid;
        aggr.COmin(a+x-1,1) = aggr.decode{b,2}(x).val.CO.cnc.min;
        aggr.COmax(a+x-1,1) = aggr.decode{b,2}(x).val.CO.cnc.max;
    end
    figure(2);
    plot(aggr.t, aggr.COmax,'k:', aggr.t, aggr.CO,'r', aggr.t, aggr.COmin,'k:')
    datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
    legend('max', 'mid', 'min')
    title(Topic_ID)
    xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
    
    dcm_obj = datacursormode(gcf); 
    set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.
end
