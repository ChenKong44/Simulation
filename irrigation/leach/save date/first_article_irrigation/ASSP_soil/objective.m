%% Comparison of ASSP, DSGT, and DSIGN-SGD for two soil types
% This script is self-contained and reproduces the three-panel layout used
% in Fig. 13. Replace the six cluster-size and energy arrays with simulation
% outputs when real experimental data are available.

clear;
clc;
close all;

rng(13);                       % Reproducible small fluctuations
iteration = 0:50:1000;         % One plotted node every 50 iterations

%% Cluster-size trajectories
% Anchor values are digitized approximations of the supplied Fig. (a).
% ASSP reaches z*=40 first; the other methods approach it more slowly and
% retain the late-stage fluctuations visible in the reference figure.
cluster.assp_sandy = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 500 650 800 1000], ...
    [20 22.5 26.8 29.3 32.8 36.8 38.5 39.4 39.6 39.7 39.7 39.7 39.6], 0.10, 31);
cluster.assp_loam = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 450 550 700 850 1000], ...
    [20 21.5 23.5 26.0 28.5 31.5 34.7 37.3 38.4 39.4 39.8 39.8 39.8 39.5], 0.12, 32);
cluster.dsgt_sandy = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 500 600 700 800 850 900 950 1000], ...
    [20 22.8 26.0 29.0 31.5 33.0 34.0 34.6 35.0 36.7 37.4 38.0 38.4 38.75 38.45 38.85 38.60], 0.30, 33);
cluster.dsgt_loam = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 500 600 700 800 850 900 950 1000], ...
    [20 20.3 20.8 21.5 23.0 25.0 27.3 29.0 31.0 34.0 35.5 37.0 37.4 38.00 37.65 38.20 37.90], 0.38, 34);
cluster.dsign_sandy = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 500 600 700 800 850 900 950 1000], ...
    [20 23.5 27.5 30.0 32.5 35.0 37.0 38.0 38.4 38.6 38.75 38.85 38.90 38.75 38.95 38.82 38.92], 0.04, 35);
cluster.dsign_loam = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 500 600 700 800 850 900 950 1000], ...
    [20 22.0 25.0 26.5 28.0 30.0 32.0 33.0 35.0 36.8 37.3 37.45 37.55 37.42 37.62 37.48 37.58], 0.04, 36);

%% Energy-consumption trajectories
% Anchor values are digitized approximations of the supplied Fig. (b).
% They intentionally preserve the ordering and late-stage rebounds shown
% in that figure rather than imposing a separate soil-order constraint.
energy.assp_sandy = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 500 650 800 1000], ...
    [49.0 43.0 38.0 33.5 27.5 21.0 18.5 17.0 16.8 16.7 16.7 16.7 16.8], 0.10, 41);
energy.assp_loam = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 450 550 700 850 1000], ...
    [49.0 46.0 41.0 37.0 32.5 27.0 22.0 19.5 18.0 16.7 16.5 16.5 16.5 16.8], 0.12, 42);
energy.dsgt_sandy = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 500 600 700 800 850 900 950 1000], ...
    [49.0 43.0 38.0 33.0 30.5 27.0 25.5 24.0 22.5 20.0 19.0 18.5 18.0 18.4 17.7 18.2 17.8], 0.28, 43);
energy.dsgt_loam = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 500 600 700 800 850 900 950 1000], ...
    [49.0 49.0 48.0 47.0 45.0 41.0 37.0 34.0 31.0 27.0 23.5 20.5 20.0 20.5 19.9 20.6 20.1], 0.36, 44);
energy.dsign_sandy = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 500 600 700 800 850 900 950 1000], ...
    [49.0 44.0 39.0 34.0 29.0 23.0 21.0 19.0 18.5 18.30 18.20 18.15 18.12 18.35 18.08 18.28 18.12], 0.04, 45);
energy.dsign_loam = make_curve(iteration, ...
    [0 50 100 150 200 250 300 350 400 500 600 700 800 850 900 950 1000], ...
    [49.0 47.0 44.0 40.0 36.0 33.5 29.0 27.0 23.0 20.5 19.5 18.7 18.2 18.45 17.95 18.25 18.00], 0.04, 46);

% Fig. (c) uses a nonnegative relative gap from the optimal converged
% energy for each soil type. Consequently, all curves remain above zero
% and approach zero as their energy consumption converges.
optimal_energy.sandy = 16.7;
optimal_energy.loam = 16.5;
gap_names = fieldnames(energy);
for k = 1:numel(gap_names)
    name = gap_names{k};
    if contains(name, 'sandy')
        reference_energy = optimal_energy.sandy;
    else
        reference_energy = optimal_energy.loam;
    end
    relative_gap.(name) = abs(energy.(name) - reference_energy) ...
        / reference_energy;
end

