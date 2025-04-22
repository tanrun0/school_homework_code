import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller
from statsmodels.graphics.tsaplots import plot_acf, plot_pacf
from statsmodels.tsa.arima.model import ARIMA
from sklearn.metrics import mean_squared_error, mean_absolute_error

# 读取CSV文件
data = pd.read_csv('data.csv')

# 后续代码保持不变
# 检查缺失值
print(data.isnull().sum())

# 描述性统计分析
print(data.describe())

corr_mean_max = np.corrcoef(data['平均值（美元/克）'], data['最高值（美元/克）'])[0, 1]
corr_mean_min = np.corrcoef(data['平均值（美元/克）'], data['最低值（美元/克）'])[0, 1]
print(f"平均价格与最高值的相关系数: {corr_mean_max}")
print(f"平均价格与最低值的相关系数: {corr_mean_min}")



# 平稳性检验
def adf_test(series):
    result = adfuller(series)
    print('ADF统计量: %f' % result[0])
    print('p值: %f' % result[1])
    print('临界值:')
    for key, value in result[4].items():
        print('\t%s: %.3f' % (key, value))
    if result[1] <= 0.05:
        print("序列平稳")
    else:
        print("序列不平稳")


adf_test(data['平均值（美元/克）'])

# 确定差分阶数
# 假设经过观察和尝试，确定d = 1（实际需根据数据确定）

# 绘制ACF和PACF图确定p和q
plot_acf(data['平均值（美元/克）'].diff(1).dropna(), lags=20)
plt.show()
plot_pacf(data['平均值（美元/克）'].diff(1).dropna(), lags=20)
plt.show()

# 假设根据ACF和PACF图确定p = 1, q = 1（实际需根据数据确定）

# 划分训练集和测试集
train_size = int(len(data) * 0.8)
train_data, test_data = data['平均值（美元/克）'].iloc[:train_size], data['平均值（美元/克）'].iloc[train_size:]

# 训练ARIMA模型
model = ARIMA(train_data, order=(1, 1, 1))
model_fit = model.fit()

# 模型评估
forecast = model_fit.get_forecast(len(test_data))
forecast_mean = forecast.predicted_mean
mse = mean_squared_error(test_data, forecast_mean)
mae = mean_absolute_error(test_data, forecast_mean)
print(f"均方误差: {mse}")
print(f"平均绝对误差: {mae}")

# 预测未来10年价格
n_steps = 10
forecast_future = model_fit.get_forecast(steps=n_steps)
forecast_future_mean = forecast_future.predicted_mean
print("未来10年平均价格预测:")
print(forecast_future_mean)

# 可视化预测结果
plt.figure(figsize=(12, 6))

# 设置图片清晰度
plt.rcParams['figure.dpi'] = 300

# 正常显示中文标签
plt.rcParams['font.sans-serif'] = ['SimHei']
# 正常显示负号
plt.rcParams['axes.unicode_minus'] = False

# 绘制历史数据
plt.plot(data['年份'], data['平均值（美元/克）'], label='历史数据', color='blue')

# 绘制测试集的预测数据
test_index = data['年份'].iloc[train_size:]
plt.plot(test_index, forecast_mean, label='测试集预测', color='orange')

# 生成未来10年的年份索引
last_year = data['年份'].iloc[-1]
future_years = pd.Index(range(last_year + 1, last_year + 1 + n_steps))

# 绘制未来10年的预测数据
plt.plot(future_years, forecast_future_mean, label='未来10年预测', color='green')

# 标注起始和结束位置的值
start_point = forecast_future_mean.iloc[0]
end_point = forecast_future_mean.iloc[-1]
plt.scatter(future_years[0], start_point, color='red', zorder=5)
plt.scatter(future_years[-1], end_point, color='red', zorder=5)
plt.annotate(f'起始值: {start_point:.2f}', (future_years[0], start_point), textcoords="offset points", xytext=(0, 10), ha='center')
plt.annotate(f'结束值: {end_point:.2f}', (future_years[-1], end_point), textcoords="offset points", xytext=(0, 10), ha='center')

plt.title('黄金价格预测')
plt.xlabel('年份')
plt.ylabel('价格(美元/克)')
plt.legend()
plt.grid(True)
plt.show()