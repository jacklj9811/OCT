function edges_show(edges,names,imgs)
% Inputs:
%
%  imgs = {img,...}
%  names = [...] (e.g.: 0:33, 21:27, etc...)
counter = 0;
len = length(edges);
screensize = get( groot, 'Screensize' );
for ns_idx = 1:len
	if mod(counter, 12) == 0
		fig = figure('Name', strcat('edge',string(names(ns_idx)),'~', string(min([names(ns_idx)+11,names(end)]))));
		set(fig,'Position',screensize);
		fig = tight_subplot(2,6,[.01 .01],[.03 .01],[.01 .01]);
		set(fig,'XTickLabel',''); set(fig,'YTickLabel','');
	end
	axes(fig(mod(counter,12)+1));
	img = imgs{ns_idx};
	% img(:,:,2) = img(:,:,2) + img(:,:,1); 
	% img(:,:,2) = zeros(size(img(:,:,2)));
	img(:,:,2) = img(:,:,3).*2;
	img(:,:,1) = zeros(size(img(:,:,1)));
	img(:,:,3) = zeros(size(img(:,:,3)));
	tmp = edges{ns_idx};
	for idx = 1:size(tmp,1)
		img(tmp(idx,1),tmp(idx,2),1) = 255;
	end
	imshow(img);title(strcat('edge',string(names(ns_idx))));
	counter = counter + 1;
end

