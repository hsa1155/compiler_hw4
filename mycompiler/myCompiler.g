grammar myCompiler;


options
{
    language=Java;
    backtrack=true;
    memoize=true;
}
@header
{
import java.util.Scanner;
}
@members {
    boolean TRACEON = false;
    boolean SUPER_TRACEON = false;
    HashMap valuemap = new HashMap();
   HashMap typemap= new HashMap();
   HashMap indexmap=new HashMap();
   boolean exetag=true;
   int labelcount = 0;
    // varCount is used to represent temporary variables.
    // The first index is 0.
    int varcount = 0;
    int printcnt = 0;
    int endcnt = 0;
    List<String> TextCode = new ArrayList<String>();
    String newLabel()
    {
       labelcount ++;
       return (new String("L")) + Integer.toString(labelcount);
    } 
    public List<String> getTextCode()
    {
       return TextCode;
    }
}

global_decelaration
    	:
    	{
       TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");}
    	( var_decelartion 
    	|func_decelartion)+
   	 ;
   
func_decelartion
  	: a=decelartion
  	{
  	TextCode.add("define dso_local i32 @" +$a.id+"()");
  	TextCode.add("{");
  	}
  	
  	
  	'(' parameter_decelartion? ')' '{' statments'}' 
  	{TextCode.add("ret i32 0");TextCode.add("}");}
  	;

parameter_decelartion
	:(decelartion)(','decelartion)* {System.out.println("unsurpported feature parameter decelartion");}
	;  

//var_decelartion_prefix*  BASIC_TYPE '*'* arith_expr      ';'
var_decelartion
	:var_decelartion_prefix*  a=decelartion 
	{
	if(exetag) {
	
	String str=(String)typemap.get($a.id);
	if(str!=null) System.out.println("error:"+$a.id+" has been decelared before");
	else
	{
	if($a.type.equals("int") )
	{
	varcount++;
	indexmap.put($a.id,String.valueOf(varcount));
	typemap.put($a.id,$a.type);
	TextCode.add("\%t" + varcount + " = alloca i32, align 4");
	}
	else if($a.type.equals("float")||$a.type.equals("double") )
	{
	varcount++;
	indexmap.put($a.id,String.valueOf(varcount));
	typemap.put($a.id,$a.type);
	TextCode.add("\%t" + varcount+ " = alloca double, align 8");
	}
	else
	{
	System.out.println("unsupported data type "+$a.type);
	}
	}
	}
	}
	(   ('=' b=condition_expr
	{
	if(exetag)
	{
	
	   String tp=$a.type;
	   String lindex=(String)indexmap.get($a.id);
    if(tp==null) {System.out.println("undefined variable "+$a.text);}
    else
    {

    if(tp.equals("String")) 
    {
     if($b.type.equals("String")) {valuemap.put($a.id,$b.str_val);}
    else if($b.type.equals("int")) {System.out.println("error: cant convert int to string");}
    else if($b.type.equals("double")) {System.out.println("error: cant convert double to string");}
    else if($b.type.equals("char")) {valuemap.put($a.id,$b.char_val);}
    else System.out.println("unsupported right type"+$b.type);
    }
    else if(tp.equals("int")) 
    {
    if($b.type.equals("String")) {System.out.println("error: cant convert string to int");}
    else if($b.type.equals("int")&&$b.index!=null) 
    {
    valuemap.put($a.id,String.valueOf($b.int_val));
      TextCode.add("store i32 \%t" + $b.index + ", i32* \%t" +lindex);
    }
    else if($b.type.equals("int")&&$b.index==null) 
    {
    valuemap.put($a.id,String.valueOf($b.int_val));
      TextCode.add("store i32 " + $b.int_val + ", i32* \%t" +lindex);
    }
    else if($b.type.equals("double")&&$b.index==null) 
    {
    valuemap.put($a.id,String.valueOf((int)$b.double_val));;
    TextCode.add("store i32 " + (int)$b.double_val+ ", i32* \%t" +lindex);
    }
     else if ($b.type.equals("double")&&$b.index!=null){System.out.println("error not supported type casting double->int");}
    else if($b.type.equals("char")) { valuemap.put($a.id,String.valueOf((int)$b.char_val));}
    else System.out.println("unsupported right type"+$b.type);
    }
    else if(tp.equals("double")) 
    {
    if($b.type.equals("String")) {System.out.println("error: cant convert string to double");}
    else if($b.type.equals("int")&&$b.index==null) 
    {
   
    valuemap.put($a.id,String.valueOf((double)$b.int_val));
    double tmp0=(double)$b.int_val; 
    long tmp=Double.doubleToLongBits(tmp0);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    TextCode.add("store double " + strcat+ ", double* \%t" +lindex);
    }
    else if ($b.type.equals("int")&&$b.index!=null){System.out.println("error not supported type casting double->int");}
    else if($b.type.equals("double")&&$b.index!=null) 
    {
    
    valuemap.put($a.id,String.valueOf($b.double_val));
    TextCode.add("store double \%t" + $b.index + ", double* \%t" +lindex);
    }
    else if($b.type.equals("double")&&$b.index==null) 
    {
    
    valuemap.put($a.id,String.valueOf($b.double_val));
    long tmp=Double.doubleToLongBits($b.double_val);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    TextCode.add("store double " + strcat+ ", double* \%t" +lindex);
    }
    else if($b.type.equals("char")) { valuemap.put($a.id,String.valueOf((double)(int)$b.char_val));}
    else System.out.println("unsupported right type"+$b.type);
    }
    else if(tp.equals("char")) 
    {
        if($b.type.equals("String")) {System.out.println("error: cant convert string to char");}
    else if($b.type.equals("int")) {valuemap.put($a.id,String.valueOf((char)$b.int_val));}
    else if($b.type.equals("double")) {valuemap.put($a.id,String.valueOf((char)$b.double_val));;}
    else if($b.type.equals("char")) { valuemap.put($a.id,String.valueOf($b.char_val));}
    else System.out.println("unsupported right type"+$b.type);
    }
    else System.out.println("unsupported left type "+$a.type);
    }
	
	}
	}
	)?| ('['c=condition_expr ']' 
	{
	if(exetag)
	{
	System.out.println("unsupported array index id[] expr ");
	}
	}
	)+  )      
		
	
	  (',' f=ID      
	  {
	if(exetag) {
	
	String str=(String)typemap.get($f.text);
	if(str!=null) System.out.println("error:"+$f.text+" has been decelared before");
	else
	{
	if($a.type.equals("int") )
	{
	varcount++;
	indexmap.put($f.text,String.valueOf(varcount));
	typemap.put($f.text,$a.type);
	TextCode.add("\%t" + varcount + " = alloca i32, align 4");
	}
	else if($a.type.equals("float")||$a.type.equals("double") )
	{
	varcount++;
	indexmap.put($f.text,String.valueOf(varcount));
	typemap.put($f.text,$a.type);
	TextCode.add("\%t" + varcount+ " = alloca double, align 8");
	}
	else
	{
	System.out.println("unsupported data type "+$a.type);
	}
	}
	}
	}
	    (    ('=' d=condition_expr
	    {
	if(exetag)
	{
	
	   String tp=$a.type;
	   String lindex=(String)indexmap.get($f.text);
    if(tp==null||lindex==null) {System.out.println("undefined variable "+$f.text);}
    else
    {

    if(tp.equals("String")) 
    {
     if($d.type.equals("String")) {valuemap.put($f.text,$d.str_val);}
    else if($d.type.equals("int")) {System.out.println("error: cant convert int to string");}
    else if($d.type.equals("double")) {System.out.println("error: cant convert double to string");}
    else if($d.type.equals("char")) {valuemap.put($f.text,$d.char_val);}
    else System.out.println("unsupported right type"+$d.type);
    }
    else if(tp.equals("int")) 
    {
    if($d.type.equals("String")) {System.out.println("error: cant convert string to int");}
    else if($d.type.equals("int")&&$d.index!=null) 
    {
    valuemap.put($f.text,String.valueOf($d.int_val));
      TextCode.add("store i32 \%t" + $d.index + ", i32* \%t" +lindex);
    }
    else if($d.type.equals("int")&&$d.index==null) 
    {
    valuemap.put($f.text,String.valueOf($d.int_val));
      TextCode.add("store i32 " + $d.int_val + ", i32* \%t" +lindex);
    }
    else if($d.type.equals("double")&&$d.index==null) 
    {
    valuemap.put($f.text,String.valueOf((int)$d.double_val));;
    TextCode.add("store i32 " + (int)$d.double_val+ ", i32* \%t" +lindex);
    }
     else if ($d.type.equals("double")&&$d.index!=null){System.out.println("error not supported type casting double->int");}
    else if($d.type.equals("char")) { valuemap.put($f.text,String.valueOf((int)$d.char_val));}
    else System.out.println("unsupported right type"+$d.type);
    }
    else if(tp.equals("double")) 
    {
    if($d.type.equals("String")) {System.out.println("error: cant convert string to double");}
    else if($d.type.equals("int")&&$d.index==null) 
    {
   
    valuemap.put($f.text,String.valueOf((double)$d.int_val));
    double tmp0=(double)$d.int_val; 
    long tmp=Double.doubleToLongBits(tmp0);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    TextCode.add("store double " + strcat+ ", double* \%t" +lindex);
    }
    else if ($d.type.equals("int")&&$d.index!=null){System.out.println("error not supported type casting double->int");}
    else if($d.type.equals("double")&&$d.index!=null) 
    {
    
    valuemap.put($f.text,String.valueOf($d.double_val));
    TextCode.add("store double \%t" + $d.index + ", double* \%t" +lindex);
    }
    else if($d.type.equals("double")&&$d.index==null) 
    {
    
    valuemap.put($f.text,String.valueOf($d.double_val));
    long tmp=Double.doubleToLongBits($d.double_val);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    TextCode.add("store double " + strcat+ ", double* \%t" +lindex);
    }
    else if($d.type.equals("char")) { valuemap.put($f.text,String.valueOf((double)(int)$d.char_val));}
    else System.out.println("unsupported right type"+$d.type);
    }
    else if(tp.equals("char")) 
    {
        if($d.type.equals("String")) {System.out.println("error: cant convert string to char");}
    else if($d.type.equals("int")) {valuemap.put($f.text,String.valueOf((char)$d.int_val));}
    else if($d.type.equals("double")) {valuemap.put($f.text,String.valueOf((char)$d.double_val));;}
    else if($d.type.equals("char")) { valuemap.put($f.text,String.valueOf($d.char_val));}
    else System.out.println("unsupported right type"+$d.type);
    }
    else System.out.println("unsupported left type "+$a.type);
    }
	
	}
	}
	    )?   
	    | ('['e=condition_expr ']'
	    {
	if(exetag)
	{
	System.out.println("unsupported array index id[] expr ");
	}
	}
	     )+         )         )*        ';'
	;


var_decelartion_prefix
	:(STORAGE_CLASS_SPECIFIER |TYPE_MODIFIER| SIGN) 
	;
	
decelartion returns [String type,String id]
	:x=BASIC_TYPE '*'*y=ID {$type=$x.text;$id=$y.text;}
	;

constant returns [String type ,String str_const,char char_const,int int_const,double double_const]
	:a=LITERAL_STRING {$type="String";int len = $a.text.length();$str_const=$a.text.substring(1,len-1);}
	|b=LITERAL_CHAR   {$type="char";$char_const=$b.text.charAt(1);}
	|c=DECIMAL_INT   {$type="int";$int_const=Integer.parseInt($c.text);}
	|d=HEX_INT       {$type="fail";System.out.println("not supported num type: hex num");}
	|e=OCTAL_INT     {$type="fail";System.out.println("not supported num type: octal num");}
	|f=FLOAT        {$type="double"; $double_const=Double.parseDouble($f.text);  }
	;

constant_num returns [String type ,int int_const,double double_const]
    :	c=DECIMAL_INT    {$type="int";$int_const=Integer.parseInt($c.text);}
	|d=HEX_INT       {$type="fail";System.out.println("not supported num type: hex num");}
	|e=OCTAL_INT     {$type="fail";System.out.println("not supported num type: octal num");}
	|f=FLOAT        {$type="double"; $double_const=Double.parseDouble($f.text);  }
	;
	
statments
	:statment*
	;
	
statment
	:'scanf' '(' LITERAL_STRING ','  (('*')=> MULT|('&')=>AND)* p=ID ','  (('*')=> MULT|('&')=>AND)*q=ID ')' ';'
	{
	if(exetag)
	{
	System.out.println("unsupported statment scanf");
	/*
	String tp1=(String)typemap.get($p.text);
	String tp2=(String)typemap.get($q.text);
    	if(tp1==null||tp2==null) {if(tp1==null)System.out.println("undefined variable "+$p.text +" as a result.scanf fails. and other part may fail too");if(tp2==null)System.out.println("undefined variable "+$q.text +" as a result.scanf fails. and other part may fail too");}
    	else
    	{
    	typemap.put($p.text,"int");
    	typemap.put($q.text,"int");
    	Scanner scanner = new Scanner(System.in);
    	int tmp1=scanner.nextInt();
    	int tmp2=scanner.nextInt();
    	valuemap.put($p.text,String.valueOf(tmp1));
    	valuemap.put($q.text,String.valueOf(tmp2));
    	}
	*/
	}
	
	}
	|'scanf' '(' a=LITERAL_STRING ','   (('*')=> MULT|('&')=>AND)* b=ID ')' ';'//int only
	{
	if(exetag)
	{
	System.out.println("unsupported statment scanf");
	/*
	String tp=(String)typemap.get($b.text);
    	if(tp==null) {System.out.println("undefined variable "+$b.text +" as a result.scanf fails. and other part may fail too");}
    	else
    	{
    	typemap.put($b.text,"int");
    	Scanner scanner = new Scanner(System.in);
    	int tmp=scanner.nextInt();
    	valuemap.put($b.text,String.valueOf(tmp));
    	}
	*/
	}
	
	}
	|'printf' '(' x1=LITERAL_STRING ','  (('*')=> MULT|('&')=>AND)* y1=assign_expr ','  (('*')=> MULT|('&')=>AND)*z1= assign_expr ')' ';'
	{
	String printftmp="";
	 if($y1.index!=null)
                  {
                   
                     if($y1.type.equals("int"))
                    { printftmp = printftmp + (", i32 \%t")+($y1.index);}
                     else if($y1.type.equals("double"))
                    { printftmp = printftmp + (", double \%t")+($y1.index);}

                  }
                  if($z1.index!=null)
                  {
                   
                     if($z1.type.equals("int"))
                    { printftmp = printftmp + (", i32 \%t")+($z1.index);}
                     else if($z1.type.equals("double"))
                    { printftmp = printftmp + (", double \%t")+($z1.index);}

                  }
                   String line = $x1.text;
                 int  linelen = line.length();
                  if(line.indexOf("\%")!=-1)
                  if(line.indexOf("\\n")==-1)
                  {
                     TextCode.add(printcnt,"@str." + printcnt + "= private unnamed_addr constant [" + (linelen-1) + "x i8] c" +line.substring(0,linelen-1)+ "\\00\"");
                     varcount++;
                     TextCode.add("\%t" + varcount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + (linelen-1) + " x i8],[" + (linelen-1) + " x i8]* @str." + printcnt + ", i64 0, i64 0)"+ printftmp + ")" );
                     printcnt++;
                     
                  }
                  else
                  {
                     TextCode.add(printcnt,"@str." + printcnt + "=private unnamed_addr constant [" + (linelen-2) + "x i8] c" +line.substring(0,linelen-3)+ "\\0A\\00\"");
                     varcount++;
                     TextCode.add("\%t" + varcount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + (linelen-2) + " x i8],[" + (linelen-2) + " x i8]* @str." + printcnt + ", i64 0, i64 0)" + printftmp + ")" );
                     printcnt++;
                     
                  }
	
	}
	|'printf' '(' x2=LITERAL_STRING ','    (('*')=> MULT|('&')=>AND)*y2=assign_expr')' ';'
	{
	String printftmp="";
	 if($y2.index!=null)
                  {
                   
                     if($y2.type.equals("int"))
                    { printftmp = printftmp + (", i32 \%t")+($y2.index);}
                     else if($y2.type.equals("double"))
                    { printftmp = printftmp + (", double \%t")+($y2.index);}

                  }
                  
                  //
                  String line = $x2.text;
                 int  linelen = line.length();
                  if(line.indexOf("\%")!=-1)
                  if(line.indexOf("\\n")==-1)
                  {
                     TextCode.add(printcnt,"@str." + printcnt + "= private unnamed_addr constant [" + (linelen-1) + "x i8] c" +line.substring(0,linelen-1)+ "\\00\"");
                     varcount++;
                     TextCode.add("\%t" + varcount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + (linelen-1) + " x i8],[" + (linelen-1) + " x i8]* @str." + printcnt + ", i64 0, i64 0)"+ printftmp + ")" );
                     printcnt++;
                     
                  }
                  else
                  {
                     TextCode.add(printcnt,"@str." + printcnt + "=private unnamed_addr constant [" + (linelen-2) + "x i8] c" +line.substring(0,linelen-3)+ "\\0A\\00\"");
                     varcount++;
                     TextCode.add("\%t" + varcount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + (linelen-2) + " x i8],[" + (linelen-2) + " x i8]* @str." + printcnt + ", i64 0, i64 0)" + printftmp + ")" );
                     printcnt++;
                     
                  }
	
	}
	|'printf' '(' x3=LITERAL_STRING ')' ';'
	{  
	String line = $x3.text;
                 int  linelen = line.length();
                  if(line.indexOf("\%")==-1)
                  {
                     if(line.indexOf("\\n")==-1)
                     {
                        TextCode.add(printcnt , "@str." + printcnt + "= private unnamed_addr constant [" + (linelen-1) + "x i8] c" +line.substring(0,linelen-1)+ "\\00\"");
                        varcount++;
                        TextCode.add("\%t" + varcount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + (linelen-1) + " x i8],[" + (linelen-1) + " x i8]* @str." + printcnt + ", i64 0, i64 0))");
                        printcnt++;
                        
                     }
                     else
                     {
                        TextCode.add(printcnt , "@str." + printcnt + "= private unnamed_addr constant [" + (linelen-2) + "x i8] c" +line.substring(0,linelen-3)+ "\\0A\\00\"");
                        varcount++;
                        TextCode.add("\%t" + varcount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + (linelen-2) + " x i8],[" + (linelen-2) + " x i8]* @str." + printcnt + ", i64 0, i64 0))");
                        printcnt++;
                        
                     }
                     
                  }
	  
	
	}
	|arith_expr';'
	|var_decelartion 
	|loop_statment
	|LOOP_CTRL ';'
	|'return' arith_expr? ';' 
	|if_statment 
	|';' 
	;

loop_statment
	:WHILE'('arith_expr ')' (statment|('{' statments '}' )  ) {if (TRACEON) System.out.println("loop_statment:WHILE'('arith_expr ')' (statment|('{' statments '}' )  )");}
	|DO (statment|('{' statments '}' )  )WHILE  '('arith_expr ')' ';' {if (TRACEON) System.out.println("loop_statment:DO (statment|('{' statments '}' )  )WHILE  '('arith_expr ')' ';'");}
	|FOR '('  ( (BASIC_TYPE arith_expr)|arith_expr?) ';'arith_expr? ';' arith_expr? ')' (statment|('{' statments '}' )  ) {if (TRACEON) System.out.println("loop_statment:FOR '('  ( (BASIC_TYPE arith_expr)|arith_expr?) ';'arith_expr? ';' arith_expr? ')' (statment|('{' statments '}' )  )");}
	;
	
if_statment
@init{boolean tmpcondit=true; boolean initexetag=exetag; String next=newLabel(); String elseLabel=newLabel();; String finalLabel=newLabel();;}
	:
	
	'if' '(' a=arith_expr ')'
	{
	
	TextCode.add("br i1 \%t" + varcount + ", label \%"  + next + ", label \%" + elseLabel);
         TextCode.add(next + ":");
         varcount++;
         
	}
	 (  statment| ('{' statments )  '}' ) 
	 {
	TextCode.add("br label \%"+  finalLabel);
	TextCode.add( elseLabel + ":");
	 }
	 ('else'  
	 {
	  
	 } 
	 (  statment| ('{' statments )  '}' )  )?
	 
	 {
	   TextCode.add("br "+"label \%" +finalLabel);
         TextCode.add(finalLabel + ":");
	 } 
	;
/*
優先權 t小較優先 越優先放越底層 
t15 ,  ==>x,y,a+b,a=5
t14 =  ==>x=y x=5
t13 ?: a?b:c
t12 || a||b
t11 && a&&b
t10 |  a|b
t9  ^  a^b
t8  &  a&b
t7  == a==b a!=b
t6  <  a<b a<=b 
t5  << a<<b a>>2
t4  +  a+b a-2
t3  *  a*b a%b
t2  單元前綴 ++a --b -c sizeof(a) (int)a !a *a &a ~a
t1  後綴 a() a++ a-- a[] a->a a.b
t0  (a) (1)
*/

arith_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
	:a=assign_expr 
	{
	  if(exetag){
	$type=$a.type;
	if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
	}
	(c=','b= assign_expr 
	{
	System.out.println("unsupproted comma experrision a,b,c...");
	}
	
	)* 
	;

assign_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
	:d=ID c=('='|ASSIGN_OPERATOR ) b=condition_expr
	{
	  if(exetag){
	if(!$c.text.equals("=")) System.out.println("unsupported assignment method " +$c.text+ "  treat as normal assign =");
	
    String tp=(String)typemap.get($d.text);
    String lindex=(String)indexmap.get($d.text);
    $index=lindex;
    if(tp==null||lindex==null) {System.out.println("undefined variable "+$d.text);$type="fail";}
    else
    {
    $type=tp;
    if($type.equals("String")) 
    {
    System.out.println("error! unsurpported left type string");
     if($b.type.equals("String")) {$str_val=$b.str_val; valuemap.put($d.text,$b.str_val);}
    else if($b.type.equals("int")) {System.out.println("error: cant convert int to string");$type="fail";}
    else if($b.type.equals("double")) {System.out.println("error: cant convert double to string");$type="fail";}
    else if($b.type.equals("char")) {$char_val=$b.char_val;valuemap.put($d.text,$b.char_val);}
    else System.out.println("unsupported right type"+$b.type);
    
    
    
    }
    else if($type.equals("int")) 
    {// if($b.type.equals("int")&&$b.index==null) doubleb=(double)$b.int_val; else if($b.type.equals("int")&&$b.index!=null  )System.out.println("error not supported type casting int -> double ");
    if($b.type.equals("String")) {System.out.println("error: cant convert string to int");$type="fail";}
    else if($b.type.equals("int")&&$b.index!=null) 
    {
    $int_val=$b.int_val;
    valuemap.put($d.text,String.valueOf($b.int_val));
      TextCode.add("store i32 \%t" + $b.index + ", i32* \%t" +lindex);
    }
    else if($b.type.equals("int")&&$b.index==null) 
    {
    $int_val=$b.int_val;
    valuemap.put($d.text,String.valueOf($b.int_val));
      TextCode.add("store i32 " + $b.int_val + ", i32* \%t" +lindex);
    }
    else if($b.type.equals("double")&&$b.index==null) 
    {
    $int_val=(int)$b.double_val;
    valuemap.put($d.text,String.valueOf((int)$b.double_val));;
    TextCode.add("store i32 " + $int_val+ ", i32* \%t" +lindex);
    }
     else if ($b.type.equals("double")&&$b.index!=null){System.out.println("error not supported type casting double->int");}
    else if($b.type.equals("char")) { $int_val=(int)$b.char_val;valuemap.put($d.text,String.valueOf((int)$b.char_val));}
    else System.out.println("unsupported right type"+$b.type);
    }
    else if($type.equals("double")) 
    {
    if($b.type.equals("String")) {System.out.println("error: cant convert string to double");$type="fail";}
    else if($b.type.equals("int")&&$b.index==null) 
    {
    $double_val=(double)$b.int_val;
    valuemap.put($d.text,String.valueOf((double)$b.int_val));
    double tmp0=(double)$b.int_val; 
    long tmp=Double.doubleToLongBits(tmp0);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    TextCode.add("store double " + strcat+ ", double* \%t" +lindex);
    }
    else if ($b.type.equals("int")&&$b.index!=null){System.out.println("error not supported type casting double->int");}
    else if($b.type.equals("double")&&$b.index!=null) 
    {
    $double_val=$b.double_val;
    valuemap.put($d.text,String.valueOf($b.double_val));
    TextCode.add("store double \%t" + $b.index + ", double* \%t" +lindex);
    }
    else if($b.type.equals("double")&&$b.index==null) 
    {
    $double_val=$b.double_val;
    valuemap.put($d.text,String.valueOf($b.double_val));
    long tmp=Double.doubleToLongBits($b.double_val);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    TextCode.add("store double " + strcat+ ", double* \%t" +lindex);
    }
    else if($b.type.equals("char")) { $double_val=(double)(int)$b.char_val;valuemap.put($d.text,String.valueOf((double)(int)$b.char_val));}
    else System.out.println("unsupported right type"+$b.type);
    }
    else if($type.equals("char")) 
    {
    	System.out.println("error! unsurpported type char");
        if($b.type.equals("String")) {System.out.println("error: cant convert string to char");$type="fail";}
    else if($b.type.equals("int")) {$char_val=(char)$b.int_val;valuemap.put($d.text,String.valueOf((char)$b.int_val));}
    else if($b.type.equals("double")) {$char_val=(char)(int)$b.double_val;valuemap.put($d.text,String.valueOf((char)$b.double_val));;}
    else if($b.type.equals("char")) { $char_val=$b.char_val;valuemap.put($d.text,String.valueOf($b.char_val));}
    else System.out.println("unsupported right type"+$b.type);
    }
    else System.out.println("unsupported left type "+$type);
    }
    }
    
    //System.out.println($d.text+" result type "+(String)typemap.get($d.text)+" value "+(String)valuemap.get($d.text));
	
	}
	|a=condition_expr
	{
	  if(exetag){
	$type=$a.type;
	if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
	} 
	;
	
	
condition_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
	:a=logical_or_expr
	{
	  if(exetag){
	$type=$a.type;
	if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
	}
	('?'assign_expr ':'condition_expr
	{
	System.out.println("unsupported logical experission a?c:b");
	}
	
	)? 
	;
	
logical_or_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
	:a=logical_and_expr
	{
	  if(exetag){
	$type=$a.type;
	if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
	}
	(c='||'b=logical_and_expr
	{
	System.out.println("unsupported calculation ||");
	  if(exetag){
	String newtype;
    double doublea=0,doubleb=0;
    int inta=0,intb=0;
    if($type.equals("double")||$b.type.equals("double")) 
    {
    newtype="double";
    
    if($type.equals("int")) doublea=(double)$int_val;
    else if($type.equals("double")) doublea=$double_val;
    else if($type.equals("char")) doublea=(double)$char_val;
    else System.out.println("unsupported mult calculation ");
    
    if($b.type.equals("int")) doubleb=(double)$b.int_val;
    else if($b.type.equals("double")) doubleb=$b.double_val;
    else if($b.type.equals("char")) doubleb=(double)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    $type="double";
    }
    else if($type.equals("String")||$b.type.equals("String")) 
    {
    System.out.println("error:multiply of string is not defined");
    $type="fail";
    }
    else
    {
     newtype="int";
      
    if($type.equals("int")) inta=$int_val;
    else if($type.equals("double")) inta=(int)$double_val;
    else if($type.equals("char")) inta=(int)$char_val;
    else System.out.println("unsupported mult calculation ");
    
    if($b.type.equals("int")) intb=$b.int_val;
    else if($b.type.equals("double")) intb=(int)$b.double_val;
    else if($b.type.equals("char")) intb=(int)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    
    $type="int";
    }
    
    if($c.text.equals("||")) 
    {
    if($type.equals("int"))
    {
    $type="int";
    boolean tmpa,tmpb;
    if(inta!=0) tmpa=true; else tmpa=false;
     if(intb!=0) tmpb=true; else tmpb=false;
    if(tmpa||tmpb) $int_val=1;
    else $int_val=0;
    
    }
    else if($type.equals("double"))
    {
     $type="int";
    boolean tmpa,tmpb;
    if(doublea!=0) tmpa=true; else tmpa=false;
     if(doubleb!=0) tmpb=true; else tmpb=false;
    if(tmpa||tmpb) $int_val=1;
    else $int_val=0;
    }
    }

  //if($type.equals("double"))  System.out.println("double"+$double_val);
  //if($type.equals("int")) System.out.println("int"+$int_val);
    }
	}
	
	)* 
	;

logical_and_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
	:a=bit_or_expr
	{
	  if(exetag){
	$type=$a.type;
	if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
	}
	(c='&&'b=bit_or_expr
	{
System.out.println("unsupported calculation &&");
	  if(exetag){
	String newtype;
    double doublea=0,doubleb=0;
    int inta=0,intb=0;
    if($type.equals("double")||$b.type.equals("double")) 
    {
    newtype="double";
    
    if($type.equals("int")) doublea=(double)$int_val;
    else if($type.equals("double")) doublea=$double_val;
    else if($type.equals("char")) doublea=(double)$char_val;
    else System.out.println("unsupported mult calculation ");
    
    if($b.type.equals("int")) doubleb=(double)$b.int_val;
    else if($b.type.equals("double")) doubleb=$b.double_val;
    else if($b.type.equals("char")) doubleb=(double)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    $type="double";
    }
    else if($type.equals("String")||$b.type.equals("String")) 
    {
    System.out.println("error:multiply of string is not defined");
    $type="fail";
    }
    else
    {
     newtype="int";
      
    if($type.equals("int")) inta=$int_val;
    else if($type.equals("double")) inta=(int)$double_val;
    else if($type.equals("char")) inta=(int)$char_val;
    else System.out.println("unsupported mult calculation ");
    
    if($b.type.equals("int")) intb=$b.int_val;
    else if($b.type.equals("double")) intb=(int)$b.double_val;
    else if($b.type.equals("char")) intb=(int)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    
    $type="int";
    }
    
    if($c.text.equals("&&")) 
    {
    if($type.equals("int"))
    {
    $type="int";
    boolean tmpa,tmpb;
    if(inta!=0) tmpa=true; else tmpa=false;
     if(intb!=0) tmpb=true; else tmpb=false;
    if(tmpa&&tmpb) $int_val=1;
    else $int_val=0;
    
    }
    else if($type.equals("double"))
    {
     $type="int";
    boolean tmpa,tmpb;
    if(doublea!=0) tmpa=true; else tmpa=false;
     if(doubleb!=0) tmpb=true; else tmpb=false;
    if(tmpa&&tmpb) $int_val=1;
    else $int_val=0;
    }
    }

  //if($type.equals("double"))  System.out.println("double"+$double_val);
  //if($type.equals("int")) System.out.println("int"+$int_val);
    
    }
	}
	
	)* 
	;

bit_or_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
	:a=bit_xor_expr
	{
	  if(exetag){
	$type=$a.type;
	if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
	}
	}
	(c='|'b=bit_xor_expr
	{
	System.out.println("unsupported bit or experriosion a|b");
	}
	)*  
	;
	
bit_xor_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
	:a=bit_and_expr
	{
	  if(exetag){
	$type=$a.type;
	if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
	}
	(c='^'b=bit_and_expr
	{
	System.out.println("unsupported bit xor experriosion a^b");
	}
	)* 
	;

bit_and_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
	:a=logical_equal_expr
	{
	  if(exetag){
	$type=$a.type;
	if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
	}
	(c='&'b= logical_equal_expr
	{
	System.out.println("unsupported bit and experriosion a&b");
	}
	)* 
	;
logical_equal_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
	:a=comparism_expr
	{
	  if(exetag){
	$type=$a.type;
	 if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
	}
	(c=LOGICAL_EQUALITY_OPERATOR b=comparism_expr
	{
	  if(exetag){
	String newtype;
    double doublea=0,doubleb=0;
    int inta=0,intb=0;
    if($type.equals("double")||$b.type.equals("double")) 
    {
    newtype="double";
    
     if($type.equals("int")&&$a.index==null) doublea=(double)$int_val; else if($type.equals("int")&&$a.index!=null  )System.out.println("error not supported type casting int -> double ");
    else if($type.equals("double")) doublea=$double_val;
    else if($type.equals("char")) doublea=(double)$char_val;
    else System.out.println("unsupported mult calculation ");
    
     if($b.type.equals("int")&&$b.index==null) doubleb=(double)$b.int_val; else if($b.type.equals("int")&&$b.index!=null  )System.out.println("error not supported type casting int -> double ");
    else if($b.type.equals("double")) doubleb=$b.double_val;
    else if($b.type.equals("char")) doubleb=(double)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    $type="double";
    }
    else if($type.equals("String")||$b.type.equals("String")) 
    {
    System.out.println("error:multiply of string is not defined");
    $type="fail";
    }
    else
    {
     newtype="int";
      
    if($type.equals("int")) inta=$int_val;
    else if($type.equals("double")) inta=(int)$double_val;
    else if($type.equals("char")) inta=(int)$char_val;
    else System.out.println("unsupported mult calculation ");
    
    if($b.type.equals("int")) intb=$b.int_val;
    else if($b.type.equals("double")) intb=(int)$b.double_val;
    else if($b.type.equals("char")) intb=(int)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    
    $type="int";
    }
    
     if($c.text.equals("==")) 
    {
    if($type.equals("int"))
    {
    
      if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp  eq i32 \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
    
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp eq i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
   
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp eq  i32 " + inta + ",\%t" + $b.index);
    $index=String.valueOf(varcount);
   
    }
    
    
    
    
    $type="int";
    if(inta==intb) $int_val=1;
    else $int_val=0;
    
    }
    else if($type.equals("double"))
    {
    
     if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp oeq  double  \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
	


    }else if($a.index!=null&&$b.index==null)
    {
    long tmp=Double.doubleToLongBits(doubleb);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp oeq  double  \%t" +$a.index + ", " + strcat  );
    $index=String.valueOf(varcount);
   
    }
    else if($a.index==null&&$b.index!=null)
    {
   long tmp=Double.doubleToLongBits(doublea);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp oeq double " +strcat + ", \%t" + $b.index );
    $index=String.valueOf(varcount);
  
    }
    
    
    
    
    
     $type="int";
    if(doublea==doubleb) $int_val=1;
    else $int_val=0;
    }
    }
    else  if($c.text.equals("!=")) 
    {
    if($type.equals("int"))
    {
    
     if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp  ne i32 \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
    
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp ne i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
   
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp ne  i32 " + inta + ",\%t" + $b.index);
    $index=String.valueOf(varcount);
   
    }
    
    
    
    $type="int";
    if(inta!=intb) $int_val=1;
    else $int_val=0;
    
    }
    else if($type.equals("double"))
    {
    
     if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp une  double  \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
	


    }else if($a.index!=null&&$b.index==null)
    {
    long tmp=Double.doubleToLongBits(doubleb);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp une  double  \%t" +$a.index + ", " + strcat  );
    $index=String.valueOf(varcount);
  
    }
    else if($a.index==null&&$b.index!=null)
    {
   long tmp=Double.doubleToLongBits(doublea);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp une double " +strcat + ", \%t" + $b.index );
    $index=String.valueOf(varcount);
  
    }
    
    
    
     $type="int";
    if(doublea!=doubleb) $int_val=1;
    else $int_val=0;
    }
    }
    
    
    //if($type.equals("double"))  System.out.println("double"+$double_val);
   //if($type.equals("int")) System.out.println("int"+$int_val);
	}
	}
	
	)*  
	;

comparism_expr  returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
	:a=shift_expr
	 {
	   if(exetag){
    
     $type=$a.type;
      if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
    
    }
	(c=COMPARISON_OPERATOR b=shift_expr
	{
	  if(exetag){
	 String newtype;
    double doublea=0,doubleb=0;
    int inta=0,intb=0;
    if($type.equals("double")||$b.type.equals("double")) 
    {
    newtype="double";
    
     if($type.equals("int")&&$a.index==null) doublea=(double)$int_val; else if($type.equals("int")&&$a.index!=null  )System.out.println("error not supported type casting int -> double ");
    else if($type.equals("double")) doublea=$double_val;
    else if($type.equals("char")) doublea=(double)$char_val;
    else System.out.println("unsupported mult calculation ");
    
   if($b.type.equals("int")&&$b.index==null) doubleb=(double)$b.int_val; else if($b.type.equals("int")&&$b.index!=null  )System.out.println("error not supported type casting int -> double ");
    else if($b.type.equals("double")) doubleb=$b.double_val;
    else if($b.type.equals("char")) doubleb=(double)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    $type="double";
    }
    else if($type.equals("String")||$b.type.equals("String")) 
    {
    System.out.println("error:multiply of string is not defined");
    $type="fail";
    }
    else
    {
     newtype="int";
      
    if($type.equals("int")) inta=$int_val;
    else if($type.equals("double")) inta=(int)$double_val;
    else if($type.equals("char")) inta=(int)$char_val;
    else System.out.println("unsupported mult calculation ");
    
    if($b.type.equals("int")) intb=$b.int_val;
    else if($b.type.equals("double")) intb=(int)$b.double_val;
    else if($b.type.equals("char")) intb=(int)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    
    $type="int";
    }
    
    
     if($c.text.equals("<")) 
    {
    if($type.equals("int"))
    {
    $type="int";
    if(inta<intb) $int_val=1;
    else $int_val=0;
    
       if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp  slt i32 \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
   
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp slt i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
   
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp slt  i32 " + inta + ",\%t" + $b.index);
    $index=String.valueOf(varcount);
   
    }
    
    
    }
    else if($type.equals("double"))
    {
    
         if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp olt  double  \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
	


    }else if($a.index!=null&&$b.index==null)
    {
    long tmp=Double.doubleToLongBits(doubleb);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp olt  double  \%t" +$a.index + ", " + strcat  );
    $index=String.valueOf(varcount);
   
    }
    else if($a.index==null&&$b.index!=null)
    {
   long tmp=Double.doubleToLongBits(doublea);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp olt double " +strcat + ", \%t" + $b.index );
    $index=String.valueOf(varcount);
  
    }
    
    
     $type="int";
    if(doublea<doubleb) $int_val=1;
    else $int_val=0;
    }
    }
    
    else if($c.text.equals(">")) 
    {
    if($type.equals("int"))
    {
    
    
           if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp  sgt i32 \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
   
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp sgt i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
   
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp sgt  i32 " + inta + ",\%t" + $b.index);
    $index=String.valueOf(varcount);
   
    }
    
    $type="int";
    if(inta>intb) $int_val=1;
    else $int_val=0;
    
    }
    else if($type.equals("double"))
    {
    
      if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp ogt  double  \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
	


    }else if($a.index!=null&&$b.index==null)
    {
    long tmp=Double.doubleToLongBits(doubleb);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp ogt  double  \%t" +$a.index + ", " + strcat  );
    $index=String.valueOf(varcount);
    
    }
    else if($a.index==null&&$b.index!=null)
    {
   long tmp=Double.doubleToLongBits(doublea);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp ogt double " +strcat + ", \%t" + $b.index );
    $index=String.valueOf(varcount);
    
    }
    
    
     $type="int";
    if(doublea>doubleb) $int_val=1;
    else $int_val=0;
    }
    }
    else if($c.text.equals("<=")) 
    {
    if($type.equals("int"))
    {
    
     if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp  sle i32 \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
  
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp sle i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
   
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp sle  i32 " + inta + ",\%t" + $b.index);
    $index=String.valueOf(varcount);
    
    }
    
    $type="int";
    if(inta<=intb) $int_val=1;
    else $int_val=0;
    
    }
    else if($type.equals("double"))
    {
    
       if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp ole  double  \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
	


    }else if($a.index!=null&&$b.index==null)
    {
    long tmp=Double.doubleToLongBits(doubleb);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp ole  double  \%t" +$a.index + ", " + strcat  );
    $index=String.valueOf(varcount);
    
    }
    else if($a.index==null&&$b.index!=null)
    {
   long tmp=Double.doubleToLongBits(doublea);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp ole double " +strcat + ", \%t" + $b.index );
    $index=String.valueOf(varcount);
    
    }
    
    
    
     $type="int";
    if(doublea<=doubleb) $int_val=1;
    else $int_val=0;
    }
    }
    
    if($c.text.equals(">=")) 
    {
    if($type.equals("int"))
    {
    
      if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp  sge i32 \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
    
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp sge i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
   
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = icmp sge  i32 " + inta + ",\%t" + $b.index);
    $index=String.valueOf(varcount);
   
    }
    
    
    $type="int";
    if(inta>=intb) $int_val=1;
    else $int_val=0;
    
    }
    else if($type.equals("double"))
    {
        if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp oge  double  \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
	


    }else if($a.index!=null&&$b.index==null)
    {
    long tmp=Double.doubleToLongBits(doubleb);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp oge  double  \%t" +$a.index + ", " + strcat  );
    $index=String.valueOf(varcount);
    
    }
    else if($a.index==null&&$b.index!=null)
    {
   long tmp=Double.doubleToLongBits(doublea);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fcmp oge double " +strcat + ", \%t" + $b.index );
    $index=String.valueOf(varcount);
    
    }
    
    
    
     $type="int";
    if(doublea>=doubleb) $int_val=1;
    else $int_val=0;
    }
    }
    
    
    
   //if($type.equals("double"))  System.out.println("double"+$double_val);
   //if($type.equals("int")) System.out.println("int"+$int_val);
    
	}
	}
	
	)* 
	; 

