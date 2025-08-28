clc;
clear;
x = [0.19 0.10 0.11 0.19 0.10 0.14 0.20 0.19 0.18 0.23 0.13 0.25];
target_spare= [];
for t =1:1:12
    fprintf('current run: %d\n',t);
    moisture = x(t);
    [targetz]=saddle(moisture);
    target_spare=[target_spare,targetz];
end