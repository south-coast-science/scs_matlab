function fig = PM1plot(~, X_data, type, ~, fig)
type_names = fieldnames(type);
PM1Color =[0.5333 0.5333 0.5333];
if strcmp(type_names, 'data')
    figure(fig)
    plt = plot(X_data, type.data.PM1, 'Color', PM1Color, 'LineWidth', 1);
    fig = ancestor(plt, 'figure');
    ax.PM1 = gca;
    legend(ax.PM1, 'PM1')
    hold on
elseif strcmp(type_names, 'aggr')
    figure(fig)
    plot(X_data, type.aggr.PM1, 'Color', PM1Color, 'LineWidth', 1);
    hold on
    plot(X_data, type.aggr.PM1_min, 'Color', PM1Color, 'LineWidth', 1, 'LineStyle', ':');
    hold on
    plt = plot(X_data, type.aggr.PM1_max, 'Color', PM1Color, 'LineWidth', 1, 'LineStyle', ':');
    fig = ancestor(plt, 'figure');
    ax.PM1 = gca;
    legend(ax.PM1, 'PM1')
    hold on
end
ylabel({'PM1 (\mug/m^3)'})
hold off
end