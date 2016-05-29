function pc = percentCorrectFromDist(criterion, mu1, mu2, sigma1, sigma2)

%% Compute the hits and correct rejections 
pc = zeros(size(mu1));

for dItr = 1:length(mu1)
    H  = 1 - normcdf(criterion, mu2(dItr), sigma2(dItr));
    CR = normcdf(criterion, mu1(dItr), sigma1(dItr));

    pc(dItr) = (H + CR)/2 * 100;
end