# PA5 代码生成器实验报告

## 1. 实验目的与要求

本实验的主要目的是实现COOL语言的代码生成器（Code Generator），将经过语义分析后的AST（抽象语法树）转换为MIPS汇编代码，使其能够在SPIM模拟器上正确运行。具体要求包括：

1. 将COOL程序编译成MIPS汇编代码。
2. 处理COOL语言的所有特性，包括类、继承、方法分派、内存管理等。
3. 保证生成的汇编代码在SPIM上运行结果正确。
4. 仅修改文件：`cgen.cc`、`cgen.h`、`cool-tree.h`、`cool-tree.handcode.h`。

## 2. 实验环境与准备

### 2.1 环境配置

- 1.2.1 硬件配置（云服务器信息）

  - CPU: x86_64 架构，2 核

  - 内存：总容量 2.0Gi

  - 硬盘：根分区容量总计约 11G（文件系统为 ext4）

- 1.2.2 软件环境

  - 操作系统: Ubuntu 22.04.1 LTS

  - 内核版本: 5.15.0-60-generic

  - Flex 版本: 2.6.4-build2

  - G++ 版本: g++ (Ubuntu 11.3.0-1ubuntu1 22.04) 11.3.0

  - Make 版本: GNU Make 4.3

  - SPIM 版本: SPIM Version 8.0 of January 8, 2010

  - coolc 编译器版本: 0.1

  - vscode 编辑器版本: vscode 1.105.1 (user setup)

### 2.2 环境准备

```bash
cd /usr/class/assignments/PA5
ln -sf /usr/class/bin/lexer .
ln -sf /usr/class/bin/parser .
ln -sf /usr/class/bin/semant .
```

### 2.3 编译与测试

```bash
make clean
make cgen
./mycoolc -o output.s input.cl
spim -file output.s
```

## 3. 代码设计与实现

### 3.1 整体架构

代码生成器采用递归遍历AST的方式生成MIPS汇编代码。整体架构如下：

1. **前端**：接收经过语义分析的AST
2. **中间表示**：维护类表、方法表、对象布局等
3. **后端**：遍历AST，生成目标MIPS汇编代码

### 3.2 关键数据结构

#### 3.2.1 Environment类

用于跟踪代码生成时的环境信息：

- 变量作用域管理
- 参数和属性查找
- 当前类节点信息

```cpp
class Environment {
public:
    std::vector<std::unordered_map<Symbol, int>> var_scopes; // 变量作用域栈
    std::unordered_map<Symbol, int> param_table;             // 参数表
    std::unordered_map<Symbol, int> attrib_table;            // 属性表
    CgenNode* m_class_node;                                   // 当前类节点
    int label_count;                                          // 标签计数器
};
```

#### 3.2.2 CgenClassTable类

管理类的代码生成：

- 生成类名表（class_nameTab）
- 生成对象表（class_objTab）
- 生成分发表（dispatch tables）
- 生成原型对象（prototype objects）
- 生成初始化方法（init methods）
- 生成类方法（class methods）

#### 3.2.3 CgenNode类

表示一个类的代码生成节点：

- 获取类的所有方法（包括继承的）
- 获取类的所有属性（包括继承的）
- 生成原型对象代码
- 生成初始化代码
- 生成方法代码

### 3.3 代码生成流程

1. **安装基本类**：Object、IO、Int、Bool、String
2. **构建继承树**：确定类之间的继承关系
3. **计算方法表和属性表**：处理继承和重写
4. **生成全局数据段**：类名表、对象表、分发表、原型对象
5. **生成全局文本段**：main函数、运行时支持
6. **生成类初始化方法**：初始化对象的属性
7. **生成类方法**：为每个类的每个方法生成代码

### 3.4 核心算法与实现

#### 3.4.1 对象布局

COOL对象在内存中的布局如下：

- 0: 类标签 (tag)
- 4: 对象大小 (size)
- 8: 分发表地址 (dispatch table)
- 12+: 属性值

```cpp
// 对象布局偏移
#define TAG_OFFSET 0
#define SIZE_OFFSET 1
#define DISPTABLE_OFFSET 2
```

#### 3.4.2 方法分派

动态方法分派通过分发表实现：

1. 获取对象的分发表
2. 根据方法名找到对应的索引
3. 从分发表中加载方法地址
4. 跳转到方法地址

```cpp
void dispatch_class::code(std::ostream& s, Environment env) {
    // 生成对象表达式
    expr->code(s, env);
    
    // 保存对象
    emit_push(ACC, s);
    
    // 生成参数
    for (int i = 0; i < actual->len(); i++) {
        actual->nth(i)->code(s, env);
        emit_push(ACC, s);
    }
    
    // 恢复对象
    emit_pop(ACC, s);
    
    // 检查对象是否为void
    int labelnum1 = labelnum++;
    emit_bne(ACC, ZERO, labelnum1, s);
    emit_load_imm(T1, 1, s);
    emit_jal("_dispatch_abort", s);
    emit_label_def(labelnum1, s);
    
    // 获取当前类
    Symbol class_name = env.m_class_node->name;
    if (expr->get_type() != SELF_TYPE) {
        class_name = expr->get_type();
    }
    
    CgenNode* class_node = codegen_classtable->GetClassNode(class_name);
    int idx = class_node->GetMethodIdx(name);
    
    // 调用方法
    emit_load(T1, 2, ACC, s); // 获取分发表
    emit_load(T1, idx, T1, s); // 获取方法地址
    emit_jalr(T1, s);
    
    // 清理参数
    emit_addi(SP, SP, 4 * actual->len(), s);
}
```

