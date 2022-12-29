function imgs_show(imgs,names)
% Inputs:
%
%  imgs = {img,...}
%  names = [...] (e.g.: 0:33, 21:27, etc...)
counter = 0;
len = length(imgs);
screensize = get( groot, 'Screensize' );
for ns_idx = 1:len
	if mod(counter, 12) == 0
		fig = figure('Name', strcat('img',string(names(ns_idx)),'~', string(min([names(ns_idx)+11,names(end)]))));
		set(fig,'Position',screensize);
		fig = tight_subplot(2,6,[.01 .01],[.03 .01],[.01 .01]);
		set(fig,'XTickLabel',''); set(fig,'YTickLabel','');
	end
	axes(fig(mod(counter,12)+1));
	imshow(imgs{ns_idx});title(strcat('img',string(names(ns_idx))));
	counter = counter + 1;
end