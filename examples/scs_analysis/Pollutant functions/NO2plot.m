function fig = NO2plot(~, X_data, type, ~, fig)
type_names = fieldnames(type);
NO2Color = [0.4941 0.2235 0.1176];
if strcmp(type_names, 'data')
    figure(fig)
    plt = plot(X_data, type.data.NO2, 'Color', NO2Color, 'LineWidth', 1);
    fig = ancestor(plt, 'figure');
    ax.NO2 = gca;
    legend(ax.NO2, 'NO2')
    hold on
elseif strcmp(type_names, 'aggr')
    figure(fig)
    plot(X_data, type.aggr.NO2, 'Color', NO2Color, 'LineWidth', 1);
    hold on
    plot(X_data, type.aggr.NO2_min, 'Color', NO2Color, 'LineWidth', 1, 'LineStyle', ':');
    hold on
    plt = plot(X_data, type.aggr.NO2_max, 'Color', NO2Color, 'LineWidth', 1, 'LineStyle', ':');
    fig = ancestor(plt, 'figure');
    ax.NO2 = gca;
    legend(ax.NO2, 'NO2')
    hold on
end
ylabel({'NO2 (ppb)'})
hold off
end
