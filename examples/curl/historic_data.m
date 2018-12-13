clearvars;

%User-defined variables:
API_key='api-key de92c5ff-b47a-4cc4-a04c-62d684d74a1f';
Topic_ID='south-coast-science-dev/production-test/loc/1/gases';
Time_interval='2018-10-26T09:35:00+01:00/2018-10-26T10:40:00+01:00';
%---------------------------------------------------------------------------------
command='curl -s -H "Authorization: %s" https://aws.southcoastscience.com/%s/%s/';
[~,cURL_out]=system(sprintf(command, API_key, Topic_ID, Time_interval));
json_decode=jsondecode(cURL_out);
sample_length=length(json_decode.Items);

%Pre-allocating variables:
datetime=cell(items_num,1);
NO2=zeros(items_num,1);
H2S=zeros(items_num,1);
CO=zeros(items_num,1);
SO2=zeros(items_num,1);
tmp=zeros(items_num,1);
hmd=zeros(items_num,1);

for n=1:sample_length
    data.parameters.datetime{n,1}= json_decode.Items(n).payload.rec;
    data.parameters.NO2(n,1)= json_decode.Items(n).payload.val.NO2.cnc;
    data.parameters.H2S(n,1)= json_decode.Items(n).payload.val.H2S.cnc;
    data.parameters.CO(n,1)= json_decode.Items(n).payload.val.CO.cnc;
    data.parameters.SO2(n,1)= json_decode.Items(n).payload.val.SO2.cnc;
    data.parameters.tmp(n,1)= json_decode.Items(n).payload.val.sht.tmp;
    data.parameters.hmd(n,1)= json_decode.Items(n).payload.val.sht.hmd;
end

data.t = cellfun(@all_functions.datenum8601, cellstr(data.datetime));
figure();
plot(data.t, data.parameters.CO)
datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
legend('CO');
title(User.Topic_ID);
xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'});

dcm_obj = datacursormode(gcf);
set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); %Update "Data-Cursor" callback to display datetime x-values.



