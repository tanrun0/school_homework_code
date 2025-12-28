#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include "cgen.h"
#include "cgen_gc.h"

extern void emit_string_constant(std::ostream& str, char *s);

int labelnum = 0; // 全局标签计数器
CgenClassTable *codegen_classtable;

//////////////////////////////////////////////////////////////////////
//
//  CgenNode and CgenClassTable methods
//
//////////////////////////////////////////////////////////////////////

// CgenNode 方法实现
void CgenNode::add_child(CgenNode *child) {
    children->append(child);
}

void CgenNode::set_parentnd(CgenNode *parent) {
    parentnd = parent;
}

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

std::vector<method_class*> CgenNode::GetFullMethods() {
    if (m_full_methods.empty()) {
        std::vector<CgenNode*> inheritance = GetInheritance();
        for (CgenNode* class_node : inheritance) {
            Features features = class_node->features;
            for (int j = features->first(); features->more(j); j = features->next(j)) {
                Feature feature = features->nth(j);
                if (feature->is_method()) {
                    method_class* method = (method_class*)feature;
                    if (m_method_idx_tab.find(method->name) == m_method_idx_tab.end()) {
                        m_full_methods.push_back(method);
                        m_method_idx_tab[method->name] = m_full_methods.size() - 1;
                    }
                }
            }
        }
    }
    return m_full_methods;
}

std::unordered_map<Symbol, int> CgenNode::GetAttribIdxTab() {
    GetFullAttribs(); // 确保已初始化
    return m_attrib_idx_tab;
}

std::unordered_map<Symbol, int> CgenNode::GetMethodIdxTab() {
    GetFullMethods(); // 确保已初始化
    return m_method_idx_tab;
}

int CgenNode::GetAttribIdx(Symbol name) {
    auto it = GetAttribIdxTab().find(name);
    if (it != GetAttribIdxTab().end()) {
        return it->second;
    }
    return -1;
}

int CgenNode::GetMethodIdx(Symbol name) {
    auto it = GetMethodIdxTab().find(name);
    if (it != GetMethodIdxTab().end()) {
        return it->second;
    }
    return -1;
}

void CgenNode::build_inheritance_tree() {
    // 构建继承树
    // ...
}

// CgenClassTable 方法实现
CgenClassTable::CgenClassTable(Classes classes, std::ostream& s) : str(s) {
    stringclasstag = 0; // 分配类标签
    intclasstag = 1;
    boolclasstag = 2;
    basic_classes_tag = 3;
    
    install_basic_classes();
    install_classes(classes);
    build_inheritance_tree();
    
    codegen_classtable = this;
}

void CgenClassTable::install_basic_classes() {
    // 安装基本类：Object, IO, Int, Bool, String
    // ...
}

void CgenClassTable::install_classes(Classes cs) {
    // 安装用户定义的类
    for (int i = cs->first(); cs->more(i); i = cs->next(i)) {
        Class_ c = cs->nth(i);
        CgenNode *node = new CgenNode();
        node->name = c->get_name();
        node->parent = c->get_parent();
        node->features = c->get_features();
        addid(c->get_name(), node);
        class_list.push_back(node);
    }
}

void CgenClassTable::build_inheritance_tree() {
    // 构建继承树
    for (CgenNode* node : class_list) {
        Symbol parent = node->get_parent();
        if (parent == No_class) {
            parent = idtable.add_string("Object");
        }
        CgenNode* parent_node = lookup(parent);
        if (parent_node) {
            node->set_parentnd(parent_node);
            parent_node->add_child(node);
        }
    }
    
    // 设置根节点
    root = lookup(idtable.add_string("Object"));
}

CgenNode* CgenClassTable::GetClassNode(Symbol name) {
    return lookup(name);
}

void CgenClassTable::compute_method_tables() {
    // 计算所有类的方法表
    // ...
}

void CgenClassTable::compute_attrib_tables() {
    // 计算所有类的属性表
    // ...
}

void CgenClassTable::code() {
    compute_method_tables();
    compute_attrib_tables();
    
    if (root) {
        code_global_data();
        code_select_gc();
        code_constants();
        code_class_nameTab();
        code_class_objTab();
        code_dispatchTabs();
        code_protObjs();
        code_global_text();
        code_class_inits();
        code_class_methods();
    }
}

// 各种代码生成函数
void CgenClassTable::code_global_data() {
    str << "\t.data\n";
}

