function angleNormalized = normalizeAngle(angleRad)  
    % 将大于2*pi的角转换到[0, 2*pi)区间内  
    angleNormalized = mod(angleRad, 2*pi);  
    if angleNormalized < 0  
        % 如果mod的结果小于0，则加上2*pi  
        angleNormalized = angleNormalized + 2*pi;  
    end  
end