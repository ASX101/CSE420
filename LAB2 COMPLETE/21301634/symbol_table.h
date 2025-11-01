#include "scope_table.h"
#include <iostream>
#include <vector>
#include <string>
#include <utility>

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
    bool insert(symbol_info *symbol);
    symbol_info *lookup(symbol_info *symbol);
    symbol_info *lookup_current_scope(symbol_info *symbol);

    void print_current_scope();
    void print_all_scopes(std::ostream &outlog);

    int get_current_scope_id();
    bool is_global_scope();
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

// Adds a symbol to the current scope
bool symbol_table::insert(symbol_info *symbol)
{
    if (current_scope == NULL)
        return false;
    return current_scope->insert_in_scope(symbol);
}

// Looks for a symbol starting from current scope up to global
symbol_info *symbol_table::lookup(symbol_info *symbol)
{
    scope_table *temp = current_scope;

    while (temp != NULL)
    {
        symbol_info *found = temp->lookup_in_scope(symbol);
        if (found != NULL)
            return found;
        temp = temp->get_parent_scope();
    }

    return NULL;
}

// Looks for a symbol in the current scope only
symbol_info *symbol_table::lookup_current_scope(symbol_info *symbol)
{
    if (current_scope == NULL)
        return NULL;
    return current_scope->lookup_in_scope(symbol);
}

// // Prints only the current scope


void symbol_table::print_current_scope()
{
    if (current_scope != NULL)
    {
        outlog << endl
               << "################################" << endl
               << endl;

        // Print all scopes from current to root
        scope_table *temp = current_scope;
        while (temp != NULL)
        {
            temp->print_scope_table(outlog);
            temp = temp->get_parent_scope();
        }

        outlog << "################################" << endl
               << endl;
    }
}

void symbol_table::print_all_scopes(std::ostream &outlog)
{
    outlog << "Symbol Table" << endl
           << endl;
    outlog << "################################" << endl
           << endl;

    scope_table *temp = current_scope;
    while (temp != NULL)
    {
        temp->print_scope_table(outlog);
        temp = temp->get_parent_scope();
    }

    outlog << "################################" << endl;
}

// Returns current scope ID
int symbol_table::get_current_scope_id()
{
    return current_scope_id;
}

// Checks if currently in global scope
bool symbol_table::is_global_scope()
{
    return current_scope != NULL && current_scope->get_parent_scope() == NULL;
}
