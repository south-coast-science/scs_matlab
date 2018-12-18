clearvars;

filename = mfilename('fullpath');
[~, name, ~] = fileparts(filename);

% User-defined variables:
Topic_ID = 'unep/ethiopia/loc/1/particulates';
start_time = '2018-12-12T12:00:00Z';
end_time = '2018-12-13T12:00:00Z';
avg_interval = '**:/5:00';
%-------------------------------------------------------------------------------------------   
json_decode = all_functions.aggr_decode_hist(Topic_ID, start_time, end_time, avg_interval);
sample_length = length(json_decode);

for n = 1:sample_length
    aggr.datetime{n ,1} = json_decode(n).rec;
    aggr.PM2p5_min(n, 1) = json_decode(n).val.pm2p5.min;
    aggr.PM2p5(n, 1) = json_decode(n).val.pm2p5.mid;
    aggr.PM2p5_max(n, 1) = json_decode(n).val.pm2p5.max;
end

aggr.t = cellfun(@all_functions.datenum8601, cellstr(aggr.datetime));
figure();
plot(aggr.t, aggr.PM2p5_min, 'r:', aggr.t, aggr.PM2p5, 'r', aggr.t, aggr.PM2p5_max, 'r:');
datetick('x', 'dd-mmm-yy HH:MM', 'keepticks', 'keeplimits');
legend('PM10 min', 'PM10 mid', 'PM10 max')
title(Topic_ID)

dcm_obj = datacursormode(gcf);
set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor);