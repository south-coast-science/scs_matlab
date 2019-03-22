% CURL HISTORIC DATA IMPORTER & PLOTTER
%
% Created 08 December 2018
%
%@author Milton Logothetis (milton.logothetis@southcoastscience.com)
%
% DESCRIPTION
% This script utilises cURL in order to import and plot raw historic data
% from a subscribed topic and a specified URL. 
% 
% EXAMPLE
% 1. Specify user-defined variables.
% 2. Specify parameters to be imported and plotted in "assign_parameter" function:
% 
% fmt: {type.data."parameter_name"(var.i,1) = jsondecode(var.i)."JSON_field"}
% 
% 3. Specify which parameters to plot within Y_data structure:
% 
% fmt (2D): {Y_data."decoded_parameter_name" = [];}
%
% 4. Choose plot type
% 
% SEE ALSO
% utilities.multiplot (multiple 2D plot)

clearvars;

% User-defined variables:
var.Topic_ID = 'unep/ethiopia/loc/1/particulates';
var.url = 'https://aws.southcoastscience.com/topicMessages?topic=%s&startTime=%s&endTime=%s';
var.start_time = '2018-12-12T12:00:00Z';
var.end_time = '2018-12-12T15:00:00Z';

% Initialization
filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);
var.url = sprintf(var.url, var.Topic_ID, var.start_time, var.end_time);
hist.last_update = [1;0];
type = [];

i = 0;
while (size(var.url) > 0)
    i = i + 1;
    jsondecode = utilities.curl_decode(var); % import & decode batch of parameters.
    
    for i = i:length(jsondecode.Items)
        type = assign_parameter(type, jsondecode, i, 0, 0); % assign parameters to arrays.
    end
    
    while isfield(jsondecode, 'next') == 1
        i = i + 1;
        i_init = i;
        item_num = 0;
        jsondecode = utilities.curl_decode_next(var, jsondecode); % if batch exceeds 1000 outputs then call next batch.
        
        for i = i:(i_init+length(jsondecode.Items)-1)
            item_num = item_num + 1;
            type = assign_parameter(type, jsondecode, i, item_num, 1); % assign parameters to arrays.
        end
    end
    var.url = ''; 
end
fig = figure('Name', 'Historic Data');

% Specify parameters for 2D plot:
Y_data.PM1 = []; Y_data.PM2p5 = []; Y_data.PM10 =[];
utilities.multiplot(Y_data, type, hist, var, jsondecode, fig);

function type = assign_parameter(type, jsondecode, i, item_num, next)
if next==0 % indicate whether curl.next is being called.
    item_num = i;
end

% Specify parameters to decode from JSON format:
type.data.datetime{i,1}= jsondecode.Items(item_num).payload.rec;
type.data.PM1(i,1) = jsondecode.Items(item_num).payload.val.pm1;
type.data.PM2p5(i,1) = jsondecode.Items(item_num).payload.val.pm2p5;
type.data.PM10(i,1) = jsondecode.Items(item_num).payload.val.pm10;
end