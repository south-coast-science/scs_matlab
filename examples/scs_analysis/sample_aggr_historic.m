% HISTORIC AGGREGATED DATA IMPORTER & PLOTTER
%
% Created 20 December 2018
%
%@author Milton Logothetis (milton.logothetis@southcoastscience.com)
%
% DESCRIPTION
% This script utilises AWS scs_analysis tools in order to import and plot
% aggregated historic data from a subscribed topic. 
% 
% EXAMPLE
% 1. Specify user-defined variables.
% 2. Specify parameters to be imported and plotted off subscribed topic:
% 
% fmt: {type.aggr."parameter_name"(i,1) = jsondecode(i)."JSON_field"}
% NOTE for max and min datafields a "_max" and "_min" string must be attached
% after the "parameter_name".
%
% e.g: type.aggr.PM10_max(i,1) = jsondecode(i).val.pm10.max;
% 
% 3. Specify which parameters to plot within Y_data(2D) or Z_data(3D) structure:
% 
% fmt (2D): {Y_data."decoded_parameter_name" = [];}
% fmt (3D): {Z_data = type.aggr."decoded_parameter_name";}
%
% 4. Choose plot type
% 
% SEE ALSO
% utilities.multiplot (multiple 2D plot)
% utilities.ddd_bar_plot (single 3D bar plot)
% utilities.ddd_surf_plot (single 3D weekly surface plot)

clearvars;

filename = mfilename('fullpath');
[~, var.filename, ~] = fileparts(filename);

% User-defined variables:
var.Topic_ID = 'south-coast-science-dev/production-test/loc/1/particulates';
var.start_time = '2019-01-14T00:00:00Z';
var.end_time = '2019-01-21T00:00:00Z';
var.avg_interval = '**:/15:00'; % Aggregated interval
var.sampling_rate_sec = 15*60; % Aggregated interval (seconds)

% Initialization:
jsondecode = utilities.decode_fcn(var); % Import parameters in JSON format. 
var.sample_length = length(jsondecode);
hist.last_update = [0;1]; % Indicate plot contains aggreggated data.

% Decode parameters from JSON format:
for i = 1:var.sample_length
    var.a = i;
    type.aggr.datetime{i,1} = jsondecode(i).rec;
    type.aggr.PM2p5_min(i,1) = jsondecode(i).val.pm2p5.min;
    type.aggr.PM2p5(i,1) = jsondecode(i).val.pm2p5.mid;
    type.aggr.PM2p5_max(i,1) = jsondecode(i).val.pm2p5.max;
    type.aggr.PM10_min(i,1) = jsondecode(i).val.pm10.min;
    type.aggr.PM10(i,1) = jsondecode(i).val.pm10.mid;
    type.aggr.PM10_max(i,1) = jsondecode(i).val.pm10.max;
    type.aggr.PM1_min(i,1) = jsondecode(i).val.pm1.min;
    type.aggr.PM1(i,1) = jsondecode(i).val.pm1.mid;
    type.aggr.PM1_max(i,1) = jsondecode(i).val.pm1.max;
% type.aggr.SO2_min(i,1) = jsondecode(i).val.SO2.cnc.min;
% type.aggr.SO2(i,1) = jsondecode(i).val.SO2.cnc.mid;
% type.aggr.SO2_max(i,1) = jsondecode(i).val.SO2.cnc.max;
%     type.aggr.NO2_min(i,1) = jsondecode(i).val.NO2.cnc.min;
%     type.aggr.NO2(i,1) = jsondecode(i).val.NO2.cnc.mid;
%     type.aggr.NO2_max(i,1) = jsondecode(i).val.NO2.cnc.max;
%     type.aggr.tmp_min(i,1) = jsondecode(i).val.sht.tmp.min;
%     type.aggr.tmp(i,1) = jsondecode(i).val.sht.tmp.mid;
%     type.aggr.tmp_max(i,1) = jsondecode(i).val.sht.tmp.max;
end


% Specify parameters for 2D plot:
% Y_data.PM10 = [];  Y_data.PM2p5 = []; Y_data.PM1= []; 
% aggr_fig = figure('Name', 'Aggregated Historic Data');
% utilities.multiplot(Y_data, type, hist, var, jsondecode, aggr_fig); 

% Specify a single parameter for 3D plot:
Z_data = type.aggr.PM10; 
ddd_handle = utilities.ddd_bar_plot(type,var, Z_data);
%ddd_handle = utilities.ddd_surf_plot(Z_data, type, var);