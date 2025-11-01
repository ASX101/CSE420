%{
	#include "symbol_table.h"

	#define YYSTYPE symbol_info *

	extern FILE *yyin;
	int yyparse(void);
	int yylex(void);
	extern YYSTYPE yylval;

	// symbol table here.
	symbol_table *table;

	// global variables
	string current_type;
	string current_func_name;
	string current_func_return_type;
	vector<pair<string, string>> current_func_params;

	// helper flags
	bool is_function_definition = false;
	bool error_found = false;

	int lines = 1;
	int errorCount = 0;

	string currentFunction = "global";

	ofstream outlog;
	ofstream outerror;


	// you may declare other necessary variables here to store necessary info
	// such as current variable type, variable list, function name, return type, function parameter types, parameters names etc.

	void yyerror(string s)
	{
		outerror << "At line :" << lines << " " << s << endl
			   << endl;
		error_found = true;
		errorCount++;
	}



	// check for function declaration
	bool is_function_declared(string name)
	{
		symbol_info *temp = new symbol_info(name, "ID");
		symbol_info *found = table->lookup(temp);
		delete temp;
		return found != NULL && found->get_is_function();
	}

	// check for variable in current scope
	bool is_variable_declared_current_scope(string name)
	{
		symbol_info *temp = new symbol_info(name, "ID");
		symbol_info *found = table->lookup_current_scope(temp);
		delete temp;
		return found != NULL;
	}	


	set<string> func_done;
%}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN ADDOP MULOP INCOP DECOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON CONST_INT CONST_FLOAT ID

%nonassoc LOWER_THAN_ELSE 
%nonassoc ELSE

%%

start : program
{
	outlog << "At line no: " << lines << " start : program " << endl
		   << endl;
	outlog << "Symbol Table" << endl
		   << endl;
	table->print_all_scopes(outlog);
};

program : program unit
{
	outlog << "At line no: " << lines << " program : program unit " << endl
		   << endl;
	outlog << $1->getname() + "\n" + $2->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + "\n" + $2->getname(), "program");
}
| unit
{
	outlog << "At line no: " << lines << " program : unit " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "program");
};

unit : var_declaration
{
	outlog << "At line no: " << lines << " unit : var_declaration " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "unit");
}
| func_definition
{
	outlog << "At line no: " << lines << " unit : func_definition " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "unit");
};

func_definition : type_specifier ID LPAREN parameter_list RPAREN
{
	// Insert function into symbol table before parsing the compound statement
	currentFunction=$2->getname();
	symbol_info* t = table->lookup($2);
	if(t == NULL){
		if (!is_function_declared($2->getname()))
		{
			vector<pair<string, string>> params = current_func_params;
			symbol_info *func = new symbol_info($2->getname(), "ID", $1->getname());
			func->set_as_function($1->getname(), params);
			table->insert(func);
		}
	}	
	else{
		outlog << "ZAZAZAZA" << endl;
		symbol_info* temp = table->lookup($2);
		for(auto i : func_done){
			if(i == currentFunction){
				yyerror("Multiple declaration of function "+currentFunction);
			}
		}
		if(temp->gettype() != "func"){
			yyerror("Multiple declaration of function "+currentFunction);
		}
		else {
        vector<pair<string, string>> v = temp->get_parameters();

        	if ($1->getname() != temp->get_return_type()) {
            yyerror("Return type mismatch with function declaration in function " + temp->getname());
        	}
    
		}
	}
	
}
compound_statement
{
	outlog << "At line no: " << lines << " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n";
	outlog << $1->getname() << " " << $2->getname() << "(" << $4->getname() << ")\n"
		   << $7->getname() << "\n\n";

	$$ = new symbol_info(
		$1->getname() + " " + $2->getname() + "(" + $4->getname() + ")\n" + $7->getname(),
		"func_def");

	// Clear function parameters for future use
	current_func_params.clear();
}

| type_specifier ID LPAREN RPAREN
{
	// Insert function with no parameters
	currentFunction=$2->getname();
	if (!is_function_declared($2->getname()))
	{
		vector<pair<string, string>> params;
		symbol_info *func = new symbol_info($2->getname(), "ID", $1->getname());
		func->set_as_function($1->getname(), params);
		table->insert(func);
	}
	else{
		symbol_info* temp = table->lookup($2);
				if(temp->gettype() != "func"){
					yyerror("Multiple declaration of function "+currentFunction);
				}
	}
}
compound_statement
{
	outlog << "At line no: " << lines << " func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n";
	outlog << $1->getname() << " " << $2->getname() << "()\n"
		   << $6->getname() << "\n\n";

	$$ = new symbol_info(
		$1->getname() + " " + $2->getname() + "()\n" + $6->getname(),
		"func_def");
};

