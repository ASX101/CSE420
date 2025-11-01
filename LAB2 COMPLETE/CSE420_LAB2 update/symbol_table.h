#include "scope_table.h"

class symbol_table
{
private:
    scope_table *current_scope;
    int bucket_count;
    int current_scope_id;

public:
    symbol_table(int bucket_count);
    ~symbol_table();
    void enter_scope();
    void exit_scope();
    bool insert(symbol_info* symbol);
    symbol_info* lookup(symbol_info* symbol);
    void print_current_scope();
    void print_all_scopes(ofstream& outlog);
    
    int get_current_scope_id();
    bool is_global_scope();

	

    // you can add more methods if you need 
};

// Constructor: Starts with global scope

symbol_table::symbol_table(int bucket_count)
{
    this->bucket_count = bucket_count;
    current_scope_id = 1;
    current_scope = new scope_table(bucket_count, current_scope_id, NULL);
}


// Destructor: Deletes all scopes
symbol_table::~symbol_table()
{
    while (current_scope != NULL)
    {
        scope_table *temp = current_scope;
        current_scope = current_scope->get_parent_scope();
        delete temp;
    }
}

// Creates a new nested scope

void symbol_table::enter_scope()
{
    current_scope_id++;
    scope_table *new_scope = new scope_table(bucket_count, current_scope_id, current_scope);
    current_scope = new_scope;
}

// Removes the current scope

void symbol_table::exit_scope()
{
    if (current_scope == NULL)
        return;

    scope_table *parent = current_scope->get_parent_scope();
    delete current_scope;
    current_scope = parent;
}



// complete the methods of symbol_table class


// void symbol_table::print_all_scopes(ofstream& outlog)
// {
//     outlog<<"################################"<<endl<<endl;
//     scope_table *temp = current_scope;
//     while (temp != NULL)
//     {
//         temp->print_scope_table(outlog);
//         temp = temp->get_parent_scope();
//     }
//     outlog<<"################################"<<endl<<endl;
// }