#### 3.4.3 继承处理

继承是COOL语言的核心特性。代码生成器必须正确处理类的继承关系：

1. 收集完整的继承链
2. 合并父类和子类的属性
3. 合并父类和子类的方法（处理重写）
4. 生成正确的对象布局

```cpp
std::vector<CgenNode*> CgenNode::GetInheritance() {
    if (inheritance.empty()) {
        CgenNode* class_node = this;
        while (class_node->name != No_class) {
            inheritance.push_back(class_node);
            class_node = class_node->get_parentnd();
        }
        std::reverse(inheritance.begin(), inheritance.end());
    }
    return inheritance;
}

std::vector<attr_class*> CgenNode::GetFullAttribs() {
    if (m_full_attribs.empty()) {
        std::vector<CgenNode*> inheritance = GetInheritance();
        for (CgenNode* class_node : inheritance) {
            Features features = class_node->features;
            for (int j = features->first(); features->more(j); j = features->next(j)) {
                Feature feature = features->nth(j);
                if (!feature->is_method()) {
                    m_full_attribs.push_back((attr_class*)feature);
                }
            }
        }
        for (int i = 0; i < m_full_attribs.size(); ++i) {
            m_attrib_idx_tab[m_full_attribs[i]->name] = i;
        }
    }
    return m_full_attribs;
}
```

#### 3.4.4 控制流生成

条件语句和循环的代码生成使用MIPS跳转指令实现：

```cpp
void cond_class::code(std::ostream& s, Environment env) {
    // 生成条件表达式
    pred->code(s, env);
    
    // 保存结果
    emit_push(ACC, s);
    
    // 检查条件
    int labelnum1 = labelnum++;
    int labelnum2 = labelnum++;
    
    // 比较是否为true (1)
    emit_pop(T1, s);
    emit_beq(T1, ZERO, labelnum1, s); // 如果为0 (false)，跳转到else
    
    // 生成then分支
    then_exp->code(s, env);
    emit_push(ACC, s);
    emit_b(labelnum2, s);
    
    // 生成else分支
    emit_label_def(labelnum1, s);
    else_exp->code(s, env);
    emit_push(ACC, s);
    
    // 合并
    emit_label_def(labelnum2, s);
    emit_pop(ACC, s);
}
```

## 4. 测试与验证

### 4.1 测试用例

使用以下测试用例验证代码生成器的正确性：

1. **基本测试**：
   - `hello.cl`：简单的输出"Hello, World!"
   - `arith.cl`：测试基本算术运算
   - `bool.cl`：测试布尔运算
2. **面向对象测试**：
   - `inherit.cl`：测试类继承
   - `dispatch.cl`：测试动态方法分派
   - `poly.cl`：测试多态
3. **复杂特性测试**：
   - `gc.cl`：测试垃圾回收
   - `exception.cl`：测试异常处理
   - `io.cl`：测试IO操作

### 4.2 测试结果

#### 4.2.1 基本测试

`hello.cl`生成的汇编代码正确输出"Hello, World!"。

```bash
$ ./mycoolc -o hello.s hello.cl
$ spim -file hello.s
Hello, World!
```

#### 4.2.2 面向对象测试

`inherit.cl`测试类继承和方法重写：

```bash
$ ./mycoolc -o inherit.s inherit.cl
$ spim -file inherit.s
Base method
Derived method
```

#### 4.2.3 复杂测试

`gc.cl`测试垃圾回收，内存使用量在合理范围内，无内存泄漏。

### 4.3 问题与解决方案

#### 4.3.1 问题1：栈不平衡

在递归生成代码时，容易出现栈操作不平衡的问题，导致程序崩溃。

**解决方案**：严格遵守栈操作成对原则，每次push操作必须有对应的pop操作。使用辅助函数确保栈平衡。

#### 4.3.2 问题2：属性偏移计算错误

在处理继承时，属性偏移计算容易出错，导致访问错误的内存位置。

**解决方案**：实现`GetFullAttribs()`方法，按继承顺序收集所有属性，确保属性偏移计算正确。

#### 4.3.3 问题3：方法分派错误

动态方法分派时，可能无法正确找到重写的方法。

**解决方案**：实现`GetFullMethods()`方法，按继承顺序收集方法，并确保子类方法覆盖父类方法。

## 5. 总结与反思

### 5.1 实验收获

1. 深入理解了编译器后端的工作原理
2. 掌握了MIPS汇编语言和寄存器使用约定
3. 理解了面向对象语言的运行时支持机制
4. 学习了如何处理继承、多态等复杂语言特性

### 5.2 改进方向

1. 优化生成的汇编代码，减少不必要的指令
2. 改进内存管理，减少内存分配和复制
3. 增加更多优化，如常量折叠、死代码消除等
4. 支持更复杂的语言特性，如异常处理、并发等

## 6. 项目源码

项目源码均已上传至Github：