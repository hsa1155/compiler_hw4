all:myCompiler_test.class myCompiler_test.class myCompilerLexer.java myCompiler.tokens myCompilerParser.java


myCompilerLexer.class:myCompilerLexer.java myCompilerParser.java myCompiler_test.java
	javac -cp ./antlr-3.5.2-complete-no-st3.jar  myCompiler_test.java myCompilerLexer.java myCompilerParser.java

myCompilerParser.class:myCompilerLexer.java myCompilerParser.java myCompiler_test.java
	javac -cp ./antlr-3.5.2-complete-no-st3.jar  myCompiler_test.java myCompilerLexer.java myCompilerParser.java

myCompiler_test.class:myCompilerLexer.java myCompilerParser.java myCompiler_test.java
	javac -cp ./antlr-3.5.2-complete-no-st3.jar  myCompiler_test.java myCompilerLexer.java myCompilerParser.java

myCompilerLexer.java:myCompiler.g
	java -jar antlr-3.5.2-complete-no-st3.jar myCompiler.g

myCompilerParser.java:myCompiler.g
	java -jar antlr-3.5.2-complete-no-st3.jar myCompiler.g

run1:myCompiler_test.class
	java -cp ./antlr-3.5.2-complete-no-st3.jar:. myCompiler_test input1.c

run2:myCompiler_test.class
	java -cp ./antlr-3.5.2-complete-no-st3.jar:. myCompiler_test input2.c

run3:myCompiler_test.class
	java -cp ./antlr-3.5.2-complete-no-st3.jar:. myCompiler_test input3.c

run4:myCompiler_test.class
	java -cp ./antlr-3.5.2-complete-no-st3.jar:. myCompiler_test input4.c

run5:myCompiler_test.class
	java -cp ./antlr-3.5.2-complete-no-st3.jar:. myCompiler_test input5.c

run:aout.ll
	lli aout.ll

clean:
	rm -rf myCompiler.tokens myCompilerLexer.java myCompilerParser.java *.class aout.* a.out *.ll a.out 