% Assuming you have 7 data sets, each with 2000 values
% Replace these with your actual data sets

dataSet1 =z1; % 2000 values
dataSet2 = z2; % 2000 values
dataSet3 = z3; % 2000 values
dataSet4 = z4; % 2000 values
dataSet5 = z5; % 2000 values
dataSet6 = z6; % 2000 values
dataSet7 = z7; % 2000 values
dataSet8 = z8; % 2000 values
% dataSet9 = z9; % 2000 values

for i=1:1:2000
    dataaverage(i) = (dataSet1(i)+dataSet2(i)+dataSet3(i)+dataSet4(i)+dataSet5(i)+dataSet6(i)+dataSet7(i)+dataSet8(i))/8;
end

% Combine all the data sets into a matrix
dataMatrix = [dataSet1(:), dataSet2(:), dataSet3(:), dataSet4(:), dataSet5(:), dataSet6(:), dataSet7(:), dataSet8(:)];

% Calculate the average across the 7 data sets
averageData = mean(dataMatrix, 2);

% Display the averaged data
disp(averageData);

figure;
x=1:1:2000;
% Create plot
plot(x,dataaverage,'b-');