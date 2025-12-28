#ifndef _CGEN_H_
#define _CGEN_H_

#include "tree.h"
#include "cool-tree.h"
#include "stringtab.h"
#include "symtab.h"
#include <unordered_map>
#include <vector>

// 寄存器常量定义
#define MAXINT  100000000
#define WORD_SIZE 4
#define LOG_WORD_SIZE 2     // for logical shifts

// 全局字符串表
extern StringTable stringtable;
extern IntTable inttable;
extern BoolTable booltable;
extern StringEntryP stringtable_add_string(char *);
extern IntEntryP inttable_add_string(char *);
extern BoolEntryP booltable_add_string(char *);

// 通用寄存器
#define ZERO "$zero"   // Zero register
#define ACC  "$a0"     // Accumulator
#define T1   "$t1"     // Temporary register 1
#define T2   "$t2"     // Temporary register 2
#define T3   "$t3"     // Temporary register 3
#define SELF "$s0"     // Self pointer register
#define SP   "$sp"     // Stack pointer register
#define FP   "$fp"     // Frame pointer register
#define RA   "$ra"     // Return address register

// 对象布局偏移
#define TAG_OFFSET 0
#define SIZE_OFFSET 1
#define DISPTABLE_OFFSET 2


// 代码生成环境类
class Environment {
public:
    Environment();
    void EnterScope();
    void ExitScope();
    void AddVar(Symbol sym);
    void AddParam(Symbol sym);
    void AddAttrib(Symbol sym);
    int LookUpVar(Symbol sym);
    int LookUpParam(Symbol sym);
    int LookUpAttrib(Symbol sym);
    
    std::vector<std::unordered_map<Symbol, int>> var_scopes;
    std::unordered_map<Symbol, int> param_table;
    std::unordered_map<Symbol, int> attrib_table;
    CgenNode* m_class_node;
    int label_count;
};

// 代码生成类节点
class CgenNode : public class__class {
private: 
    CgenNode *parentnd;                        // Parent of class
    List<CgenNode> *children;                  // Children of class
    std::vector<CgenNode*> inheritance;       // Inheritance chain
    std::vector<attr_class*> m_full_attribs;   // All attributes including inherited ones
    std::unordered_map<Symbol, int> m_attrib_idx_tab; // Attribute name to index mapping
    std::unordered_map<Symbol, int> m_method_idx_tab; // Method name to index mapping
    std::vector<method_class*> m_full_methods; // All methods including inherited ones
    int m_depth;                               // Depth in inheritance tree
    
public:
    void set_depth(int depth) { m_depth = depth; }
    int get_depth() { return m_depth; }
    void add_child(CgenNode *child);
    List<CgenNode> *get_children() { return children; }
    void set_parentnd(CgenNode *parent);
    CgenNode *get_parentnd() { return parentnd; }
    
    std::vector<CgenNode*> GetInheritance();
    std::vector<attr_class*> GetFullAttribs();
    std::vector<method_class*> GetFullMethods();
    std::unordered_map<Symbol, int> GetAttribIdxTab();
    std::unordered_map<Symbol, int> GetMethodIdxTab();
    int GetAttribIdx(Symbol name);
    int GetMethodIdx(Symbol name);
    
    void build_inheritance_tree();
};

// 类表
typedef CgenNode *CgenNodeP;

class CgenClassTable : public SymbolTable<Symbol,CgenNode> {
private:
    List<CgenNode> *nds;
    std::vector<CgenNode*> class_list;
    CgenNode* root; // Root of inheritance tree
    
    void install_basic_classes();
    void install_classes(Classes cs);
    void build_inheritance_tree();
    void compute_method_tables();
    void compute_attrib_tables();

public:
    std::ostream& str;
    int basic_classes_tag;
    int stringclasstag;
    int intclasstag;
    int boolclasstag;
    
    CgenNode* GetClassNode(Symbol name);
    
    CgenClassTable(Classes, std::ostream& str);
    void code();
    void code_constants();
    void code_class_nameTab();
    void code_class_objTab();
    void code_dispatchTabs();
    void code_protObjs();
    void code_class_inits();
    void code_class_methods();
    void code_global_data();
    void code_global_text();
    void code_select_gc();
};

// 寄存器操作函数
void emit_load(const char *dest, int offset, const char *base, std::ostream& s);
void emit_store(const char *src, int offset, const char *base, std::ostream& s);
void emit_load_imm(const char *dest, int imm, std::ostream& s);
void emit_addi(const char *dest, const char *src1, int imm, std::ostream& s);
void emit_add(const char *dest, const char *src1, const char *src2, std::ostream& s);
void emit_sub(const char *dest, const char *src1, const char *src2, std::ostream& s);
void emit_mul(const char *dest, const char *src1, const char *src2, std::ostream& s);
void emit_div(const char *dest, const char *src1, const char *src2, std::ostream& s);
void emit_and(const char *dest, const char *src1, const char *src2, std::ostream& s);
void emit_or(const char *dest, const char *src1, const char *src2, std::ostream& s);
void emit_not(const char *dest, const char *src, std::ostream& s);
void emit_seq(const char *dest, const char *src1, const char *src2, std::ostream& s);
void emit_slt(const char *dest, const char *src1, const char *src2, std::ostream& s);
void emit_slti(const char *dest, const char *src1, int imm, std::ostream& s);
void emit_beq(const char *src1, const char *src2, const char *label, std::ostream& s);
void emit_bne(const char *src1, const char *src2, const char *label, std::ostream& s);
void emit_j(const char *label, std::ostream& s);
void emit_jal(const char *label, std::ostream& s);
void emit_jalr(const char *reg, std::ostream& s);
void emit_jr(const char *reg, std::ostream& s);
void emit_label_def(const char *label, std::ostream& s);
void emit_label_def(int label, std::ostream& s);
void emit_label_ref(const char *label, std::ostream& s);
void emit_label_ref(int label, std::ostream& s);
void emit_push(const char *reg, std::ostream& s);
void emit_pop(const char *reg, std::ostream& s);
void emit_move(const char *dest, const char *src, std::ostream& s);
void emit_li(const char *dest, int imm, std::ostream& s);
void emit_la(const char *dest, const char *label, std::ostream& s);
void emit_blt(const char *src1, const char *src2, const char *label, std::ostream& s);
void emit_ble(const char *src1, const char *src2, const char *label, std::ostream& s);
void emit_bgt(const char *src1, const char *src2, const char *label, std::ostream& s);
void emit_bge(const char *src1, const char *src2, const char *label, std::ostream& s);
void emit_blti(const char *src1, int imm, const char *label, std::ostream& s);
void emit_bgti(const char *src1, int imm, const char *label, std::ostream& s);
void emit_beqi(const char *src1, int imm, const char *label, std::ostream& s);
void emit_bnei(const char *src1, int imm, const char *label, std::ostream& s);
void emit_syscall(int code, std::ostream& s);
void emit_exit(int code, std::ostream& s);
void emit_load_int(const char *dest, int value, std::ostream& s);
void emit_load_bool(const char *dest, bool value, std::ostream& s);
void emit_load_string(const char *dest, const char *str, std::ostream& s);

// 全局变量
extern int lineno;
extern CgenClassTable *codegen_classtable;
extern int labelnum;

#endif