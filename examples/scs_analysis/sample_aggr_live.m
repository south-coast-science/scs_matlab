% SAMPLE AGGREGATE LIVE DATA IMPORTER & PLOTTER
%
% Created 20 December 2018
%
%@author Milton Logothetis (milton.logothetis@southcoastscience.com)
%
% DESCRIPTION
% This script utilises AWS scs_analysis tools in order to import and plot
% aggregated live data from a subscribed topic. 
% 
% EXAMPLE
% 1. Specify user-defined variables.
% 2. Specify parameters to be imported and plotted off subscribed topic:
% 
% fmt: {type.aggr."parameter_name"(var.i+n-1,1) = jsondecode{var.j,1}(n)."JSON_field"}
% 
% 3. Specify which parameters to plot within Y_data structure:
% 
% fmt (2D): {Y_data."decoded_parameter_name" = [];}
% 
% SEE ALSO
% utilities.multiplot (multiple 2D plot)

clearvars;

% User-defined variables:
var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases'; % Specify subscription topic.
sampling_rate = 10;                                                   % Specify sensor's sampling rate in seconds.
var.avg_interval = '**:/15:00';                                       % Specify averaging time interval in required format.
var.sampling_rate_sec = 15*60;                                        % Specify averaging time interval in seconds.

% Initialization
filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);
var.start_time = utilities.time_init(var.Topic_ID);
var.i = 0;
hist.last_update = [0;1]; % indicate script contains aggregated data.
aggr_fig = figure('Name', 'Aggregated Live Data');

while(1)
    pause(var.sampling_rate_sec);
    
    if var.i==0
    var.i = var.i + 1;
    var.j = var.i;
    elseif var.i>0
        var.i = var.i + n;
        var.j = var.j + 1;
        var.start_time = jsondecode{end,1}(end).rec;
    end

    jsondecode{var.j,1} = utilities.decode_fcn(var);
    
    % Define parameters extracted from aggregated data:
    for n = 1:length(jsondecode{end})
        type.aggr.datetime{var.i+n-1,1} = jsondecode{var.j,1}(n).rec;
        type.aggr.CO(var.i+n-1,1) = jsondecode{var.j,1}(n).val.CO.cnc.mid;
        type.aggr.CO_min(var.i+n-1,1) = jsondecode{var.j,1}(n).val.CO.cnc.min;
        type.aggr.CO_max(var.i+n-1,1) = jsondecode{var.j,1}(n).val.CO.cnc.max;
        type.aggr.NO2(var.i+n-1,1)= jsondecode{var.j,1}(n).val.NO2.cnc.mid;
        type.aggr.NO2_min(var.i+n-1,1) = jsondecode{var.j,1}(n).val.NO2.cnc.min;
        type.aggr.NO2_max(var.i+n-1,1) = jsondecode{var.j,1}(n).val.NO2.cnc.max;
    end
        
    % Specify parameters for 2D plot:
    Y_data.CO = []; Y_data.NO2 = []; 
    utilities.multiplot(Y_data, type, hist, var, jsondecode, aggr_fig);
    
    % % Specify a single parameter for 3D plot:
    Z_data = type.aggr.CO;
    ddd_handle = utilities.ddd_bar_plot(type,var, Z_data);
end