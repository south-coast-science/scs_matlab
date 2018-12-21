clearvars;

%User-defined variables:
url = 'https://aws.southcoastscience.com/topicMessages?topic=unep/ethiopia/loc/1/climate&startTime=%s&endTime=%s';
start_time = '2018-12-13T07:03:59.712Z';
end_time = '2018-12-13T15:10:59.712Z';
%------------------------------------------------------------------------------------------------------------------------------------------------------------
url = sprintf(url, start_time, end_time);

i = 0;
while (size(url) > 0)
    i = i + 1;
    command='curl -s "%s"';
    [~,curl_out]=system(sprintf(command, url));
    json_decode=jsondecode(curl_out);
    
    for i=i:length(json_decode.Items)
        data.datetime{i,1}= json_decode.Items(i).payload.rec;
        %data.NO2(i,1)= json_decode.Items(i).payload.val.NO2.cnc;
        %data.H2S(i,1)= json_decode.Items(i).payload.val.H2S.cnc;
        %data.CO(i,1)= json_decode.Items(i).payload.val.CO.cnc;
        %data.SO2(i,1)= json_decode.Items(i).payload.val.SO2.cnc;
        data.tmp(i,1)= json_decode.Items(i).payload.val.tmp;
        data.hmd(i,1)= json_decode.Items(i).payload.val.hmd;
    end
    
    if isfield(json_decode, 'next') == 1
        i = i + 1;
        url = json_decode.next;
        command=sprintf(command, url);
        [~,curl_out]=system(command);
        json_decode=jsondecode(curl_out);
        sample_length=length(json_decode.Items);
        
        for i = i:length(json_decode.Items)
        data.datetime{i,1}= json_decode.Items(i).payload.rec;
        %data.NO2(i,1)= json_decode.Items(i).payload.val.NO2.cnc;
        %data.H2S(i,1)= json_decode.Items(i).payload.val.H2S.cnc;
        %data.CO(i,1)= json_decode.Items(i).payload.val.CO.cnc;
        %data.SO2(i,1)= json_decode.Items(i).payload.val.SO2.cnc;
        data.tmp(i,1)= json_decode.Items(i).payload.val.tmp;
        data.hmd(i,1)= json_decode.Items(i).payload.val.hmd;
        end
    else
        url = '';
    end
end

data.t = cellfun(@all_functions.datenum8601, cellstr(data.datetime));
figure();
plot(data.t, data.tmp, data.t, data.hmd)
datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
legend('tmp', 'hmd')
xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})

dcm_obj = datacursormode(gcf);
set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.
