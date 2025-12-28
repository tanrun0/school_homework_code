#ifndef COOL_TREE_HANDCODE_H
#define COOL_TREE_HANDCODE_H

#include "tree.h"
#include "cool-tree.h"
#include "cgen.h"

// 为所有表达式节点添加 code 方法
class program_class;
typedef program_class *Program;

class class__class;
typedef class__class *Class_;

class feature_class;
typedef feature_class *Feature;

class formal_class;
typedef formal_class *Formal;

class expression_class;
typedef expression_class *Expression;

class branch_class;
typedef branch_class *Case;

void program_class::cgen(std::ostream &s);
void class__class::code(std::ostream &s, Environment env);
void method_class::code(std::ostream &s, Environment env);
void attr_class::code_init(std::ostream &s, Environment env);
Expression expression_class::code(std::ostream &s, Environment env);
void expression_class::code_ref(std::ostream &s, Environment env);
void assign_class::code(std::ostream &s, Environment env);
void static_dispatch_class::code(std::ostream &s, Environment env);
void dispatch_class::code(std::ostream &s, Environment env);
void cond_class::code(std::ostream &s, Environment env);
void loop_class::code(std::ostream &s, Environment env);
void typcase_class::code(std::ostream &s, Environment env);
void block_class::code(std::ostream &s, Environment env);
void let_class::code(std::ostream &s, Environment env);
void plus_class::code(std::ostream &s, Environment env);
void sub_class::code(std::ostream &s, Environment env);
void mul_class::code(std::ostream &s, Environment env);
void divide_class::code(std::ostream &s, Environment env);
void neg_class::code(std::ostream &s, Environment env);
void lt_class::code(std::ostream &s, Environment env);
void eq_class::code(std::ostream &s, Environment env);
void leq_class::code(std::ostream &s, Environment env);
void comp_class::code(std::ostream &s, Environment env);
void int_const_class::code(std::ostream &s, Environment env);
void bool_const_class::code(std::ostream &s, Environment env);
void string_const_class::code(std::ostream &s, Environment env);
void new__class::code(std::ostream &s, Environment env);
void isvoid_class::code(std::ostream &s, Environment env);
void no_expr_class::code(std::ostream &s, Environment env);
void object_class::code(std::ostream &s, Environment env);

#endif