parameter_list : parameter_list COMMA type_specifier ID
{
	outlog << "At line no: " << lines << " parameter_list : parameter_list COMMA type_specifier ID " << endl
		   << endl;
	outlog << $1->getname() << "," << $3->getname() << " " << $4->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + "," + $3->getname() + " " + $4->getname(), "param_list");

	// store the necessary information about the function parameters
	pair<string, string> param($3->getname(), $4->getname());
	current_func_params.push_back(param);
	// They will be needed when you want to enter the function into the symbol table
}
| parameter_list COMMA type_specifier
{
	outlog << "At line no: " << lines << " parameter_list : parameter_list COMMA type_specifier " << endl
		   << endl;
	outlog << $1->getname() << "," << $3->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + "," + $3->getname(), "param_list");

	// store the necessary information about the function parameters

	pair<string, string> param($3->getname(), "");
	current_func_params.push_back(param);
	// They will be needed when you want to enter the function into the symbol table
}
| type_specifier ID
{
	outlog << "At line no: " << lines << " parameter_list : type_specifier ID " << endl
		   << endl;
	outlog << $1->getname() << " " << $2->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + " " + $2->getname(), "param_list");

	// store the necessary information about the function parameters
	pair<string, string> param($1->getname(), $2->getname());
	current_func_params.push_back(param);
	// They will be needed when you want to enter the function into the symbol table
}
| type_specifier
{
	outlog << "At line no: " << lines << " parameter_list : type_specifier " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "param_list");

	// store the necessary information about the function parameters
	pair<string, string> param($1->getname(), "");
	current_func_params.push_back(param);
	// They will be needed when you want to enter the function into the symbol table
};

compound_statement : LCURL
{
	// Enter a new scope
	table->enter_scope();

	// Add function parameters to the current scope, if any
	if (!current_func_params.empty())
	{
		for (auto param : current_func_params)
		{
			if (!param.second.empty())
			{
				symbol_info *param_symbol = new symbol_info(param.second, "ID", param.first);
				table->insert(param_symbol);
			}
		}
	}
}
statements RCURL
{
	outlog << "At line no: " << lines << " compound_statement : LCURL statements RCURL\n\n";
	outlog << "{\n"
		   << $3->getname() << "\n}\n\n";

	// Print the current scope (symbol table) before exiting
	table->print_current_scope();

	// Exit the current scope
	table->exit_scope();

	$$ = new symbol_info("{\n" + $3->getname() + "\n}", "comp_stmnt");
}

| LCURL
{
	// Enter a new scope
	table->enter_scope();
}
RCURL
{
	outlog << "At line no: " << lines << " compound_statement : LCURL RCURL\n\n";
	outlog << "{\n}\n\n";

	// Print the current scope (symbol table) before exiting
	table->print_current_scope();

	// Exit the current scope
	table->exit_scope();

	$$ = new symbol_info("{\n}", "comp_stmnt");
};

var_declaration : type_specifier declaration_list SEMICOLON
{
	outlog << "At line no: " << lines << " var_declaration : type_specifier declaration_list SEMICOLON " << endl
		   << endl;
	outlog << $1->getname() << " " << $2->getname() << ";" << endl
		   << endl;

	$$ = new symbol_info($1->getname() + " " + $2->getname() + ";", "var_dec");

	// Insert necessary information about the variables in the symbol table
	current_type = $1->getname();

	if (current_type == "void")
	{
		yyerror("Variable type cannot be void");
	}
};

type_specifier : INT
{
	outlog << "At line no: " << lines << " type_specifier : INT " << endl
		   << endl;
	outlog << "int" << endl
		   << endl;

	$$ = new symbol_info("int", "type");
}
| FLOAT
{
	outlog << "At line no: " << lines << " type_specifier : FLOAT " << endl
		   << endl;
	outlog << "float" << endl
		   << endl;

	$$ = new symbol_info("float", "type");
}
| VOID
{
	outlog << "At line no: " << lines << " type_specifier : VOID " << endl
		   << endl;
	outlog << "void" << endl
		   << endl;

	$$ = new symbol_info("void", "type");
};


