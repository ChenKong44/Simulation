% Load saved figures
fig1=hgload('figure1.fig');
fig2=hgload('figure2.fig');
fig3=hgload('figure3.fig');
% Prepare subplots
figure
h(1)=subplot(1,3,1);
h(2)=subplot(1,3,2);
h(3)=subplot(1,3,3);
% Paste figures on the subplots
copyobj(allchild(get(fig1,'CurrentAxes')),h(1));
copyobj(allchild(get(fig2,'CurrentAxes')),h(2));
copyobj(allchild(get(fig3,'CurrentAxes')),h(3));
% Add legends
l(1)=legend(h(1),'LegendForFirstFigure');
l(2)=legend(h(2),'LegendForSecondFigure');
l(3)=legend(h(3),'LegendForSecondFigure');