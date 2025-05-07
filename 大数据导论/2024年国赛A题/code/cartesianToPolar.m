function Y = cartesianToPolar(x, y)  
    % 计算极径  
    r = sqrt(x.^2 + y.^2);  
      
    % 计算极角（以弧度为单位），注意atan2的使用确保了正确的象限  
    theta = atan2(y, x);  

    Y = [r, theta];
end  