shift_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
    :a=add_expr
     {
       if(exetag){
    {
     $type=$a.type;
      if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
    }
    }
    (c=SHIFT_OPERATOR b=add_expr
    {
    System.out.println("unsupported shift operator. skip this operaration(a<<b)");
    }
    
    )*  
    ;

add_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
    :a=mult_expr 
     {
       if(exetag){
    {
     $type=$a.type;
     if($a.index!=null) $index=$a.index;
    
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
    }
    }
    
    (c= ('+'|'-')b=mult_expr 
   {
     if(exetag){
    String newtype;
    double doublea=0,doubleb=0;
    int inta=0,intb=0;
    if($type.equals("double")||$b.type.equals("double")) 
    {
    newtype="double";
    
    if($type.equals("int")&&$a.index==null) doublea=(double)$int_val; else if($type.equals("int")&&$a.index!=null  )System.out.println("error not supported type casting int -> double ");
    else if($type.equals("double")) doublea=$double_val;
    else if($type.equals("char")) doublea=(double)$char_val;
    else System.out.println("unsupported mult calculation ");
    
     if($b.type.equals("int")&&$b.index==null) doubleb=(double)$b.int_val; else if($b.type.equals("int")&&$b.index!=null  )System.out.println("error not supported type casting int -> double ");
    else if($b.type.equals("double")) doubleb=$b.double_val;
    else if($b.type.equals("char")) doubleb=(double)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    $type="double";
    }
    else if($type.equals("String")||$b.type.equals("String")) 
    {
    System.out.println("error:multiply of string is not defined");
    $type="fail";
    }
    else
    {
     newtype="int";
      
    if($type.equals("int")) inta=$int_val;
    else if($type.equals("double")) inta=(int)$double_val;
    else if($type.equals("char")) inta=(int)$char_val;
    else System.out.println("unsupported mult calculation ");
    
    if($b.type.equals("int")) intb=$b.int_val;
    else if($b.type.equals("double")) intb=(int)$b.double_val;
    else if($b.type.equals("char")) intb=(int)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    
    $type="int";
    }
    
    
      if($c.text.equals("+")) 
    {
    if($type.equals("int"))
    {
    
      if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = add nsw i32 \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = add nsw i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = add nsw i32 \%t" + $b.index + ", " + inta);
    $index=String.valueOf(varcount);
    }
    
    $int_val=inta+intb;
    }
    else if($type.equals("double"))
    {
   
    if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = fadd double  \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);



    }else if($a.index!=null&&$b.index==null)
    {
    long tmp=Double.doubleToLongBits(doubleb);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fadd double  \%t" +$a.index + ", " + strcat  );
    $index=String.valueOf(varcount);
    }
    else if($a.index==null&&$b.index!=null)
    {
   long tmp=Double.doubleToLongBits(doublea);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fadd double \%t" +$b.index + ", " + strcat  );
    $index=String.valueOf(varcount);
    }
    
    
    $double_val=doublea+doubleb;
    }
    }
    else if($c.text.equals("-")) 
    {
    if($type.equals("int"))
    {
    
       if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = sub nsw i32 \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = sub nsw i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = sub nsw i32 " + inta + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
    }
    
    $int_val=inta-intb;
    }
    else if($type.equals("double"))
    {
    
       if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = fsub double  \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);



    }else if($a.index!=null&&$b.index==null)
    {
    long tmp=Double.doubleToLongBits(doubleb);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fsub double  \%t" +$a.index + ", " + strcat  );
    $index=String.valueOf(varcount);
    }
    else if($a.index==null&&$b.index!=null)
    {
   long tmp=Double.doubleToLongBits(doublea);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fsub double " +strcat + ", \%t" + $b.index );
    $index=String.valueOf(varcount);
    }
    
    
    
    $double_val=doublea-doubleb;
    }
    }
    
      //if($type.equals("double"))  System.out.println("double"+$double_val);
   //if($type.equals("int")) System.out.println("int"+$int_val);
   }
   
   }  
    )* 
   
    ;