void CgenClassTable::code_select_gc() {
    str << "\t.globl gc_init\n";
    str << "\t.globl gc_collect\n";
    str << "\t.globl _MemMgr_INITIALIZER\n";
    str << "\t.globl _MemMgr_FINALIZER\n";
    str << "\t.globl _MemMgr_ALLOC\n";
    str << "\t.globl _MemMgr_FREE\n";
    str << "\t.globl _MemMgr_FROM_SPACE\n";
    str << "\t.globl _MemMgr_TO_SPACE\n";
    str << "\t.globl _MemMgr_NUM_PAGES\n";
    str << "\t.text\n";
    str << "_MemMgr_NUM_PAGES:\n";
    str << "\t.word 0\n";
    str << "\t.text\n";
}

void CgenClassTable::code_constants() {
    // 添加必需的常量
    stringtable.add_string(""); // 空字符串
    inttable.add_string("0");   // 整数0
    booltable.add_string("0");  // false
    booltable.add_string("1");  // true
    
    // 生成所有字符串常量
    stringtable.code_string_table(str, stringclasstag);
    
    // 生成所有整数常量
    inttable.code_string_table(str, intclasstag);
    
    // 生成布尔常量
    code_bools(boolclasstag);
}

void CgenClassTable::code_class_nameTab() {
    str << "\t.globl class_nameTab\n";
    str << "\t.data\n";
    str << "class_nameTab:\n";
    
    // 为每个类生成类名
    for (CgenNode* node : class_list) {
        str << "\t.word\t";
        emit_string_constant(str, (char*)node->name->get_string());
        str << endl;
    }
}

void CgenClassTable::code_class_objTab() {
    str << "\t.globl class_objTab\n";
    str << "\t.data\n";
    str << "class_objTab:\n";
    
    // 为每个类生成对象
    for (CgenNode* node : class_list) {
        str << "\t.word\t" << node->name << "_protObj" << endl;
    }
}

void CgenClassTable::code_dispatchTabs() {
    // 为每个类生成分发表
    for (CgenNode* node : class_list) {
        str << node->name << DISPTAB_SUFFIX << ":" << endl;
        
        std::vector<method_class*> methods = node->GetFullMethods();
        for (method_class* method : methods) {
            str << "\t.word\t" << method->name << "_" << node->name << endl;
        }
    }
}

void CgenClassTable::code_protObjs() {
    // 为每个类生成原型对象
    for (CgenNode* node : class_list) {
        str << node->name << "_protObj:" << endl;
        
        // 对象头
        str << "\t.word\t" << node->name << "_class_tag" << endl; // tag
        str << "\t.word\t" << node->GetFullAttribs().size() + 3 << endl; // size
        str << "\t.word\t" << node->name << DISPTAB_SUFFIX << endl; // dispatch table
        
        // 属性初始化
        std::vector<attr_class*> attribs = node->GetFullAttribs();
        for (attr_class* attrib : attribs) {
            if (attrib->get_init() == nullptr) {
                str << "\t.word\t0" << endl;
            } else {
                // 使用默认值
                str << "\t.word\t0" << endl;
            }
        }
    }
}

void CgenClassTable::code_class_inits() {
    // 为每个类生成初始化方法
    for (CgenNode* node : class_list) {
        str << node->name << "_init:" << endl;
        
        // 保存返回地址
        emit_push(RA, str);
        
        // 保存self
        emit_push(SELF, str);
        
        // 设置self
        emit_move(SELF, ACC, str);
        
        // 调用父类初始化
        CgenNode* parent = node->get_parentnd();
        if (parent) {
            str << "\tjal\t" << parent->name << "_init" << endl;
            
            // 恢复self
            emit_pop(SELF, str);
        }
        
        // 初始化属性
        std::vector<attr_class*> attribs = node->GetFullAttribs();
        Environment env;
        env.m_class_node = node;
        
        for (attr_class* attrib : attribs) {
            if (attrib->get_parent() == node->name && attrib->get_init() != nullptr) {
                int idx = node->GetAttribIdx(attrib->name);
                attrib->get_init()->code(str, env);
                
                // 存储到属性
                emit_store(ACC, idx + 3, SELF, str);
            }
        }
        
        // 恢复self
        emit_pop(SELF, str);
        
        // 恢复返回地址
        emit_pop(RA, str);
        
        // 返回
        emit_jr(RA, str);
    }
}

