% Read CSV file
df = readtable('^GSPC.labels.full.csv');

% Extract features and labels
X = df{:, 2:6};  % extract all columns except the first (date column)
Y = df{:, end};    % extract the last column (label column)

% Define training, validation, and test set sizes
trainSize = 0.6;    % use 60% of the data for training
valSize = 0.2;      % use 20% of the data for validation
testSize = 0.2;     % use 20% of the data for testing

% Split data into training, validation, and test sets
n = size(X, 1);
randIdx = randperm(n);
trainEndIdx = round(trainSize*n);
valEndIdx = round((trainSize+valSize)*n);

trainIdx = randIdx(1:trainEndIdx);
valIdx = randIdx(trainEndIdx+1:valEndIdx);
testIdx = randIdx(valEndIdx+1:end);

% Extract subsets of X and Y for training, validation, and test
Xtrain = X(trainIdx, :);
Ytrain = Y(trainIdx);
Xval = X(valIdx, :);
Yval = Y(valIdx);
Xtest = X(testIdx, :);
Ytest = Y(testIdx);

% Labels
Y_training = table2array(df(1:trainEndIdx,end));
Y_test = table2array(df(testIdx,end));

% Drop unnecessary columns
df(:, {'Open','High', 'Low','Volume', 'AdjClose'}) = [];
% Create a new variable named "ID"
df.ID = (0:height(df)-1)';

% Calculate pairwise distances using all features
k = 5;
distances = pdist2(Xtest, Xtrain, 'euclidean');

% Sort distances and get indices of k+1 nearest neighbors
[sortedD, idx] = sort(distances, 2);

Ypred = mode(Ytrain(idx(:,1:k)), 2);


% Initial values 
tp=0; fp=0; tn=0; fn=0;

for i=1:length(Y_test)
    if Ypred(i)==1
        if Y_test(i)==1
            tp=tp+1;
        else
            fp=fp+1;
        end
    else
        if Y_test(i)==1
            fn=fn+1;
        else
            tn=tn+1;
        end
    end
end

tpr=tp/(tp+fn);
fpr=fp/(fp+tn);


%Calculate TPR and FPR for various threshold values
thresholds = 0:0.01:5;
tprs = zeros(size(thresholds));
fprs = zeros(size(thresholds));

for i = 1:length(thresholds)
   thresh = thresholds(i);
   tprs(i) = sum((Ypred >= thresh) & (Y_test == 1))/sum(Y_test == 1);
   fprs(i) = sum((Ypred >= thresh) & (Y_test == 0))/sum(Y_test == 0);
end

%Plot the ROC curve
figure
plot(fprs, tprs, 'LineWidth', 2)
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title('ROC Curve')
axis square
