% 使用 findMinimumB 函数  
left = 0.4; % wide 的下界  
right = 0.6; % wide 的上界 
tolerance = 1e-8; % 搜索停止的容差（可选，根据需要设置） 
r = 4.5;
minwide = findMiniWide(left, right, @is_well_3, r, tolerance);

if ~isnan(minwide)  
    fprintf('满足判断函数的最小值 minwide 是: %.7f\n', minwide);  
else  
    fprintf('在给定的范围内，没有找到满足判断函数的 minwide 值。\n');  
end