void CgenClassTable::code_class_methods() {
    // 为每个类的每个方法生成代码
    for (CgenNode* node : class_list) {
        std::vector<method_class*> methods = node->GetFullMethods();
        Environment env;
        env.m_class_node = node;
        
        for (method_class* method : methods) {
            if (method->get_parent() == node->name) {
                str << method->name << "_" << node->name << ":" << endl;
                
                // 保存帧指针
                emit_push(FP, str);
                emit_move(FP, SP, str);
                
                // 保存self
                emit_push(SELF, str);
                emit_move(SELF, ACC, str);
                
                // 保存返回地址
                emit_push(RA, str);
                
                // 为局部变量分配空间
                emit_addi(SP, SP, -4 * method->formals->len(), str);
                
                // 保存参数
                for (int i = 0; i < method->formals->len(); i++) {
                    Formal formal = method->formals->nth(i);
                    env.AddParam(formal->get_name());
                    emit_store(formal->get_name()->get_string(), i, FP, str);
                }
                
                // 生成方法体代码
                method->get_expr()->code(str, env);
                
                // 恢复栈
                emit_addi(SP, FP, -4, str);
                
                // 恢复返回地址
                emit_pop(RA, str);
                
                // 恢复self
                emit_pop(SELF, str);
                
                // 恢复帧指针
                emit_pop(FP, str);
                
                // 返回
                emit_jr(RA, str);
            }
        }
    }
}

void CgenClassTable::code_global_text() {
    str << "\t.text\n";
    str << "\t.globl main\n";
    str << "main:\n";
    
    // 初始化堆
    str << "\taddiu $sp, $sp, -12\t\t# stack frame for main\n";
    str << "\tsw $fp, 8($sp)\n";
    str << "\tsw $s0, 4($sp)\n";
    str << "\tsw $ra, 0($sp)\n";
    str << "\taddiu $fp, $sp, 8\n";
    str << "\tjal gc_init\n";
    
    // 创建Main对象
    str << "\tjal Object_init\n";
    str << "\tla $a0, Main_protObj\n";
    str << "\tjal Object_copy\n";
    
    // 调用main方法
    str << "\tjal Main_main\n";
    
    // 退出程序
    str << "\tli $v0, 10\n";
    str << "\tsyscall\n";
    
    // 恢复栈
    str << "\tlw $ra, 0($sp)\n";
    str << "\tlw $s0, 4($sp)\n";
    str << "\tlw $fp, 8($sp)\n";
    str << "\taddiu $sp, $sp, 12\n";
}

// Environment 类实现
Environment::Environment() {
    var_scopes.push_back(std::unordered_map<Symbol, int>());
    m_class_node = nullptr;
    label_count = 0;
}

void Environment::EnterScope() {
    var_scopes.push_back(std::unordered_map<Symbol, int>());
}

void Environment::ExitScope() {
    if (var_scopes.size() > 1) {
        var_scopes.pop_back();
    }
}

void Environment::AddVar(Symbol sym) {
    var_scopes.back()[sym] = var_scopes.back().size();
}

void Environment::AddParam(Symbol sym) {
    param_table[sym] = param_table.size();
}

void Environment::AddAttrib(Symbol sym) {
    attrib_table[sym] = attrib_table.size();
}

int Environment::LookUpVar(Symbol sym) {
    for (auto it = var_scopes.rbegin(); it != var_scopes.rend(); ++it) {
        auto found = it->find(sym);
        if (found != it->end()) {
            return found->second;
        }
    }
    return -1;
}

int Environment::LookUpParam(Symbol sym) {
    auto found = param_table.find(sym);
    if (found != param_table.end()) {
        return found->second;
    }
    return -1;
}

int Environment::LookUpAttrib(Symbol sym) {
    auto found = attrib_table.find(sym);
    if (found != attrib_table.end()) {
        return found->second;
    }
    return -1;
}

// 各种表达式的代码生成实现
void assign_class::code(std::ostream& s, Environment env) {
    // 生成右值表达式
    expr->code(s, env);
    
    // 保存结果
    emit_push(ACC, s);
    
    // 获取属性索引
    int idx = env.LookUpAttrib(name);
    if (idx != -1) {
        // 存储到属性
        emit_pop(ACC, s);
        emit_store(ACC, idx + 3, SELF, s);
        emit_move(ACC, ACC, s); // 确保结果在ACC中
    } else {
        // 局部变量
        int var_idx = env.LookUpVar(name);
        if (var_idx != -1) {
            emit_pop(T1, s);
            emit_store(T1, var_idx, FP, s);
            emit_move(ACC, T1, s);
        } else {
            // 参数
            int param_idx = env.LookUpParam(name);
            if (param_idx != -1) {
                emit_pop(T1, s);
                emit_store(T1, param_idx, FP, s);
                emit_move(ACC, T1, s);
            }
        }
    }
}

