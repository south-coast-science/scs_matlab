function fig = PM10plot(~, X_data, type, ~, fig)
type_names = fieldnames(type);
PM10Color = [0 0 0];
if strcmp(type_names, 'data')
    figure(fig)
    plt = plot(X_data, type.data.PM10, 'Color', PM10Color, 'LineWidth', 1);
    fig = ancestor(plt, 'figure');
    ax.PM10 = gca;
    legend(ax.PM10, 'PM10')
    hold on
elseif strcmp(type_names, 'aggr')
    figure(fig)
    plot(X_data, type.aggr.PM10, 'Color', PM10Color, 'LineWidth', 1);
    hold on
    plot(X_data, type.aggr.PM10_min, 'Color', PM10Color, 'LineWidth', 1, 'LineStyle', ':');
    hold on
    plt = plot(X_data, type.aggr.PM10_max, 'Color', PM10Color, 'LineWidth', 1, 'LineStyle', ':');
    fig = ancestor(plt, 'figure');
    ax.PM10 = gca;
    legend(ax.PM10, 'PM10')
    hold on
end
ylabel({'PM10 (\mug/m^3)'})
hold off
end
