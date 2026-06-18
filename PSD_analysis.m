% Define input file name
filename_in = 'input_psd.xlsx';

% Load raw data from the Excel file
rawData = readmatrix(filename_in);

% Get data dimensions
num_rows = size(rawData, 1);
num_cols = size(rawData, 2);

% Define bin edges for particle size distribution histogram
custom_edges = 0:5:60; 

% Preallocate matrix for statistical metrics (Count, d10, d50, d90, d32)
statMat = zeros(5, num_cols); 

% Process statistics for each column
for r = 1:num_cols
    S = StatProcess(rawData, r);
    statMat(:,r) = S;
end

% Color palette for sequential plotting
color_list = {'r', 'g', 'b', 'c', 'm', 'y', 'k', 'w'};

% Generate size distribution plots for each dataset
for n = 1:num_cols

    % Extract statistical metrics for the current column
    P_l   = statMat(1, n);
    d10_l = statMat(2, n);
    d50_l = statMat(3, n);
    d90_l = statMat(4, n);
    D32_l = statMat(5, n);

    % Format legend text with statistical summary
                      legend_text = sprintf(['Points: %d\n' ...
                     'd10: %.2f \\mum\n' ...
                     'd50: %.2f \\mum\n' ...
                     'd90: %.2f \\mum\n' ...
                     'd32: %.2f \\mum'], ...
                     P_l, d10_l, d50_l, d90_l, D32_l);
    
    % Filter, clean, and sort data for visualization
    figure;
    graphMat= rawData(:, n);
    graphMat = graphMat(~isnan(graphMat));
    graphMat = graphMat(graphMat > 0);
    graphMat = sort(graphMat);

    % Plot probability density function (PDF) histogram
    h1 = histogram(graphMat, 'BinEdges', custom_edges, 'FaceColor', color_list{n}, 'Normalization', 'pdf');
    hold on;
    xlabel('Particle size, \mum')
    ylabel('Probability Density');
    title('PSD-graph (PDF)');
    grid on;
    
    % Display legend with integrated statistics
    legend([h1], [string(legend_text)], 'Location', 'northeast');
    hold off;
end


% Helper function for data cleaning and statistical calculation
function [statRow] = StatProcess(dataMat, colmnNum)

    % Extract, clean (remove NaNs/zeros), and sort specific column data
    processMat= dataMat(:, colmnNum);
    processMat = processMat(~isnan(processMat));
    processMat = processMat(processMat > 0);
    processMat = sort(processMat);
    
    % Calculate total number of valid data points
    points = length(processMat);

    % Compute characteristic particle size percentiles
    d10 = quantile(processMat,0.10);
    d50 = quantile(processMat,0.50);
    d90 = quantile(processMat,0.90);

    % Calculate Sauter mean diameter (d32)
    D32 = sum(processMat.^3)/sum(processMat.^2);

    % Output statistics as a column vector
    statRow = [points, d10, d50, d90, D32];
    statRow = statRow';

end