mult_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
    :a=prefix_expr  
    {
      if(exetag){
    {
     $type=$a.type;
      if($a.index!=null) $index=$a.index;
    if($type.equals("String")) $str_val=$a.str_val;
    else if($type.equals("int")) $int_val=$a.int_val;
    else if($type.equals("double")) $double_val=$a.double_val;
    else if($type.equals("char")) $char_val=$a.char_val;
    else System.out.println("unsupported");
    }
    }
    }
    
    ( c=('*'|'/'|'%')  b=prefix_expr      
    {
      if(exetag){
    String newtype;
    double doublea=0,doubleb=0;
    int inta=0,intb=0;
    if($type.equals("double")||$b.type.equals("double")) 
    {
    newtype="double";
    
    if($type.equals("int")&&$a.index==null) doublea=(double)$int_val; else if($type.equals("int")&&$a.index!=null  )System.out.println("error not supported type casting int -> double ");
    else if($type.equals("double")) doublea=$double_val;
    else if($type.equals("char")) doublea=(double)$char_val;
    else System.out.println("unsupported mult calculation ");
    
    if($b.type.equals("int")&&$b.index==null) doubleb=(double)$b.int_val; else if($b.type.equals("int")&&$b.index!=null  )System.out.println("error not supported type casting int -> double ");
    else if($b.type.equals("double")) doubleb=$b.double_val;
    else if($b.type.equals("char")) doubleb=(double)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    $type="double";
    }
    else if($type.equals("String")||$b.type.equals("String")) 
    {
    System.out.println("error:multiply of string is not defined");
    $type="fail";
    }
    else
    {
     newtype="int";
      
    if($type.equals("int")) inta=$int_val;
    else if($type.equals("double")) inta=(int)$double_val;
    else if($type.equals("char")) inta=(int)$char_val;
    else System.out.println("unsupported mult calculation ");
    
    if($b.type.equals("int")) intb=$b.int_val;
    else if($b.type.equals("double")) intb=(int)$b.double_val;
    else if($b.type.equals("char")) intb=(int)$b.char_val;
    else System.out.println("unsupported mult calculation ");
    
    $type="int";
    }
    
    
    
    if($c.text.equals("*")) 
    {
    if($type.equals("int"))
    {
    $int_val=inta*intb;
    
    if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = mul nsw i32 \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = mul nsw i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = mul nsw i32 \%t" + $b.index + ", " + inta);
    $index=String.valueOf(varcount);
    }
    
    }
    else if($type.equals("double"))
    {
    $double_val=doublea*doubleb;
    
    if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = fmul double  \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);



    }else if($a.index!=null&&$b.index==null)
    {
    long tmp=Double.doubleToLongBits(doubleb);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fmul double  \%t" +$a.index + ", " + strcat  );
    $index=String.valueOf(varcount);
    }
    else if($a.index==null&&$b.index!=null)
    {
   long tmp=Double.doubleToLongBits(doublea);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fmul double \%t" +$b.index + ", " + strcat  );
    $index=String.valueOf(varcount);
    }
    
    
    }
    }
    
    if($c.text.equals("/")) 
    {
    if($type.equals("int"))
    {
    if(intb==0){System.out.println("warning div by 0,set ans =0"); $int_val=0;}
    else $int_val=inta/intb;
    
      if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = sdiv  i32 \%t" + $a.index+ ", \%t" + $b.index);
    $index=String.valueOf(varcount);
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = sdiv i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = sdiv i32 \%t" + $b.index + ", " + inta);
    $index=String.valueOf(varcount);
    }
    
    
    
    }
    else if($type.equals("double"))
    {
     if(doubleb==0){System.out.println("warning div by 0,set ans =0"); $double_val=0;}
    else $double_val=doublea/doubleb;
    
     if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = fdiv double  \%t" + $a.index + ", \%t" + $b.index);
    $index=String.valueOf(varcount);



    }else if($a.index!=null&&$b.index==null)
    {
    long tmp=Double.doubleToLongBits(doubleb);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fdiv double  \%t" +$a.index + ", " + strcat  );
    $index=String.valueOf(varcount);
    }
    else if($a.index==null&&$b.index!=null)
    {
   long tmp=Double.doubleToLongBits(doublea);
    String strcat = "0x" +  Long.toHexString(tmp) ;
    strcat = strcat.replaceAll(" ","");
    
    varcount++;
    TextCode.add("\%t" + varcount + " = fdiv double \%t" +$b.index + ", " + strcat  );
    $index=String.valueOf(varcount);
    }
    
    
    }
    }
    
     if($c.text.equals("\%")) 
    {
    
    if($type.equals("int"))
    {
    
        if($a.index!=null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = srem i32 \%t" + $a.index+ ", \%t" + $b.index);
    $index=String.valueOf(varcount);
    }else if($a.index!=null&&$b.index==null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = srem i32 \%t" + $a.index + ", " + intb);
    $index=String.valueOf(varcount);
    }
    else if($a.index==null&&$b.index!=null)
    {
    varcount++;
    TextCode.add("\%t" + varcount + " = srem i32 \%t" + $b.index + ", " + inta);
    $index=String.valueOf(varcount);
    }
    
    
    if(intb==0){System.out.println("warning div by 0,set ans =0"); $int_val=0;}
    else {inta\%=intb;$int_val=inta;}
    }
    else if($type.equals("double"))
    {
    System.out.println("error!  \% is not supported for double "); System.exit(1);
     if(doubleb==0){System.out.println("warning div by 0,set ans =0"); $double_val=0;}
    else {doublea\%=doubleb;;$double_val=doublea;}
    }
    }
     }
    }
      )*
      {
  // if($type.equals("double"))  System.out.println("double"+$double_val);
   //if($type.equals("int")) System.out.println("int"+$int_val);
      }
   
    ;