declaration_list : declaration_list COMMA ID
{
	outlog << "At line no: " << lines << " declaration_list : declaration_list COMMA ID " << endl
		   << endl;
	outlog << $1->getname() + "," << $3->getname() << endl
		   << endl;
	$$ = new symbol_info($1->getname() + "," + $3->getname(), "decl_list");

	// you may need to store the variable names to insert them in symbol table here or later
	if (is_variable_declared_current_scope($3->getname()))
	{

		yyerror("Multiple declaration of variable "+$3->getname());
	}
	else
	{
		// Create and insert new variable
		symbol_info *new_var = new symbol_info($3->getname(), "ID", current_type);
		table->insert(new_var);
		$$ = new symbol_info($1->getname() + "," + $3->getname(), "decl_list");
	}
}
     
| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD // array after some declaration
{
	outlog << "At line no: " << lines << " declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD " << endl
		   << endl;
	outlog << $1->getname() + "," << $3->getname() << "[" << $5->getname() << "]" << endl
		   << endl;
	$$ = new symbol_info($1->getname() + "," + $3->getname() + "[" + $5->getname() + "]", "decl_list");

	// you may need to store the variable names to insert them in symbol table here or later
	if (is_variable_declared_current_scope($3->getname()))
	{
		yyerror("Multiple declaration of variable "+$3->getname());
	
	}
	else
	{
		// Create and insert new array
		int size = stoi($5->getname());
		symbol_info *new_array = new symbol_info($3->getname(), "ID", current_type, size);
		table->insert(new_array);
		$$ = new symbol_info($1->getname() + "," + $3->getname() + "[" + $5->getname() + "]", "decl_list");
	}
}
| ID
{
	outlog << "At line no: " << lines << " declaration_list : ID " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;
	$$ = new symbol_info($1->getname(), "decl_list");

	// you may need to store the variable names to insert them in symbol table here or later
	if (is_variable_declared_current_scope($1->getname()))
	{
		yyerror("Multiple declaration of variable "+$1->getname());
	}
	else
	{
		// Create and insert new variable
		symbol_info *new_var = new symbol_info($1->getname(), "ID", current_type);
		table->insert(new_var);
		$$ = new symbol_info($1->getname(), "decl_list");
	}
}
| ID LTHIRD CONST_INT RTHIRD // array
{
	outlog << "At line no: " << lines << " declaration_list : ID LTHIRD CONST_INT RTHIRD " << endl
		   << endl;
	outlog << $1->getname() << "[" << $3->getname() << "]" << endl
		   << endl;
	$$ = new symbol_info($1->getname() + "[" + $3->getname() + "]", "decl_list");

	// you may need to store the variable names to insert them in symbol table here or later
	if (is_variable_declared_current_scope($1->getname()))
	{
		yyerror("Multiple declaration of variable "+$1->getname());
	}
	else
	{
		// Create and insert new array
		int size = stoi($3->getname());
		symbol_info *new_array = new symbol_info($1->getname(), "ID", current_type, size);
		table->insert(new_array);
		$$ = new symbol_info($1->getname() + "[" + $3->getname() + "]", "decl_list");
	}
};

statements : statement
{
	outlog << "At line no: " << lines << " statements : statement " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "stmnts");
}
| statements statement
{
	outlog << "At line no: " << lines << " statements : statements statement " << endl
		   << endl;
	outlog << $1->getname() << "\n"
		   << $2->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + "\n" + $2->getname(), "stmnts");
};

