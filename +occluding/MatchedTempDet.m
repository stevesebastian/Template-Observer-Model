%
% noise background
ahi = 64; alo = 2; % split
% ahi = sqrt(alo^2 + ahi^2)/sqrt(2); alo = ahi; %uniform
sz = 301;
z = randn(sz);
for i=1:sz
  for j=1:sz
    if j <= sz/2
      z(i,j) = alo*z(i,j)+128;
    else
      z(i,j) = ahi*z(i,j)+128;
    end
  end
end
%
% raised-cosine-windowed sinewave target
cen = sz/2 + 0.5;   %target center
rad = sz/4;         %target radius
amp = 16;           %target amplitude
freq = 4/rad;       %target frequency cy/pix
t = zeros(sz,sz);
for i=1:sz
  for j=1:sz
    r = ((i-cen)^2 + (j-cen)^2)^0.5;
    if r <= rad
      t(i,j) = amp*0.5*(1+cos(pi()*r/rad))*sin(2*pi()*freq*(i-cen));
    else
      t(i,j) = 0;
    end
    z(i,j) = z(i,j)+t(i,j); %add target to background
  end
end
figure; colormap(gray(256));image(z);axis image;
%
% subtemplate
m = 3;
st = zeros(m,m); 

