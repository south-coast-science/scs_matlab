clearvars;

joined_filename = 'praxis_ref_joined_ah_short_corr3.csv'; 
T = readtable(joined_filename); % Read filename as table

% Specify rec column name (e.g datenum(T."rec_name", '...')):
rec = datenum(T.rec, 'yyyy-mm-ddTHH:MM:SSZ'); 
% Specify concentration column names:
refname = 'ref.15 minute "real" data'; 
repname = 'praxis.val.NO2.cnc';
corrname = 'praxis.val.NO2.cnc-ah-corr';
% Specify external parameter column name:
ext_par = 'praxis.val.sht.tmp';

% Specify colors:
cncCol = [51 51 255; 255 153 51; 102 204 0]/255;
extCol = [0.6510 0.1686 0.0902];

% Assigning correct names to column names:
for i = 1:width(T)
    if isempty(T.Properties.VariableDescriptions{i})
        continue
    end
    varname{i,1} = extractBetween(T.Properties.VariableDescriptions{i}, "heading: '", length(T.Properties.VariableDescriptions{i}), 'Boundaries', 'exclusive');
    ref = strcmp(refname, varname{i});
    rep = strcmp(repname, varname{i});
    corr = strcmp(corrname, varname{i});
    ext = strcmp(ext_par, varname{i});
    
    if ref == 1
        var.ref = T.Properties.VariableNames{i};
    elseif rep == 1
        var.rep = T.Properties.VariableNames{i};
    elseif corr == 1
        var.corr = T.Properties.VariableNames{i};
    elseif ext == 1 
        varext.tmp = T.Properties.VariableNames{i};
    end
end

% Assign values to names:
fnamesvar = fieldnames(var);
fnamesvarext = fieldnames(varext);
for i = 1:length(fnamesvar)
    var.(fnamesvar{i}) = T.(var.(fnamesvar{i})); % concentration values
end
varext.(fnamesvarext{1}) = T.(varext.(fnamesvarext{1})); % external parameter values

% Plotting 
% Subplot 1 (Concentrations)
fig = figure();
sb1 = subplot(2,1,1);
sb1.Position = [0.13 0.46 0.7750 0.45];
for i = 1:length(fnamesvar)
    plt1 = plot(rec, var.(fnamesvar{i}), 'Color', cncCol(i,:), 'LineWidth', 0.75);
    hold on
end
grid minor
datetick('x', 'dd-mmm-yy HH:MM', 'keepticks', 'keeplimits');
legend(fnamesvar)

% Subplot 2 (External Parameter)
sb2 = subplot(2,1,2);
sb2.Position = [0.13 0.1 0.7750 0.25];
for i = 1:length(fnamesvarext)
    plt2 = plot(rec, varext.(fnamesvarext{i}), 'Color', extCol, 'LineWidth', 1);
    hold on
end
grid minor
datetick('x', 'dd-mmm-yy HH:MM', 'keepticks', 'keeplimits');

% Plot properties
title(sb1, 'Correction of external factors affecting cnc')
ylabel(sb1, 'Concentration (ppb)')
ylabel(sb2, 'Temperature (\circC)')
dcm_obj = datacursormode(gcf);
dcm_obj.UpdateFcn = @utilities.data_cursor; % Updates "Data-Cursor" callback to display datetime x-values.