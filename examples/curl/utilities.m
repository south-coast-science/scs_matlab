classdef utilities
    % SCS-Matlab cURL Utilities
    %
    % Created 05 December 2018
    % 
    % @author: Milton Logothetis (milton.logothetis@southcoastscience.com)
    %
    % DESCRIPTION
    % This class contains all of the utility functions for importing, decoding 
    % and plotting the requested data from the scs-matlab curl scripts. It also 
    % contains tools developed for post-processing the imported or 
    % plotted data (csv, pdf write).
    
    methods(Static)
        
        % cURL importer/decoder functions
        %------------------------------------------------------------------
        
        % Get last recorded rec value
        function start_time = time_init(Topic_ID)
            last_rec = 'aws_byline.py -t %s';
            [~, init_out] = system(sprintf(last_rec, Topic_ID));
            init_out = jsondecode(init_out);
            start_time = init_out.last_write;
        end
        
        % cURL Call
        function json_decode = curl_decode(var)
            % DESCRIPTION
            % Utilise cURL to import data of a subscribed topic (var.Topic_ID)
            % from a specified URL(var.url). The function imports and
            % decodes all the data from the specified var.start_time until 
            % the current time.
            
            var.url = sprintf(var.url, var.Topic_ID, var.start_time);
            curl_cmd = 'curl -s "%s"';
            [~,curl_out] = system(sprintf(curl_cmd, var.url));
            json_decode = jsondecode(curl_out);
        end
        function json_decode = curl_decode_next(var, json_decode)
            var.url = json_decode.next;
            curl_cmd = 'curl -s "%s"';
            [~,curl_out] = system(sprintf(curl_cmd, var.url));
            json_decode = jsondecode(curl_out);
        end
               
        % Plot-functions
        % -----------------------------------------------------------------
        
        % Multi-plot
        function [fig,properties,mplt] = multiplot(Y_data, type, hist, var, jsondecode, fig)
            % DESCRIPTION
            % This function processes the provided inputs to distinguish
            % between 4 different categories:
            % - Gases: CO, NO2, H2S, SO2.
            % - Particulates: PM1, PM2.5, PM10.
            % - Temperature: tmp.
            % - Humidity: hmd.
            %
            % Once it determines how many different types of pollutants
            % have been passed in to it as well as how many pollutants of 
            % the same type exist, it chooses how to plot them. Same pollutant
            % types are plotted in the same subplot and different types are 
            % attached in different subplots on the same figure. While this
            % function decides how to categorize the inputs, the plotting
            % is executed by calling utilities.pol_plot.
            %
            % SYNOPSIS
            % Inputs:
            % - Y_data: structure with empty fields indicating selected
            %   pollutant name.
            % - type: data structure containing either raw(type.data) or aggregated
            %   (type.aggr) data.
            % - hist: indicates what type of data was last plotted:
            %   hist.last_update=[1;0] -> raw data, hist.last_update=[0;1] -> aggr data.
            % - var: structure containing initialization information.
            % - jsondecode: either structure or cell array of structures
            %   containing the decoded format of imported data. 
            % - fig: figure handle to plot.
            % Outputs:
            % - fig: updated figure handle containing new axis.
            % - properties: plot properties structure containing legend
            %   entries.
            % - mplt: multiplot pre-processing outputs for cross-function linking.
            %   
            % SEE ALSO 
            % utilities: pol_plot, plotproperties
            
            mplt.pollutants = ["CO";"NO2";"H2S";"SO2";"PM1";"PM2p5";"PM10";"tmp";"hmd"];
            gases = mplt.pollutants(1:4,:);
            particulates = mplt.pollutants(5:7,:);
            mplt.which_pol = ismember(mplt.pollutants(:,:), fieldnames(Y_data));
            which_gas = ismember(gases(:,:),fieldnames(Y_data));
            which_pm = ismember(particulates(:,:),fieldnames(Y_data));
            idx = find(mplt.which_pol==1);
            gases_true = any(ismember(fieldnames(Y_data), gases));
            particulates_true = any(ismember(fieldnames(Y_data), particulates));
            hmd_true = any(ismember(fieldnames(Y_data), 'hmd'));
            tmp_true = any(ismember(fieldnames(Y_data), 'tmp'));
            mplt.num_pol = [sum(which_gas),sum(which_pm);hmd_true,tmp_true];
            mplt.type_pol = [gases_true, particulates_true; hmd_true, tmp_true];
            mplt.idxx = find(mplt.type_pol==1);
            type_count = sum(mplt.type_pol(:)==1);
            properties = [];
            
            if hist.last_update(1) == 1 && hist.last_update(2)==0
                categ = type.data;
            elseif hist.last_update(1) == 0 && hist.last_update(2)==1
                categ = type.aggr;
            end
            X_data = cellfun(@thirdparty_fcns.datenum8601, cellstr(categ.datetime));
            
            if type_count==1
                for n=1:length(fieldnames(Y_data))
                    [fig, mplt, properties] = utilities.pol_plot(X_data,type,hist,fig,mplt,properties,idx(n),mplt.idxx,n);
                    hold on
                end
                utilities.plotproperties(var, properties, mplt, mplt.idxx, 1)
                hold off
            elseif type_count==2
                for n=1:mplt.num_pol(mplt.idxx(1))
                    chart.ax1 = subplot(2,1,1);
                    [fig, mplt, properties] = utilities.pol_plot(X_data,type,hist,fig,mplt,properties,idx(n),mplt.idxx(1),n);
                    hold(chart.ax1, 'on')
                end
                utilities.plotproperties(var, properties, mplt, mplt.idxx(1), 1)
                hold(chart.ax1, 'off')
                for m=n+1:n+mplt.num_pol(mplt.idxx(2))
                    chart.ax2 = subplot(2,1,2);
                    [fig, mplt, properties] = utilities.pol_plot(X_data,type,hist,fig,mplt,properties,idx(m),mplt.idxx(2),m);
                    hold(chart.ax2, 'on')
                end
                utilities.plotproperties(var, properties, mplt, mplt.idxx(2), 0)
                hold(chart.ax2, 'off')
            elseif type_count==3
                for n=1:mplt.num_pol(mplt.idxx(1))
                    chart.ax1 = subplot(2,2,[1,2]);
                    [fig, mplt, properties] = utilities.pol_plot(X_data,type,hist,fig,mplt,properties,idx(n),mplt.idxx(1),n);
                    hold(chart.ax1, 'on')
                end
                utilities.plotproperties(var, properties, mplt, mplt.idxx(1), 1)
                hold(chart.ax1, 'off')
                for m=n+1:n+mplt.num_pol(mplt.idxx(2))
                    chart.ax2 = subplot(2,2,3);
                    [fig, mplt, properties] = utilities.pol_plot(X_data,type,hist,fig,mplt,properties,idx(m),mplt.idxx(2),m);
                    hold(chart.ax2, 'on')
                end
                utilities.plotproperties(var, properties, mplt, mplt.idxx(2), 0)
                hold(chart.ax2, 'off')
                for k=m+1:m+mplt.num_pol(mplt.idxx(3))
                    chart.ax3 = subplot(2,2,4);
                    [fig, mplt, properties] = utilities.pol_plot(X_data,type,hist,fig,mplt,properties,idx(k),mplt.idxx(3),k);
                    hold(chart.ax3, 'on')
                end
                utilities.plotproperties(var, properties, mplt, mplt.idxx(3), 0)
                hold(chart.ax3, 'off')
            end
            
            % if sensor-tag exists attach it on bottom left corner:
            if isa(jsondecode, 'cell')
                decode_field = jsondecode{1};
            elseif isa(jsondecode, 'struct')
                decode_field = jsondecode(1);
            end
            if ismember(fieldnames(decode_field), 'tag')
                sensor_tag = 'device_tag:%s';
                sensor_tag = sprintf(sensor_tag, decode_field.tag);
                uicontrol(fig, 'Style', 'text', 'String', sensor_tag, 'Position', [20, 20, 120, 15]);
            end
        end

        % Pollutant plotter 
        function [fig, mplt, properties] = pol_plot(X_data,type,hist,fig,mplt,properties,idx,idxx,n)
            % DESCRIPTION
            % 2D plotter function (plot.m) that also assigns colors and 
            % labels to pollutants. If raw data is passed in the function
            % expects a single variable whereas if aggregated data are
            % passed in, 3 variables are plotted (aggregated mid data,
            % min and max).
            % 
            % SYNOPSIS
            % Inputs:
            % - X_data: datenum format of datetime data. 
            % - idx: indicates position of selected pollutants in
            %   "pollutants" array (multiplot).
            % - idxx: indicates position of category of selected pollutant
            %   in "type_pol" array (multiplot).
            % - n: index for current iteration of "num_pol" (how many 
            %   same-category pollutants are being plotted).
            %
            % SEE ALSO: 
            % utilities: multiplot
            
            pollutants = mplt.pollutants;
            
            COColor = [0.2549 0.4235 0.2431];
            NO2Color = [0.4941 0.2235 0.1176];
            H2SColor = [0.6431 0.3059 0.1725];
            SO2Color = [0.4353 0.1412 0.0863];
            PM1Color = [0.5333 0.5333 0.5333];
            PM2p5Color = [0.3333 0.3333 0.3333];
            PM10Color = [0 0 0];
            tmpColor = [0.6510 0.1686 0.0902];
            hmdColor = [0.1176 0.2980 0.4863];
            
            Color = [COColor;NO2Color;H2SColor;SO2Color;PM1Color;...
                PM2p5Color;PM10Color;tmpColor;hmdColor];
            y_label = {'CO (ppb)';'NO2 (ppb)';'H2S (ppb)';'SO2 (ppb)';'PM1 (\mug/m^3)';...
                'PM2.5 (\mug/m^3)';'PM10 (\mug/m^3)';'Temperature(\circC)';'Relative Humidity (%)'};
            y_label_grp = {'Gases (ppb)';'Relative Humidity (%)';'Particulates (\mum/m^3)';'Temperature(\circC)'};
            legnd = {"CO";"NO2";"H2S";"SO2";"PM1";"PM2.5";"PM10";"tmp";"hmd"};
            d_properties = table(y_label,legnd, Color);
            
            if hist.last_update(1)==1 && hist.last_update(2)==0
                figure(fig)
                mplt.plt(n) = plot(X_data, type.data.(pollutants(idx)), 'Color', d_properties.Color(idx,:), 'LineWidth', 1);
                fig = ancestor(mplt.plt(n), 'figure');
                hold on
            elseif hist.last_update(1)==0 && hist.last_update(2)==1
                figure(fig)
                plot(X_data, type.aggr.(strcat(pollutants(idx), '_min')), 'Color', d_properties.Color(idx,:), 'LineWidth', 1, 'LineStyle', ':');
                hold on
                plot(X_data, type.aggr.(strcat(pollutants(idx), '_max')), 'Color', d_properties.Color(idx,:), 'LineWidth', 1, 'LineStyle', ':');
                hold on
                mplt.plt(n) = plot(X_data, type.aggr.(pollutants(idx)), 'Color', d_properties.Color(idx,:), 'LineWidth', 1);
                fig = ancestor(mplt.plt(n), 'figure');
            end
            if mplt.num_pol(idxx)>1
                ylabel(y_label_grp(idxx))
                properties.lgnd_names(n,1) = pollutants(idx);
            else
                ylabel(y_label(idx))
                legend(gca, legnd(idx))
            end
            hold off
        end
               
        % Plot properties
        function plotproperties(var, properties, mplt, idxx, ttl)
            % DESCRIPTION
            % Assigns properties to 2D plots.
            % 
            % SYNOPSIS
            % Inputs:
            % -ttl: input 1 to attach title to plot, 0 otherwise.
            % 
            % SEE ALSO
            % utilities.multiplot
            
            if strcmp(var.filename, 'live_data')
                datetick('x', 'dd-mmm-yy HH:MM:SS', 'keeplimits');
                grid on
                grid minor
            else
                datetick('x', 'dd-mmm-yy HH:MM', 'keepticks', 'keeplimits');
                grid on
                grid minor
            end
            if mplt.num_pol(idxx)>1
                legend(mplt.plt(:), properties.lgnd_names{:})
                properties.lgnd_names =[];
            end
            if ttl==1
                title(var.Topic_ID)
            end
            xlabel({'Date-Time'; '(dd-mmm-yy HH:MM:SS)'})
            dcm_obj = datacursormode(gcf);
            dcm_obj.UpdateFcn = @utilities.data_cursor; % Updates "Data-Cursor" callback to display datetime x-values.
        end
       
        % Function to display datetime values on "Data-Cursor" selection
        function output_txt = data_cursor(~,dcm_obj)
            pos = get(dcm_obj,'Position');
            output_txt = {['X: ', datestr(pos(1))],['Y: ',num2str(pos(2),4)]};
            if length(pos) > 2
                output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
            end
        end
        %------------------------------------------------------------------
        % CSV writer
        % To write data to a csv file ensure that the data is in a "data"
        % structure and specify "filename".
        function csv_write(filename, data)
            fnames = fieldnames(data);
            T = table;
            for i = 1:length(fnames)
                x_T = table(num2cell(getfield(data, fnames{i})));
                x_T.Properties.VariableNames = {fnames{i}};
                T = [T, x_T];
            end
            writetable(T, filename)
        end
        
        % Figure to PDF writer
        % Specify "pdf_name" before calling function.
        function figuretopdf(pdf_name)
            h=gcf;
            set(h,'PaperOrientation','landscape');
            set(h,'PaperPosition', [1 1 28 19]);
            print(gcf, '-dpdf', pdf_name);
        end
    end
end