void static_dispatch_class::code(std::ostream& s, Environment env) {
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
    
    // 调用方法
    CgenNode* class_node = codegen_classtable->GetClassNode(type_name);
    int idx = class_node->GetMethodIdx(name);
    emit_load(T1, 2, ACC, s); // 获取分发表
    emit_load(T1, idx, T1, s); // 获取方法地址
    emit_jalr(T1, s);
    
    // 清理参数
    emit_addi(SP, SP, 4 * actual->len(), s);
}

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

void loop_class::code(std::ostream& s, Environment env) {
    int start_label = labelnum++;
    int end_label = labelnum++;
    
    // 保存循环结束标签
    emit_label_def(start_label, s);
    
    // 生成条件表达式
    pred->code(s, env);
    
    // 检查条件
    emit_beq(ACC, ZERO, end_label, s); // 如果为0 (false)，退出循环
    
    // 生成主体
    body->code(s, env);
    
    // 跳回开始
    emit_b(start_label, s);
    
    // 循环结束
    emit_label_def(end_label, s);
    
    // 返回0 (void)
    emit_load_imm(ACC, 0, s);
}

void typcase_class::code(std::ostream& s, Environment env) {
    // 生成表达式
    expr->code(s, env);
    
    // 保存表达式结果
    emit_push(ACC, s);
    
    // 保存标签
    std::vector<int> case_labels;
    int end_label = labelnum++;
    
    // 为每个分支生成代码
    List<branch_class*> cases = GetCases();
    for (int i = cases->first(); cases->more(i); i = cases->next(i)) {
        branch_class* branch = cases->nth(i);
        int case_label = labelnum++;
        case_labels.push_back(case_label);
        
        // 检查类型
        emit_pop(T1, s); // 恢复表达式结果
        emit_push(T1, s); // 重新保存
        
        // 获取对象标签
        emit_load(T2, TAG_OFFSET, T1, s);
        
        // 比较标签
        CgenNode* branch_class_node = codegen_classtable->GetClassNode(branch->GetType());
        emit_load_imm(T3, branch_class_node->get_class_tag(), s);
        emit_bne(T2, T3, case_label, s);
        
        // 生成分支代码
        Environment case_env = env;
        case_env.EnterScope();
        case_env.AddVar(branch->GetName());
        
        // 将表达式结果存入局部变量
        branch->GetExpr()->code(s, case_env);
        
        // 保存结果
        emit_push(ACC, s);
        
        // 跳转到结束
        emit_b(end_label, s);
        
        // 分支标签
        emit_label_def(case_label, s);
    }
    
    // 默认情况（应该不会执行到）
    emit_load_imm(ACC, 0, s);
    emit_push(ACC, s);
    
    // 结束标签
    emit_label_def(end_label, s);
    emit_pop(ACC, s);
}

void block_class::code(std::ostream& s, Environment env) {
    // 生成所有表达式
    for (int i = body->first(); body->more(i); i = body->next(i)) {
        body->nth(i)->code(s, env);
    }
}

void let_class::code(std::ostream& s, Environment env) {
    Environment let_env = env;
    let_env.EnterScope();
    
    // 生成初始化表达式
    if (init != nullptr) {
        init->code(s, let_env);
    } else {
        emit_load_imm(ACC, 0, s);
    }
    
    // 保存结果
    let_env.AddVar(identifier);
    emit_store(ACC, let_env.LookUpVar(identifier), FP, s);
    
    // 生成主体
    body->code(s, let_env);
    
    // 退出作用域
    let_env.ExitScope();
}

void plus_class::code(std::ostream& s, Environment env) {
    // 生成左操作数
    e1->code(s, env);
    emit_push(ACC, s);
    
    // 生成右操作数
    e2->code(s, env);
    
    // 恢复左操作数
    emit_pop(T1, s);
    
    // 执行加法
    emit_add(ACC, T1, ACC, s);
}

// 类似地实现其他二元操作符

