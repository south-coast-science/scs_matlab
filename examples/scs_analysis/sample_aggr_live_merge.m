clearvars;

%User-defined variables:
User.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases';
User.sampling_rate = 10; % sensor's sampling rate in seconds
User.avg_interval = '**:/1:00';
User.avg_interval_sec = 60; % averaging interval in seconds
%----------------------------------------------------------------
%Pre-allocation
sensor_datetime = 'localised_datetime.py';
localised_datetime_start = cell(1000, 1);
dataout = cell(1000, 1);
%----------------------------------------------------------------
%Initialization
[~, data.init.datetime] = system(sensor_datetime);
data.init.datetime = strtrim(data.init.datetime);
pause(User.sampling_rate);
hist_cmd = 'aws_topic_history.py %s -s %s | node.py -a';
[~, data.init.dataout] = system(sprintf(hist_cmd, User.Topic_ID, data.init.datetime));
data.init.jsondecode = jsondecode(data.init.dataout);

i = 0;
a = 0;
while (1)
    
    i = i + 1;
    
    if i==1
        localised_datetime_start{i,1} = data.init.jsondecode(end).rec;
        pause(User.sampling_rate);
        
    elseif i>1
        localised_datetime_start{i,1} = data.jsondecode{end,1}.rec;
        pause(User.sampling_rate);
    end
    
    [~, dataout{i,1}] = system(sprintf(hist_cmd, User.Topic_ID, localised_datetime_start{i,1}));
    
    data.jsondecode{i, 1} = jsondecode(dataout{i, 1});
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
    title(User.Topic_ID)
    xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
    
    dcm_obj = datacursormode(gcf);
        set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.
    
    if rem(i, User.avg_interval_sec/User.sampling_rate)==0
        
        if a==0
            a = a+1;
            b=a;
        elseif a>0
            a = a+x;
            b=b+1;
            data.init.jsondecode.rec = aggr.decode{end,2}(end).rec;
        end
        
        aggr_cmd = 'aws_topic_history.py %s -s %s | sample_aggregate.py -m -c %s val.CO.cnc 1 | node.py -a';
        [~, aggr.decode{b,1}] = system(sprintf(aggr_cmd, User.Topic_ID, data.init.jsondecode.rec, User.avg_interval));
        aggr.decode{b,2} = jsondecode(aggr.decode{b,1});
        
        doc_num = length(aggr.decode{end,2});
        for x=1:doc_num
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
        title(User.Topic_ID)
        xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
        
        dcm_obj = datacursormode(gcf);
        set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.
    end
end