prefix_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
    :'++'f=prefix_expr 
    {
      if(exetag){
    System.out.println("unsupported ++ or -- ignore ++/-- and continue");
    $type=$f.type;
    if($type.equals("String")) $str_val=$f.str_val;
    else if($type.equals("int")) $int_val=$f.int_val;
    else if($type.equals("double")) $double_val=$f.double_val;
    else if($type.equals("char")) $char_val=$f.char_val;
    else System.out.println("unsupported");
    }
    }
    |'--'g=prefix_expr 
    {
      if(exetag){
    System.out.println("unsupported ++ or -- ignore ++/-- and continue");
    $type=$g.type;
    if($type.equals("String")) $str_val=$g.str_val;
    else if($type.equals("int")) $int_val=$g.int_val;
    else if($type.equals("double")) $double_val=$g.double_val;
    else if($type.equals("char")) $char_val=$g.char_val;
    else System.out.println("unsupported");
    }
    }
    |'!'e=prefix_expr  
    {
      if(exetag){
      System.out.println("unsupported ! ignore ! and continue");
    $type=$e.type;
    if($type.equals("String")){ $type="int"; $int_val=0;}
    else if($type.equals("int")){$type="int"; if($e.int_val==0) $int_val=1; else $int_val=0; }
    else if($type.equals("double")) {$type="int"; if($e.double_val==0) $int_val=1; else $int_val=0; }
    else if($type.equals("char")){$type="int"; if((int)$e.char_val==0) $int_val=1; else $int_val=0; }
    else System.out.println("unsupported");
    }
  
    }
    |'~'prefix_expr  
    {
    
    $type="fail";
    System.out.println("unsupported  ~expr");
    
    }
    |'*'c=prefix_expr  //* and & is not really implemented *or &(something) means something itself
    {
      if(exetag){
    $type=$c.type;
     if($c.index!=null) $index=$c.index;
    if($type.equals("String")) $str_val=$c.str_val;
    else if($type.equals("int")) $int_val=$c.int_val;
    else if($type.equals("double")) $double_val=$c.double_val;
    else if($type.equals("char")) $char_val=$c.char_val;
    else System.out.println("unsupported");
    }
    }
    |'&'d=prefix_expr  
    {
      if(exetag){
    $type=$b.type;
     if($d.index!=null) $index=$d.index;
    if($type.equals("String")) $str_val=$d.str_val;
    else if($type.equals("int")) $int_val=$d.int_val;
    else if($type.equals("double")) $double_val=$d.double_val;
    else if($type.equals("char")) $char_val=$d.char_val;
    else System.out.println("unsupported");    
    }
    }
    |'(' var_decelartion_prefix* x=BASIC_TYPE ')'y= prefix_expr 
    {
      if(exetag){
    System.out.println("type casting is not supported yet. skip casting");
    $type=$y.type;
     if($type.equals("String")) $str_val=$y.str_val;
    else if($type.equals("int")) $int_val=$y.int_val;
    else if($type.equals("double")) $double_val=$y.double_val;
    else if($type.equals("char")) $char_val=$y.char_val;
    else System.out.println("unsupported");    
    }
    }
    |'-'a=constant_num
    {
    if(exetag){
    $type=$a.type;
    if($type.equals("int")) $int_val=$a.int_const*-1;
    else if($type.equals("double")) $double_val=$a.double_const*-1;
    else System.out.println("unsupported  num type" + $a.text);
    
    System.out.println(" "+$int_val);
    }
    }
    |'sizeof' '(' (( ID (('.'|'->')ID)*   )|( var_decelartion_prefix* BASIC_TYPE  )) ')'
    {
    $type="fail";
    System.out.println("unsupported  sizeof expr");
    }
    |b=suffix_expr
    {
    if(exetag){
     $type=$b.type;
      if($b.index!=null) $index=$b.index;
    if($type.equals("String")) $str_val=$b.str_val;
    else if($type.equals("int")) $int_val=$b.int_val;
    else if($type.equals("double")) $double_val=$b.double_val;
    else if($type.equals("char")) $char_val=$b.char_val;
    else System.out.println("unsupported");
    }
    }
    ;