void int_const_class::code(std::ostream& s, Environment env) {
    emit_load_int(ACC, atoi(token->get_string()), s);
}

void bool_const_class::code(std::ostream& s, Environment env) {
    emit_load_bool(ACC, val, s);
}

void string_const_class::code(std::ostream& s, Environment env) {
    emit_load_string(ACC, token->get_string(), s);
}

void new__class::code(std::ostream& s, Environment env) {
    // 分配对象
    CgenNode* class_node = codegen_classtable->GetClassNode(type_name);
    emit_load_imm(ACC, class_node->GetFullAttribs().size() + 3, s); // 对象大小
    emit_jal("_Alloc", s);
    
    // 复制原型对象
    emit_push(ACC, s);
    emit_la(T1, (char*)(type_name->get_string()) + "_protObj", s);
    emit_jal("Object_copy", s);
    emit_pop(T1, s);
    
    // 调用初始化方法
    emit_move(ACC, T1, s);
    emit_jal((char*)(type_name->get_string()) + "_init", s);
}

void isvoid_class::code(std::ostream& s, Environment env) {
    // 生成表达式
    e1->code(s, env);
    
    // 检查是否为0
    emit_seq(ACC, ACC, ZERO, s);
}

void no_expr_class::code(std::ostream& s, Environment env) {
    emit_load_imm(ACC, 0, s);
}

void object_class::code(std::ostream& s, Environment env) {
    if (name == idtable.add_string("self")) {
        emit_move(ACC, SELF, s);
    } else {
        int var_idx = env.LookUpVar(name);
        if (var_idx != -1) {
            emit_load(ACC, var_idx, FP, s);
        } else {
            int param_idx = env.LookUpParam(name);
            if (param_idx != -1) {
                emit_load(ACC, param_idx, FP, s);
            } else {
                int attrib_idx = env.LookUpAttrib(name);
                if (attrib_idx != -1) {
                    emit_load(ACC, attrib_idx + 3, SELF, s);
                }
            }
        }
    }
}

// 辅助函数的实现
void emit_load(const char *dest, int offset, const char *base, std::ostream& s) {
    s << "\tlw\t" << dest << ", " << offset * 4 << "(" << base << ")" << endl;
}

void emit_store(const char *src, int offset, const char *base, std::ostream& s) {
    s << "\tsw\t" << src << ", " << offset * 4 << "(" << base << ")" << endl;
}

void emit_load_imm(const char *dest, int imm, std::ostream& s) {
    s << "\tli\t" << dest << ", " << imm << endl;
}

void emit_addi(const char *dest, const char *src1, int imm, std::ostream& s) {
    if (imm >= 0) {
        s << "\taddi\t" << dest << ", " << src1 << ", " << imm << endl;
    } else {
        s << "\taddi\t" << dest << ", " << src1 << ", -" << -imm << endl;
    }
}

void emit_add(const char *dest, const char *src1, const char *src2, std::ostream& s) {
    s << "\tadd\t" << dest << ", " << src1 << ", " << src2 << endl;
}

void emit_sub(const char *dest, const char *src1, const char *src2, std::ostream& s) {
    s << "\tsub\t" << dest << ", " << src1 << ", " << src2 << endl;
}

void emit_mul(const char *dest, const char *src1, const char *src2, std::ostream& s) {
    s << "\tmul\t" << dest << ", " << src1 << ", " << src2 << endl;
}

void emit_div(const char *dest, const char *src1, const char *src2, std::ostream& s) {
    s << "\tdiv\t" << src1 << ", " << src2 << endl;
    s << "\tmflo\t" << dest << endl;
}

void emit_and(const char *dest, const char *src1, const char *src2, std::ostream& s) {
    s << "\tand\t" << dest << ", " << src1 << ", " << src2 << endl;
}

void emit_or(const char *dest, const char *src1, const char *src2, std::ostream& s) {
    s << "\tor\t" << dest << ", " << src1 << ", " << src2 << endl;
}

void emit_not(const char *dest, const char *src, std::ostream& s) {
    s << "\tnot\t" << dest << ", " << src << endl;
}

void emit_seq(const char *dest, const char *src1, const char *src2, std::ostream& s) {
    int label1 = labelnum++;
    int label2 = labelnum++;
    
    emit_bne(src1, src2, label1, s);
    emit_load_imm(dest, 1, s);
    emit_b(label2, s);
    emit_label_def(label1, s);
    emit_load_imm(dest, 0, s);
    emit_label_def(label2, s);
}

