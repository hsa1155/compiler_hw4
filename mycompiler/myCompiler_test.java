import org.antlr.runtime.*;
import java.util.ArrayList;
import java.util.List;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.Objects;

public class myCompiler_test {
	public static void main(String[] args) throws Exception {

      CharStream input = new ANTLRFileStream(args[0]);
      myCompilerLexer lexer = new myCompilerLexer(input);
      CommonTokenStream tokens = new CommonTokenStream(lexer);
      PrintWriter printWriter = null;
 
      myCompilerParser parser = new myCompilerParser(tokens);
      parser.global_decelaration();
      try {
            printWriter = new PrintWriter("aout.ll");
        } catch (FileNotFoundException e) {
            System.out.println("Unable to locate the fileName: " + e.getMessage());
        }
      /* Output text section */
      List<String> text_code = parser.getTextCode();
      System.out.println("");
      System.out.println("");
      for (int i=0; i < text_code.size(); i++){
         System.out.println(text_code.get(i));
         
        Objects.requireNonNull(printWriter).println(text_code.get(i));


      }
      printWriter.close();
      }
}
