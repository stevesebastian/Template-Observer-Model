function [splitNoiseImg, noiseImg, sigmaImage] = generateSplitNoiseImage(noiseSize, meanPixel, noiseLow, noiseHigh, bPlot)

if(~exist('bPlot', 'var') || isempty(bPlot))
    bPlot = 0;
end

splitNoiseImg = randn(noiseSize);
midPoint = ceil(size(splitNoiseImg)./2);

splitNoiseImg(:, 1:midPoint) = splitNoiseImg(:, 1:midPoint).*noiseLow + meanPixel;
splitNoiseImg(:, (1+midPoint):end) = splitNoiseImg(:, (1+midPoint):end).*noiseHigh + meanPixel;

meanNoise = sqrt(noiseLow.^2 + noiseHigh^2)/sqrt(2);
noiseImg = randn(noiseSize).*meanNoise + meanPixel;

if(bPlot)
    figure; 
    subplot(1,2,1);
    colormap(gray(256));
    image(splitNoiseImg);
    axis image;
    
    subplot(1,2,2);
    colormap(gray(256));
    image(noiseImg);
    axis image;
end