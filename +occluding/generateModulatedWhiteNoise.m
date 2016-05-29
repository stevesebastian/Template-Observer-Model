function [modNoiseImg, noiseImg, meanNoiseMap] = generateModulatedWhiteNoise(noiseMap, meanPixel, bPlot)

if(~exist('bPlot', 'var') || isempty(bPlot))
    bPlot = 0;
end

uniqueNoiseLvls = unique(noiseMap);
% meanNoise = 0;
% for nItr = 1:length(uniqueNoiseLvls)
%     meanNoise = meanNoise + uniqueNoiseLvls(nItr).^2;
% end

meanNoise = sqrt(sum(uniqueNoiseLvls.^2))./sqrt(length(uniqueNoiseLvls));

% Generate a noise image for each unique noise level in the noise map
modNoiseImg = randn(size(noiseMap)).*noiseMap + meanPixel;
noiseImg = randn(size(noiseMap)).*meanNoise + meanPixel;

meanNoiseMap = ones(size(noiseMap)).*meanNoise;

if(bPlot)
    figure; 
    subplot(1,2,1);
    colormap(gray(256));
    image(modNoiseImg);
    axis image;
    
    subplot(1,2,2);
    colormap(gray(256));
    image(noiseImg);
    axis image;
end