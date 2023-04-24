% Read CSV file
df = readtable('^GSPC.csv');
df = df(1:end, :);
df.Date = datetime(df.Date, 'InputFormat', 'yyyy-MM-dd');

% Create a plot
figure;
plot(df.Date, df.Close, 'r');
xlabel('Date');
ylabel('Difference in daily price/USD');
title('S&P500 Analysis');
grid on;

% Drop unnecessary columns
df(:, {'Open','High', 'Low','Volume', 'AdjClose'}) = [];
% Create a new variable named "ID"
df.ID = (0:height(df)-1)';

% Calculate pairwise distances using "ID" variable
k = 5;
distances = pdist2(table2array(df(:,2)), table2array(df(:,2)), 'euclidean');

% Sort distances and get indices of k+1 nearest neighbors
[sortedD, idx] = sort(distances, 2);

% Replace "Date" column with "ID" column
df.Date = df.ID;

% Analyze mean distances
distances_mean = mean(sortedD(:,2:k+1), 2);
%distances_mean_normalized = distances_mean / max(distances_mean);

% Set outlier threshold and find indices of outlier values
%th_percentile = prctile(distances_mean,90); 
th_percentile = 5; 
outlier_index = find(distances_mean > th_percentile);

% Assign scores to anomalies
anomaly_scores = zeros(size(df,1), 1);
anomaly_scores(outlier_index) = distances_mean(outlier_index);

if anomaly_scores(outlier_index) > 0

    anomaly_scores(anomaly_scores > 0) = 1;

end 

% Display outlier values
outlier_values = df(outlier_index, :);

figure;
plot(df.Date, df.Close, 'b');
hold on;
scatter(outlier_values.Date, outlier_values.Close, 'or');
xlabel('Date');
ylabel('Daily closing price/USD');
title('S&P500 Stock Prices');
grid on;
hold off;