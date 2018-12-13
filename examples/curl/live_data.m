clearvars;

%User-defined variables:
API_key='api-key de92c5ff-b47a-4cc4-a04c-62d684d74a1f';
Topic_ID='south-coast-science-dev/production-test/loc/1/gases';
%-----------------------------------------------------------------------------------
i = 0;
while (1)
i = i + 1;

current_time_cmd='localised_datetime.py';
[~, localised_datetime_start]=system(sprintf(current_time_cmd));
pause(10);
delayed_time_cmd='localised_datetime.py';
[~, localised_datetime_end]=system(sprintf(delayed_time_cmd));
Time_interval='%s/%s';
Time_interval=sprintf(Time_interval, localised_datetime_start,localised_datetime_end);
curl_cmd='curl -s -H "Authorization: %s" https://aws.southcoastscience.com/%s/%s/';
[~,curl_out]=system(sprintf(curl_cmd, API_key, Topic_ID, Time_interval));

json_decode=jsondecode(curl_out);
sample_length=length(json_decode.Items);

%Parameters to plot:
data.parameters.datetime{i,1}= json_decode.Items(i).payload.rec;
data.parameters.NO2(i,1)= json_decode.Items(i).payload.val.NO2.cnc;
data.parameters.H2S(i,1)= json_decode.Items(i).payload.val.H2S.cnc;
data.parameters.CO(i,1)= json_decode.Items(i).payload.val.CO.cnc;
data.parameters.SO2(i,1)= json_decode.Items(i).payload.val.SO2.cnc;
data.parameters.tmp(i,1)= json_decode.Items(i).payload.val.sht.tmp;
data.parameters.hmd(i,1)= json_decode.Items(i).payload.val.sht.hmd;

data.t = cellfun(@all_functions.datenum8601, cellstr(data.datetime));
figure();
plot(data.t, data.parameters.CO)
datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
legend('CO');
title(User.Topic_ID);
xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'});

dcm_obj = datacursormode(gcf);
set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.
end




