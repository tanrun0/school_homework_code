function minwide = findMiniWide(left, right, is_well_3, r, tolerance)  
    % left 是下界，right 是上界  
    % 初始化 minwide 为 NaN，表示尚未找到满足条件的最小值  
    minwide = right;  
    
    % 创建一个匿名函数，它将 is_well_3 和 r 结合起来，只接受一个参数 wide  
    isValidFunc = @(wide) is_well_3(wide, r);  
    
    % 二分查找循环  
    while right - left > tolerance  
        mid = (left + right) / 2;  
        if isValidFunc(mid)  
            % 如果 mid 值有效，则尝试缩小范围到左半部分，并更新 minwide  
            right = mid;  
            if mid < minwide  
                minwide = mid;  
            end  
        else  
            % 如果 mid 值无效，则缩小范围到右半部分  
            left = mid;
        end  
    end  
end