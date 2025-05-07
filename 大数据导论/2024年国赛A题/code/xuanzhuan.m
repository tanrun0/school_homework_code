function new_coords = xuanzhuan(coords, theta, zhong)  
    % coords 是一个 4x2 的矩阵，包含长方形的四个顶点坐标  
    % theta 是旋转的角度(顺时针)，单位为度  
  
    % 将角度转换为弧度  
    theta_rad = deg2rad(theta);  
  
    % 构建旋转矩阵  
    R = [cos(theta_rad), sin(theta_rad); -sin(theta_rad), cos(theta_rad)];  
  
    % 初始化新的坐标矩阵  
    new_coords = zeros(size(coords));  
  
    % 对每个顶点应用旋转矩阵  
    for i = 1:size(coords, 1)  
        % 平移点  
        translated_point = coords(i, :) - [zhong(1), zhong(2)];  
        % 应用旋转矩阵  
        rotated_point = R * translated_point';  
        % 平移回原来的位置  
        new_coords(i, :) = rotated_point' + [zhong(1), zhong(2)];  
    end  
end  