statement : var_declaration
{
	outlog << "At line no: " << lines << " statement : var_declaration " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "stmnt");
}
| func_definition
{
	outlog << "At line no: " << lines << " statement : func_definition " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "stmnt");
}
| expression_statement
{
	outlog << "At line no: " << lines << " statement : expression_statement " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "stmnt");
}
| compound_statement
{
	outlog << "At line no: " << lines << " statement : compound_statement " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "stmnt");
}
| FOR LPAREN expression_statement expression_statement expression RPAREN statement
{
	outlog << "At line no: " << lines << " statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement " << endl
		   << endl;
	outlog << "for(" << $3->getname() << $4->getname() << $5->getname() << ")\n"
		   << $7->getname() << endl
		   << endl;

	$$ = new symbol_info("for(" + $3->getname() + $4->getname() + $5->getname() + ")\n" + $7->getname(), "stmnt");
}
| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
{
	outlog << "At line no: " << lines << " statement : IF LPAREN expression RPAREN statement " << endl
		   << endl;
	outlog << "if(" << $3->getname() << ")\n"
		   << $5->getname() << endl
		   << endl;

	$$ = new symbol_info("if(" + $3->getname() + ")\n" + $5->getname(), "stmnt");
}
| IF LPAREN expression RPAREN statement ELSE statement
{
	outlog << "At line no: " << lines << " statement : IF LPAREN expression RPAREN statement ELSE statement " << endl
		   << endl;
	outlog << "if(" << $3->getname() << ")\n"
		   << $5->getname() << "\nelse\n"
		   << $7->getname() << endl
		   << endl;

	$$ = new symbol_info("if(" + $3->getname() + ")\n" + $5->getname() + "\nelse\n" + $7->getname(), "stmnt");
}
| WHILE LPAREN expression RPAREN statement
{
	outlog << "At line no: " << lines << " statement : WHILE LPAREN expression RPAREN statement " << endl
		   << endl;
	outlog << "while(" << $3->getname() << ")\n"
		   << $5->getname() << endl
		   << endl;

	$$ = new symbol_info("while(" + $3->getname() + ")\n" + $5->getname(), "stmnt");
}
| PRINTLN LPAREN ID RPAREN SEMICOLON
{
	outlog << "At line no: " << lines << " statement : PRINTLN LPAREN ID RPAREN SEMICOLON " << endl
		   << endl;
	outlog << "printf(" << $3->getname() << ");" << endl
		   << endl;

	$$ = new symbol_info("printf(" + $3->getname() + ");", "stmnt");
	
	symbol_info* t = table->lookup($3);
	if(t == NULL){
		yyerror("Undeclared variable: "+$3->getname());
		}	

}
| RETURN expression SEMICOLON
{
	outlog << "At line no: " << lines << " statement : RETURN expression SEMICOLON " << endl
		   << endl;
	outlog << "return " << $2->getname() << ";" << endl
		   << endl;

	$$ = new symbol_info("return " + $2->getname() + ";", "stmnt");
};

expression_statement : SEMICOLON
{
	outlog << "At line no: " << lines << " expression_statement : SEMICOLON " << endl
		   << endl;
	outlog << ";" << endl
		   << endl;

	$$ = new symbol_info(";", "expr_stmt");
}
| expression SEMICOLON
{
	outlog << "At line no: " << lines << " expression_statement : expression SEMICOLON " << endl
		   << endl;
	outlog << $1->getname() << ";" << endl
		   << endl;

	$$ = new symbol_info($1->getname() + ";", "expr_stmt");
};

variable : ID
{
	outlog << "At line no: " << lines << " variable : ID " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;
	symbol_info* t = table->lookup($1);
	if(t == NULL){
				yyerror("Undeclared variable: "+$1->getname());
				$$ = new symbol_info($1->getname(), "varbl");
				}
	else{
		if(t->get_is_array() == true){
			yyerror("variable is of array type : "+$1->getname());
			$$ = new symbol_info($1->getname(), "array");
			
		}
		
	}

	
}
| ID LTHIRD expression RTHIRD
{
	outlog << "At line no: " << lines << " variable : ID LTHIRD expression RTHIRD " << endl
		   << endl;
	outlog << $1->getname() << "[" << $3->getname() << "]" << endl
		   << endl;
	symbol_info* t = table->lookup($1);
	if(t == NULL){
				yyerror("Undeclared function: "+$1->getname());
				$$ = new symbol_info($1->getname() + "[" + $3->getname() + "]", "array");
				}
	else{
			
		if(t->get_is_array()==false){
			yyerror("variable is not of array type : "+$1->getname());
		}
		if(t->get_data_type()=="FLOAT"){
				yyerror("array index is not of integer type : "+$1->getname());	
		}
		
	}			

};

// expression : logic_expression
// {
// 	outlog << "At line no: " << lines << " expression : logic_expression " << endl
// 		   << endl;
// 	outlog << $1->getname() << endl
// 		   << endl;

// 	$$ = new symbol_info($1->getname(), "expr");
// }
// | variable ASSIGNOP logic_expression
// {
// 	outlog << "At line no: " << lines << " expression : variable ASSIGNOP logic_expression " << endl
// 		   << endl;
// 	outlog << $1->getname() << "=" << $3->getname() << endl
// 		   << endl;

