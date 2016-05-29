function mwnTest(target, targetAmpLvls, noiseMap, meanPixel, estWindowSize)

nTrials = 100;
responseNoise       = zeros(length(targetAmpLvls), nTrials);
responseModNoise    = zeros(length(targetAmpLvls), nTrials);

responseNoiseEst    = zeros(length(targetAmpLvls), nTrials);
responseModNoiseEst = zeros(length(targetAmpLvls), nTrials);

targetPresent       = zeros(length(targetAmpLvls), nTrials);

dPrimeMod       = zeros(length(targetAmpLvls), 1);
dPrimeNoise     = zeros(length(targetAmpLvls), 1);
dPrimeLowNoise  = zeros(length(targetAmpLvls), 1);

for aItr = 1:length(targetAmpLvls)
    
    for tItr = 1:nTrials
        [modNoiseImg, noiseImg, uniNoiseMap] = occluding.generateModulatedWhiteNoise(noiseMap, meanPixel);
        
        if(binornd(1, 0.5))
            modNoiseImg = modNoiseImg + target.*targetAmpLvls(aItr);
            noiseImg    = noiseImg + target.*targetAmpLvls(aItr);
            
            targetPresent(aItr, tItr) = 1;            
        end
        
        responseModNoise(aItr, tItr) = occluding.mwnIdealDetector(modNoiseImg, target, targetAmpLvls(aItr), noiseMap);     
        responseNoise(aItr, tItr)    = occluding.mwnIdealDetector(noiseImg, target, targetAmpLvls(aItr), uniNoiseMap);       
        
        % Estimate the noise
        noiseMapEst    = stdfilt(modNoiseImg, ones(estWindowSize));
        uniNoiseMapEst = stdfilt(noiseImg, ones(estWindowSize));
        
        responseModNoiseEst(aItr, tItr) = occluding.mwnIdealDetector(modNoiseImg, target, targetAmpLvls(aItr), noiseMapEst);     
        responseNoiseEst(aItr, tItr)    = occluding.mwnIdealDetector(noiseImg, target, targetAmpLvls(aItr), uniNoiseMapEst);       
    end
    
    lowNoiseArea = noiseMap == min(unique(noiseMap));
    
	dPrimeMod(aItr) = targetAmpLvls(aItr).*sqrt(sum(target(:).*target(:)./noiseMap(:).^2));
	dPrimeNoise(aItr) = targetAmpLvls(aItr).*sqrt(sum(target(:).*target(:)./uniNoiseMap(:).^2));
    
    dPrimeLowNoise(aItr) = targetAmpLvls(aItr).*sqrt(sum(target(lowNoiseArea).*target(lowNoiseArea)./noiseMap(lowNoiseArea).^2));
end

noisePC    = mean(responseNoise == targetPresent, 2);
modNoisePC = mean(responseModNoise == targetPresent, 2);

noisePCEst    = mean(responseNoiseEst == targetPresent, 2);
modNoisePCEst = mean(responseModNoiseEst == targetPresent, 2);

modNoisePCDPrime = normcdf(dPrimeMod/2);
noisePCDPrime = normcdf(dPrimeNoise/2);
lowNoisePCDPrime = normcdf(dPrimeLowNoise/2);
figure; hold on; axis square; 
plot(targetAmpLvls, [modNoisePC'; modNoisePCEst'], '-o', 'LineWidth', 2);
plot(targetAmpLvls, modNoisePCDPrime', '-k', 'LineWidth', 2);
plot(targetAmpLvls, lowNoisePCDPrime', '--k', 'LineWidth', 2);

ylim([0.4 1]);
xlabel('Target Amplitude');
ylabel('Percent Correct');
title('Modulated White Noise');

legend('Sigma known exactly', 'Estimated sigma');        
legend boxoff;

box off;
set(gca, 'TickDir', 'out' );
set(gcf,'color','w');
set(gca,'fontsize',14);

figure; hold on; axis square; 
plot(targetAmpLvls, [noisePC'; noisePCEst'], '-o', 'LineWidth', 2);
plot(targetAmpLvls, noisePCDPrime', '-k', 'LineWidth', 2);

ylim([0.4 1]);
xlabel('Target Amplitude');
ylabel('Percent Correct');
title('White Noise');

legend('Sigma known exactly', 'Estimated sigma');        
legend boxoff;

box off;
set(gca, 'TickDir', 'out' );
set(gcf,'color','w');
set(gca,'fontsize',14);

k = 1;
    
    
    