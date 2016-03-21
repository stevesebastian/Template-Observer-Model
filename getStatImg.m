function statImg = getStatImg(ImgStats, imgIndex, statTypeStr, targetTypeIndex)

switch statTypeStr
    case 'L'
        statImg = reshape(ImgStats.L(:,imgIndex), [326 182]);
    case 'C'
        statImg = reshape(ImgStats.C(:,imgIndex), [326 182]);
    case 'Sa'
        statImg = reshape(ImgStats.Sa(:,imgIndex,targetTypeIndex), [326 182]);
    case 'Ss'
        statImg = reshape(ImgStats.Sa(:,imgIndex,targetTypeIndex), [326 182]);
end