// 	if($1->get_data_type()=="void" && $3->get_data_type()!="void" ){
// 			yyerror("operation on void type");
		
// 	}
// 	else if(($1->get_data_type()!="FLOAT") && ($1->get_data_type() != $3->get_data_type())){
// 		yyerror("Warning: Assignment of float value into variable of integer type");
			
// 	}
	
	

// 	$$ = new symbol_info($1->getname() + "=" + $3->getname(), "expr");
// };


expression : logic_expression //expr can be void
	   {
	    	outlog<<"At line no: "<<lines<<" expression : logic_expression "<<endl<<endl;
			outlog<<$1->getname()<<endl<<endl;
			
			$$ = new symbol_info($1->getname(),"expr");
			$$->setvartype($1->getvartype());
	   }
	   | variable ASSIGNOP logic_expression 	
	   {
	    	outlog<<"At line no: "<<lines<<" expression : variable ASSIGNOP logic_expression "<<endl<<endl;
			outlog<<$1->getname()<<"="<<$3->getname()<<endl<<endl;

			$$ = new symbol_info($1->getname()+"="+$3->getname(),"expr");
			$$->setvartype($1->getvartype());
			
			if($1->getvartype() == "void" || $3->getvartype() == "void") 
			{
				outerror<<"At line no: "<<lines<<" operation on void type "<<endl<<endl;
				outlog<<"At line no: "<<lines<<" operation on void type "<<endl<<endl;
				errors++;
				
				$$->setvartype("error");
			}
			else if($1->getvartype() == "int" && $3->getvartype() == "float") 
			{
				outerror<<"At line no: "<<lines<<" Warning: Assignment of float value into variable of integer type "<<endl<<endl;
				outlog<<"At line no: "<<lines<<" Warning: Assignment of float value into variable of integer type "<<endl<<endl;
				errors++;
				
				$$->setvartype("int");
			}
			
			if($1->getvartype() == "error" || $3->getvartype() == "error") 
			{
				$$->setvartype("error");
			}
			
	   }
	   ;



logic_expression : rel_expression
{
	outlog << "At line no: " << lines << " logic_expression : rel_expression " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "lgc_expr");
}
| rel_expression LOGICOP rel_expression
{
	outlog << "At line no: " << lines << " logic_expression : rel_expression LOGICOP rel_expression " << endl
		   << endl;
	outlog << $1->getname() << $2->getname() << $3->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + $2->getname() + $3->getname(), "lgc_expr");
	if($1->get_data_type()=="void" || $3->get_data_type()=="void" ){
			yyerror("operation on void type");
	}
};

rel_expression : simple_expression
{
	outlog << "At line no: " << lines << " rel_expression : simple_expression " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "rel_expr");
}
| simple_expression RELOP simple_expression
{
	outlog << "At line no: " << lines << " rel_expression : simple_expression RELOP simple_expression " << endl
		   << endl;
	outlog << $1->getname() << $2->getname() << $3->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + $2->getname() + $3->getname(), "rel_expr");
	

	if($1->get_data_type()=="void" || $3->get_data_type()=="void" ){
			yyerror("operation on void type");
	}

};

simple_expression : term
{
	outlog << "At line no: " << lines << " simple_expression : term " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "simp_expr");
}
| simple_expression ADDOP term
{
	outlog << "At line no: " << lines << " simple_expression : simple_expression ADDOP term " << endl
		   << endl;
	outlog << $1->getname() << $2->getname() << $3->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + $2->getname() + $3->getname(), "simp_expr");
	if($1->get_data_type()=="float" || $3->get_data_type()=="float"){
			$$->set_data_type("float");
	}
	else if($1->get_data_type()=="int" || $3->get_data_type()=="int"){
			$$->set_data_type("int");
	}
	if($1->get_data_type()=="void" || $3->get_data_type()=="void" ){
			yyerror("operation on void type");
	}	
};

term : unary_expression // term can be void because of un_expr->factor
{
	outlog << "At line no: " << lines << " term : unary_expression " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "term");
}
| term MULOP unary_expression
{
	outlog << "At line no: " << lines << " term : term MULOP unary_expression " << endl
		   << endl;
	outlog << $1->getname() << $2->getname() << $3->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + $2->getname() + $3->getname(), "term");
	if($1->get_data_type()=="void" || $3->get_data_type()=="void" ){
		yyerror("operation on void type");
	}
	if($2->getname()=="%"){
		if($3->getname()=="0"){
			yyerror("Modulus by 0");
		}
		else if($1->get_data_type()!="int" || $3->get_data_type()!="int"){
			yyerror("Modulus operator on non integer type");				
		}
		else{
			if($1->get_data_type()=="float" || $3->get_data_type()=="float"){
				$$->set_data_type("float");
			}
			else{
				$$->set_data_type("int");
			}
		}
		
	}	

};

