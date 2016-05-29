function plotTemplateRespSigmaVsStats(ImgStats, targetTypeStr, modelFunction, params, fpOut)
%% plotTempalteRespSigmaVsStats
%   Plots and save the standard deviation of the tempalte response as a
%   function of each statistic.
%   Input:
%           ImgStats          - structure containing the statistics
%           targetTypeStr            - Target type ('gabor' or 'dog')]
%           fpOut               - Path where plots are saved 
%   Output:
%           None        
%

%% Check variables 

if(nargin < 4)
    bModel = 0;
    modelFunction = [];
    params = [];
else
    bModel = 1;
end

if(~exist('fpOut', 'var') || isempty(fpOut))
    bSave = 0;
else
    bSave = 1;
end

if(strcmp(targetTypeStr, 'all'))
    targetTypeStr = ImgStats.Settings.targetKey;
end

bScale = 1;
%% Get template response sigmas

targetIndex = lib.getTargetIndexFromString(ImgStats.Settings,targetTypeStr);

nTargets = size(targetIndex,2);

tSigma = model.computeTemplateResponseSigma(ImgStats, targetTypeStr, bScale);

%% Get bin values
binCenterStruct = ImgStats.Settings.binCenters;
nBins = 10;

binCenter = [];

for iTarget = targetIndex
    for iLum = 1:nBins
        for iCon  = 1:nBins
            for iSim = 1:nBins
                Lin(iLum,iCon,iSim,iTarget) = binCenterStruct.L(iLum);
                Cin(iLum,iCon,iSim,iTarget) = binCenterStruct.C(iCon);
                Sin(iLum,iCon,iSim,iTarget) = binCenterStruct.Sa(iSim,iTarget);
            end
        end
    end
    binCenter = [binCenter squeeze(Sin(1,1,1:10,iTarget))'];
end

if(bModel) 
    sigmaModel = modelFunction(params,Lin,Cin,Sin);
end

%% Plot

% Similarity
for lItr = 1:10
    figure(lItr); hold on; axis square;
    c = get(gca, 'ColorOrder');
    set(gca, 'TickDir', 'out' );
    set(gcf,'color','w');
    set(gca,'fontsize',14);
    xlabel('Similarity'); 
    ylabel('Scaled template response sigma');
    for cItr = 1:10
        color = mod(cItr, size(c, 1));
        if(color == 0)
            color = 7;
        end
   
        if(strcmp(targetTypeStr, 'all'))
                tSigmaCurr = [];
                tSigmaModel = [];
                for iTarget = 1:size(ImgStats.Settings.targetKey,2)
                    tSigmaCurr = [tSigmaCurr squeeze(tSigma(lItr, cItr, :, iTarget))'];
                    if(bModel)
                        tSigmaModel = [tSigmaModel squeeze(sigmaModel(lItr,cItr,:,iTarget))'];
                    end      
                end
        else
            tSigmaCurr = squeeze(tSigma(lItr, cItr, :))';
        end

        plot(binCenter, tSigmaCurr, 'o', 'LineWidth', 2, 'MarkerSize', 9, 'MarkerFaceColor', c(color,:), 'Color', c(color,:));
        x1 = max(binCenter);
        y1 = max(tSigmaCurr);
        t = text(x1, y1, ['  \leftarrow C = ', num2str(cItr)]);
        t.Color = c(color,:);
        t.FontWeight = 'bold';
        gcaYLim = get(gca, 'ylim');
        
        if(bModel)
            plot(binCenter, tSigmaModel, '-', 'LineWidth', 2, 'MarkerSize', 9, 'MarkerFaceColor', c(color,:), 'Color', c(color,:));
        else
            coeffs = polyfit(binCenter, tSigmaCurr, 1);
            % Get fitted values
            fittedX = linspace(min(binCenter), max(binCenter), 200);
            fittedY = polyval(coeffs, fittedX);
            % Plot the fitted line
            plot(fittedX, fittedY, '-', 'LineWidth', 2, 'Color', c(color,:));
        end
        
    end
	ylim([gcaYLim(2)./-30, gcaYLim(2)]);
    xlim([min(binCenter)-0.02, max(binCenter)+0.03]);
    t = text(binCenter(1)+0.02, gcaYLim(2)-gcaYLim(2)*0.1, ['L = ' num2str(lItr)]);
    t.FontSize = 16;
    t.FontWeight = 'bold';
    if(bSave)
        saveas(gcf, [fpOut '/' num2str(lItr) '.pdf']);
    end
end
