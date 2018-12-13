clearvars;

% User-defined variables:
Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases'; % Specify subscription topic.
sampling_rate = 10;                                               % Specify sensor's sampling rate in seconds.
%-------------------------------------------------------------------------------------------------------------
% Pre-allocating variables
localised_datetime_start = cell(1000, 1);
dataout = cell(1000, 1);
%-------------------------------------------------------------------------------------------------------------
sensor_datetime = 'localised_datetime.py';
[~, data.init.datetime] = system(sensor_datetime);
data.init.datetime = strtrim(data.init.datetime);
pause(sampling_rate);
hist_cmd = 'aws_topic_history.py %s -s %s | node.py -a';
[~, data.init.dataout] = system(sprintf(hist_cmd, Topic_ID, data.init.datetime));
data.init.jsondecode = jsondecode(data.init.dataout);

i = 0;
while (1)
    
i = i + 1;

if i==1
    localised_datetime_start{i,1} = data.init.jsondecode(end).rec;
    pause(sampling_rate);
    
elseif i>1
    localised_datetime_start{i,1} = data.jsondecode{end,1}.rec;
    pause(sampling_rate);
end

[~, dataout{i,1}] = system(sprintf(hist_cmd, Topic_ID, localised_datetime_start{i,1}));

data.jsondecode{i, 1} = jsondecode(dataout{i, 1});
document_len = length(data.jsondecode{i,1});

if document_len > 1
    for n = 2:document_len
        data.jsondecode{i+n-1,1} = data.jsondecode{i,1}(n);
        
        for j=i:(i+document_len-1)
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
plot(data.t, data.parameters.NO2, data.t, data.parameters.CO)
datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
legend('NO2','CO')
title(Topic_ID)
xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})

dcm_obj = datacursormode(gcf);
set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); % Updates "Data-Cursor" callback to display datetime x-values.
end

   