suffix_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
    :x=primary_expr '(' y=arith_expr? ')' 
    {
    {
     System.out.println("unsupported function call "+$x.text+"("+$y.text+")");
     $type="func";
    }
    }
    |primary_expr '[' assign_expr ']'
    {
     System.out.println("unsupported array index id[] expr ");
     $type="array";
    }
    |c=primary_expr d=('++'|'--')      
    {
    if(exetag){
    System.out.println("unsupported ++ or -- ignore ++/-- and continue");
    $type=$c.type;
    if($type.equals("String")) $str_val=$c.str_val;
    else if($type.equals("int")) $int_val=$c.int_val;
    else if($type.equals("double")) $double_val=$c.double_val;
    else if($type.equals("char")) $char_val=$c.char_val;
    else System.out.println("unsupported");
    }
    }
    |primary_expr ('.'|'->') ID     
    {
    $type="fail";
    System.out.println("unsupported  expr . ID ");
    }
    |b=primary_expr  
    {
    if(exetag){
    $type=$b.type;
    if($b.index!=null) $index=$b.index;
    if($type.equals("String")) $str_val=$b.str_val;
    else if($type.equals("int")) $int_val=$b.int_val;
    else if($type.equals("double")) $double_val=$b.double_val;
    else if($type.equals("char")) $char_val=$b.char_val;
    else System.out.println("unsupported");
    }
    }
    ;

