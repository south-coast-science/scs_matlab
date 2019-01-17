function [fig, chart] = multiplot(Y_data, type, var, fig)
gases = {'CO';'NO2';'H2S';'SO2'};
particulates = {'PM1'; 'PM2p5'; 'PM10'};

gases_true = any(ismember(fieldnames(Y_data), gases));
particulates_true = any(ismember(fieldnames(Y_data), particulates));
hmd_true = any(ismember(fieldnames(Y_data), 'hmd'));
tmp_true = any(ismember(fieldnames(Y_data), 'tmp'));
type_pol = [gases_true, particulates_true; hmd_true, tmp_true];
type_count = sum(type_pol(:)==1);
if strcmp(fieldnames(type), 'data')
    ctg = type.data;
elseif strcmp(fieldnames(type), 'aggr')
    ctg = type.aggr;
end
X_data = cellfun(@thirdparty_fcns.datenum8601, cellstr(ctg.datetime));

if type_count==1
    for n=1:length(fieldnames(Y_data))
        if isfield(Y_data, 'NO2')
            fig = NO2plot(Y_data, X_data, type, var, fig);
            Y_data = rmfield(Y_data, 'NO2');
        elseif isfield(Y_data, 'CO')
            fig = COplot(Y_data, X_data, type, var, fig);
            Y_data = rmfield(Y_data, 'CO');
        elseif isfield(Y_data, 'SO2')
            fig = SO2plot(Y_data, X_data, type, var, fig);
            Y_data = rmfield(Y_data, 'SO2');
        elseif isfield(Y_data, 'H2S')
            fig = H2Splot(Y_data, X_data, type, var, fig);
            Y_data = rmfield(Y_data, 'H2S');
        elseif isfield(Y_data, 'PM1')
            fig = PM1plot(Y_data, X_data, type, var, fig);
            Y_data = rmfield(Y_data, 'PM1');
        elseif isfield(Y_data, 'PM2p5')
            fig = PM2p5plot(Y_data, X_data, type, var, fig);
            Y_data = rmfield(Y_data, 'PM2p5');
        elseif isfield(Y_data, 'PM10')
            fig = PM10plot(Y_data, X_data, type, var, fig);
            Y_data = rmfield(Y_data, 'PM10');
        elseif isfield(Y_data, 'tmp')
            fig = tmpplot(Y_data, X_data, type, var, fig);
        elseif isfield(Y_data, 'hmd')
            fig = hmdplot(Y_data, X_data, type, var, fig);
        end
        hold on
        utilities.plotproperties(var)
        if isequal(type_pol,[1,0;0,0]) && length(num2cell(fig.CurrentAxes.Children))>1
            ylabel('Gases (ppb)')
        elseif isequal(type_pol,[0,1;0,0]) && length(num2cell(fig.CurrentAxes.Children))>1
            ylabel('Particulates (\mug/m^3)')
        end
    end
    hold off
elseif type_count==2
    if isfield(Y_data, 'NO2') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2, 1, 1);
        fig = NO2plot(Y_data, X_data, data, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,1,2);
        fig = tmpplot(Y_data, X_data, data, var, fig);
        utilities.subplotproperties(var)
    end
    
    if isfield(Y_data, 'NO2') && isfield(Y_data, 'PM10')
        chart.ax1 = subplot(2, 1, 1);
        fig = NO2plot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,1,2);
        fig = PM10plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
    end
elseif type_count==3
    if isfield(Y_data, 'NO2') && isfield(Y_data, 'PM1') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = NO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM1plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'NO2') && isfield(Y_data, 'PM1') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = NO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM1plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'NO2') && isfield(Y_data, 'PM2p5') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = NO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM2p5plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'NO2') && isfield(Y_data, 'PM2p5') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = NO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM2p5plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'NO2') && isfield(Y_data, 'PM10') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = NO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM10plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'NO2') && isfield(Y_data, 'PM10') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = NO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM10plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        %-----------------------------------------------
    elseif isfield(Y_data, 'CO') && isfield(Y_data, 'PM1') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = COplot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM1plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'CO') && isfield(Y_data, 'PM1') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = COplot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM1plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'CO') && isfield(Y_data, 'PM2p5') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = COplot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM2p5plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'CO') && isfield(Y_data, 'PM2p5') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = COplot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM2p5plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'CO') && isfield(Y_data, 'PM10') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = COplot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM10plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'CO') && isfield(Y_data, 'PM10') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = COplot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM10plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        %------------------------------------------------
    elseif isfield(Y_data, 'SO2') && isfield(Y_data, 'PM1') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = SO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM1plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'SO2') && isfield(Y_data, 'PM1') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = SO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM1plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'SO2') && isfield(Y_data, 'PM2p5') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = SO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM2p5plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'SO2') && isfield(Y_data, 'PM2p5') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = SO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM2p5plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'SO2') && isfield(Y_data, 'PM10') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = SO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM10plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'SO2') && isfield(Y_data, 'PM10') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = SO2plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM10plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        %------------------------------------------------
    elseif isfield(Y_data, 'H2S') && isfield(Y_data, 'PM1') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = H2Splot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM1plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'H2S') && isfield(Y_data, 'PM1') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = H2Splot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM1plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'H2S') && isfield(Y_data, 'PM2p5') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = H2Splot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM2p5plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'H2S') && isfield(Y_data, 'PM2p5') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = H2Splot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM2p5plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'H2S') && isfield(Y_data, 'PM10') && isfield(Y_data, 'tmp')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = tmpplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = H2Splot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM10plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
    elseif isfield(Y_data, 'H2S') && isfield(Y_data, 'PM10') && isfield(Y_data, 'hmd')
        chart.ax1 = subplot(2,2,[1,2]);
        fig = hmdplot(Y_data, X_data, type, var, fig);
        utilities.plotproperties(var)
        
        chart.ax2 = subplot(2,2,3);
        fig = H2Splot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
        
        chart.ax3 = subplot(2,2,4);
        fig = PM10plot(Y_data, X_data, type, var, fig);
        utilities.subplotproperties(var)
    end
end
end




