clearvars;

%User-defined variables:
var.Topic_ID ='unep/ethiopia/loc/1/gases';
sampling_rate = 10; % sensor's sampling rate in seconds
var.avg_interval = '**:/1:00';
avg_interval_sec = 60; % averaging interval in seconds
%---------------------------------------------------------------------
var.start_time = cell(1000,1);
%Initialization
var.avg_ratio = avg_interval_sec/sampling_rate;
sensor_datetime = 'localised_datetime.py';
[~, var.start_time{1,1}] = system(sensor_datetime);
var.start_time{1,1} = strtrim(var.start_time{1,1});
pause(sampling_rate);
var.i = 0;
var.a = 0;
data.init.jsondecode = all_functions.decode_live(var);
while (1)
    
    var.i = var.i + 1;
    
    if var.i==1
        var.start_time{var.i,1} = data.init.jsondecode(end).rec;
        pause(sampling_rate);
    elseif var.i>1
        var.start_time{var.i,1} = data.jsondecode{end,1}.rec;
        pause(sampling_rate);
    end
    data.jsondecode{var.i, 1} = all_functions.decode_live(var);
    document_len = length(data.jsondecode{var.i,1});
    
    if document_len > 1
        for n = 2:document_len
            data.jsondecode{var.i+n-1,1} = data.jsondecode{var.i,1}(n);
            
            for j=var.i:(var.i+document_len-1)
                %Define parameters extracted from decoded live data:
                data.parameters.datetime{j, 1} = data.jsondecode{var.i, 1}(n-1).rec;
                data.parameters.NO2(j, 1) = data.jsondecode{var.i, 1}(n-1).val.NO2.cnc;
                %data.parameters.CO(j, 1) = data.jsondecode{var.i, 1}(n-1).val.CO.cnc;
                data.parameters.SO2(j, 1) = data.jsondecode{var.i, 1}(n-1).val.SO2.cnc;
                %data.parameters.H2S(j, 1) = data.jsondecode{var.i, 1}(n-1).val.H2S.cnc;
                data.parameters.hmd(j, 1) = data.jsondecode{var.i, 1}(n-1).val.sht.hmd;
                data.parameters.tmp(j, 1) = data.jsondecode{var.i, 1}(n-1).val.sht.tmp;
                n=n+1;
            end
            n=n-document_len;
            data.jsondecode{var.i,1}(n)=[];
        end
        var.i=var.i+n-1;
    else
        %Define live extracted parameter names:
        data.parameters.datetime{var.i, 1} = data.jsondecode{var.i, 1}.rec;
        data.parameters.NO2(var.i, 1) = data.jsondecode{var.i, 1}.val.NO2.cnc;
        %data.parameters.CO(var.i, 1) = data.jsondecode{var.i, 1}.val.CO.cnc;
        data.parameters.SO2(var.i, 1) = data.jsondecode{var.i, 1}.val.SO2.cnc;
        %data.parameters.H2S(var.i, 1) = data.jsondecode{var.i, 1}.val.H2S.cnc;
        data.parameters.hmd(var.i, 1) = data.jsondecode{var.i, 1}.val.sht.hmd;
        data.parameters.tmp(var.i, 1) = data.jsondecode{var.i, 1}.val.sht.tmp;
    end
    
    data.t = cellfun(@all_functions.datenum8601, cellstr(data.parameters.datetime));
    
    figure(1);
    plot(data.t, data.parameters.NO2) %Specify parameteres to plot live.
    datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
    legend('NO2')
    title(var.Topic_ID)
    xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
    
    dcm_obj = datacursormode(gcf);
    set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.
    
    if rem(var.i, var.avg_ratio)==0
        
        if var.a==0
            var.a = var.a+1;
            var.b=var.a;
            [aggr.decode{var.b,2}] = all_functions.aggr_decode_live_merge(var);
        elseif var.a>0
            var.a = var.a+x;
            var.b=var.b+1;
            var.start_time_aggr = aggr.decode{end,2}(end).rec;
            [aggr.decode{var.b,2}] = all_functions.aggr_decode_live(var);
        end        
        for x=1:length(aggr.decode{end,2})
            %Define parameters to extract from decoded aggregated data:
            aggr.datetime{var.a+x-1,1} = aggr.decode{var.b,2}(x).rec;
            aggr.t = cellfun(@all_functions.datenum8601, cellstr(aggr.datetime));
            aggr.NO2(var.a+x-1,2)= aggr.decode{var.b,2}(x).val.NO2.cnc.mid;
            aggr.NO2(var.a+x-1,1) = aggr.decode{var.b,2}(x).val.NO2.cnc.min;
            aggr.NO2(var.a+x-1,3) = aggr.decode{var.b,2}(x).val.NO2.cnc.max;
        end
        figure(2);
        plot(aggr.t, aggr.NO2(1:end,1), ':r',...
             aggr.t, aggr.NO2(1:end,2),'r',...
             aggr.t, aggr.NO2(1:end,3), ':r') %Insert aggregated parameters to plot.
        datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
        legend('max', 'mid', 'min')
        title(var.Topic_ID)
        xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
        
        dcm_obj = datacursormode(gcf);
        set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.
    end
end

