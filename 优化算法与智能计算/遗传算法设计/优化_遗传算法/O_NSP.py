class NurseScheduleProblem:
    """
    护士排班问题类
    """

    def __init__(self, hardConstraintPenalty):
        # 硬约束惩罚系数
        self.hardConstraintPenalty = hardConstraintPenalty
        # 8名护士列表
        self.nurses = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
        # 护士的班次偏好 - 早班、午班、晚班
        self.shiftPreference = [[1, 0, 0], [1, 1, 0], [0, 0, 1], [0, 1, 0], [0, 0, 1], [1, 1, 1], [0, 1, 1], [1, 1, 1]]
        # 医院规则：每个班次最少需要的护士数
        self.shiftMin = [2, 2, 1]
        # 医院规则：每个班次最多允许的护士数
        self.shiftMax = [3, 4, 1]
        # 医院规则：每个护士每周最多工作班次数
        self.maxShiftsPerweek = 5
        # 排班周数
        self.weeks = 1
        # 每天班次数
        self.shiftPerDay = 3
        # 每周班次数
        self.shiftsPerWeek = 7 * self.shiftPerDay
        # 排班总长度（基因数）
        self.scheduleLength = len(self.nurses) * self.shiftsPerWeek * self.weeks

    def getCost(self, schedule):
        """
        计算给定排班方案的总成本（违反约束的程度）
        """
        # 将整个排班转换为按护士划分的子排班字典
        numOfGenesPerNurse = self.scheduleLength // len(self.nurses)
        nurseShiftDict = {}  # 空字典
        index = 0
        # 填充字典
        for nurse in self.nurses:
            nurseShiftDict[nurse] = schedule[index: index + numOfGenesPerNurse]
            index += numOfGenesPerNurse

        # 计算各种违反约束的情况
        # 1. 连续工作违反
        # 医院规则1：护士不允许连续工作两个班次
        consecutiveViolations = 0
        # 遍历每个护士的班次
        for shiftsPerNurse in nurseShiftDict.values():
            # 查找两个连续的1（表示连续工作）
            for shift1, shift2 in zip(shiftsPerNurse, shiftsPerNurse[1:]):
                if shift1 == 1 and shift2 == 1:
                    consecutiveViolations += 1

        # 2. 每周班次数违反
        # 医院规则2：护士每周工作班次不超过5次
        shiftsPerWeekViolations = 0
        # 获取每个护士的班次（包含多周排班）
        for shiftsPerNurse in nurseShiftDict.values():
            # 遍历每周排班
            for i in range(self.weeks):
                weelyShifts = shiftsPerNurse[i * self.shiftsPerWeek: (i + 1) * self.shiftsPerWeek]
                if sum(weelyShifts) > self.maxShiftsPerweek:
                    shiftsPerWeekViolations += (sum(weelyShifts) - self.maxShiftsPerweek)

        # 3. 班次护士数违反
        # 医院规则3：每个班次的护士数应在以下范围：
        # 早班：2-3人
        # 午班：2-4人
        # 晚班：1-2人
        nursesPerShiftViolations = 0

        # 创建包含每个班次护士数的列表
        numOfNursesPerShift = [sum(nursesPerShift) for nursesPerShift in zip(*nurseShiftDict.values())]

        # 计算违反情况
        for shiftIndex, numOfNurses in enumerate(numOfNursesPerShift):
            shiftType = shiftIndex % self.shiftPerDay  # 0:早班, 1:午班, 2:晚班
            if numOfNurses > self.shiftMax[shiftType]:
                nursesPerShiftViolations += (numOfNurses - self.shiftMax[shiftType])
            elif numOfNurses < self.shiftMin[shiftType]:
                nursesPerShiftViolations += (self.shiftMin[shiftType] - numOfNurses)

        # 4. 偏好违反
        preferenceViolations = 0
        # 8名护士的偏好
        for nurseIndex, shiftPreference in enumerate(self.shiftPreference):
            # 将每日偏好复制为每周偏好
            nursePreference = shiftPreference * (self.shiftsPerWeek // self.shiftPerDay)
            # 护士的排班
            sheduleOfTheNurse = nurseShiftDict[self.nurses[nurseIndex]]
            # 比较护士偏好和实际排班
            for preference, shedule in zip(nursePreference, sheduleOfTheNurse):
                if preference == 0 and shedule == 1:
                    preferenceViolations += 1

        # 硬约束违反总数（乘以惩罚系数）
        hardContstraintViolations = (
                consecutiveViolations + shiftsPerWeekViolations + nursesPerShiftViolations) * self.hardConstraintPenalty
        # 软约束违反总数（不加惩罚）
        softConstraintViolations = preferenceViolations
        # 总成本
        cost = hardContstraintViolations + softConstraintViolations
        return cost

    # 打印信息。与getCost()几乎相同...
    # 这些代码应该改进...
    def printInfo(self, schedule):
        """
        打印给定排班方案的信息
        """
        # 将整个排班转换为按护士划分的子排班字典
        numOfGenesPerNurse = self.scheduleLength // len(self.nurses)
        nurseShiftDict = {}  # 空字典
        index = 0
        # 填充字典
        for nurse in self.nurses:
            nurseShiftDict[nurse] = schedule[index: index + numOfGenesPerNurse]
            index += numOfGenesPerNurse

        # 打印护士排班字典
        print("每位护士的排班: ")
        for nurse, nurseShedule in nurseShiftDict.items():
            print(nurse, ":", nurseShedule)

        # 计算各种违反约束的情况
        # 1. 连续工作违反
        consecutiveViolations = 0
        for shiftsPerNurse in nurseShiftDict.values():
            for shift1, shift2 in zip(shiftsPerNurse, shiftsPerNurse[1:]):
                if shift1 == 1 and shift2 == 1:
                    consecutiveViolations += 1

        # 打印连续工作违反
        print("连续工作违反次数: ", consecutiveViolations)

        # 2. 每周班次数违反
        shiftsPerWeekViolations = 0
        for shiftsPerNurse in nurseShiftDict.values():
            for i in range(self.weeks):
                weelyShifts = shiftsPerNurse[i * self.shiftsPerWeek: (i + 1) * self.shiftsPerWeek]
                if sum(weelyShifts) > self.maxShiftsPerweek:
                    shiftsPerWeekViolations += (sum(weelyShifts) - self.maxShiftsPerweek)

        # 打印每周班次数违反
        print("每周班次数违反: ", shiftsPerWeekViolations)

        # 3. 班次护士数违反
        nursesPerShiftViolations = 0
        numOfNursesPerShift = [sum(nursesPerShift) for nursesPerShift in zip(*nurseShiftDict.values())]
        for shiftIndex, numOfNurses in enumerate(numOfNursesPerShift):
            shiftType = shiftIndex % self.shiftPerDay
            if numOfNurses > self.shiftMax[shiftType]:
                nursesPerShiftViolations += (numOfNurses - self.shiftMax[shiftType])
            elif numOfNurses < self.shiftMin[shiftType]:
                nursesPerShiftViolations += (self.shiftMin[shiftType] - numOfNurses)

        # 打印班次护士数违反
        print("班次护士数违反: ", nursesPerShiftViolations)

        # 4. 偏好违反
        preferenceViolations = 0
        for nurseIndex, shiftPreference in enumerate(self.shiftPreference):
            nursePreference = shiftPreference * (self.shiftsPerWeek // self.shiftPerDay)
            sheduleOfTheNurse = nurseShiftDict[self.nurses[nurseIndex]]
            for preference, shedule in zip(nursePreference, sheduleOfTheNurse):
                if preference == 0 and shedule == 1:
                    preferenceViolations += 1

        # 打印偏好违反
        print("偏好违反: ", preferenceViolations)

        # 硬约束违反总数（乘以惩罚系数）
        hardContstraintViolations = (
                consecutiveViolations + shiftsPerWeekViolations + nursesPerShiftViolations) * self.hardConstraintPenalty
        # 软约束违反总数（不加惩罚）
        softConstraintViolations = preferenceViolations
        # 总成本
        cost = hardContstraintViolations + softConstraintViolations
        print("总成本: ", cost)


# In[40]:


# 测试护士排班问题
test = NurseScheduleProblem(10)

# In[41]:


import numpy as np

# 生成随机解
randomSolution = np.random.randint(2, size=168)

# In[42]:


# 打印随机解的信息
test.printInfo(randomSolution)

# In[43]:


# 遗传算法流程
import random
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

from deap import base
from deap import creator
from deap import tools
from deap import algorithms

# 问题常数
HARD_CONSTRAINT_PENALTY = 10

# 遗传算法常数
POPULATION_SIZE = 100
P_CROSSOVER = 0.9
P_MUTATION = 0.1
MAX_GENERATIONS = 100
HALL_OF_FAME_SIZE = 5

# 设置随机种子
RANDOM_SEED = 42
random.seed(RANDOM_SEED)

# 创建工具箱
toolbox = base.Toolbox()

# 创建护士排班问题实例
nsp = NurseScheduleProblem(HARD_CONSTRAINT_PENALTY)

# 定义单目标最小化适应度策略
creator.create("FitnessMin", base.Fitness, weights=(-1.0,))

# 创建个体类
# 1) 基于列表创建Individual类，包含适应度
creator.create("Individual", list, fitness=creator.FitnessMin)
# 2) 创建生成基因的算子
toolbox.register("zeroOrOne", random.randint, 0, 1)
# 3) 创建填充染色体的算子
toolbox.register("individualCreator", tools.initRepeat, creator.Individual, toolbox.zeroOrOne, nsp.scheduleLength)
# 4) 创建生成种群的算子
toolbox.register("populationCreator", tools.initRepeat, list, toolbox.individualCreator, POPULATION_SIZE)


# 适应度函数定义
def Cost(individual):
    return nsp.getCost(individual),  # 适应度是元组，所以返回元组


# 注册评估函数
toolbox.register("evaluate", Cost)

# 遗传算子配置
toolbox.register("select", tools.selTournament, tournsize=2)  # 锦标赛选择
toolbox.register("mate", tools.cxTwoPoint)  # 两点交叉
toolbox.register("mutate", tools.mutFlipBit, indpb=1.0 / nsp.scheduleLength)  # 位翻转变异

# 遗传算法流程...
# 生成初始种群
population = toolbox.populationCreator()
# 准备统计对象
stats = tools.Statistics(lambda ind: ind.fitness.values)
stats.register("min", np.min)  # 最小适应度
stats.register("avg", np.mean)  # 平均适应度
# 定义名人堂对象
hof = tools.HallOfFame(HALL_OF_FAME_SIZE)
# 执行遗传算法
population, logbook = algorithms.eaSimple(population, toolbox, cxpb=P_CROSSOVER, mutpb=P_MUTATION,
                                          ngen=MAX_GENERATIONS, stats=stats, halloffame=hof, verbose=True)
# 打印最佳解
best = hof.items[0]
print("最佳解: ", best)
print("最佳适应度: ", best.fitness.values[0])
print()
print("最佳排班: ")
nsp.printInfo(best)

# 提取统计信息
minFitness, meanFitness = logbook.select("min", "avg")

# 绘制统计图表
sns.set_style("whitegrid")
plt.plot(minFitness, color="red", label="Minimum")
plt.plot(meanFitness, color="green", label="Average")
plt.xlabel("Generation")
plt.ylabel("Fitness")
plt.title("Nurse Scheduling Problem - Genetic Algorithm Performance")
plt.legend()
plt.show()