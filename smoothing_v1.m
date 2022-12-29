% Idea:
%	     unmoved slice edge count, eye line fit
% Pseudocode:                             __________
% 		 first count fourth fit     first|__________|
%     or second count fourth fit        /       second
% for i in all lines                   /fourth
% 	count black and white
% 	c i = count
% end
% for j in the same c row
% 	ployfit( c j data)
%     model = ployfit
% 	hat j = model( c j data)
% 	hat st j = st(hat j st. to cj)
% end
% 3dshow(hat)
% 3dfig title = 1
% 
% 3dshow(hat st j)
% 3dfig title = 2

c = zeros(size(vid, [1 2 4]));
% second count fourth fit
% second count
for first_i = 1:size(vid,1)
	for fourth_i  = 1:size(vid,4)
		line_i = permute(vid(first_i, :, 1, fourth_i),[2 1 3 4]);
		
		ele_first = line_i(1);
		record_i = 1;
		head_tail = zeros(size(vid,2),1);
		for ele_i = 1:size(line_i)
			ele = line_i(ele_i);
			if ele ~= ele_first
				record_i = record_i + 1;
				ele_first = ele;
			end
			head_tail(record_i) = head_tail(record_i) + 1;
		end
		head_tail = head_tail(find(head_tail));
		tail_head = flip(head_tail);
		htht = zeros(size(head_tail,1)*2,1);
		htht_i = 1;
		for ele_i = 1:size(head_tail)
			htht(htht_i) = head_tail(ele_i);
			htht_i = htht_i + 1;
			htht(htht_i) = tail_head(ele_i);
			htht_i = htht_i + 1;
		end
		c(first_i,1:size(head_tail),fourth_i) = htht(1:size(head_tail));
	end
end
% fourth fit
hat = ones(size(vid, [1 2 4]))*size(vid,2);
for first_i = 1:size(vid,1)
	for second_i = 1:size(vid,2)
		line_i = permute(c(first_i, second_i, :),[3 1 2]);
		valuable_i = find(line_i ~= size(vid,2));
		valuable_line = line_i(valuable_i);
		p = polyfit(1:size(valuable_i),valuable_line,2);
		hat_i = zeros(size(line_i,1),1);
		hat_i = polyval(p,1:size(valuable_i));
		hat_i(find(hat_i<0)) = 0;
		hat_i = round(hat_i);

		hat(first_i,second_i,valuable_i) = hat_i;
	end
end
modelfit = zeros(size(vid, [1 2 4]));
for first_i = 1:size(vid,1)
	for fourth_i  = 1:size(vid,4)
		line_i = permute(hat(first_i, :, fourth_i),[2 1 3]);
		% head_tail recovery + sum(head_tail)==size(vid,2)
		ht_length = max(find(line_i));
		head_tail = zeros(ht_length,1);
		tail_head = zeros(ht_length,1);
		ht_i = 1;
		th_i = 1;
		sumup = 0;
		for ele_i = 1:ht_length
			if sumup >= size(vid,2)
				break;
			end
			ele = line_i(ele_i);
			sumup = sumup + ele;
			if sumup > size(vid,2)
				ele = ele + size(vid,2) - sumup;
			end

			if ht_i == th_i
				head_tail(ht_i) = ele;
				ht_i = ht_i + 1;
			else
				tail_head(th_i) = ele;
				th_i = th_i + 1;
			end
		end
		head_tail = head_tail + flip(tail_head);
		% modelfit recovery
		mf_i = 1;
		val_fitin = 0;
		for ele_i = 1:ht_length
			ele = head_tail(ele_i);
			for loc = 1:ele
				modelfit(first_i,mf_i,fourth_i) = val_fitin;
				mf_i = mf_i + 1;
			end
			if val_fitin == 0
				val_fitin = 1;
			else
				val_fitin = 0;
			end
		end
	end
end
