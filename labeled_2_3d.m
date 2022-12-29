function labeled_2_3d(labeled_data_loc)
% dbstop if error
cd('D:/OCT/tagged/left1(micron) (1) [MConverter.eu]');
save_location='D:/OCT/tagged/left1(micron) (1) [MConverter.eu]/3dl3.obj';
color_target_edge = [255;13;13];
for x = 1 : 97
	if x < 10
		name = strcat('0000',num2str(x));
	elseif x < 100
		name = strcat('000',num2str(x));
	elseif x < 1000
		name = strcat('00',num2str(x));
	elseif x < 10000
		name = strcat('0',num2str(x));
	else
		name = num2str(x);
	end
	I = imread(strcat(name,'.tiff'));
	It = ones(size(I(:,:,1))).*255;
	It(I(:,:,1)~=255 | I(:,:,2)~=13 | I(:,:,3)~=13) = 0; % need to be changed if color changes
	It = imfill(It);
	Ilabel(:,:,x) = double(It);
	Ir(:,:,x) = double(I(:,:,1)); Ig(:,:,x) = double(I(:,:,2)); Ib(:,:,x) = double(I(:,:,3));
end

% Volume Viewer
volumeViewer(Ir,Ilabel,'ScaleFactors',[248,237,655]);
