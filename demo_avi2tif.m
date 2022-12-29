% obj = VideoReader('D:/OCT/l2r.avi');
obj = VideoReader('D:/OCT/newdata/patient_001/left2(micron).avi');
vid = obj.read();
if size(vid,4) >= 1000
	error('Too many picture!!!');
end
% cd('D:/OCT/l2r');
cd('D:/OCT/newdata/patient_001/left2(micron)/');
for x = 1 : size(vid,4)
	if x-1 < 10
		name = strcat('00',num2str(x-1));
	elseif x-1 < 100
		name = strcat('0',num2str(x-1));
	else
		name = num2str(x-1);
	end
    imwrite(vid(:,:,:,x),strcat('p001mc2_',name,'.tif'));
end
% %% reversed version
% cd('D:/OCT/r2l');
% for x = 1 : size(vid,4)
% 	if size(vid,4) - (x-1) - 1 < 10
% 		name = strcat('00',num2str(size(vid,4) - (x-1) - 1));
% 	elseif size(vid,4) - (x-1) - 1 < 100
% 		name = strcat('0',num2str(size(vid,4) - (x-1) - 1));
% 	else
% 		name = num2str(size(vid,4) - (x-1) - 1);
% 	end
%     imwrite(vid(:,:,:,x),strcat('xx02',name,'.tif'));
% end