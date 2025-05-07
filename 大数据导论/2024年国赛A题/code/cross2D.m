function cross_product = cross2D(v1, v2)
    % 计算二维向量的叉乘（实际上是计算行列式）
    cross_product = v1(1) * v2(2) - v1(2) * v2(1);
 end