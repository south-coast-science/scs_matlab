clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

%User-defined variables:
var.Topic_ID ='unep/ethiopia/loc/1/gases';
sampling_rate = 10;                        % sensor's sampling rate in seconds
var.avg_interval = '**:/1:00';
avg_interval_sec = 60;                     % averaging interval in seconds
%--------------------------------------------------------------------------
%Pre-allocation
var.start_time = cell(1000,1);
var.start_time_aggr = cell(1000,1);
%--------------------------------------------------------------------------
%Initialization
var.avg_ratio = avg_interval_sec/sampling_rate;
var.start_time{1,1} = utilities.time_init(var);
var.i = 0;
var.a = 0;
while (1)
     pause(sampling_rate);
    if var.i==0
        var.i = var.i + 1;
        var.j = var.i;
    elseif var.i>0
        var.i = var.i + n;
        var.j = var.j + 1;
        var.start_time{var.j,1} = type.data.datetime{end};
    end
    % Check last updated type
    hist.data = [];
    if isfield(hist, 'aggr')
    hist = rmfield(hist, 'aggr');
    end
    hist.last_update = [isfield(hist, 'data'); isfield(hist, 'aggr')];
    
    jsondecode{var.j,1} = utilities.decode_live_merge(var);
   
    for n = 1:length(jsondecode{end,1})
        type.data.datetime{var.i+n-1,1} = jsondecode{var.j,1}(n).rec;
        type.data.NO2(var.i+n-1,1) = jsondecode{var.j,1}(n).val.NO2.cnc;
        %type.data.CO(var.i+n-1,1) = jsondecode{var.j,1}(n).val.CO.cnc;
        type.data.SO2(var.i+n-1,1) = jsondecode{var.j,1}(n).val.SO2.cnc;
        %type.data.H2S(var.i+n-1,1) = jsondecode{var.j,1}(n).val.H2S.cnc;
        type.data.hmd(var.i+n-1,1) = jsondecode{var.j,1}(n).val.sht.hmd;
        type.data.tmp(var.i+n-1,1) = jsondecode{var.j,1}(n).val.sht.tmp;
    end
    
    if var.i==1
        live_fig = figure('Name', 'Live Data');
    end
    Y_data.NO2 = [];  % Specify parameters to plot.
    live_fig = utilities.multiplot(Y_data, type, hist, var, jsondecode, live_fig);
        
    if rem(var.i, var.avg_ratio)==0
      
    if var.a==0
    var.a = var.a+1;
    var.b = var.a;
    elseif var.a>0
        var.a = var.a+x;
        var.b = var.b+1;
        var.start_time_aggr{var.a} = type.aggr.datetime{end};
    end
    % Check last updated type
    hist.aggr = [];
    hist = rmfield(hist, 'data');
    hist.last_update = [isfield(hist, 'data'); isfield(hist, 'aggr')];
    
    jsondecode_aggr{var.b,1} = utilities.aggr_decode_live_merge(var);
    
    % Define parameters extracted from aggregated data:
    for x = 1:length(jsondecode_aggr{end,1})
        type.aggr.datetime{var.a+x-1,1} = jsondecode_aggr{var.b,1}(x).rec;
        type.aggr.NO2(var.a+x-1,1)= jsondecode_aggr{var.b,1}(x).val.NO2.cnc.mid;
        type.aggr.NO2_min(var.a+x-1,1) = jsondecode_aggr{var.b,1}(x).val.NO2.cnc.min;
        type.aggr.NO2_max(var.a+x-1,1) = jsondecode_aggr{var.b,1}(x).val.NO2.cnc.max;
        type.aggr.tmp(var.a+x-1,1) = jsondecode_aggr{var.b,1}(x).val.sht.tmp.mid;
        type.aggr.tmp_min(var.a+x-1,1) = jsondecode_aggr{var.b,1}(x).val.sht.tmp.min;
        type.aggr.tmp_max(var.a+x-1,1) = jsondecode_aggr{var.b,1}(x).val.sht.tmp.max;
    end
    
    if var.a==1
        aggr_fig = figure('Name', 'Live Aggregated Data');
    end
    Y_data_aggr.NO2 = []; Y_data_aggr.tmp = []; % Specify parameters to plot in shown format.
    aggr_fig = utilities.multiplot(Y_data_aggr, type, hist, var, jsondecode_aggr, aggr_fig);
    end
end