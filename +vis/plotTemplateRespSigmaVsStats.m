function plotTemplateRespSigmaVsStats(ImgStats, targetTypeStr, simType, fpOut)
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

if(~exist('fpOut', 'var') || isempty(fpOut))
    bSave = 0;
else
    bSave = 1;
end

if(strcmp(targetTypeStr, 'all'))
    binCenter = [];
    for iTarget = 1:size(ImgStats.Settings.targetKey,2)
        targetIndex = lib.getTargetIndexFromString(ImgStats.Settings,ImgStats.Settings.targetKey{iTarget});
        target = ImgStats.Settings.targets(:,:,targetIndex);
        scaleFactor = sum(target(:).*target(:)); 
    
        tMatch = ImgStats.tMatch(:,:,targetIndex);
        if(strcmp(simType, 'amp'))
            patchIndex = ImgStats.patchIndex{targetIndex};
            binCenter = [binCenter ImgStats.Settings.binCenters.Sa(:,targetIndex)'];
        else
            patchIndex = ImgStats.patchIndexSs{targetIndex};
            binCenter = [binCenter ImgStats.Settings.binCenters.Ss(:,targetIndex)'];
        end
        
    
        tSigma(:,:,:,iTarget) = model.computeTemplateResponseSigma(tMatch, patchIndex, scaleFactor);
    end
else
    targetIndex = lib.getTargetIndexFromString(ImgStats.Settings,targetTypeStr);
    target = ImgStats.Settings.targets(:,:,targetIndex);
    scaleFactor = sum(target(:).*target(:)); 
    
    
    tMatch = ImgStats.tMatch(:,:,targetIndex);
    
    if(strcmp(simType, 'amp'))
        patchIndex = ImgStats.patchIndex{targetIndex};
        binCenter = ImgStats.Settings.binCenters.Sa(:,targetIndex)';
    else
        patchIndex = ImgStats.patchIndexSs{targetIndex};
        binCenter = ImgStats.Settings.binCenters.Ss(:,targetIndex)';
    end
    
    tSigma = model.computeTemplateResponseSigma(tMatch, patchIndex, scaleFactor);

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
                for iTarget = 1:size(ImgStats.Settings.targetKey,2)
                    tSigmaCurr = [tSigmaCurr squeeze(tSigma(lItr, cItr, :, iTarget))'];
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
        
        coeffs = polyfit(binCenter, tSigmaCurr, 1);
        % Get fitted values
        fittedX = linspace(min(binCenter), max(binCenter), 200);
        fittedY = polyval(coeffs, fittedX);
        % Plot the fitted line
        plot(fittedX, fittedY, '-', 'LineWidth', 2, 'Color', c(color,:));
        
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
