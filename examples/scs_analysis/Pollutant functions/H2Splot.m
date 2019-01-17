function fig = H2Splot(~, X_data, type, ~, fig)
type_names = fieldnames(type);
H2SColor = [0.6431 0.3059 0.1725];
if strcmp(type_names, 'data')
    figure(fig)
    plt = plot(X_data, type.data.H2S, 'Color', tmpColor, 'LineWidth', 1);
    fig = ancestor(plt, 'figure');
    ax.H2S = gca;
    legend(ax.H2S, 'H2S')
    hold on
elseif strcmp(type_names, 'aggr')
    figure(fig)
    plot(X_data, type.aggr.H2S, 'Color', H2SColor, 'LineWidth', 1);
    hold on
    plot(X_data, type.aggr.H2S_min, 'Color', H2SColor, 'LineWidth', 1, 'LineStyle', ':');
    hold on
    plt = plot(X_data, type.aggr.H2S_max, 'Color', H2SColor, 'LineWidth', 1, 'LineStyle', ':');
    fig = ancestor(plt, 'figure');
    ax.H2S = gca;
    legend(ax.H2S, 'H2S')
    hold on
end
ylabel({'H2S (ppb)'})
hold off
end