clearvars;

%User-defined variables:
url = 'https://aws.southcoastscience.com/topicMessages?topic=unep/ethiopia/loc/1/climate&startTime=%s';
sampling_rate = 60;
%-----------------------------------------------------------------------------------------------------------------
i = 0;
while (1)
    i = i + 1;
    
    if i==1
        [~, start_time] = system('localised_datetime.py');
        start_time = strtrim(start_time);
    elseif i > 1
        start_time = data.datetime{end,1};
    end
    pause(sampling_rate);
    url = sprintf(url, start_time);
    curl_cmd = 'curl -s "%s"';
    [~,curl_out] = system(sprintf(curl_cmd, url));
    json_decode = jsondecode(curl_out);
    doc_length = length(json_decode.Items);
    
    data.datetime{i,1}= json_decode.Items(i).payload.rec;
    data.tmp(i,1)= json_decode.Items(i).payload.val.tmp;
    data.hmd(i,1)= json_decode.Items(i).payload.val.hmd;
    
    data.t = cellfun(@all_functions.datenum8601, cellstr(data.datetime));
    figure(1);
    plot(data.t, data.tmp, data.t, data.hmd)
    datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
    legend('tmp', 'hmd');
    xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'});
    
    dcm_obj = datacursormode(gcf);
    set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.
end




