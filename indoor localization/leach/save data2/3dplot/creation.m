rng(0,'twister');
a = 5;
b = 500;
y = a.*randn(1000,1) + b;
stats = [mean(y) std(y) var(y)];

rng default
z = linspace(0,4*pi,250);
x = 2*cos(z) + rand(1,250);
y = 2*sin(z) + rand(1,250);

S = repmat([50,25,10],numel(X),1);
C = repmat([1,2,3],numel(X),1);
s = S(:);
c = C(:);

figure
scatter3(x,y,z,s,c)
view(-30,10)


syms x
term1(x) = -0.5 * log(2 * pi^2 * x^2);
term2(x) = -((40 - 43)^2) / (2 * x^2);
L_expect(x) = term1(x) + term2(x);
L_expectdiff(x) = diff(L_expect(x));
