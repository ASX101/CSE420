#include "symbol_info.h"

extern ofstream outlog; // Declare the output file stream

class scope_table
{
private:
    int bucket_count;
    int unique_id;
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table;

    int hash_function(string name)
    {
        // write your hash function here
        int hash = 0;
        for (char ch : name)
        {
            hash += ch;
        }
        return hash % bucket_count;
    }

public:
    scope_table();
    scope_table(int bucket_count, int unique_id, scope_table *parent_scope);
    scope_table *get_parent_scope();
    int get_unique_id();
    symbol_info *lookup_in_scope(symbol_info *symbol);
    bool insert_in_scope(symbol_info *symbol);
    bool delete_from_scope(symbol_info *symbol);
    void print_scope_table(std::ostream &outlog);
    ~scope_table();

    // you can add more methods if you need
};

// complete the methods of scope_table class
scope_table::scope_table()
{
    bucket_count = 10;
    unique_id = 1;
    table.resize(bucket_count);
    outlog << "New ScopeTable with ID " << unique_id << " created" << endl
           << endl;
}

scope_table::scope_table(int bucket_count, int unique_id, scope_table *parent_scope)
{
    this->bucket_count = bucket_count;
    this->unique_id = unique_id;
    this->parent_scope = parent_scope;
    table.resize(bucket_count);
    outlog << "New ScopeTable with ID " << unique_id << " created" << endl
           << endl;
}
scope_table::~scope_table()
{
    outlog << "ScopeTable with ID " << unique_id << " removed" << endl
           << endl;
    for (auto &bucket : table)
    {
        for (auto symbol : bucket)
        {
            delete symbol;
        }
        bucket.clear();
    }
    table.clear();
}

scope_table *scope_table::get_parent_scope()
{
    return parent_scope;
}

int scope_table::get_unique_id()
{
    return unique_id;
}

void scope_table::print_scope_table(std::ostream &outlog)
{
    outlog << "ScopeTable # " << unique_id << endl;
    for (int i = 0; i < bucket_count; i++)
    {
        if (!table[i].empty())
        {
            outlog << i << " --> " << endl;
            for (auto current : table[i])
            {
                outlog << "< " << current->getname() << " : " << current->gettype() << " >" << endl;

                if (current->get_is_function())
                {

                    outlog << "Function Definition" << endl;
                    outlog << "Return Type: " << current->get_return_type() << endl;
                    vector<pair<string, string>> params = current->get_parameters();
                    outlog << "Number of Parameters: " << params.size() << endl;
                    outlog << "Parameter Details: ";
                    for (int j = 0; j < params.size(); j++)
                    {
                        outlog << params[j].first << " " << params[j].second;
                        if (j < params.size() - 1)
                            outlog << ", ";
                    }
                    outlog << endl;
                }
                else if (current->get_is_array())
                {
                    outlog << "Array" << endl;
                    outlog << "Type: " << current->get_data_type() << endl;
                    outlog << "Size: " << current->get_array_size() << endl;
                }
                else
                {

                    outlog << "Variable" << endl;
                    outlog << "Type: " << current->get_data_type() << endl;
                }
            }
        }
    }
    outlog << endl;
}

bool scope_table::insert_in_scope(symbol_info *symbol)
{
    if (lookup_in_scope(symbol) != NULL)
    {
        return false;
    }

    int hash_value = hash_function(symbol->getname());
    table[hash_value].push_back(symbol);
    return true;
}

symbol_info *scope_table::lookup_in_scope(symbol_info *symbol)
{
    int hash_val = hash_function(symbol->getname());

    for (symbol_info *current : table[hash_val])
    {
        if (current->getname() == symbol->getname())
        {
            return current;
        }
    }
    return NULL;
}

bool scope_table::delete_from_scope(symbol_info *symbol)
{
    int index = hash_function(symbol->getname());
    // list<symbol_info *> &bucket = table[index];
    auto &bucket = table[index];

    for (auto it = bucket.begin(); it != bucket.end(); ++it)
    {
        if ((*it)->getname() == symbol->getname())
        {
            bucket.erase(it);
            return true;
        }
    }
    return false;
}