unary_expression : ADDOP unary_expression // un_expr can be void because of factor
{
	outlog << "At line no: " << lines << " unary_expression : ADDOP unary_expression " << endl
		   << endl;
	outlog << $1->getname() << $2->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + $2->getname(), "un_expr");
	$$->set_data_type($2->get_data_type());
}
| NOT unary_expression
{
	outlog << "At line no: " << lines << " unary_expression : NOT unary_expression " << endl
		   << endl;
	outlog << "!" << $2->getname() << endl
		   << endl;

	$$ = new symbol_info("!" + $2->getname(), "un_expr");
	$$->set_data_type($2->get_data_type());
}
| factor
{
	outlog << "At line no: " << lines << " unary_expression : factor " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "un_expr");
};

factor : variable
{
	outlog << "At line no: " << lines << " factor : variable " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "fctr");
}
| ID LPAREN argument_list RPAREN
{
	outlog << "At line no: " << lines << " factor : ID LPAREN argument_list RPAREN " << endl
		   << endl;
	outlog << $1->getname() << "(" << $3->getname() << ")" << endl
		   << endl;

	symbol_info* t = table->lookup($1);
	if(t == NULL){
				yyerror("Undeclared function: "+$1->getname());
				}

	$$ = new symbol_info($1->getname() + "(" + $3->getname() + ")", "fctr");
}
| LPAREN expression RPAREN
{
	outlog << "At line no: " << lines << " factor : LPAREN expression RPAREN " << endl
		   << endl;
	outlog << "(" << $2->getname() << ")" << endl
		   << endl;

	$$ = new symbol_info("(" + $2->getname() + ")", "fctr");
	$$->set_data_type($2->get_data_type());
}
| CONST_INT
{
	outlog << "At line no: " << lines << " factor : CONST_INT " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "fctr");
	$$->set_data_type("int");
}
| CONST_FLOAT
{
	outlog << "At line no: " << lines << " factor : CONST_FLOAT " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "fctr");
	$$->set_data_type("float");
}
| variable INCOP
{
	outlog << "At line no: " << lines << " factor : variable INCOP " << endl
		   << endl;
	outlog << $1->getname() << "++" << endl
		   << endl;

	$$ = new symbol_info($1->getname() + "++", "fctr");
}
| variable DECOP
{
	outlog << "At line no: " << lines << " factor : variable DECOP " << endl
		   << endl;
	outlog << $1->getname() << "--" << endl
		   << endl;

	$$ = new symbol_info($1->getname() + "--", "fctr");
};

argument_list : arguments
{
	outlog << "At line no: " << lines << " argument_list : arguments " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "arg_list");
}
|
{
	outlog << "At line no: " << lines << " argument_list :  " << endl
		   << endl;
	outlog << "" << endl
		   << endl;

	$$ = new symbol_info("", "arg_list");
};

arguments : arguments COMMA logic_expression
{
	outlog << "At line no: " << lines << " arguments : arguments COMMA logic_expression " << endl
		   << endl;
	outlog << $1->getname() << "," << $3->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname() + "," + $3->getname(), "arg");
}
| logic_expression
{
	outlog << "At line no: " << lines << " arguments : logic_expression " << endl
		   << endl;
	outlog << $1->getname() << endl
		   << endl;

	$$ = new symbol_info($1->getname(), "arg");
};

%%

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		cout << "Please input file name" << endl;
		return 0;
	}
	yyin = fopen(argv[1], "r");
	outlog.open("21301211+21301436_log.txt", ios::trunc);
	outerror.open("21301211+21301436_error.txt", ios::trunc);

	if (yyin == NULL)
	{
		cout << "Couldn't open file" << endl;
		return 0;
	}
	// Enter the global or the first scope here
	table = new symbol_table(10);

	yyparse();

	delete table;

	outlog << endl
		   << "Total lines: " << lines << endl;

	outlog.close();

	outerror << endl
		   << "Total errors: " << errorCount << endl;

	outerror.close();	   

	fclose(yyin);

	return 0;
}