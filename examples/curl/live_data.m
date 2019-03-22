% LIVE CURL DATA IMPORTER & PLOTTER
%
% Created 08 December 2018
%
%@author Milton Logothetis (milton.logothetis@southcoastscience.com)
%
% DESCRIPTION
% This script utilises cURL in order to import and plot raw live data
% from a subscribed topic and a specified URL. 
% 
% EXAMPLE
% 1. Specify user-defined variables.
% 2. Specify parameters to be imported and plotted off subscribed topic:
% 
% fmt: {type.data."parameter_name"(var.i,1) = jsondecode(var.i)."JSON_field"}
% 
% 3. Specify which parameters to plot within Y_data structure:
% 
% fmt (2D): {Y_data."decoded_parameter_name" = [];}
% 
% SEE ALSO
% utilities.multiplot (multiple 2D plot)

clearvars;

% User-defined variables:
var.Topic_ID = 'south-coast-science-dev/alphasense/loc/301/particulates';           % Specify subscription topic.
var.url = 'https://aws.southcoastscience.com/topicMessages?topic=%s&startTime=%s';  % Specify URL.
sampling_rate = 10;                                                                 % Specify sensor's sampling rate in seconds.

% Initialization
filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);
jsondecode = cell(1000,1);
var.i = 0;
hist.last_update = [1;0];
live_fig = figure('Name', 'Live Data');

while (1)
    var.i = var.i + 1;
    
    if var.i==1 && isfield(jsondecode{1,1}, 'message')==0
        var.start_time = utilities.time_init(var.Topic_ID);
        pause(sampling_rate*2);
        jsondecode{var.i,2} = utilities.curl_decode(var);
        var.start_time = jsondecode{var.i,2}.Items(end).payload.rec;
    elseif var.i > 1
        var.start_time = type.data.datetime{end};
    end
    pause(sampling_rate);
    jsondecode{var.i,1} = utilities.curl_decode(var);
    
    if isfield(jsondecode{1,1}, 'message')==1
        var.i = 0;
        continue
    end
    if isfield(jsondecode{var.i,1}, 'Items')==1
        if isempty(jsondecode{var.i,1}.Items)==1 && var.i==1
            var.i = 0;
            var.j = 0;
            continue
        end
    end
    var.z = var.i;
    item_len = length(jsondecode{var.z}.Items);
    if item_len>1
        for n = 2:item_len
            jsondecode{var.i+n-1}.Items = jsondecode{var.z}.Items(2);
            jsondecode{var.z}.Items(2) = [];
        end
       var.i = var.i+n-1;
    end
    
    for x = var.z : (var.z+item_len-1)
        % Specify parameters to decode from JSON format:
        type.data.datetime{x,1}= jsondecode{x}.Items.payload.rec;
        type.data.PM1(x,1) = jsondecode{x}.Items.payload.val.pm1;
        type.data.PM2p5(x,1) = jsondecode{x}.Items.payload.val.pm2p5;
        type.data.PM10(x,1) = jsondecode{x}.Items.payload.val.pm10;
    end
    
    % Specify parameters for 2D plot:
    Y_data.PM1 = []; Y_data.PM2p5 = []; Y_data.PM10 =[];
    utilities.multiplot(Y_data, type, hist, var, jsondecode, live_fig);
end