function testResponseInNoise(template, nTests, imgSize, meanPixel, noiseLow, noiseHigh, winSize)

% nTests = 500;
% imgSize = 101;
% meanPixel = 128;
% noiseLow = 4;
% noiseHigh = 64;

wWin = ones(winSize,winSize);

targetAmp = [13 26 35 50];
% alpha = 0.01:0.01:0.2;
alpha = 0:0.025:0.3;

splitDPrime     = zeros(length(targetAmp), length(alpha));
constantDPrime  = zeros(length(targetAmp), length(alpha));
lowDPrime       = zeros(length(targetAmp), length(alpha));

splitDPrimeT    = zeros(length(targetAmp), length(alpha));
constantDPrimeT = zeros(length(targetAmp), length(alpha));
lowDPrimeT      = zeros(length(targetAmp), length(alpha));


for aItr = 1:length(targetAmp)
    for alphaItr = 1:length(alpha)
   
        target = template.*targetAmp(aItr);
        
        constantNoise  = zeros(nTests,1);
        constantNoiseT = zeros(nTests,1);
        splitNoise     = zeros(nTests,1);
        splitNoiseT    = zeros(nTests,1);
        lowNoise       = zeros(nTests,1);
        lowNoiseT      = zeros(nTests,1);
        
        constantSignal  = zeros(nTests,1);
        constantSignalT = zeros(nTests,1);
        splitSignal     = zeros(nTests,1);
        splitSignalT    = zeros(nTests,1);
        lowSignal       = zeros(nTests,1);
        lowSignalT      = zeros(nTests,1);
        
        for tItr = 1:nTests
            [splitNoiseImg, noiseImg] = ...
                occluding.generateSplitNoiseImage(imgSize, meanPixel, noiseLow, noiseHigh);
            
            lowNoiseImg = occluding.generateSplitNoiseImage(imgSize, meanPixel, noiseLow, noiseLow);

            % Crop noise and take template match on that
            
            CoutSplit = stats.computeSceneContrast(splitNoiseImg, wWin, []);
            Cout = stats.computeSceneContrast(noiseImg, wWin, []);

            [splitNoise(tItr), splitNoiseT(tItr)] = ...
                occluding.computeWeightedTemplateResponse(template, splitNoiseImg, alpha(alphaItr), CoutSplit.Crms);

            [splitSignal(tItr), splitSignalT(tItr)] = ...
                occluding.computeWeightedTemplateResponse(template, splitNoiseImg+target, alpha(alphaItr), CoutSplit.Crms);

            [constantNoise(tItr), constantNoiseT(tItr)] = ...
                occluding.computeWeightedTemplateResponse(template, noiseImg, alpha(alphaItr), Cout.Crms);

            [constantSignal(tItr), constantSignalT(tItr)] = ...
                occluding.computeWeightedTemplateResponse(template, noiseImg+target, alpha(alphaItr), Cout.Crms);   
            
            [~, lowNoiseT(tItr)]  = occluding.computeWeightedTemplateResponse(template, lowNoiseImg, alpha(alphaItr), Cout.Crms);
            [~, lowSignalT(tItr)] = occluding.computeWeightedTemplateResponse(template, lowNoiseImg+target, alpha(alphaItr), Cout.Crms);
            
        end

        splitDPrime(aItr, alphaItr) = abs(mean(splitNoise(:)) - mean(splitSignal(:)))./sqrt((std(splitSignal(:)).^2 + std(splitNoise(:)).^2)./2);
        constantDPrime(aItr, alphaItr) = abs(mean(constantNoise(:)) - mean(constantSignal(:)))./sqrt((std(constantSignal(:)).^2 + std(constantNoise(:)).^2)./2);
        
        splitDPrimeT(aItr, alphaItr) = abs(mean(splitNoiseT(:)) - mean(splitSignalT(:)))./sqrt((std(splitSignalT(:)).^2 + std(splitNoiseT(:)).^2)./2);
        constantDPrimeT(aItr, alphaItr) = abs(mean(constantNoiseT(:)) - mean(constantSignalT(:)))./sqrt((std(constantSignalT(:)).^2 + std(constantNoiseT(:)).^2)./2);
        
        lowDPrimeT(aItr, alphaItr) = abs(mean(lowNoiseT(:)) - mean(lowSignalT(:)))./sqrt((std(lowSignalT(:)).^2 + std(lowNoiseT(:)).^2)./2);

    end
        %%
        figure;
%         plot(alpha, [splitDPrime(aItr,:); constantDPrime(aItr,:); splitDPrimeT(aItr,:); constantDPrimeT(aItr,:); lowDPrimeT(aItr,:)], '-o', 'LineWidth', 2);
        plot(alpha, [splitDPrime(aItr,:); constantDPrime(aItr,:); splitDPrimeT(aItr,:); constantDPrimeT(aItr,:)], '-o', 'LineWidth', 2);
        title(['D Prime vs Alpha. Amplitude: ' num2str(targetAmp(aItr))]);
        xlabel('Alpha Parameter');
        ylabel('D Prime');
        axis square;
        legend('Split Noise cTemplate Model', 'Uniform Noise cTemplate Model', 'Split Noise Template Model', 'Uniform Noise Template Model'); %, 'Low Noise Template Model');
        legend boxoff;
        box off;
        set(gca, 'TickDir', 'out' );
        set(gcf,'color','w');
        set(gca,'fontsize',14);
end

%% Check the template response is the same with standard template
%% Inspect local contrast numbers in the noise to set alpha

% figure; 
% histogram(splitNoiseT); hold on; histogram(constantNoiseT);

% figure; 
% plot(alpha, splitDPrime', '-ko', 'LineWidth', 2);
% title('D Prime vs Alpha');
% xlabel('Alpha');
% ylabel('D Prime');
% axis square; 
% 
% figure; 
% plot(targetAmp, constantDPrimeT', '-ko', 'LineWidth', 2);
% title('D Prime vs Amplitude');
% xlabel('Target Amplitude in pixels');
% ylabel('D Prime');
% axis square; 
% 
% figure; 
% histogram(constantNoiseT); 
% hold on; 
% histogram(constantSignalT);
% axis square;
% title(['Constant Noise, d prime = ' num2str(constantDPrimeT(end))]);
% xlabel('Response');
% ylabel('Count');
% legend({'Noise','Signal + Noise'}, 'box', 'off');
% % 
% % figure; 
% % histogram(splitNoise); 
% % hold on; 
% % histogram(splitSignal);
% % title(['Split Noise, d prime = ' num2str(splitDPrime(end))]);
% % axis square;
% % xlabel('Response');
% % ylabel('Count');
% % legend({'Noise','Signal + Noise'}, 'box', 'off');