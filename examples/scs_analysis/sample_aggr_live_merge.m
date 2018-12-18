clearvars;

%User-defined variables:
Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases';
sampling_rate = 10; % sensor's sampling rate in seconds
avg_interval = '**:/1:00';
avg_interval_sec = 60; % averaging interval in seconds
%---------------------------------------------------------------------
start_time = cell(1000,1);
%Initialization
avg_ratio = avg_interval_sec/sampling_rate;
sensor_datetime = 'localised_datetime.py';
[~, start_time{1,1}] = system(sensor_datetime);
start_time{1,1} = strtrim(start_time{1,1});
pause(sampling_rate);
i = 0;
a = 0;
data.init.jsondecode = all_functions.decode_live(Topic_ID, start_time, i);
while (1)
    
    i = i + 1;
    
    if i==1
        start_time{i,1} = data.init.jsondecode(end).rec;
        pause(sampling_rate);
    elseif i>1
        start_time{i,1} = data.jsondecode{end,1}.rec;
        pause(sampling_rate);
    end
    data.jsondecode{i, 1} = all_functions.decode_live(Topic_ID, start_time, i);
    document_len = length(data.jsondecode{i,1});
    
    if document_len > 1
        for n = 2:document_len
            data.jsondecode{i+n-1,1} = data.jsondecode{i,1}(n);
            
            for j=i:(i+document_len-1)
                %Define parameters extracted from decoded live data:
                data.parameters.datetime{j, 1} = data.jsondecode{i, 1}(n-1).rec;
                data.parameters.NO2(j, 1) = data.jsondecode{i, 1}(n-1).val.NO2.cnc;
                data.parameters.CO(j, 1) = data.jsondecode{i, 1}(n-1).val.CO.cnc;
                data.parameters.SO2(j, 1) = data.jsondecode{i, 1}(n-1).val.SO2.cnc;
                data.parameters.H2S(j, 1) = data.jsondecode{i, 1}(n-1).val.H2S.cnc;
                data.parameters.hmd(j, 1) = data.jsondecode{i, 1}(n-1).val.sht.hmd;
                data.parameters.tmp(j, 1) = data.jsondecode{i, 1}(n-1).val.sht.tmp;
                n=n+1;
            end
            n=n-document_len;
            data.jsondecode{i,1}(n)=[];
        end
        i=i+n-1;
    else
        %Define live extracted parameter names:
        data.parameters.datetime{i, 1} = data.jsondecode{i, 1}.rec;
        data.parameters.NO2(i, 1) = data.jsondecode{i, 1}.val.NO2.cnc;
        data.parameters.CO(i, 1) = data.jsondecode{i, 1}.val.CO.cnc;
        data.parameters.SO2(i, 1) = data.jsondecode{i, 1}.val.SO2.cnc;
        data.parameters.H2S(i, 1) = data.jsondecode{i, 1}.val.H2S.cnc;
        data.parameters.hmd(i, 1) = data.jsondecode{i, 1}.val.sht.hmd;
        data.parameters.tmp(i, 1) = data.jsondecode{i, 1}.val.sht.tmp;
    end
    
    data.t = cellfun(@all_functions.datenum8601, cellstr(data.parameters.datetime));
    
    figure(1);
    plot(data.t, data.parameters.CO) %Specify parameteres to plot live.
    datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
    legend('CO')
    title(Topic_ID)
    xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
    
    dcm_obj = datacursormode(gcf);
    set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.
    
    if rem(i, avg_ratio)==0
        
        if a==0
            a = a+1;
            b=a;
        elseif a>0
            a = a+x;
            b=b+1;
            start_time_aggr = aggr.decode{end,2}(end).rec;
        end
        %Aggregated data import/decode:
        [aggr.decode{b,2}, aggr.decode{b,1}] = all_functions.aggr_decode_live(Topic_ID, start_time,...
            start_time_aggr, avg_interval, avg_ratio, a, b, i);
        
        for x=1:length(aggr.decode{end,2})
            %Define parameters to extract from decoded aggregated data:
            aggr.datetime{a+x-1,1} = aggr.decode{b,2}(x).rec;
            aggr.t = cellfun(@all_functions.datenum8601, cellstr(aggr.datetime));
            aggr.CO(a+x-1,2)= aggr.decode{b,2}(x).val.CO.cnc.mid;
            aggr.CO(a+x-1,1) = aggr.decode{b,2}(x).val.CO.cnc.min;
            aggr.CO(a+x-1,3) = aggr.decode{b,2}(x).val.CO.cnc.max;
        end
        figure(2);
        plot(aggr.t, aggr.CO(1:end,1), ':k',...
            aggr.t, aggr.CO(1:end,2),'r',...
            aggr.t, aggr.CO(1:end,3), ':k') %Insert aggregated parameters to plot.
        datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
        legend('max', 'mid', 'min')
        title(Topic_ID)
        xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
        
        dcm_obj = datacursormode(gcf);
        set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.
    end
end

