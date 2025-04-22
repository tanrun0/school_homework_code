import pandas as pd
import matplotlib.pyplot as plt

# 读取CSV文件
df = pd.read_csv('data.csv')

# 设置字体为中文
plt.rcParams['font.family'] = 'SimSun'

# 绘制平均值的折线图
plt.plot(df['年份'], df['平均值（美元/克）'], 'r-', label='平均值', ms=1.5, lw=1)
# 绘制最高值的折线图
plt.plot(df['年份'], df['最高值（美元/克）'], 'y--', label='最高值', ms=1.5, lw=1)
# 绘制最低值的折线图
plt.plot(df['年份'], df['最低值（美元/克）'], 'g-.', label='最低值', ms=1.5, lw=1)

# 标记最高值中的最大值
max_high_price = df['最高值（美元/克）'].max()
max_high_year = df[df['最高值（美元/克）'] == max_high_price]['年份'].values[0]
plt.scatter(max_high_year, max_high_price, color='yellow', zorder=5)
plt.annotate(f'{max_high_price}', (max_high_year, max_high_price), textcoords="offset points", xytext=(0, 10),
             ha='center')

# 标记最低值中的最大值
max_low_price = df['最低值（美元/克）'].max()
max_low_year = df[df['最低值（美元/克）'] == max_low_price]['年份'].values[0]
plt.scatter(max_low_year, max_low_price, color='green', zorder=5)
plt.annotate(f'{max_low_price}', (max_low_year, max_low_price), textcoords="offset points", xytext=(0, 10), ha='center')

# 起始位置标记一下（平均值中的最小值）
min_avg_price = df['平均值（美元/克）'].min()
min_avg_year = df[df['平均值（美元/克）'] == min_avg_price]['年份'].values[0]
plt.scatter(min_avg_year, min_avg_price, color='red', zorder=5)
plt.annotate(f'{min_avg_price}', (min_avg_year, min_avg_price), textcoords="offset points", xytext=(0, 10), ha='center')

# 标记平均值中的最大值
max_avg_price = df['平均值（美元/克）'].max()
max_avg_year = df[df['平均值（美元/克）'] == max_avg_price]['年份'].values[0]
plt.scatter(max_avg_year, max_avg_price, color='red', zorder=5)
plt.annotate(f'{max_avg_price}', (max_avg_year, max_avg_price), textcoords="offset points", xytext=(0, 10), ha='center')

# 自动调整纵坐标范围
y_min = min(min_avg_price, max_low_price)
y_max = max(max_high_price, max_avg_price)
padding = (y_max - y_min) * 0.1  # 添加一些额外的边距
plt.ylim(y_min - padding, y_max + padding)

# 添加标题和坐标轴标签
plt.title('1969-2024 黄金价格变化')
plt.xlabel('年份')
plt.ylabel('价格（美元/克）')

# 添加图例，用于区分不同曲线
plt.legend()

# 保存图片
plt.savefig('1969-2024 黄金价格变化.png', dpi=600)

# 显示图形
plt.show()