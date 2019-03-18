classdef humidity_fcns
    methods(Static)
        
        % Absolute humidity calculator
        function [aH,RH] = abs_humidity(type)
            
            Rw = 461.52; % Specific gas constant for water vapour (J/kg*K)
            Pc = 22.064*10^6; % Critical Pressure (Pa)
            Tc = 647.096; % Critical Temperature (K)
            a1 = -7.85951783;
            a2 = 1.84408259;
            a3 = -11.7866497;
            a4 = 22.6807411;
            a5 = -15.9618719;
            a6 = 1.80122502;
            
            for n=1:length(type.data.tmp)
                
                T(n,1) = type.data.tmp(n,1); % Ambient Temperature(degrees C)
                RH(n,1) = type.data.hmd(n,1); % Relative Humidity (%)
                th(n,1) = 1-((T(n)+273.15)/Tc);
                
                Pws(n,1) = Pc*exp((Tc/(T(n)+273.15))*(a1*th(n)+a2*th(n)^1.5+a3*th(n)^3+a4*th(n)^3.5+a5*th(n)^4+a6*th(n)^7.5)); % (kPa)
                Pw(n,1) = RH(n)*Pws(n)/100; % (kPa)
                aH(n,1) = Pw(n)*1000/(Rw*(T(n)+273.15)); % (g/m^3)
                
            end
            % W = 621.97*Pw*(P-Pw); % Mixing Ratio (g/kg)
            % h = (T+273.15)*(1.01+0.00189*W)+2.5*W; % enthalpy (kJ/kg)
        end
        
        % Ambient pressure depending on height calculator (below h=11km)
        function P = P_atm(T,h)
            
            p0 = 101325; % Pressure at sea level (Pa)
            L = 0.0065; % Standard temperature lapse rate (K/m)
            
            g = 9.80665; % Acceleration due to gravity (m/s2)
            M = 0.0289644; % Molar mass of earth's air (kg/mol)
            R = 8.3144598; % Gas constant (J/(mol*K))
            
            A = (g*M)/(R*L);
            P = p0*(1-(L*h/(T+L*h+273.15)))^A; % Atmospheric Pressure (Pa)
        end
        
        % Ambient pressure at sea level (below h=11km)
        function p0 = P_sea(P,h,T)
            L = 0.0065; % Standard temperature lapse rate (K/m)
            
            g = 9.80665; % Acceleration due to gravity (m/s2)
            M = 0.0289644; % Molar mass of earth's air (kg/mol)
            R = 8.3144598; % Gas constant (J/(mol*K))
            
            A = (g*M)/(R*L);
            p0 = P/((1-(L*h/(T+L*h+273.15)))^A); % Sea-level pressure (Pa)
        end
        
        % Create csv spreadsheet
        function create_spreadsheet(type, filename)
            [aH,~] = humidity_fcns.abs_humidity(type);
            data.datetime = type.data.datetime;
            data.NO2 = type.data.NO2;
            data.NO2_weC = type.data.NO2_wec;
            data.NO = type.data.NO;
            data.NO_weC = type.data.NO_wec;
            data.CO = type.data.CO;
            data.CO_weC = type.data.CO_wec;
            data.tmp = type.data.tmp;
            data.hmd = type.data.hmd;
            data.aH = aH;
            utilities.csv_write(filename,data);
        end
        
        % Linear correlation
        function R_squared = R_squared(data1, data2)
            y_bar = mean(data2); % mean of observed data
            SStot = sum((data2-y_bar).^2); % total sum of squares
            SSreg = sum((data1-y_bar).^2); % regression sum of squares
            SSres = sum(data2-data1).^2; % sum of squares of residuals
            R_squared = 1-(SSres/SStot); % coefficient of determination
        end
        
        % RGB_assign
        function out = rgb_assign(data, doc_len, rgb)
            out = zeros(doc_len,3);
            
            for i = 1:doc_len
                d = data.rec(i,1) - data.rec(1,1);
                frac = d/(data.rec(end,1)-data.rec(1,1));
                if (0<=frac)&&(frac<0.1)
                    out(i,1) = rgb{1,1};
                    out(i,2) = rgb{1,2};
                    out(i,3) = rgb{1,3};
                elseif (0.1<=frac)&&(frac<0.2)
                    out(i,1) = rgb{2,1};
                    out(i,2) = rgb{2,2};
                    out(i,3) = rgb{2,3};
                elseif (0.2<=frac)&&(frac<0.3)
                    out(i,1) = rgb{3,1};
                    out(i,2) = rgb{3,2};
                    out(i,3) = rgb{3,3};
                elseif (0.3<=frac)&&(frac<0.4)
                    out(i,1) = rgb{4,1};
                    out(i,2) = rgb{4,2};
                    out(i,3) = rgb{4,3};
                elseif (0.4<=frac)&&(frac<0.5)
                    out(i,1) = rgb{5,1};
                    out(i,2) = rgb{5,2};
                    out(i,3) = rgb{5,3};
                elseif (0.5<=frac)&&(frac<0.5)
                    out(i,1) = rgb{6,1};
                    out(i,2) = rgb{6,2};
                    out(i,3) = rgb{6,3};
                elseif (0.6<=frac)&&(frac<0.7)
                    out(i,1) = rgb{7,1};
                    out(i,2) = rgb{7,2};
                    out(i,3) = rgb{7,3};
                elseif (0.7<=frac)&&(frac<0.8)
                    out(i,1) = rgb{8,1};
                    out(i,2) = rgb{8,2};
                    out(i,3) = rgb{8,3};
                elseif (0.8<=frac)&&(frac<0.9)
                    out(i,1) = rgb{9,1};
                    out(i,2) = rgb{9,2};
                    out(i,3) = rgb{9,3};
                elseif frac>=0.9
                    out(i,1) = rgb{10,1};
                    out(i,2) = rgb{10,2};
                    out(i,3) = rgb{10,3};
                end
            end
        end
        
        % Read regression csv dataset
        function [data, rgb, joined_filename] = reg_read_init(joined_filename, doc_len, N_cols, rep_col, ref_col, aH_col)
            
            data.aH = zeros(doc_len,4);
            loc = table([1;rep_col-1],[1;ref_col-1],[1;aH_col-1], 'VariableNames', {'cnc_rep';'cnc_ref';'aH'});
            data.rep_weC_sens = csvread(joined_filename, loc.cnc_rep(1), loc.cnc_rep(2), [loc.cnc_rep(1) loc.cnc_rep(2) doc_len loc.cnc_rep(2)]);
            data.ref_cnc = csvread(joined_filename, loc.cnc_ref(1), loc.cnc_ref(2), [loc.cnc_ref(1) loc.cnc_ref(2) doc_len loc.cnc_ref(2)]);
            data.aH(:,1) = csvread(joined_filename, loc.aH(1), loc.aH(2), [loc.aH(1) loc.aH(2) doc_len loc.aH(2)]);
            data.rec = textscan(fopen(joined_filename), ['%q' repmat('%*f', [1,N_cols-1])], 'Delimiter', ',', 'HeaderLines', 1);
            data.rec = data.rec{1,1}(:);
            data.rec(cellfun('isempty', data.rec)) = []; % remove any empty cells 
            data.rec = datenum(data.rec, 'yyyy-mm-ddTHH:MM:SSZ');
            data.ref_cnc(data.ref_cnc <= 0.1) = NaN; % set ref_rows less than this value to NaN
            
            
            joined_filename = strrep(joined_filename, '_', ' ');
            
            red = [206; 115; 56; 255; 255; 255; 255; 255; 205; 255];
            green = [229; 250; 209; 251; 201; 169; 105; 38; 28; 64];
            blue = [191; 65; 66; 0; 0; 0; 98; 0; 0; 255];
            rgb = table(red, green, blue);
            rgb_vec = cell(doc_len, 3);
            
            % Color data based on rec values
            n = 1:floor((doc_len)/10):doc_len;
            for i=1:10
                if i==10
                    rgb_vec(n(i):end,1) = num2cell(rgb{i,1});
                    rgb_vec(n(i):end,2) = num2cell(rgb{i,2});
                    rgb_vec(n(i):end,3) = num2cell(rgb{i,3});
                else
                    rgb_vec(n(i):n(i+1),1) = num2cell(rgb{i,1});
                    rgb_vec(n(i):n(i+1),2) = num2cell(rgb{i,2});
                    rgb_vec(n(i):n(i+1),3) = num2cell(rgb{i,3});
                end
            end
            
            for i = 1:doc_len
                data.aH(i,2) = rgb_vec{i,1}/255;
                data.aH(i,3) = rgb_vec{i,2}/255;
                data.aH(i,4) = rgb_vec{i,3}/255;
            end
        end
        
        % Color points based on aH value
        function [data, aH, cmap] = aH_color(data, rgb, int_step)
            
            % for collated data (rgb colors cycle every 1/int_step cells)
            int_step = 0.1;
            aH_int(:,1) = min(floor(data.aH(:,1))):int_step:max(data.aH(:,1));
            n = 1:10:length(aH_int);
            for i = 1:length(n)
                aH_int(n(i):n(i)+9,2) = rgb{1:10, 1}/255;
                aH_int(n(i):n(i)+9,3) = rgb{1:10, 2}/255;
                aH_int(n(i):n(i)+9,4) = rgb{1:10, 3}/255;
            end
            
            % for whole data charting (rgb colors cycle through the whole
            % aH range)
            aH_tot(:,1) = min(data.aH(:,1)):int_step:max(data.aH(:,1));
            i = round(linspace(1, length(aH_tot), height(rgb)));
            for count = 1:height(rgb)
                if count == 10
                    aH_tot(i(count):end,2) = rgb{end,1}/255;
                    aH_tot(i(count):end,3) = rgb{end,2}/255;
                    aH_tot(i(count):end,4) = rgb{end,3}/255;
                else
                    aH_tot(i(count):i(count+1),2) = linspace(rgb{count,1}, rgb{count+1,1}, i(count+1)-i(count)+1)/255;
                    aH_tot(i(count):i(count+1),3) = linspace(rgb{count,2}, rgb{count+1,2}, i(count+1)-i(count)+1)/255;
                    aH_tot(i(count):i(count+1),4) = linspace(rgb{count,3}, rgb{count+1,3}, i(count+1)-i(count)+1)/255;
                end
            end
            
            cmap.aH_int = aH_int;
            cmap.aH_tot = aH_tot;
            fnames = fieldnames(cmap);
            idx.aH_int = cell(length(cmap.aH_int),1);
            idx.aH_tot = cell(length(cmap.aH_tot),1);
            aH.aH_int = data.aH;
            aH.aH_tot = data.aH;
            
            for fn = 1:length(fnames)
                for i = 1:length(cmap.(fnames{fn}))
                    if i==length(cmap.(fnames{fn}))
                        idx.(fnames{fn}){i,1} = find(data.aH(:,1)==cmap.(fnames{fn})(i,1));
                    else
                        idx.(fnames{fn}){i,1} = find(data.aH(:,1)>=cmap.(fnames{fn})(i,1) & data.aH(:,1)<cmap.(fnames{fn})(i+1,1));
                    end
                end
                
                starting_idx = find(cmap.aH_int(:,1)== min(data.aH(:,1))); %minimum aH indices
                for i = starting_idx:length(cmap.(fnames{fn}))
                    for n = 1:length(idx.(fnames{fn}){i,1})
                        aH.(fnames{fn})(idx.(fnames{fn}){i,1}(n),2) = cmap.(fnames{fn})(i,2);
                        aH.(fnames{fn})(idx.(fnames{fn}){i,1}(n),3) = cmap.(fnames{fn})(i,3);
                        aH.(fnames{fn})(idx.(fnames{fn}){i,1}(n),4) = cmap.(fnames{fn})(i,4);
                    end
                end
            end
            data = rmfield(data, 'aH');
        end
        
        % Regression scatter plot (2D or 3D)
        function scatter_reg_col(model, clr_data, data, init)
            
            col = init.col;  % Simplifying names 
            n = init.n;
            if init.col_aH
            cmap = model.cmap.aH_tot;
            end
            
            figure('units','normalized','outerposition',[0 0 1 1]);
            
            if col==1
                scatter(clr_data.Var1, clr_data.Var2, 15, [clr_data.Var3 clr_data.Var4 clr_data.Var5],...
                    'filled');
                hold on
                if n>1
                    m = model.linear_reg{n}.Coefficients.Estimate(2);
                    b = model.linear_reg{n}.Coefficients.Estimate(1);
                    R_squared = model.linear_reg{n}.Rsquared.Ordinary;
                    A{1,4} = sprintf('points: %d', height(model.linear_reg{n}.Variables));
                elseif n==1
                    m = model.linear_reg.Coefficients.Estimate(2);
                    b = model.linear_reg.Coefficients.Estimate(1);
                    R_squared = model.linear_reg.Rsquared.Ordinary;
                    A{1,4} = sprintf('points: %d', height(model.linear_reg.Variables));
                end
                
                plot(clr_data.Var1, m*clr_data.Var1 + b, 'LineWidth', 0.7, 'Color', 'r')
                hold off
                
                cbhr = colorbar('eastoutside');
                %cbhb = colorbar('southoutside');
                count=0;
                if init.col_aH==0
                    colormap(data.aH(:,2:4))
                    for i = 1:round(length(data.rec)/(length(cbhr.Ticks)-1)):length(data.rec)
                        count=count+1;
                        tick_lbl(count,1) = data.rec(i,1);
                    end
                    tick_lbl(end+1,1) = data.rec(end,1);
                    cbhr.TickLabels = {datestr(tick_lbl, 'dd-mm-yyyy')};
                else
                    % East colorbar
                    colormap(cbhr, cmap(:,2:4))
                    for i = 1:round(length(cmap)/(length(cbhr.Ticks)-1)):length(cmap)
                        count=count+1;
                        tick_lbl(count,1) = cmap(i,1);
                    end
                    tick_lbl(end+1,1) = cmap(end,1);
                    cbhr.TickLabels = tick_lbl;
                    ylabel(cbhr, init.cbhr_label)
                end
                
            elseif col==0
                if n>1
                    plot(model.linear_reg{n})
                    m = model.linear_reg{n}.Coefficients.Estimate(2);
                    b = model.linear_reg{n}.Coefficients.Estimate(1);
                    R_squared = model.linear_reg{n}.Rsquared.Ordinary;
                    A{1,4} = sprintf('points: %d', height(model.linear_reg{n}.Variables));
                elseif n==1
                    plot(model.linear_reg)
                    m = model.linear_reg.Coefficients.Estimate(2);
                    b = model.linear_reg.Coefficients.Estimate(1);
                    R_squared = model.linear_reg.Rsquared.Ordinary;
                    A{1,4} = sprintf('points: %d', height(model.linear_reg.Variables));
                end
            end
            grid minor
            an = annotation('textbox', [0.75 0.45 0 0]);
            A{1,1} = sprintf('m = %f', m);
            A{1,2} = sprintf('b = %f', b);
            A{1,3} = sprintf('R^2 = %f', R_squared);
            an.String = sprintf('%s\n%s\n%s\n%s', A{1,1}, A{1,2}, A{1,3}, A{1,4});
            an.FitBoxToText = 'on';
            an.BackgroundColor = 'w';
        end
        
        % Collated regression plot (based on aH_ints)
        function fig = collated_reg_aH_rec(model, data, rownames, aH_ints, init, n)
            
            fig = figure('units','normalized','outerposition',[0 0 1 1]);        
            
            if init.col==1
  
                idx.(rownames{n}) = find(data.aH(:,1)>=aH_ints.min_lim(n) & data.aH(:,1)<aH_ints.max_lim(n));
                if isempty(idx.(rownames{n})) % if no indices extracted, continue to next loop
                    fig = {};
                    close(gcf)
                    return
                end
                model.linear_reg{n} = fitlm(data.ref_cnc(idx.(rownames{n})), data.rep_weC_sens(idx.(rownames{n})));
                clr_data = table(model.linear_reg{n,1}.Variables.x1, model.linear_reg{n,1}.Variables.y, data.aH(idx.(rownames{n}),2), data.aH(idx.(rownames{n}),3), data.aH(idx.(rownames{n}),4));
                scatter(clr_data.Var1, clr_data.Var2, 15, [clr_data.Var3 clr_data.Var4 clr_data.Var5], 'filled');
                hold on
                
                m = model.linear_reg{n}.Coefficients.Estimate(2);
                b = model.linear_reg{n}.Coefficients.Estimate(1);
                R_squared = model.linear_reg{n}.Rsquared.Ordinary;
                A{1,4} = sprintf('points: %d', height(model.linear_reg{n}.Variables));
                
                plot(clr_data.Var1, m*clr_data.Var1 + b, 'LineWidth', 0.7, 'Color', 'r')
                hold off
                
                cbh = colorbar;
                count=0;
                if init.col_aH==0
                    colormap(data.aH(:,2:4))
                    for i = 1:round(length(data.rec)/(length(cbh.Ticks)-1)):length(data.rec)
                        count=count+1;
                        tick_lbl(count,1) = data.rec(i,1);
                    end
                    tick_lbl(end+1, 1) = data.rec(end,1);
                    cbh.TickLabels = {datestr(tick_lbl, 'dd-mm-yyyy')};
                else
                    colormap(model.cmap.aH_int(1:10,2:4)) % essentially the same as rgb table
                    tick_lbl(1:11,1) = aH_ints.min_lim(n):init.int_step:aH_ints.max_lim(n);
                    cbh.TickLabels = tick_lbl;
                    ylabel(cbh, init.cbhr_label)
                end
            elseif init.col==0
                plot(model.linear_reg{n})
                m = model.linear_reg{n}.Coefficients.Estimate(2);
                b = model.linear_reg{n}.Coefficients.Estimate(1);
                R_squared = model.linear_reg{n}.Rsquared.Ordinary;
                A{1,4} = sprintf('points: %d', height(model.linear_reg{n}.Variables));
            end
            grid minor
            an = annotation('textbox', [0.75 0.3 0 0]);
            A{1,1} = sprintf('m = %f', m);
            A{1,2} = sprintf('b = %f', b);
            A{1,3} = sprintf('R^2 = %f', R_squared);
            an.String = sprintf('%s\n%s\n%s\n%s', A{1,1}, A{1,2}, A{1,3}, A{1,4});
            an.FitBoxToText = 'on';
            an.BackgroundColor = 'w';
        end
        
        % 3D sphere scatter plot (ideal for around 6000 points)
        function scatter3sph(x, y, z, sf, rgb)
            % Inputs:
            % sf =  scale factor
            % rgb = 3-element vector
            
            figure();
            ax = gca;
            hold(ax, 'on')
            
            [x1, y1, z1] = sphere(10);
            
            x1 = sf*x1;
            y1 = sf*y1;
            z1 = sf*z1;
            
            for i = 1:6000
                surf(ax, x(i)+x1, y(i)+y1, z(i)+z1, 'FaceColor', rgb(i,:), 'EdgeColor', 'none')
            end
            axis equal
            light('Position',[1 0 0],'Style','infinite');
            lighting phong
            view(3)
        end
    end
end