void emit_slt(const char *dest, const char *src1, const char *src2, std::ostream& s) {
    s << "\tslt\t" << dest << ", " << src1 << ", " << src2 << endl;
}

void emit_slti(const char *dest, const char *src1, int imm, std::ostream& s) {
    s << "\tslti\t" << dest << ", " << src1 << ", " << imm << endl;
}

void emit_beq(const char *src1, const char *src2, const char *label, std::ostream& s) {
    s << "\tbeq\t" << src1 << ", " << src2 << ", " << label << endl;
}

void emit_beq(const char *src1, const char *src2, int label, std::ostream& s) {
    s << "\tbeq\t" << src1 << ", " << src2 << ", ";
    emit_label_ref(label, s);
    s << endl;
}

void emit_bne(const char *src1, const char *src2, const char *label, std::ostream& s) {
    s << "\tbne\t" << src1 << ", " << src2 << ", " << label << endl;
}

void emit_bne(const char *src1, const char *src2, int label, std::ostream& s) {
    s << "\tbne\t" << src1 << ", " << src2 << ", ";
    emit_label_ref(label, s);
    s << endl;
}

void emit_j(const char *label, std::ostream& s) {
    s << "\tj\t" << label << endl;
}

void emit_jal(const char *label, std::ostream& s) {
    s << "\tjal\t" << label << endl;
}

void emit_jalr(const char *reg, std::ostream& s) {
    s << "\tjalr\t" << reg << endl;
}

void emit_jr(const char *reg, std::ostream& s) {
    s << "\tjr\t" << reg << endl;
}

void emit_label_def(const char *label, std::ostream& s) {
    s << label << ":" << endl;
}

void emit_label_def(int label, std::ostream& s) {
    s << "label" << label << ":" << endl;
}

void emit_label_ref(const char *label, std::ostream& s) {
    s << label;
}

void emit_label_ref(int label, std::ostream& s) {
    s << "label" << label;
}

void emit_push(const char *reg, std::ostream& s) {
    emit_addi(SP, SP, -4, s);
    emit_store(reg, 0, SP, s);
}

void emit_pop(const char *reg, std::ostream& s) {
    emit_load(reg, 0, SP, s);
    emit_addi(SP, SP, 4, s);
}

void emit_move(const char *dest, const char *src, std::ostream& s) {
    s << "\tmove\t" << dest << ", " << src << endl;
}

void emit_li(const char *dest, int imm, std::ostream& s) {
    s << "\tli\t" << dest << ", " << imm << endl;
}

void emit_la(const char *dest, const char *label, std::ostream& s) {
    s << "\tla\t" << dest << ", " << label << endl;
}

void emit_blt(const char *src1, const char *src2, const char *label, std::ostream& s) {
    s << "\tblt\t" << src1 << ", " << src2 << ", " << label << endl;
}

void emit_ble(const char *src1, const char *src2, const char *label, std::ostream& s) {
    s << "\tble\t" << src1 << ", " << src2 << ", " << label << endl;
}

void emit_bgt(const char *src1, const char *src2, const char *label, std::ostream& s) {
    s << "\tbgt\t" << src1 << ", " << src2 << ", " << label << endl;
}

void emit_bge(const char *src1, const char *src2, const char *label, std::ostream& s) {
    s << "\tbge\t" << src1 << ", " << src2 << ", " << label << endl;
}

void emit_blti(const char *src1, int imm, const char *label, std::ostream& s) {
    s << "\tblti\t" << src1 << ", " << imm << ", " << label << endl;
}

void emit_bgti(const char *src1, int imm, const char *label, std::ostream& s) {
    s << "\tbgti\t" << src1 << ", " << imm << ", " << label << endl;
}

void emit_beqi(const char *src1, int imm, const char *label, std::ostream& s) {
    s << "\tbeqi\t" << src1 << ", " << imm << ", " << label << endl;
}

void emit_bnei(const char *src1, int imm, const char *label, std::ostream& s) {
    s << "\tbnei\t" << src1 << ", " << imm << ", " << label << endl;
}

void emit_syscall(int code, std::ostream& s) {
    s << "\tli\t$v0, " << code << endl;
    s << "\tsyscall" << endl;
}

void emit_exit(int code, std::ostream& s) {
    emit_load_imm("$v0", 10, s);
    emit_syscall(10, s);
}

