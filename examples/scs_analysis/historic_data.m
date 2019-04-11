% HISTORIC DATA IMPORTER & PLOTTER
%
% Created 20 December 2018
%
%@author Milton Logothetis (milton.logothetis@southcoastscience.com)
%
% DESCRIPTION
% This script utilises AWS scs_analysis tools in order to import and plot
% raw historic data from a subscribed topic. 
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
% 4. Choose plot type
% 
% SEE ALSO
% utilities.multiplot (multiple 2D plot)

clearvars;

% User-defined variables:
var.Topic_ID = 'unep/ethiopia/loc/1/particulates';
var.start_time = '2018-12-24T00:00:00Z';
var.end_time = '2018-12-24T01:00:00Z';

% Initialization
filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);
jsondecode = utilities.decode_fcn(var); % Import parameters in JSON format. 
var.sample_length = length(jsondecode);
hist.last_update = [1;0]; % Indicate data type is raw data.

for i = 1:var.sample_length
    var.i = i;
    
    % Specify parameters to decode from JSON format:
    type.data.datetime{var.i,1} = jsondecode(var.i).rec;
    type.data.PM1(var.i,1) = jsondecode(var.i).val.pm1;
    type.data.PM2p5(var.i,1) = jsondecode(var.i).val.pm2p5;
    type.data.PM10(var.i,1) = jsondecode(var.i).val.pm10;
end

live_fig = figure('Name', 'Historic Data');

% Specify parameters for 2D plot:
Y_data.PM10 = []; Y_data.PM2p5 = []; Y_data.PM1 = []; 
utilities.multiplot(Y_data, type, hist, var, jsondecode, live_fig);
