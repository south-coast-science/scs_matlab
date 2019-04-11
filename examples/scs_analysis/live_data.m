% LIVE DATA IMPORTER & PLOTTER
%
% Created 20 December 2018
%
%@author Milton Logothetis (milton.logothetis@southcoastscience.com)
%
% DESCRIPTION
% This script utilises AWS scs_analysis tools in order to import and plot
% raw live data from a subscribed topic. 
% 
% EXAMPLE
% 1. Specify user-defined variables.
% 2. Specify parameters to be imported and plotted off subscribed topic:
% 
% fmt: {type.data."parameter_name"(var.i+n-1,1) = jsondecode{var.j,1}(n)."JSON_field"}
% 
% 3. Specify which parameters to plot within Y_data structure:
% 
% fmt (2D): {Y_data."decoded_parameter_name" = [];}
% 
% SEE ALSO
% utilities.multiplot (multiple 2D plot)

clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

% User-defined variables:
var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/gases'; % Specify subscription topic.
sampling_rate = 10;                                                   % Specify sensor's sampling rate in seconds.

% Initialization
var.start_time = utilities.time_init(var.Topic_ID);
var.i = 0;
hist.last_update = [1;0]; % Indicate data type is raw data.

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
    
    % Decode parameters from JSON format:
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
        live_fig = figure('Name', 'Live Data'); % Initialize figure.
    end
    
    % Specify parameters for 2D plot:
    Y_data.NO2 = []; Y_data.SO2 =[]; Y_data.tmp =[]; Y_data.hmd=[];
    [live_fig,properties,mplt] = utilities.multiplot(Y_data, type, hist, var, jsondecode, live_fig);
end