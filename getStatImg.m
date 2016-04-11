function [statImg, hwSize] = getStatImg(ImgStats, imgIndex, statTypeStr, targetTypeIndex)

hwSize = [326, 182];

switch statTypeStr
    case 'L'
        statImg = reshape(ImgStats.L(:,imgIndex), hwSize);
    case 'C'
        statImg = reshape(ImgStats.C(:,imgIndex), hwSize);
    case 'Sa'
        statImg = reshape(ImgStats.Sa(:,imgIndex,targetTypeIndex), hwSize);
    case 'Ss'
        statImg = reshape(ImgStats.Ss(:,imgIndex,targetTypeIndex), hwSize);
end