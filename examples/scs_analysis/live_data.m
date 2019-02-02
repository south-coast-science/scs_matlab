clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

% User-defined variables:
var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases'; % Specify subscription topic.
sampling_rate = 10;                                                   % Specify sensor's sampling rate in seconds.
%-------------------------------------------------------------------------------------------------------------
% Initialization
var.start_time = utilities.time_init(var);
var.i = 0;
while (1)
    pause(sampling_rate);
    if var.i==0
        var.i = var.i + 1;
        var.j = var.i;
    elseif var.i>0
        var.i = var.i + n;
        var.j = var.j + 1;
        var.start_time = type.data.datetime{end};
    end
    jsondecode{var.j,1} = utilities.decode_fcn(var);
   
    for n = 1:length(jsondecode{end})
        type.data.datetime{var.i+n-1,1} = jsondecode{var.j,1}(n).rec;
        type.data.NO2(var.i+n-1,1) = jsondecode{var.j,1}(n).val.NO2.cnc;
        type.data.CO(var.i+n-1,1) = jsondecode{var.j,1}(n).val.CO.cnc;
        type.data.SO2(var.i+n-1,1) = jsondecode{var.j,1}(n).val.SO2.cnc;
        type.data.H2S(var.i+n-1,1) = jsondecode{var.j,1}(n).val.H2S.cnc;
        type.data.hmd(var.i+n-1,1) = jsondecode{var.j,1}(n).val.sht.hmd;
        type.data.tmp(var.i+n-1,1) = jsondecode{var.j,1}(n).val.sht.tmp;
    end
    
    if var.i==1
        live_fig = figure('Name', 'Live Data');
    end
    Y_data.NO2 = []; Y_data.tmp =[]; % Specify plotted parameters in shown format.
    multiplot(Y_data, type, var, jsondecode, live_fig);
end