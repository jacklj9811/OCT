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

% 1.��ʾ�߽�
% bwboundaries(Y);	% ���ٶ�ֵͼ���е�����߽�
% bwtraceboundary(Y);	% ���ٶ�����ͼ���еĶ���
% figure(1);
% visboundaries(Y);

% 2.���ԲȦ
% imfindcircles(Y);	% ʹ��Բ�λ���任����Բ
% viscircles(Y);	% ����Ȧ��

% 3.����Ե���ݶ�
figure(2)
edge(Y);	% ��ǿ��ͼ���в��ұ�Ե
title('edge(Y)');
% edge3(Y);	% �� 3-D ǿ������в��ұ�Ե
% imgradient(Y);	% ���Ҷ�άͼ����ݶȷ��Ⱥͷ���
figure(3);
imshow(imgradientxy(Y));	% ���Ҷ�άͼ��ķ����ݶ�
title('imgradientxy(Y)');
% imshow(imgradient3(Y));	% ���� 3-D ͼ����ݶȷ��Ⱥͷ���
figure(4);
imshow(imgradientxyz(Y));	% ���� 3-D ͼ��ķ����ݶ�
title('imgradientxyz(Y)');

% 4.�����
BW = edge(Y,'canny');
% hough(Y);	% ����任
% houghlines(Y);	% ���ڻ���任��ȡ�߶�
% houghpeaks(Y);	% ʶ�����任�еķ�ֵ
% radon(Y);	% 뱱任
% iradon(Y);	% ��뱱任
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


% 5.ʹ���Ĳ����ֽ���ͬ����, size of image must satisfies I_size = 2^?x2^?
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
% qtdecomp(Y);	% �Ĳ����ֽ�
% qtgetblk(Y);	% �Ĳ����ֽ��еĿ�ֵ
% qtsetblk(Y);	% ���Ĳ����ֽ������ÿ�ֵ

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