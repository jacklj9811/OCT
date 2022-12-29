t = Tiff('yy02096.tif','r');
imageData = read(t);
Y = imageData(:,:,1);
imshow(imageData);
title('OCT original Image (RGB)');
