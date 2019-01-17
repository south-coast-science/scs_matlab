function fig = hmdplot(~, X_data, type, ~, fig)
type_names = fieldnames(type);
hmdColor = [0.1176 0.2980 0.4863];
if strcmp(type_names, 'data')
    figure(fig)
    plt = plot(X_data, type.data.hmd, 'Color', hmdColor, 'LineWidth', 1);
    fig = ancestor(plt, 'figure');
    ax.hmd = gca;
    legend(ax.hmd, 'hmd')
    hold on
elseif strcmp(type_names, 'aggr')
    figure(fig)
    plot(X_data, type.aggr.hmd, 'Color', hmdColor, 'LineWidth', 1);
    hold on
    plot(X_data, type.aggr.hmd_min, 'Color', hmdColor, 'LineWidth', 1, 'LineStyle', ':');
    hold on
    plt = plot(X_data, type.aggr.hmd_max, 'Color', hmdColor, 'LineWidth', 1, 'LineStyle', ':');
    fig = ancestor(plt, 'figure');
    ax.hmd = gca;
    legend(ax.hmd, 'hmd')
    hold on
end
ylabel({'Relative Humidity (%)'})
hold off
end