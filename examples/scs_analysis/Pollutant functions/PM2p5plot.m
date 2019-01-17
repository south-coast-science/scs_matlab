function fig = PM2p5plot(~, X_data, type, ~, fig)
type_names = fieldnames(type);
PM2p5Color = [0.3333 0.3333 0.3333];
if strcmp(type_names, 'data')
    figure(fig)
    plt = plot(X_data, type.data.PM2p5, 'Color', PM2p5Color, 'LineWidth', 1);
    fig = ancestor(plt, 'figure');
    ax.PM2p5 = gca;
    legend(ax.PM2p5, 'PM2p5')
    hold on
elseif strcmp(type_names, 'aggr')
    figure(fig)
    plot(X_data, type.aggr.PM2p5, 'Color', PM2p5Color, 'LineWidth', 1);
    hold on
    plot(X_data, type.aggr.PM2p5_min, 'Color', PM2p5Color, 'LineWidth', 1, 'LineStyle', ':');
    hold on
    plt = plot(X_data, type.aggr.PM2p5_max, 'Color', PM2p5Color, 'LineWidth', 1, 'LineStyle', ':');
    fig = ancestor(plt, 'figure');
    ax.PM2p5 = gca;
    legend(ax.PM2p5, 'PM2p5')
    hold on
end
ylabel({'PM2p5(\mug/m^3)'})
hold off
end