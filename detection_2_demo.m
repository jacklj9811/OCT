%% Show input
% t = Tiff('yy02023.tif','r');
% t = Tiff('yy02045.tif','r');
% t = Tiff('yy02046.tif','r');
% t = Tiff('yy02047.tif','r');
t = Tiff('yy02049.tif','r');
% t = Tiff('yy02065.tif','r');
imageData = read(t);

% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
% Y2 = medfilt2(Y2);
if(false)
	Y = imageData(:,:,1);
	Y2 = imageData(:,:,2);
	Y3 = imageData(:,:,3);
	figure(1);
	imshow(imageData);
	title('OCT original Image (RGB)');
	Y(Y<100) = 0;
	Y2_tmp = medfilt2(Y2,[23,23]);
	Y2(Y2_tmp < 25) = 0;

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
	Y2_v2(BW1) = Y2_v2(BW1).* 1.5;
	Y2_v2(BW2) = Y2_v2(BW2).*3;
	figure(10);
	imshow(Y2_v2);
	title('Y2_v2');
	BW2_v2 = edge(Y2_v2,'canny');
	figure(11);
	imshow(BW2_v2);
	title('canny 2_v2');
end

if(false)
	Y = imageData(:,:,1);
	figure(1); imshow(Y);
	Bright = Y; 
	CertainlyBright=Bright; CertainlyBright(CertainlyBright<80) = 0; CertainlyBright(CertainlyBright>0)=200;%figure(2);imshow(CertainlyBright);
	MaybeB=Bright;MaybeB(MaybeB<40)=0;MaybeB(MaybeB>=80)=0;MaybeB(MaybeB>0)=150;%figure(3);imshow(MaybeB);
	Bright=CertainlyBright+MaybeB;%figure(4);imshow(Bright);
	Dark = Y;
	MaybeD=Dark;MaybeD(MaybeD<15)=0;MaybeD(MaybeD>=40)=0;MaybeD(MaybeD>0)=75;figure(5);imshow(MaybeD);
	All=Bright+MaybeD;figure(6);imshow(All);
	threshold = 75;
	More=medfilt2(All);More(More<threshold)=0;figure(7);imshow(More);% delete small noises
	count = 1;
end

Y = imageData(:,:,1);
Y = Y(1:466,510:880);
Y = double(Y)/255;
figure(1);imshow(Y);
[U,S,V] = svd(Y);
S(30:end,:)=0;
% figure(2);imshow(U*S*V');
Ym = movmean(Y,6,2);
Ym = Ym';
Ym = movmean(Ym,6,2);
Ym = Ym';
% figure(3);imshow(Ym);
Ym(Ym<prctile(Ym,25)) = 0;% 35 60
% Ym = Ym';
% Ym = movmean(Ym,6,2);
% Ym = Ym';
% Ym = movmean(Ym,6,2);
% Ym(Ym<0.02) = 0;
ec = edge(Ym,'canny');
figure(4);imshow(ec);
% figure(8);
% while(1)
% 	More=medfilt2(More);More(More<threshold)=0;
% 	count = count + 1;
% 	if mod(count, 5) == 0
% 		imshow(More);
% 		hhh = 1;
% 	end
% end
% figure(12);
% imshow(edge(Y2_v2));
% title('edge of Y2v2');
% BW3 = edge(Y3,'canny');
% figure(10);
% imshow(BW3);
% title('canny 3');
% Edge Extraction
% length_min = 340;
% rownow = 1;
% while ~length_min(find(Ym(rownow,:)))
% 	rownow = rownow + 1;
% end
% col = find(Ym(rownow,:));
% xy = [rownow, col(1)];
% if Ym(xy(1,1)+1,xy(1,2)-1)
% 	xy(2,:) = [xy(1,1)+1,xy(1,2)-1];
% else
% 	Ym[]
% end
