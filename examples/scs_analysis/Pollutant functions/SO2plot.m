function fig = SO2plot(~, X_data, type, ~, fig)
type_names = fieldnames(type);
SO2Color = [0.4353 0.1412 0.0863];
if strcmp(type_names, 'data')
    figure(fig)
    plt = plot(X_data, type.data.SO2, 'Color', SO2Color, 'LineWidth', 1);
    fig = ancestor(plt, 'figure');
    ax.SO2 = gca;
    legend(ax.SO2, 'SO2')
    hold on
elseif strcmp(type_names, 'aggr')
    figure(fig)
    plot(X_data, type.aggr.SO2, 'Color', SO2Color, 'LineWidth', 1);
    hold on
    plot(X_data, type.aggr.SO2_min, 'Color', SO2Color, 'LineWidth', 1, 'LineStyle', ':');
    hold on
    plt = plot(X_data, type.aggr.SO2_max, 'Color', SO2Color, 'LineWidth', 1, 'LineStyle', ':');
    fig = ancestor(plt, 'figure');
    ax.SO2 = gca;
    legend(ax.SO2, 'SO2')
    hold on
end
ylabel({'SO2 (ppb)'})
hold off
end