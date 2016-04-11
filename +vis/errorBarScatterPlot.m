function errorBarScatterPlot(x, y, axisLim, fTitle, xTitle, yTitle, bin)

N = length(x);    % Number of points

% Define errorbar
if(~exist('bin', 'var') || isempty(bin))
    n = 15;     % Number of x-bins
    bin = linspace(min(x), max(x), n+1);
else
    n = 10;
end

ind  = sum(bsxfun(@minus, x, ones(N,1)*bin)>=0,2);
indy = sum(bsxfun(@minus, y, ones(N,1)*bin)>=0,2);

m = NaN(n,1);
e = NaN(n,1);

for i = 1:n
    m(i) = mean(y(ind==i));   % Mean value over the bin
    e(i) = std(y(ind==i));    % Standard deviation
    
    mI(i) = mean(ind(indy==i));
    eI(i) = std(ind(indy==i));
end

%%
figure; hold on; 
plot(0:n+1, 0:n+1, '-r', 'LineWidth', 2);
errorbar(1:n, mI, eI, 'ko-', 'LineWidth', 2);

axis square;
ylim([0 n+1]);
xlim([0 n+1]);
set(gca, 'TickDir', 'out' );
set(gcf,'color','w');
set(gca,'fontsize',18);
title([fTitle ' Bins']);
xlabel([xTitle ' Bins']);
ylabel([yTitle ' Bins']);

%%
figure; hold on;

u = (bin(1:end-1)+bin(2:end))/2;

plot(axisLim, axisLim, '-r', 'Linewidth', 2);
errorbar(u,m,e,'ko-', 'lineWidth', 2);

th = text(axisLim(1) + axisLim(2).*0.08, axisLim(2) - axisLim(2).*0.08, ['\rho = ' num2str(corr(x, y), '%0.3f')]);
set(th, 'fontsize', 18); 

axis square;
set(gca, 'TickDir', 'out' );
set(gcf,'color','w');
set(gca,'fontsize',18);
ylim(axisLim);
xlim(axisLim);
title(fTitle);
xlabel(xTitle);
ylabel(yTitle);
