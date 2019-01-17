function fig = tmpplot(~, X_data, type, ~, fig)
type_names = fieldnames(type);
tmpColor =[0.6510 0.1686 0.0902];
if strcmp(type_names, 'data')
    figure(fig)
    plt = plot(X_data, type.data.tmp, 'Color', tmpColor, 'LineWidth', 1);
    fig = ancestor(plt, 'figure');
    ax.tmp = gca;
    legend(ax.tmp, 'tmp')
    hold on
elseif strcmp(type_names, 'aggr')
    figure(fig)
    plot(X_data, type.aggr.tmp, 'Color', tmpColor, 'LineWidth', 1);
    hold on
    plot(X_data, type.aggr.tmp_min, 'Color', tmpColor, 'LineWidth', 1, 'LineStyle', ':');
    hold on
    plt = plot(X_data, type.aggr.tmp_max, 'Color', tmpColor, 'LineWidth', 1, 'LineStyle', ':');
    fig = ancestor(plt, 'figure');
    ax.tmp = gca;
    legend(ax.tmp, 'tmp')
    hold on
end
ylabel({'Temperature(\circC)'})
hold off
end