primary_expr returns [String type ,String str_val,char char_val,int int_val,double double_val,String index]
    :a=ID 
    {
    if(exetag){
    String tp=(String)typemap.get($a.text);
    if(tp==null) {System.out.println("undefined variable "+$a.text);$type="fail";}
    else
    {
    String vIndex = (String)indexmap.get($a.text);
    $type=tp;
   if(valuemap.get($a.text)==null) System.out.println("var has no value "+$a.text);
    else if($type.equals("String")) $str_val=(String) valuemap.get($a.text);
    else if($type.equals("int")) {$int_val=           Integer.parseInt(    (String)    valuemap.get($a.text)       )   ;  varcount++;   TextCode.add("\%t" + varcount + "=load i32, i32* \%t" + vIndex);$index=String.valueOf(varcount);}
    else if($type.equals("double")) {$double_val=      Double.parseDouble    (         (String)    valuemap.get($a.text)          );varcount++;   TextCode.add("\%t" + varcount + "=load double, double* \%t" + vIndex);$index=String.valueOf(varcount);}
    else if($type.equals("char")) $char_val=$a.text.charAt(0);
    else System.out.println("unsupported");
    }
    }
    }
    |b=constant
    {
    if(exetag){
    $type=$b.type;
    if($type.equals("String")) $str_val=$b.str_const;
    else if($type.equals("int")) $int_val=$b.int_const;
    else if($type.equals("double")) $double_val=$b.double_const;
    else if($type.equals("char")) $char_val=$b.char_const;
    else System.out.println("unsupported");
    }
    }
       |'('c= assign_expr ')'
       {
       if(exetag){
       $type=$c.type;
       
       
       if($type.equals("String")) $str_val=$c.str_val;
    else if($type.equals("int")) $int_val=$c.int_val;
    else if($type.equals("double")) $double_val=$c.double_val;
    else if($type.equals("char")) $char_val=$c.char_val;
    else System.out.println("unsupported type "+$type);
       }
       }

    ;


