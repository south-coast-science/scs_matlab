classdef utilities
    methods(Static)
        % Get last recorded datetime
        function start_time = time_init(var)
            last_rec = 'aws_byline.py -t %s';
            [~, init_out] = system(sprintf(last_rec, var.Topic_ID));
            init_out = jsondecode(init_out);
            start_time = init_out.rec;
        end
        
        % Historic/Aggregated data importer/decoder
        function json_decode = decode_fcn(var)
            var_names = evalin('caller','fieldnames(var)');
            exist_end = any(strcmp(var_names,'end_time'));
            if contains(var.filename, 'sample_aggr')==1 && exist_end==1
                aggr_cmd = 'aws_topic_history.py %s -s %s -e %s | sample_aggregate.py -m -c %s val | node.py -a';
                [~, aggr_hist_out] = system(sprintf(aggr_cmd, var.Topic_ID, var.start_time, var.end_time, var.avg_interval));
                json_decode = jsondecode(aggr_hist_out);
            elseif contains(var.filename, 'sample_aggr')==1 && exist_end==0
                aggr_cmd = 'aws_topic_history.py %s -s %s| sample_aggregate.py -m -c %s val | node.py -a';
                [~, aggr_live_out] = system(sprintf(aggr_cmd, var.Topic_ID, var.start_time, var.avg_interval));
                json_decode = jsondecode(aggr_live_out);
            elseif exist_end==0
                live_cmd = 'aws_topic_history.py %s -s %s | node.py -a';
                [~, live_out] = system(sprintf(live_cmd, var.Topic_ID, var.start_time));
                json_decode = jsondecode(live_out);
            else
                hist_cmd = 'aws_topic_history.py %s -s %s -e %s | node.py -a';
                [~, hist_out] = system(sprintf(hist_cmd, var.Topic_ID, var.start_time, var.end_time));
                json_decode = jsondecode(hist_out);
            end
        end
        
        % Sample aggregate live merged importer-decoders
        function json_decode = decode_live_merge(var)
            live_cmd = 'aws_topic_history.py %s -s %s | node.py -a';
            [~, live_out] = system(sprintf(live_cmd, var.Topic_ID, var.start_time{var.j}));
            json_decode = jsondecode(live_out);
        end
        function json_decode = aggr_decode_live_merge(var)
            aggr_cmd = 'aws_topic_history.py %s -s %s | sample_aggregate.py -m -c %s val | node.py -a';
            if var.a>1
                [~, aggr_decode{var.b}] = system(sprintf(aggr_cmd, var.Topic_ID, var.start_time_aggr{var.a}, var.avg_interval));
            else
                [~, aggr_decode{var.b}] = system(sprintf(aggr_cmd, var.Topic_ID, var.start_time{1}, var.avg_interval));
            end
            json_decode = jsondecode(aggr_decode{var.b});
        end
        %-----------------------------------------------------------------------------------------
        
        
        % Plot-functions
        % 2D hist_data plot
        function [X_data, chart] = twoD_hist_plot(var, Y_data, data, aggr)
            if exist('data', 'var')==1
                type = data;
            elseif exist('aggr', 'var')==1
                type = aggr;
            end
            X_data = cellfun(@thirdparty_fcns.datenum8601, cellstr(type.datetime));
            if var.i==1 || var.i==var.sample_length
                figure('Name', 'Historic Data');
            end
            chart = plot(X_data, Y_data);
            utilities.plotproperties(var);
        end
        
        % 2D live_data plot
        function [X_data, live_chart] = twoD_live_plot(var, Y_data, data)
            X_data = cellfun(@thirdparty_fcns.datenum8601, cellstr(data.datetime));
            if var.i==1
                figure('Name', 'Live Data');
            end
            live_chart = plot(X_data, Y_data);
            hold on
            utilities.plotproperties(var);
            hold off
        end
        
        % 2D live_aggr_data plot
        function [X_data, aggr_chart] = twoD_live_aggr_plot(var, Y_data_aggr, aggr)
            X_data = cellfun(@thirdparty_fcns.datenum8601, cellstr(aggr.datetime));
            if var.a==1
                figure('Name', 'Live Aggregated Data');
            end
            aggr_chart = plot(X_data, Y_data_aggr);
            hold on
            utilities.plotproperties(var);
            hold off
        end
        
        % Function to display datetime values on "Data-Cursor" selection
        function output_txt = data_cursor(~,dcm_obj)
            pos = get(dcm_obj,'Position');
            output_txt = {['X: ', datestr(pos(1))],['Y: ',num2str(pos(2),4)]};
            if length(pos) > 2
                output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
            end
        end
        
        % 2D plot with pollutant colors
        function live_fig = pollutantcolors(Y_data, data, var, live_fig)
            NO2Color = [0.4941 0.2235 0.1176];
            COColor = [0.2549 0.4235 0.2431];
            SO2Color = [0.4353 0.1412 0.0863];
            H2SColor = [0.6431 0.3059 0.1725];
            PM1Color =[0.5333 0.5333 0.5333];
            PM2p5Color = [0.3333 0.3333 0.3333];
            PM10Color = [0 0 0];
            hmdColor = [0.1176 0.2980 0.4863];
            tmpColor =[0.6510 0.1686 0.0902];
            
            X_data = cellfun(@thirdparty_fcns.datenum8601, cellstr(data.datetime));
            
            if isfield(Y_data, 'NO2')==1
                figure(live_fig)
                plt = plot(X_data, data.NO2, 'Color', NO2Color, 'LineWidth', 1);
                live_fig = ancestor(plt, 'figure');
                hold on
            end
            if isfield(Y_data, 'CO')==1
                figure(live_fig)
                plt = plot(X_data, data.CO, 'Color', COColor, 'LineWidth', 1);
                live_fig = ancestor(plt, 'figure');
                hold on
            end
            if isfield(Y_data, 'SO2')==1
                figure(live_fig)
                plt = plot(X_data, data.SO2, 'Color', SO2Color, 'LineWidth', 1);
                live_fig = ancestor(plt, 'figure');
                hold on
            end
            if isfield(Y_data, 'H2S')==1
                figure(live_fig)
                plt = plot(X_data, data.H2S, 'Color', H2SColor, 'LineWidth', 1);
                live_fig = ancestor(plt, 'figure');
                hold on
            end
            if isfield(Y_data, 'PM1')==1
                figure(live_fig)
                plt = plot(X_data, data.PM1, 'Color', PM1Color, 'LineWidth', 1);
                live_fig = ancestor(plt, 'figure');
                hold on
            end
            if isfield(Y_data, 'PM2p5')==1
                figure(live_fig)
                plt = plot(X_data, data.PM2_5, 'Color', PM2p5Color, 'LineWidth', 1);
                live_fig = ancestor(plt, 'figure');
                hold on
            end
            if isfield(Y_data, 'PM10')==1
                figure(live_fig)
                plt = plot(X_data, data.PM10, 'Color', PM10Color, 'LineWidth', 1);
                live_fig = ancestor(plt, 'figure');
                hold on
            end
            if isfield(Y_data, 'hmd')==1
                figure(live_fig)
                plt = plot(X_data, data.hmd, 'Color', hmdColor, 'LineWidth', 1);
                live_fig = ancestor(plt, 'figure');
                hold on
            end
            if isfield(Y_data, 'tmp')==1
                figure(live_fig)
                plt = plot(X_data, data.tmp, 'Color', tmpColor, 'LineWidth', 1);
                live_fig = ancestor(plt, 'figure');
                hold on
            end
            utilities.plotproperties(var)
            hold off
        end
        
        function aggr_fig = aggrpollutantcolors(Y_data_aggr, aggr, var, aggr_fig)
            NO2Color = [0.4941 0.2235 0.1176];
            COColor = [0.2549 0.4235 0.2431];
            SO2Color = [0.4353 0.1412 0.0863];
            H2SColor = [0.6431 0.3059 0.1725];
            PM1Color =[0.5333 0.5333 0.5333];
            PM2p5Color = [0.3333 0.3333 0.3333];
            PM10Color = [0 0 0];
            hmdColor = [0.1176 0.2980 0.4863];
            tmpColor =[0.6510 0.1686 0.0902];
            
            X_data = cellfun(@thirdparty_fcns.datenum8601, cellstr(aggr.datetime));

            if isfield(Y_data_aggr, 'NO2')==1
                figure(aggr_fig)
                plot(X_data, aggr.NO2, 'Color', NO2Color, 'LineWidth', 1);
                hold on 
                plot(X_data, aggr.NO2_min, 'Color', NO2Color, 'LineWidth', 1, 'LineStyle', ':');
                hold on
                plt = plot(X_data, aggr.NO2_max, 'Color', NO2Color, 'LineWidth', 1, 'LineStyle', ':');
                aggr_fig = ancestor(plt, 'figure');
                hold on 
            end
            if isfield(Y_data_aggr, 'CO')==1
                figure(aggr_fig)
                plot(X_data, aggr.CO, 'Color', COColor, 'LineWidth', 1);
                hold on
                plot(X_data, aggr.CO_min, 'Color', COColor, 'LineWidth', 1, 'LineStyle', ':')
                hold on
                plt = plot(X_data, aggr.CO_max, 'Color', COColor, 'LineWidth', 1, 'LineStyle', ':');
                aggr_fig = ancestor(plt, 'figure');
                hold on 
            end
            if isfield(Y_data_aggr, 'SO2')==1
                figure(aggr_fig)
                plot(X_data, aggr.SO2, 'Color', SO2Color, 'LineWidth', 1);
                hold on
                plot(X_data, aggr.SO2_min, 'Color', SO2Color, 'LineWidth', 1, 'LineStyle', ':')
                hold on
                plt = plot(X_data, aggr.SO2_max, 'Color', SO2Color, 'LineWidth', 1, 'LineStyle', ':');
                aggr_fig = ancestor(plt, 'figure');
                hold on 
            end
            if isfield(Y_data_aggr, 'H2S')==1
                figure(aggr_fig)
                plot(X_data, aggr.H2S, 'Color', H2SColor, 'LineWidth', 1);
                hold on
                plot(X_data, aggr.H2S_min, 'Color', H2SColor, 'LineWidth', 1, 'LineStyle', ':')
                hold on
                plt = plot(X_data, aggr.H2S_max, 'Color', H2SColor, 'LineWidth', 1, 'LineStyle', ':');
                aggr_fig = ancestor(plt, 'figure');
                hold on 
            end
            if isfield(Y_data_aggr, 'PM1')==1
                figure(aggr_fig)
                plot(X_data, aggr.pm1, 'Color', PM1Color, 'LineWidth', 1);
                hold on
                plot(X_data, aggr.PM1_min, 'Color', PM1Color, 'LineWidth', 1, 'LineStyle', ':')
                hold on
                plt = plot(X_data, aggr.PM1_max, 'Color', PM1Color, 'LineWidth', 1, 'LineStyle', ':');
                aggr_fig = ancestor(plt, 'figure');
                hold on 
            end
            if isfield(Y_data_aggr, 'PM2p5')==1
                figure(aggr_fig)
                plot(X_data, aggr.PM2p5, 'Color', PM2p5Color, 'LineWidth', 1);
                hold on
                plot(X_data, aggr.PM2p5_min, 'Color', PM2p5Color, 'LineWidth', 1, 'LineStyle', ':')
                hold on
                plt = plot(X_data, aggr.PM2p5_max, 'Color', PM2p5Color, 'LineWidth', 1, 'LineStyle', ':');
                aggr_fig = ancestor(plt, 'figure');
                hold on 
            end
            if isfield(Y_data_aggr, 'PM10')==1
                figure(aggr_fig)
                plot(X_data, aggr.PM10, 'Color', PM10Color, 'LineWidth', 1);
                hold on
                plot(X_data, aggr.PM10_min, 'Color', PM10Color, 'LineWidth', 1, 'LineStyle', ':')
                hold on
                plt = plot(X_data, aggr.PM10_max, 'Color', PM10Color, 'LineWidth', 1, 'LineStyle', ':');
                aggr_fig = ancestor(plt, 'figure');
                hold on 
            end
            if isfield(Y_data_aggr, 'hmd')==1
                figure(aggr_fig)
                plot(X_data, aggr.hmd, 'Color', hmdColor, 'LineWidth', 1);
                hold on
                plot(X_data, aggr.hmd_min, 'Color', hmdColor, 'LineWidth', 1, 'LineStyle', ':')
                hold on
                plt = plot(X_data, aggr.hmd_max, 'Color', hmdColor, 'LineWidth', 1, 'LineStyle', ':');
                aggr_fig = ancestor(plt, 'figure');
                hold on 
                
            end
            if isfield(Y_data_aggr, 'tmp')==1
                figure(aggr_fig)
                plot(X_data, aggr.tmp, 'Color', tmpColor, 'LineWidth', 1);
                hold on
                plot(X_data, aggr.tmp_min, 'Color', tmpColor, 'LineWidth', 1, 'LineStyle', ':')
                hold on
                plt = plot(X_data, aggr.tmp_max, 'Color', tmpColor, 'LineWidth', 1, 'LineStyle', ':');
                aggr_fig = ancestor(plt, 'figure');
                hold on 
            end
            utilities.plotproperties(var)
            hold off
        end
        %---------------------------------------------------------------------
        function plotproperties(var)
            if strcmp(var.filename, 'live_data')
                datetick('x', 'dd-mmm-yy HH:MM:SS', 'keeplimits');
                if var.i==1
                    grid on
                    grid minor
                end
            else
                datetick('x', 'dd-mmm-yy HH:MM', 'keepticks', 'keeplimits');
                grid on
                grid minor
            end
            title(var.Topic_ID)
            xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
            dcm_obj = datacursormode(gcf);
            set(dcm_obj, 'UpdateFcn',@utilities.data_cursor); % Updates "Data-Cursor" callback to display datetime x-values.
        end
        
        function subplotproperties(var)
            if strcmp(var.filename, 'live_data')
                datetick('x', 'dd-mmm-yy HH:MM:SS', 'keeplimits');
                if var.i==1
                    grid on
                    grid minor
                end
            else
                datetick('x', 'dd-mmm-yy HH:MM', 'keepticks', 'keeplimits');
                grid on
                grid minor
            end
            xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
            dcm_obj = datacursormode(gcf);
            set(dcm_obj, 'UpdateFcn',@utilities.data_cursor); % Updates "Data-Cursor" callback to display datetime x-values.
        end
        %---------------------------------------------------------------------
        
        
        % CSV writer
        % To write data to a csv file ensure that the data is in a "data"
        % or "aggr" structure and specify "filename".
        function csv_write(filename, type)
            fnames = fieldnames(type);
            T = table;
            for i = 1:length(fnames)
                x_T = table(num2cell(getfield(type, fnames{i})));
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
%-------------------------------------------------------------------------------------------------