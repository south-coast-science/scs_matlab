function fig = COplot(~, X_data, type, ~, fig)
type_names = fieldnames(type);
COColor = [0.2549 0.4235 0.2431];
if strcmp(type_names, 'data')
    figure(fig)
    plt = plot(X_data, type.data.CO, 'Color', COColor, 'LineWidth', 1);
    fig = ancestor(plt, 'figure');
    ax.CO = gca;
    legend(ax.CO, 'CO')
    hold on
elseif strcmp(type_names, 'aggr')
    figure(fig)
    plot(X_data, type.aggr.CO, 'Color', COColor, 'LineWidth', 1);
    hold on
    plot(X_data, type.aggr.CO_min, 'Color', COColor, 'LineWidth', 1, 'LineStyle', ':');
    hold on
    plt = plot(X_data, type.aggr.CO_max, 'Color', COColor, 'LineWidth', 1, 'LineStyle', ':');
    fig = ancestor(plt, 'figure');
    ax.CO = gca;
    legend(ax.CO, 'CO')
    hold on
end
ylabel({'CO (ppb)'})
hold off
end