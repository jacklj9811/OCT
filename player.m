location = 'D:/OCT/';
cd(location);
filenames = dir([location,'*.tif']);
N = length(filenames);
for i = 22:22  % 2 46
	%% Show input
	t = Tiff(filenames(i).name,'r');
	imageData = read(t);
	Y = imageData(:,:,1);
	Y = Y(1:466,510:880);
	Y = Y.*2;
	Y(Y<prctile(Y(Y>0),40)) = 0;
	ori = Y;
	p_ori=ori;p_ori(p_ori>0)=255;
	Y = double(Y)/255;
	gradient_threshold = 0;
	gs = gradient_threshold;
	for i = 1:2
		minusUp=Y(2:end,:)-Y(1:(end-1),:); % lighter positive, darker negative
		minusDown=-minusUp;
		minusLeft=Y(:,2:end)-Y(:,1:(end-1));
		minusRight=-minusLeft;
		minusUL=Y(2:end,2:end)-Y(1:(end-1),1:(end-1));
		minusDR=-minusUL;
		minusUR=Y(2:end,1:(end-1))-Y(1:(end-1),2:end);
		minusDL=-minusUR;
		minusUp=[zeros(1,size(Y,2));minusUp];
		minusDown=[minusDown;zeros(1,size(Y,2))];
		minusLeft=[zeros(size(Y,1),1),minusLeft];
		minusRight=[minusRight,zeros(size(Y,1),1)];
		minusUL=[zeros(1,size(Y,2));zeros((size(Y,1)-1),1),minusUL];
		minusDR=[minusDR,zeros((size(Y,1)-1),1);zeros(1,size(Y,2))];
		minusUR=[zeros(1,size(Y,2));minusUR,zeros((size(Y,1)-1),1)];
		minusDL=[zeros((size(Y,1)-1),1),minusDL;zeros(1,size(Y,2))];
		logic=((minusUp>gs)+(minusDown>gs)+(minusLeft>gs)+(minusRight>gs)+(minusUL>gs)+(minusDR>gs)+(minusUR>gs)+(minusDL>gs))<=2;
		Y(logic)=Y(logic).*2;
		Y(~logic)=Y(~logic).*0.5; 
		Y(Y<prctile(Y(Y>0),30))=0;
		figure(i);
		subplot(2,3,1);imshow(Y);title('Y');
		subplot(2,3,2);tmp=Y;tmp(tmp>0)=1;imshow(tmp);title('Y positive');
		subplot(2,3,3);imshow(edge(Y,'canny'));title('canny');
		subplot(2,3,4);imshow(ori);title("ori");
		subplot(2,3,5);imshow(p_ori);title("positive ori");
		subplot(2,3,6);imshow(edge(ori,'canny'));title('ori canny');
	end
	% imwrite(im2uint16(ec), ['D:/OCT/edge/edge_',filenames(i).name]);
	% imwrite(im2uint16(judge), ['D:/OCT/judge/judge_',filenames(i).name]);
end