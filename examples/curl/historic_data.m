clearvars;
%User-defined variables:
var.Topic_ID = 'unep/ethiopia/loc/1/particulates';
var.url = 'https://aws.southcoastscience.com/topicMessages?topic=%s&startTime=%s&endTime=%s';
var.start_time = '2018-12-12T12:00:00Z';
var.end_time = '2018-12-12T15:00:00Z';
%------------------------------------------------------------------------------------------------------------------------------------------------------------
var.url = sprintf(var.url, var.Topic_ID, var.start_time, var.end_time);

i = 0;
while (size(var.url) > 0)
    i = i + 1;
    json_decode = all_functions.curl_decode(var);
    
    for i = i:length(json_decode.Items)
        data.datetime{i,1}= json_decode.Items(i).payload.rec;
        %data.NO2(i,1)= json_decode.Items(i).payload.val.NO2.cnc;
        %data.H2S(i,1)= json_decode.Items(i).payload.val.H2S.cnc;
        %data.CO(i,1)= json_decode.Items(i).payload.val.CO.cnc;
        %data.SO2(i,1)= json_decode.Items(i).payload.val.SO2.cnc;
        %data.tmp(i,1)= json_decode.Items(i).payload.val.tmp;
        %data.hmd(i,1)= json_decode.Items(i).payload.val.hmd;
        data.pm1(i,1) = json_decode.Items(i).payload.val.pm1;
        data.pm2_5(i,1) = json_decode.Items(i).payload.val.pm2p5;
        data.pm10(i,1) = json_decode.Items(i).payload.val.pm10;
        
    end
    
    while isfield(json_decode, 'next') == 1
        i = i + 1;
        i_init = i;
        item_num = 0;
        json_decode = all_functions.curl_decode_next(var, json_decode);
        for i = i:(i_init+length(json_decode.Items)-1)
            item_num = item_num + 1;
            data.datetime{i,1}= json_decode.Items(item_num).payload.rec;
            %data.NO2(i,1)= json_decode.Items(item_num).payload.val.NO2.cnc;
            %data.H2S(i,1)= json_decode.Items(item_num).payload.val.H2S.cnc;
            %data.CO(i,1)= json_decode.Items(item_num).payload.val.CO.cnc;
            %data.SO2(i,1)= json_decode.Items(item_num).payload.val.SO2.cnc;
            %data.tmp(i,1)= json_decode.Items(item_num).payload.val.tmp;
            %data.hmd(i,1)= json_decode.Items(item_num).payload.val.hmd;
            data.pm1(i,1) = json_decode.Items(item_num).payload.val.pm1;
            data.pm2_5(i,1) = json_decode.Items(item_num).payload.val.pm2p5;
            data.pm10(i,1) = json_decode.Items(item_num).payload.val.pm10;
        end
    end
    var.url = '';
end

figure();
Y_data = [data.pm1, data.pm2_5, data.pm10];
[data.t, chart] = all_functions.twoD_plot(var, Y_data, data, i);
legend('pm1', 'pm2.5', 'pm10')

