location = 'D:/OCT/';
cd(location);
filenames = dir([location,'*.tif']);
N = length(filenames);
for i = 1:N
	%% Show input
	t = Tiff(filenames(i).name,'r');
	imageData = read(t);
	Y = imageData(:,:,1);
	Y = Y(1:466,510:880);
	Y = Y.*1.2;
	Y = double(Y)/255;
	Ym = movmean(Y,6,2);
	Ym = Ym';
	Ym = movmean(Ym,6,2);
	Ym = Ym';
	% figure(3);imshow(Ym);
	Ym(Ym<prctile(Ym,25)) = 0;% 35 60
	ec = edge(Ym,'canny');
	judge = Y.*1.2; judge(ec) = 1;
	imwrite(im2uint16(ec), ['D:/OCT/edge/edge_',filenames(i).name]);
	imwrite(im2uint16(judge), ['D:/OCT/judge/judge_',filenames(i).name]);
end