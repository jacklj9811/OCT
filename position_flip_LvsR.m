function [fliped_pos] = position_flip_LvsR(pointpos, Y)
	ncol = size(Y,2);
	fliped_pos = [pointpos(1), ncol + 1 - pointpos(2)];
end