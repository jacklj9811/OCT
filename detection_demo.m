%% Show input
t = Tiff('yy02046.tif','r');
imageData = read(t);
Y = imageData(:,:,1);
Y2 = imageData(:,:,2);
Y3 = imageData(:,:,3);
figure(1);
imshow(imageData);
title('OCT original Image (RGB)');
Y(Y<100) = 0;

%% Algo.s

% 1.显示边界
% bwboundaries(Y);	% 跟踪二值图像中的区域边界
% bwtraceboundary(Y);	% 跟踪二进制图像中的对象
% figure(1);
% visboundaries(Y);

% 2.检测圆圈
% imfindcircles(Y);	% 使用圆形霍夫变换查找圆
% viscircles(Y);	% 创建圈子

% 3.检测边缘和梯度
figure(2)
edge(Y);	% 在强度图像中查找边缘
title('edge(Y)');
% edge3(Y);	% 在 3-D 强度体积中查找边缘
% imgradient(Y);	% 查找二维图像的梯度幅度和方向
figure(3);
imshow(imgradientxy(Y));	% 查找二维图像的方向梯度
title('imgradientxy(Y)');
% imshow(imgradient3(Y));	% 查找 3-D 图像的梯度幅度和方向
figure(4);
imshow(imgradientxyz(Y));	% 查找 3-D 图像的方向梯度
title('imgradientxyz(Y)');

% 4.检测线
BW = edge(Y,'canny');
% hough(Y);	% 霍夫变换
% houghlines(Y);	% 基于霍夫变换提取线段
% houghpeaks(Y);	% 识别霍夫变换中的峰值
% radon(Y);	% 氡变换
% iradon(Y);	% 逆氡变换
[H,T,R] = hough(BW,'RhoResolution',0.5,'Theta',-90:0.5:89);
figure(5);
subplot(2,1,1);
imshow(Y);
title('Y');
subplot(2,1,2);
imshow(imadjust(rescale(H)),'XData',T,'YData',R,...
      'InitialMagnification','fit');
title('Hough transform of Y');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gca,hot);
P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');
hold off;

lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
figure(6), imshow(Y), hold on
title('hough transformation - line detection');
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
hold off;


% 5.使用四叉树分解检测同构块, size of image must satisfies I_size = 2^?x2^?
I = Y(1:512,end-511:end);
S = qtdecomp(I,.27);
blocks = repmat(uint8(0),size(S));
for dim = [512 256 128 64 32 16 8 4 2 1];    
  numblocks = length(find(S==dim));    
  if (numblocks > 0)        
    values = repmat(uint8(1),[dim dim numblocks]);
    values(2:dim,2:dim,:) = 0;
    blocks = qtsetblk(blocks,S,dim,values);
  end
end
blocks(end,1:end) = 1;
blocks(1:end,end) = 1;
figure(7);
imshow(blocks,[]);
title('qtdecomp');
% qtdecomp(Y);	% 四叉树分解
% qtgetblk(Y);	% 四叉树分解中的块值
% qtsetblk(Y);	% 在四叉树分解中设置块值

%% edge detection & selection
BW1 = edge(Y,'canny');
figure(8);
imshow(BW1);
title('canny 1');
BW2 = edge(Y2,'canny');
figure(9);
imshow(BW2);
title('canny 2');
Y2_v2 = Y2;
Y2_v2(BW2) = Y2_v2(BW2).*3;
figure(10);
imshow(Y2_v2);
title('Y2_v2');
BW2_v2 = edge(Y2_v2,'canny');
figure(11);
imshow(BW2_v2);
title('canny 2_v2');
% BW3 = edge(Y3,'canny');
% figure(10);
% imshow(BW3);
% title('canny 3');