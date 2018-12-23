clearvars;

% User-defined variables:
var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases'; % Specify subscription topic.
sampling_rate = 10;                                                   % Specify sensor's sampling rate in seconds.
%-------------------------------------------------------------------------------------------------------------
% Pre-allocating variables
var.start_time = cell(1000, 1);
%-------------------------------------------------------------------------------------------------------------
var.i = 0;
while (1)
var.i = var.i + 1;

if var.i==1
    var.start_time{var.i} = all_functions.time_init(var);
elseif var.i>1
    var.start_time{var.i} = data.jsondecode{end}.rec;
end
pause(sampling_rate);
data.jsondecode{var.i,1} = all_functions.decode_live(var);
doc_len = length(data.jsondecode{var.i,1});

if doc_len > 1
    for n = 2:doc_len
        data.jsondecode{var.i+n-1} = data.jsondecode{var.i}(n);
        
        for j=var.i:(var.i+doc_len-1)
            data.parameters.datetime{j,1} = data.jsondecode{var.i}(n-1).rec;
            data.parameters.NO2(j,1) = data.jsondecode{var.i}(n-1).val.NO2.cnc;
            data.parameters.CO(j,1) = data.jsondecode{var.i}(n-1).val.CO.cnc;
            data.parameters.SO2(j,1) = data.jsondecode{var.i}(n-1).val.SO2.cnc;
            data.parameters.H2S(j,1) = data.jsondecode{var.i}(n-1).val.H2S.cnc;
            data.parameters.hmd(j,1) = data.jsondecode{var.i}(n-1).val.sht.hmd;
            data.parameters.tmp(j,1) = data.jsondecode{var.i}(n-1).val.sht.tmp;
            n=n+1;
        end
        n=n-doc_len;
        data.jsondecode{var.i}(n)=[];
    end
    var.i=var.i+n-1;
else
    data.parameters.datetime{var.i,1} = data.jsondecode{var.i}.rec;
    data.parameters.NO2(var.i,1) = data.jsondecode{var.i}.val.NO2.cnc;
    data.parameters.CO(var.i,1) = data.jsondecode{var.i}.val.CO.cnc;
    data.parameters.SO2(var.i,1) = data.jsondecode{var.i}.val.SO2.cnc;
    data.parameters.H2S(var.i,1) = data.jsondecode{var.i}.val.H2S.cnc;
    data.parameters.hmd(var.i,1) = data.jsondecode{var.i}.val.sht.hmd;
    data.parameters.tmp(var.i,1) = data.jsondecode{var.i}.val.sht.tmp;
end

data.t = cellfun(@all_functions.datenum8601, cellstr(data.parameters.datetime));

figure(1);
plot(data.t, data.parameters.NO2, data.t, data.parameters.CO)
datetick('x', 'dd-mmm-yy HH:MM:SS','keepticks','keeplimits')
legend('NO2','CO')
title(var.Topic_ID)
xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})

dcm_obj = datacursormode(gcf);
set(dcm_obj, 'UpdateFcn',@all_functions.data_cursor); % Updates "Data-Cursor" callback to display datetime x-values.
end

   