BASIC_TYPE
    :'short'
    |'int'
    |'long'
    |'double'
    |'float'
    |'char'
    |'void'
    ;

SIGN
    :'signed'
    |'unsigned'
    ;

EXTEND_TYPE
    :'struct'
    |'enum'
    |'union'
    ;

TYPEDEF
    :'typedef'
    ;

TYPE_MODIFIER
    :'const'
    |'restrict'
    |'volatile'
    ;

NULL_PTR
    :'NULL'
    ;

STORAGE_CLASS_SPECIFIER
    : 'extern'
	| 'static'
	| 'auto'
	| 'register'
	;

INLINE
    :'inline'
    ;

FLOW_CONTROL
    :'if'
    |'else'
    |'switch'
    |'case'
    |'default'
    ;



FOR
	:'for'
	;

WHILE
	:'while'
	;

DO
	:'do'
	;

LOOP_CTRL
	:'break'
	| 'continue'
	;

JUMP
    :'goto'
    |'return'
    ;

SIZEOF
    :'sizeof'
    ;


LITERAL_STRING
    :'"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

LITERAL_CHAR
    :'\'' (~('\'')|EscapeSequence) '\''
    ;

DECIMAL_INT
    : ('0' | '1'..'9' '0'..'9'*)
    ;

HEX_INT
    : '0' ('x'|'X') ('0'..'9'|'A'..'F'|'a'..'f')+
    ;

