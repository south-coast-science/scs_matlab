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
        function [fig, chart] = multiplot(Y_data, type, hist, var, jsondecode, fig)
            
            pollutants = ["CO";"NO2";"H2S";"SO2";"PM1";"PM2p5";"PM10";"tmp";"hmd"];
            gases = pollutants(1:4,:);
            particulates = pollutants(5:7,:);
            which_pol = ismember(pollutants(:,:), fieldnames(Y_data));
            which_gas = ismember(gases(:,:),fieldnames(Y_data));
            which_pm = ismember(particulates(:,:),fieldnames(Y_data));
            idx = find(which_pol==1);
            gases_true = any(ismember(fieldnames(Y_data), gases));
            particulates_true = any(ismember(fieldnames(Y_data), particulates));
            hmd_true = any(ismember(fieldnames(Y_data), 'hmd'));
            tmp_true = any(ismember(fieldnames(Y_data), 'tmp'));
            num_pol = [sum(which_gas),sum(which_pm);hmd_true,tmp_true];
            type_pol = [gases_true, particulates_true; hmd_true, tmp_true];
            idxx = find(type_pol==1);
            type_count = sum(type_pol(:)==1);
            
            if hist.last_update == [1;0]
                categ = type.data;
            elseif hist.last_update == [0;1]
                categ = type.aggr;
            end
            X_data = cellfun(@thirdparty_fcns.datenum8601, cellstr(categ.datetime));
            
            if type_count==1
                for n=1:length(fieldnames(Y_data))
                    fig = utilities.pol_plot(X_data,type,hist,fig,pollutants,idx(n,:));
                    hold on
                    utilities.plotproperties(var)
                end
                hold off
            elseif type_count==2
                for n=1:num_pol(idxx(1))
                    chart.ax1 = subplot(2, 1, 1);
                    fig = utilities.pol_plot(X_data,type,hist,fig,pollutants,idx(n,:));
                    hold(chart.ax1, 'on')
                    utilities.plotproperties(var)
                end
                hold(chart.ax1, 'off')
                for m=n+1:n+num_pol(idxx(2))
                    chart.ax2 = subplot(2,1,2);
                    fig = utilities.pol_plot(X_data,type,hist,fig,pollutants,idx(m,:));
                    hold(chart.ax2, 'on')
                    utilities.subplotproperties(var)
                end
                hold(chart.ax2, 'off')
            elseif type_count==3
                for n=1:num_pol(idxx(1))
                    chart.ax1 = subplot(2,2,[1,2]);
                    fig = utilities.pol_plot(X_data,type,hist,fig,pollutants,idx(n,:));
                    hold(chart.ax1, 'on')
                    utilities.plotproperties(var)
                end
                hold(chart.ax1, 'off')
                for m=n+1:n+num_pol(idxx(2))
                    chart.ax2 = subplot(2,2,3);
                    fig = utilities.pol_plot(X_data,type,hist,fig,pollutants,idx(m,:));
                    hold(chart.ax2, 'on')
                    utilities.subplotproperties(var)
                end
                hold(chart.ax2, 'off')
                for k=m+1:m+num_pol(idxx(3))
                    chart.ax3 = subplot(2,2,4);
                    fig = utilities.pol_plot(X_data,type,hist,fig,pollutants,idx(k,:));
                    hold(chart.ax3, 'on')
                    utilities.subplotproperties(var)
                end
                hold(chart.ax3, 'off')
                if ismember(fieldnames(jsondecode), 'tag')
                    sensor_tag = 'device_tag:%s';
                    sensor_tag = sprintf(sensor_tag, jsondecode(1).tag);
                    uicontrol(fig, 'Style', 'text', 'String', sensor_tag, 'Position', [20, 20, 120, 15]);
                end
            end
        end
        
        function [fig, ax] = pol_plot(X_data,type,hist,fig,pollutants,idx)
            
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
            legnd = ["CO";"NO2";"H2S";"SO2";"PM1";"PM2.5";"PM10";"tmp";"hmd"];
            properties = table(Color,y_label,legnd);
            
            if hist.last_update == [1;0]
                figure(fig)
                plt = plot(X_data, type.data.(pollutants(idx,:)), 'Color', properties.Color(idx,:), 'LineWidth', 1);
                fig = ancestor(plt, 'figure');
                legend(gca, properties.legnd(idx,:))
                hold on
            elseif hist.last_update == [0;1]
                figure(fig)
                plot(X_data, type.aggr.(pollutants(idx,:)), 'Color', properties.Color(idx,:), 'LineWidth', 1);
                hold on
                plot(X_data, type.aggr.(pollutants(idx,:)),'_min', 'Color', properties.Color(idx,:), 'LineWidth', 1, 'LineStyle', ':');
                hold on
                plt = plot(X_data, type.aggr.(pollutants(idx,:)),'_max', 'Color', properties.Color(idx,:), 'LineWidth', 1, 'LineStyle', ':');
                fig = ancestor(plt, 'figure');
                legend(gca, properties.legnd(idx,:))
                hold on
            end
            ylabel(y_label(idx,:))
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
        
        % Weekly 3D plot for single pollutant
        function ddd_handle = ddd_surf_plot(Z_data, type, var)
            t = cellfun(@thirdparty_fcns.datenum8601, cellstr(type.aggr.datetime));
            
            integ = floor(t);
            x = t-integ;
            y = weekday(floor(t), 'long');
            z = Z_data;
            
            figure();
            tri = delaunay(x,y);
            ddd_handle = trisurf(tri, x, y, z);
            
            axis vis3d
            light('Position',[-50 -15 29]);
            lighting phong
            shading interp
            colorbar EastOutside
            
            xlim([0 0.999])
            xticks(0:1/12:24)
            datetick('x', 'HH:MM:SS', 'keepticks','keeplimits');
            xlabel({'Daytime'; '(HH:MM:SS)'},'FontWeight', 'bold')
            
            ylim([1 7])
            yticks(1:1:7)
            yticklabels({'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'})
            ylabel('Weekdays','FontWeight', 'bold')
            
            title(var.Topic_ID, 'Fontweight', 'bold')
            
            dcm_obj = datacursormode(gcf);
            dcm_obj.UpdateFcn = utilities.data_cursor; % Updates "Data-Cursor" callback to display datetime x-values.
        end
        
        % 3D bar chart
        function ddd_handle = ddd_bar_plot(type, var, Z_data)
            x_tick = 12;
            
            day_vals = 86400/var.sampling_rate_sec;
            
            t = cellfun(@thirdparty_fcns.datenum8601, cellstr(type.aggr.datetime));
            x_integ = floor(t);
            x = t-x_integ;
            
            x = x*day_vals;
            x(x==0)=day_vals;
            y = floor(t);
            difff = diff(y);
            day_num = sum(difff~=0);
            z = Z_data;
            Z = z(1:day_vals);
            
            xygrid = zeros(floor(max(x)),day_num);
            for i = 2:length(y)
                y(i)=y(i)-y(1)+1;
            end
            y(1)= 1; y(end)=y(end-1);
            for i = 1:length(x)
                xx = round(x(i)); yy = y(i); zz = z(i);
                if zz > xygrid(xx,yy)
                    xygrid(xx,yy) = zz;
                end
            end
            
            fig = figure();
            ddd_handle = bar3(xygrid, 1);
            
            ry = day_vals/x_tick;
            yticks(0:ry:12*ry)
            yticklabels({'00:00:00', '02:00:00', '04:00:00', '06:00:00', '08:00:00', '10:00:00',...
                '12:00:00','14:00:00','16:00:00','18:00:00','20:00:00','22:00:00', '24:00:00'}) % Set ytick interval labels.
            ylim([0 day_vals])
            ylabel({'Daytime'; '(HH:MM:SS)'},'FontWeight', 'bold')
            
            dts = datenum(var.start_time, 'yyyy-mm-ddTHH:MM:SSZ');
            dte = datenum(var.end_time, 'yyyy-mm-ddTHH:MM:SSZ');
            rx = 7;
            xticks(0:rx:day_num)
            xticklabels({datestr(dts:rx:dte, 'ddd DD mmm')})
            xlim([0 y(end)])
            xlabel('Days','FontWeight', 'bold')
            
            polname = fieldnames(type.aggr);
            ttle = '%s: %s - %s';
            title(sprintf(ttle, polname{2}, datestr(dts, 'ddd DD mmm yyyy'), datestr(dte, 'ddd DD mmm yyyy')));
            
            l1 = light('Position',[-50 -15 100]);
            l2 = light('Position',[50 15 100]);
            lighting phong
            shading interp
            colorbar EastOutside
            colourmap(type, ddd_handle, Z_data);
            
            sensor_tag = 'Topic_ID:%s';
            sensor_tag = sprintf(sensor_tag, var.Topic_ID);
            uicontrol(fig, 'Style', 'text', 'String', sensor_tag, 'Position', [20, 20, 300, 15]);
            
        end
        %---------------------------------------------------------------------
        % Plot properties
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
            dcm_obj.UpdateFcn = utilities.data_cursor; % Updates "Data-Cursor" callback to display datetime x-values.
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
            dcm_obj.UpdateFcn = utilities.data_cursor; % Updates "Data-Cursor" callback to display datetime x-values.
        end
        
        % Colormap for 3D plots
        function col_map = colourmap(type, ddd_handle, Z_data)
            
            % Change colourmap to vary with height
            for k = 1:length(ddd_handle)
                zdata = ddd_handle(k).ZData;
                ddd_handle(k).CData = zdata;
                ddd_handle(k).FaceColor = 'interp';
            end
            
            % RGB interval values as specified by EMSOL
            red = [206; 115; 56; 255; 255; 255; 255; 255; 205; 255];
            green = [229; 250; 209; 251; 201; 169; 105; 38; 28; 64];
            blue = [191; 65; 66; 0; 0; 0; 98; 0; 0; 255];
            rgb = table(red, green, blue);
            
            % CO 5min, 15min, 30min and 1hr threshold values
            CO_5min = {(0:33);(34:66);(67:99);(100:120);(121:142);(143:163);(164:184);(185:200);(201:215);216};
            CO_15min = {(0:23);(24:46);(47:69);(70:85);(86:100);(101:120);(121:135);(136:151);(152:167);168};
            CO_30min = {(0:18);(19:37);(38:54);(55:70);(71:85);(86:100);(101:115);(116:130);(131:145);146};
            CO_1hr = {(0:13);(14:26);(27:39);(40:50);(51:62);(63:73);(74:85);(86:97);(98:110);111};
            tables.CO = table(CO_5min, CO_15min, CO_30min, CO_1hr);
            
            % NO2 5min, 15min, 30min and 1hr threshold values
            NO2_5min = {(0:330);(331:660);(661:989);(990:1249);(1250:1509);(1510:1769);(1770:1929);(1930:2189);(2190:2300);2301};
            NO2_15min = {(0:200);(201:400);(401:599);(600:750);(751:900);(901:1050);(1051:1200);(1201:1330);(1331:1480);1481};
            NO2_30min = {(0:133);(134:266);(267:399);(400:533);(534:663);(664:793);(794:920);(921:1050);(1051:1186);1187};
            NO2_1hr = {(0:66);(67:133);(134:199);(200:267);(268:334);(335:400);(401:467);(468:534);(535:600);601};
            tables.NO2 = table(NO2_5min, NO2_15min, NO2_30min, NO2_1hr);
            
            % SO2 5min, 15min, 30min and 1hr threshold values
            SO2_5min = {(0:233);(234:466);(467:699);(700:854);(855:1009);(1010:1165);(1166:1320);(1321:1475);(1476:1630);1631};
            SO2_15min = {(0:150);(151:300);(301:449);(450:530);(531:610);(611:690);(691:770);(771:880);(881:980);981};
            SO2_30min = {(0:133);(134:268);(269:399);(400:488);(489:577);(578:666);(667:754);(755:842);(843:930);931};
            SO2_1hr = {(0:116);(117:232);(233:349);(350:430);(431:511);(512:592);(593:770);(771:949);(950:1064);1065};
            tables.SO2 = table(SO2_5min, SO2_15min, SO2_30min, SO2_1hr);
            
            % PM1 5min, 15min, 30min and 1hr threshold values
            PM1_5min = {(0:20);(21:40);(41:59);(60:70);(71:81);(82:92);(93:103);(104:114);(115:130);131};
            PM1_15min = {(0:16);(17:33);(34:47);(48:56);(57:65);(66:74);(75:80);(81:86);(87:93);94};
            PM1_30min = {(0:13);(14:27);(28:39);(40:55);(56:63);(64:71);(72:79);(80:87);(88:95);96};
            PM1_1hr = {(0:10);(11:21);(22:31);(32:40);(41:48);(49:56);(57:63);(64:68);(69:73);74};
            tables.PM1 = table(PM1_5min, PM1_15min, PM1_30min, PM1_1hr);
            
            % PM2.5 5min, 15min, 30min and 1hr threshold values
            PM2p5_5min = {(0:25);(25:50);(51:74);(75:90);(91:106);(107:122);(123:148);(149:164);(165:180);181};
            PM2p5_15min = {(0:20);(21:40);(41:59);(60:68);(69:76);(77:84);(85:92);(93:100);(101:110);111};
            PM2p5_30min = {(0:16);(17:32);(33:49);(50:70);(71:80);(81:90);(91:96);(97:102);(103:105);106};
            PM2p5_1hr = {(0:13);(14:27);(28:39);(40:50);(51:60);(61:69);(70:79);(80:88);(89:95);96};
            tables.PM2p5 = table(PM2p5_5min, PM2p5_15min, PM2p5_30min, PM2p5_1hr);
            
            % PM10 5min, 15min, 30min and 1hr threshold values
            PM10_5min = {(0:49);(50:100);(101:149);(150:174);(175:219);(220:239);(240:259);(260:279);(280:289);290};
            PM10_15min = {(0:40);(41:80);(81:119);(120:140);(141:160);(161:180);(181:202);(203:224);(225:246);247};
            PM10_30min = {(0:33);(34:67);(68:99);(100:116);(117:133);(134:150);(151:166);(167:182);(183:200);201};
            PM10_1hr = {(0:26);(27:52);(53:79);(80:100);(101:120);(121:135);(136:150);(151:172);(173:180);181};
            tables.PM10 = table(PM10_5min, PM10_15min, PM10_30min, PM10_1hr);
            
            % Assign pollutant colormap and interval to dynamic variables "table" and "varn"
            pol = fieldnames(type.aggr);
            pol = pol{end};
            T = tables.(pol);
            
            int = datenum(type.aggr.datetime, 'yyyy-mm-ddTHH:MM:SSZ');
            int = diff(int);
            int = round(int(1), 4);
            plot_int.pol_5min = round(5/(24*60),4);
            plot_int.pol_15min = round(15/(24*60),4);
            plot_int.pol_30min = round(30/(24*60),4);
            plot_int.pol_1hr = round(60/(24*60),4);
            
            fnames = fieldnames(plot_int);
            for i = 1:length(fnames)
                which_int{i,1} = isequal(plot_int.(fnames{i}), int);
            end
            idx = find([which_int{:}]==1);
            varn = T{:,idx};
            
            % Dynamic colormap algorythm
            for n=1:length(varn)
                n_intervals{n,1} = length(varn{n,1});
                if n-1==0
                    for i=1:varn{n}(end)
                        for c=1:3
                            col_map(i,c) = ((rgb{n+1,c}-rgb{n,c})/(n_intervals{n}+0.1))*i+rgb{n,c};
                        end
                    end
                else
                    y=0;
                    for i=varn{n}(1):varn{n}(end)
                        y=y+1;
                        for c=1:3
                            if n+1>length(varn)
                                col_map(i,c) = rgb{n,c};
                            else
                                col_map(i,c) = ((rgb{n+1,c}-rgb{n,c})/(n_intervals{n}+0.1))*y+rgb{n,c};
                            end
                        end
                    end
                end
            end
            col_map = col_map/255;
            colormap(col_map)
            caxis([0 i])
        end
        %---------------------------------------------------------------------
        
        
        % CSV writer
        % To write data to a csv file ensure that the data are all in the
        % same structure and specify "filename".

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
            h.PaperOrientation = 'landscape';
            h.PaperPosition = [1 1 28 19];
            print(gcf, '-dpdf', pdf_name);
        end
    end
end

%-------------------------------------------------------------------------------------------------