%% Plot
styles = {
    'assp_sandy',  [0.00 0.00 0.00], '-',  'o', 2.0, 'ASSP-sandy loam';
    'assp_loam',   [0.00 0.00 0.00], '--', 'o', 2.0, 'ASSP-loam';
    'dsgt_sandy',  [0.85 0.10 0.10], '-',  'd', 1.8, 'DSGT-sandy loam';
    'dsgt_loam',   [0.85 0.10 0.10], '--', 'd', 1.8, 'DSGT-loam';
    'dsign_sandy', [0.00 0.35 0.75], '-',  '*', 1.8, 'DSIGN-SGD-sandy loam';
    'dsign_loam',  [0.00 0.35 0.75], '--', '*', 1.8, 'DSIGN-SGD-loam'
};

% Each result is drawn in an R2025b figure-container tab. Avoid forcing
% standalone window positions because that restores the legacy menu bar.
axes_position = [0.13 0.14 0.82 0.80];

fig_cluster = create_figure('Cluster size');
ax1 = axes('Parent', fig_cluster, 'Units', 'normalized', ...
    'Position', axes_position);
plot_family(ax1, iteration, cluster, styles);
format_axes(ax1, [0 1000], [10 50], 0:200:1000, 10:5:50);
xlabel(ax1, 'Number of Iterations');
ylabel(ax1, 'Cluster size');
title(ax1, '(a) Cluster size', 'FontWeight', 'normal');
legend(ax1, 'Location', 'southeast', 'FontSize', 14);

fig_energy = create_figure('Energy consumption');
ax2 = axes('Parent', fig_energy, 'Units', 'normalized', ...
    'Position', axes_position);
plot_family(ax2, iteration, energy, styles);
format_axes(ax2, [0 1000], [10 70], 0:200:1000, 10:10:70);
xlabel(ax2, 'Number of Iterations');
ylabel(ax2, 'Energy consumption');
title(ax2, '(b) Energy consumption', 'FontWeight', 'normal');
legend(ax2, 'Location', 'northeast', 'FontSize', 14);

fig_gap = create_figure('Relative energy consumption gap');
ax3 = axes('Parent', fig_gap, 'Units', 'normalized', ...
    'Position', axes_position);
plot_family(ax3, iteration, relative_gap, styles);
format_axes(ax3, [0 1000], [-0.1 2.0], 0:200:1000, 0:0.5:2.0);
xlabel(ax3, 'Number of Iterations');
ylabel(ax3, 'Relative energy consumption gap, \psi', 'Interpreter', 'tex');
legend(ax3, 'Location', 'northeast', 'FontSize', 14);

figures = [fig_cluster, fig_energy, fig_gap];
for k = 1:numel(figures)
    set(findall(figures(k), '-property', 'FontName'), ...
        'FontName', 'Times New Roman');
    set(findall(figures(k), '-property', 'FontSize'), 'FontSize', 14);
end

% Optional publication export:
% exportgraphics(fig_cluster, 'cluster_size.pdf', 'ContentType', 'vector');
% exportgraphics(fig_energy, 'energy_consumption.pdf', 'ContentType', 'vector');
% exportgraphics(fig_gap, 'relative_energy_gap.pdf', 'ContentType', 'vector');
% exportgraphics(fig_cluster, 'cluster_size.png', 'Resolution', 600);
% exportgraphics(fig_energy, 'energy_consumption.png', 'Resolution', 600);
% exportgraphics(fig_gap, 'relative_energy_gap.png', 'Resolution', 600);

%% Local functions
function values = make_curve(x, anchor_x, anchor_y, noise_level, seed)
    values = interp1(anchor_x, anchor_y, x, 'pchip');
    rng(seed);
    window = [1 2 3 4 5 6 5 4 3 2 1];
    window = window / sum(window);
    noise = conv(randn(size(x)), window, 'same');
    noise([1:6, end-5:end]) = 0;
    values = values + noise_level * noise;
end

function fig = create_figure(figure_name)
    % R2025b opens this figure in the modern figure container by default.
    % Setting Position, WindowStyle='normal', MenuBar='figure', or
    % ToolBar='figure' would undock it and restore the legacy figure tools.
    fig = figure('Name', figure_name, ...
        'NumberTitle', 'off', ...
        'Color', 'w');
end

function plot_family(ax, x, curves, styles)
    hold(ax, 'on');
    for i = 1:size(styles, 1)
        name = styles{i, 1};
        plot(ax, x, curves.(name), ...
            'Color', styles{i, 2}, ...
            'LineStyle', styles{i, 3}, ...
            'Marker', styles{i, 4}, ...
            'MarkerSize', 5.5, ...
            'MarkerFaceColor', 'none', ...
            'LineWidth', styles{i, 5}, ...
            'DisplayName', styles{i, 6});
    end
    hold(ax, 'off');
end

function format_axes(ax, x_limits, y_limits, x_ticks, y_ticks)
    grid(ax, 'on');
    box(ax, 'on');
    xlim(ax, x_limits);
    ylim(ax, y_limits);
    xticks(ax, x_ticks);
    yticks(ax, y_ticks);
    ax.GridAlpha = 0.18;
    ax.LineWidth = 0.8;
    ax.TickDir = 'in';
end
