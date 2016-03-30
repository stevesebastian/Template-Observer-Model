function sigmaOut = sixParamLCS(params, Lin,Cin,Sin)

sigmaOut(:,:,:,1) = params(1).*(Lin(:,:,:,1)+params(4)).*(Cin(:,:,:,1)+params(5)).*(Sin(:,:,:,1)+params(6));
sigmaOut(:,:,:,2) = params(2).*(Lin(:,:,:,2)+params(4)).*(Cin(:,:,:,2)+params(5)).*(Sin(:,:,:,2)+params(6));
sigmaOut(:,:,:,3) = params(3).*(Lin(:,:,:,3)+params(4)).*(Cin(:,:,:,3)+params(5)).*(Sin(:,:,:,3)+params(6));