OCTAL_INT
    :'0' ('0'..'7')+
    ;
    
FLOAT
    :('0'..'9')+ '.' ('0'..'9')* (('e'|'E') ('+'|'-')? ('0'..'9')+ )? ('f'|'F'|'d'|'D')?
    |'.' ('0'..'9')+ (('e'|'E') ('+'|'-')? ('0'..'9')+ )? ('f'|'F'|'d'|'D')?
    |('0'..'9')+ (  (('e'|'E') ('+'|'-')? ('0'..'9')+ )|  ('f'|'F'|'d'|'D') |(('e'|'E') ('+'|'-')? ('0'..'9')+ ) ('f'|'F'|'d'|'D'))
    ;

PARENTHESES_LEFT
    :'('
    ;

PARENTHESES_RIGHT
    :')'
    ;

SQUARE_BRACKETS_LEFT
    :'['
    ;

SQUARE_BRACKETS_RIGHT
    :']'
    ;

CURLY_BRACKETS_LEFT
    :'{'
    ;

CURLY_BRACKETS_RIGHT
    :'}'
    ;

COLON
    :':'
    ;


SEMI_COLON
    :';'
    ;

COMMA
    :','
    ;

DOT
    :'.'
    ;

ARROW
    :'->'
    ;

QUESTION
    :'?'
    ;

  LOGICAL_EQUALITY_OPERATOR
  	:'=='
  	|'!='
  	;

SHIFT_OPERATOR
    :'<<'
    |'>>'
    ;

COMPARISON_OPERATOR
    :'<'
    |'<='
    |'>'
    |'>='
    ;
  

ASSIGN_OPERATOR
    :
    '+='
    |'-='
    |'*='
    |'/='
    |'%='
    |'|='
    |'&='
    |'^='
    |'<<='
    |'='
    |'>>='
    ;
    
 PLUSPLUS
    :'++'
    ;

PLUS
    :'+'
    ;

MINUSMINUS
    :'--'
    ;

MINUS
    :'-'
    ;

DIVIDE
    :'/'
    ;

MOD
    :'%'
    ;

MULT
    :'*'
    ;

OROR
    :'||'
    ;

OR
    :'|'
    ;

ANDAND
    :'&&'
    ;

AND
    :'&'
    ;

NOT
    :'~'
    ;

XOR
    :'^'
    ;

WOW
    :'!'
    ;

ID
	:	LETTER (LETTER|DIGIT)*
	;

WS
    :(' '|'\r'|'\t'|'\u000C') {$channel=HIDDEN;}
    ;

NEW_LINE: '\n'{$channel=HIDDEN;};

COMMENT
    :   '/*' ( options {greedy=false;} : . )* '*/'
    ;

LINE_COMMENT
    : '//' ~('\n'|'\r')* '\r'? '\n'?{$channel=HIDDEN;}
    ;

LINE_COMMAND 
    :'#' ~('\n'|'\r')* '\r'? '\n'?{$channel=HIDDEN;}
    ;

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';
fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   OctalEscape
    ;

fragment
OctalEscape
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;
 
 


/*
LOGICAL_OPERATOR
    :'!'
    |'||'
    |'&&'
    ;


    INDECREASE
  	:'++'
  	|'--'	
  	;
  	
 BITWISE_OPERATOR
    :'|'
    |'&'
    |'~'
    |'^'
    ;

MATH_OPERATOR
    :'+'
    |'-'
    |'/'
    |'*'
    |'%'
    ;

*/



/*if_statment
@init{boolean tmpcondit=true; boolean initexetag=exetag; String next; String elseLabel; String finalLabel;}
	:'if' '(' a=arith_expr ')'
	{
	if(initexetag){
	if($a.type.equals("String")) tmpcondit=true;
	else if($a.type.equals("int"))  {      if($a.int_val !=0) tmpcondit=true;    else tmpcondit=false;                               }
	else if($a.type.equals("double")){      if($a.double_val !=0) tmpcondit=true;    else tmpcondit=false;                               }
	else if($a.type.equals("char")){      if((int)$a.char_val !=0) tmpcondit=true;    else tmpcondit=false;                               }
	else System.out.println("error: unknown condition type "+$a.type);
	
	if(tmpcondit) exetag=true; else exetag=false;
	}
	}
	 (  statment| ('{' statments )  '}' ) 
	 {
	 if(initexetag) exetag=true;
	 }
	 ('else'  
	 {
	 if(initexetag) if(!tmpcondit) exetag=true; else exetag=false;
	 } 
	 (  statment| ('{' statments )  '}' )  )?
	 
	 {
	 if(initexetag) exetag=true;
	 } 
	;
	*/
	/*
	if(exetag)
	{
	int len = $x1.text.length();
	 String typey1=$y1.type;
	String typez1=$z1.type;
	int valy=0;
	int valz=0;
	
	if(typey1.equals("String")){      System.out.println("error: unsupported parameter type in printf "+typey1);   }
	else if(typey1.equals("int"))  {               valy=$y1.int_val;          }
	else if(typey1.equals("double")){            valy=(int)$y1.double_val          ;    }
	else if(typey1.equals("char")){        valy=(int)$y1.char_val;          }
	else System.out.println("error: unsupported parameter type "+typey1);
	
	if(typez1.equals("String")){      System.out.println("error: unsupported parameter type in printf "+typez1);   }
	else if(typez1.equals("int"))  {               valz=$z1.int_val;          }
	else if(typez1.equals("double")){            valz=(int)$z1.double_val          ;    }
	else if(typez1.equals("char")){        valz=(int)$z1.char_val;          }
	else System.out.println("error: unsupported parameter type "+typez1);
	
	System.out.printf($x1.text.substring(1,len-1).replace("\\n","\%n"),valy,valz);  
	
	
	}
	*/