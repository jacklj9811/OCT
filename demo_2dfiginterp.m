dbstop if error
current_path = pwd;
cd('D:/OCT/tagged/left1(micron) (1) [MConverter.eu]');
save_location='D:/OCT/tagged/left1(micron) (1) [MConverter.eu]/3dl3.obj';
color_target_edge = [255;13;13];
% fileID = fopen(save_location,'w');
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
	edge_It = edge(It);
	area_It_ori(x) = 0.5 * length(find(edge_It)) + length(find(It)) - 1; % 0.5 * n_edge + n_inside -1
	Ilabel(:,:,x) = double(It);
	Ir(:,:,x) = double(I(:,:,1)); Ig(:,:,x) = double(I(:,:,2)); Ib(:,:,x) = double(I(:,:,3));
end
% volume
volume_ori = sum(area_It_ori) - 0.5 * (area_It_ori(1) + area_It_ori(end)); % (a1+a2)/2+...+(an-1+an)/2
volume = volume_ori * 3258 * 4887 * 4887 / 97 / 384 / 384; % that 1912... still cannot judge where is the bottom of the figure...

fprintf('Volume = %.3f μm^3 = %.3f mm^3.\n', volume, volume/10^9);
% % interpolation 3D 
% [nrow,ncol,nhei] = size(Ir);
% [X,Y,Z] = meshgrid(1:ncol,1:nrow,(1:nhei)*(52.66/97)*(384/79));
% si = (52.66/97)*(384/79);
% [Xq,Yq,Zq] = meshgrid(1:0.5:ncol,1:nrow,(1:(0.5/si):nhei)*si);
% Ir_q = interp3(X,Y,Z,Ir,Xq,Yq,Zq);
% Ig_q = interp3(X,Y,Z,Ig,Xq,Yq,Zq);
% Ib_q = interp3(X,Y,Z,Ib,Xq,Yq,Zq);
% Volume Viewer
% volumeViewer(Ir,Ilabel,'ScaleFactors',[248,237,655]); % 2022.3.26: this 1912...still cannot judge where is the bottom of the figure...
volumeViewer(Ir,Ilabel,'ScaleFactors',[248,248,655]);
% x:y:z=(4887/384):(1912/157):(3258/97)=(248 08041):(237 39392):(654 72768)=248:237:655=12.7266:12.1783:33.5876=10:10:26
% vv = labelvolshow(Ilabel,Ir);
% vv = labelvolshow(Ilabel,Ir,'ScaleFactors',[248,237,655],'CameraUpVector',[-0.009763131303901,-0.999938901125155,0.005184137706553],'CameraViewAngle',15,'VolumeOpacity',0.068966000000000,'VolumeThreshold',0.392156862745098);
% vv.CameraPosition = [-2.377193436613884e+02,-3.449582641876987e+02,-7.391186518907886e+02];
% ,'CameraUpVector',[-0.009763131303901,-0.999938901125155,0.005184137706553],'CameraViewAngle',15,'VolumeOpacity',0.068966000000000,'VolumeThreshold',0.392156862745098

% fclose(fileID);
cd(current_path);