void emit_load_int(const char *dest, int value, std::ostream& s) {
    // 从整数表中加载常量
    IntEntryP entry = inttable.add_int(value);
    s << "\tlw\t" << dest << ", ";
    entry->code_ref(s);
    s << endl;
}

void emit_load_bool(const char *dest, bool value, std::ostream& s) {
    // 从布尔表中加载常量
    BoolEntryP entry = booltable.add_bool(value);
    s << "\tlw\t" << dest << ", ";
    entry->code_ref(s);
    s << endl;
}

void emit_load_string(const char *dest, const char *str, std::ostream& s) {
    // 从字符串表中加载常量
    StringEntryP entry = stringtable.add_string(str);
    s << "\tlw\t" << dest << ", ";
    entry->code_ref(s);
    s << endl;
}

//
//  Emit methods for various MIPS instructions
//
void StringEntry::code_ref(ostream& s)
{
    s << STRCONST_PREFIX << index;
}

void IntEntry::code_ref(ostream& s)
{
    s << INTCONST_PREFIX << index;
}

void BoolEntry::code_ref(ostream& s)
{
    s << BOOLCONST_PREFIX << index;
}

void StringTable::code_string_table(ostream& s, int stringclasstag)
{
    for (List<StringEntry> *l = tbl; l; l = l->tl())
        l->hd()->code_def(s, stringclasstag);
}

void IntTable::code_string_table(ostream& s, int intclasstag)
{
    for (List<IntEntry> *l = tbl; l; l = l->tl())
        l->hd()->code_def(s, intclasstag);
}

void BoolTable::code_string_table(ostream& s, int boolclasstag)
{
    for (List<BoolEntry> *l = tbl; l; l = l->tl())
        l->hd()->code_def(s, boolclasstag);
}

void StringEntry::code_def(ostream& s, int stringclasstag)
{
    int len = strlen(str);
    IntEntryP lensym = inttable.add_int(len);
    
    // 计算对象大小
    int size = DEFAULT_OBJFIELDS + STRING_SLOTS + (len + 4) / 4;
    
    // GC标记
    s << WORD << "-1" << endl;
    
    // 标签定义
    code_ref(s);
    s << LABEL;
    
    // 类标签
    s << WORD << stringclasstag << endl;
    
    // 对象大小
    s << WORD << size << endl;
    
    // 分发表
    s << WORD << STR << DISPTAB_SUFFIX << endl;
    
    // 字符串长度
    s << WORD;
    lensym->code_ref(s);
    s << endl;
    
    // 字符串数据
    s << ".ascii \""; 
    for (int i = 0; i < len; i++) {
        char c = str[i];
        if (c == '\\' || c == '\"' || c == '\n' || c == '\t' || c == '\b') {
            s << '\\';
            switch (c) {
                case '\\': s << '\\'; break;
                case '\"': s << '\"'; break;
                case '\n': s << 'n'; break;
                case '\t': s << 't'; break;
                case '\b': s << 'b'; break;
                default: s << c;
            }
        } else if (isprint(c)) {
            s << c;
        } else {
            char temp[8];
            snprintf(temp, 8, "\\%03o", (unsigned char)c);
            s << temp;
        }
    }
    s << "\"" << endl;
    
    // 对齐
    s << ALIGN;
}

void IntEntry::code_def(ostream& s, int intclasstag)
{
    // GC标记
    s << WORD << "-1" << endl;
    
    // 标签定义
    code_ref(s);
    s << LABEL;
    
    // 类标签
    s << WORD << intclasstag << endl;
    
    // 对象大小
    s << WORD << DEFAULT_OBJFIELDS + INT_SLOTS << endl;
    
    // 分发表
    s << WORD << INT << DISPTAB_SUFFIX << endl;
    
    // 整数值
    s << WORD << ival << endl;
}

void BoolEntry::code_def(ostream& s, int boolclasstag)
{
    // GC标记
    s << WORD << "-1" << endl;
    
    // 标签定义
    code_ref(s);
    s << LABEL;
    
    // 类标签
    s << WORD << boolclasstag << endl;
    
    // 对象大小
    s << WORD << DEFAULT_OBJFIELDS + BOOL_SLOTS << endl;
    
    // 分发表
    s << WORD << BOOL << DISPTAB_SUFFIX << endl;
    
    // 布尔值 (0或1)
    s << WORD << (val ? 1 : 0) << endl;
}