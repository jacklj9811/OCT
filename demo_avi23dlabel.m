dbstop if error
aviloc = 'D:/OCT/newdata/patient_001/left1(micron).avi';
obj = VideoReader(aviloc);
vid = obj.read();
if size(vid,4) >= 1000
	error('Too many picture!!!');
end
% edge detection
color_target_edge = [255;13;13];
Ilabel = zeros(size(vid,[1,2,4])); Ir=Ilabel; Ig=Ir; Ib=Ir;
for x = 1 : size(vid,4)
	I = vid(:,:,:,x);
	It = ones(size(I(:,:,1))).*255;
	It(I(:,:,1)~=255 | I(:,:,2)~=13 | I(:,:,3)~=13) = 0; % need to be changed if color changes
	It = imfill(It);
	Ilabel(:,:,x) = double(It);
	Ir(:,:,x) = double(I(:,:,1)); Ig(:,:,x) = double(I(:,:,2)); Ib(:,:,x) = double(I(:,:,3));
end
% Volume Viewer
% volumeViewer(Ir,Ilabel,'ScaleFactors',[248,237,655]); % 2022.3.26: this 1912...still cannot judge where is the bottom of the figure...
volumeViewer(Ir,Ilabel,'ScaleFactors',[248,248,655]);
