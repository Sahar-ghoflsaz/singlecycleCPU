using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;


namespace Miniature_Compiler
{
    class Program
    {
        public int pcplus4 = 0;
        public static string[] Instructions;
        public static string[] instruction;
        public string[] symbolTable;
        public string[] output;
        public void error_check ()
        {
            Environment.Exit(0);
        }

        int[] memory = new int[256];

        public void initial(string[] tempo)
        {
            Instructions = tempo;
            symbolTable = new string[tempo.Length];
            output = new string[tempo.Length];
            
        }
         public void exitFunction(){  
            Array.Clear(Instructions, 0, Instructions.Length);
            Array.Clear(symbolTable, 0, symbolTable.Length);
            Array.Clear(instruction, 0, Instructions.Length);
            Array.Clear(output, 0, symbolTable.Length);
         }
        
        public bool check_duplicate_label(string[] Instructions)
        {
            for (int i = 0; i < Instructions.Length;i++)
            {
                string[] tabSplit = Instructions[i].Split('\t');
                if (tabSplit.Length < 3 || tabSplit[0] =="")
                    continue;
                string test = tabSplit[0];
                for (int j = i+1; j < Instructions.Length;j++)
                {
                    string[] tabSplit1 = Instructions[j].Split('\t');
                    if (tabSplit1.Length < 3)
                        continue;
                    if (test == tabSplit1[0])
                        return false;
                }
            }


            return true;
        }



        public void delete_comments(string[] Instructions, int i)
        {
            string[] withoutcom = Instructions[i].Split('#');
            if (withoutcom.Length > 1)
            {
                Instructions[i] = withoutcom[0];
                Instructions[i]= Instructions[i].Remove(Instructions[i].Length - 1);
            }
        }
        public bool fillTable(string[] Instructions, string[] symbolTable)
        {
            using (StreamWriter sw = new StreamWriter(@"E:\visual\INSTRUCTIONS1.txt"))
            {
                for (int y = 0; y < Instructions.Length; y++)
                {
                    sw.WriteLine(Instructions[y]);
                }

            }
            Console.WriteLine(Instructions.Length);
            for (int i = 0 ; i < Instructions.Length; i++)
            {

                string[] label = Instructions[i].Split('\t');

                if (label[0] == "")
                {
                    symbolTable[i] = "";
                }
                else
                {
                    for (int j = 0; j < i; j++)
                    {
                        if (symbolTable[j] == label[0]) return false;
                    }
                    symbolTable[i] = label[0];
                }
              
            }
            using (StreamWriter sw = new StreamWriter(@"E:\visual\INSTRUCTIONS2.txt"))
            {
                for (int y = 0; y < Instructions.Length; y++)
                {
                    sw.WriteLine(Instructions[y]);
                }

            }
            return true;
           
        }

        public bool check_lable_availablity(string[] Instructions, string[] symbolTable, int i)
        {
            int number;  
            string[] tabSplit = Instructions[i].Split('\t');
            Console.WriteLine(tabSplit.Length);
            
            string[] commaSplit = { "" };

            if (tabSplit.Length == 2) // halt and noop
                return true;

            else if (tabSplit.Length == 3)
                commaSplit = tabSplit[2].Split(',');

            if (!(int.TryParse(commaSplit[commaSplit.Length - 1], out number))) //find out whether its offset is label or number
            {
                for (int k = 0; k < symbolTable.Length; k++)
                {

                    if (commaSplit[commaSplit.Length - 1] == symbolTable[k])
                    {
                        commaSplit[commaSplit.Length - 1] = (4 * k).ToString();
                        
                        if (tabSplit[1] == "beq")
                        {
                            commaSplit[commaSplit.Length - 1] = ((4 * k)-(i*4)-4).ToString();
                        }
                        tabSplit[2] = string.Join(",", commaSplit);
                        Instructions[i] = string.Join("\t", tabSplit);
                        return true;
                    }

                }
                return false;
            }
            return true;

        }

        public void sync(string[] Instructions, int i)
        {
     
            string[] a = Instructions[i].Split('\t',' ');
            int alength= a.Length;
            for (int j = 1; j < alength; j++)
            {
                if (a[j] == "" )
                {
                    for (int k = j; k < alength-1; k++)
                    {
                        a[k] = a[k + 1];
                    }
                    alength = alength - 1;
                    j=j-1;
                }
            
            }
            Instructions[i] = string.Join("\t", a, 0, alength);
            
        }
        public string IntToBinary4(string str)
        {

            string binary = "";
            int offset = Convert.ToInt32(str);
            binary = Convert.ToString(offset, 2);

            if (offset > 16 || offset < 0)
            {
                Console.WriteLine("Error: No such a register is available");
                exitFunction();
                System.Environment.Exit(0);
            }
            while (binary.Length < 4)
                binary = binary.Insert(0, "0"); // zero extend
            binary = binary.Substring(binary.Length - 4, 4);
            return binary;
        }

        public string IntToBinary16(string str)
        {

            string binary = "";
            int offset = Convert.ToInt32(str);
            binary = Convert.ToString(offset, 2);

            if (offset > 32767 || offset < -32768)
            {
                Console.WriteLine("Offset doesn't fit in 16 bits");
                exitFunction();
                System.Environment.Exit(0);
            }
            while (binary.Length < 16)
                binary = binary.Insert(0, "0");
            binary = binary.Substring(binary.Length - 16, 16);

            return binary;
        }


        public string[] assmble(string[] instruction , int len)
        {


            string[] tempo = new string[len];
            for (int i = 0; i < len; i++)
            {
                tempo[i] = instruction[i];
            }
            initial(tempo);
            if (Instructions[0] != null)
            {
                bool duplicate = fillTable(Instructions, symbolTable);
                if (!duplicate)
                {
                    Console.WriteLine("Error: Duplication in Lables");
                    exitFunction();
                    System.Environment.Exit(0);
                } 

                for (int i = 0; i < Instructions.Length; i++) 
                {
                    delete_comments(Instructions, i); //use this function to delete all the comments after '#'

                    sync(Instructions, i); // convert to same structure for the sake of better encodeig
                    Console.WriteLine(i);
                    bool RightLabel = check_lable_availablity(Instructions,symbolTable,i); //symbolic labels to number and chck their availability
                   
                    if (!RightLabel)
                    {
                        Console.WriteLine("Error: line " + i + " No such a Label in the Symbol Table ");
                        exitFunction();
                        System.Environment.Exit(0);

                    }
                }
           
            }
            if (Instructions[0]!=null)
            {
                for (int i = 0; i < Instructions.Length; i++)
                {

                    string[] temp = Instructions[i].Split('\t');
                    string result = "";
                    string compare = "";
                    int index = 2; // the registers are available here

                    compare = temp[1];

                    if (compare == "add" || compare == "sub" || compare == "slt" || compare == "or" || compare == "nand")
                    {
                        result = "000000000000";
                        string[] registers = temp[index].Split(',');
                        string rd = IntToBinary4(registers[0]);
                        result = rd + result;

                        string rt = IntToBinary4(registers[2]);
                        result = rt + result;

                        string rs = IntToBinary4(registers[1]);
                        result = rs + result;
                        if (compare == "add")
                        {
                            result = "00000000" + result;
                        }
                        else if (compare == "sub")
                        {
                            result = "00000001" + result;
                        }
                        else if (compare == "slt")
                        {
                            result = "00000010" + result;
                        }
                        else if (compare == "or")
                        {
                            result = "00000011" + result;
                        }
                        else if (compare == "nand")
                        {
                            result = "00000100" + result;
                        }
                    }
                    else if (compare == "addi" || compare == "slti" || compare == "ori" || compare == "lw" || compare == "sw" || compare == "beq")
                    {
                        string[] registers = temp[index].Split(',');

                        result = IntToBinary16(registers[2]);

                        string rt = IntToBinary4(registers[0]);
                        result = rt + result;

                        string rs = IntToBinary4(registers[1]);
                        result = rs + result;
                        if (compare == "addi")
                        {
                            result = "00000101" + result;
                        }
                        else if (compare == "ori")
                        {
                            result = "00000110" + result;
                        }
                        else if (compare == "slti")
                        {
                            result = "00000111" + result;
                        }
                        else if (compare == "lw")
                        {
                            result = "00001001" + result;
                        }
                        else if (compare == "sw")
                        {
                            result = "00001010" + result;
                        }
                        else if (compare == "beq")
                        {
                            result = "00001011" + result;
                        }
                    }
                    else if (compare == "lui")
                    {
                        string[] registers = temp[index].Split(',');
                        result = IntToBinary16(registers[1]);
                        string rt = IntToBinary4(registers[0]);
                        result = rt + result;
                        result = "0000" + result; //rs
                        result = "00001000" + result;//op
                    }
                    else if (compare == "jalr")
                    {
                        string[] registers = temp[index].Split(',');
                        result = "0000000000000000"; // offset
                        string rt = IntToBinary4(registers[0]);
                        result = rt + result;

                        string rs = IntToBinary4(registers[1]);
                        result = rs + result;

                        result = "00001100" + result;
                    }
                    
                    else if (compare == "j")
                    {
                        result = IntToBinary16(temp[index]);// offset

                        result = "00000000" +result; // 8 bit zero
                        result = "00001101" + result;
                    }
                    else if (compare == "noop") // zero except for opcode
                    {
                        result = "0000000000000000"; // offset
                        result = "0000111000000000" + result; // opcode and unused
                    }
                    else if (compare == "halt") // zero except for opcode
                    {
                        result = "0000000000000000"; // offset
                        result = "0000111100000000" + result; // opcode and unused  
                    }

                    else if (compare == ".space")
                    {
                        int offset = Convert.ToInt32(temp[2]);
                        for (int f = 0; f < offset; f++)
                        {
                            memory[pcplus4] = 0;
                            pcplus4 = pcplus4 + 4;
                        }
                        result = "00000000000000000000000000000000";
                    }
                    else if (compare == ".fill") 
                    {

                        int offset = Convert.ToInt32(temp[2]);
                        memory[pcplus4] = offset;

                        result = Convert.ToString(offset, 2);
                        while (result.Length < 32)
                            result = result.Insert(0, "0");
                        result = result.Substring(result.Length - 32, 32);
                    }
                    else
                    {
                        Console.WriteLine("Error: Wrong opcode");
                        exitFunction();
                        System.Environment.Exit(0);

                    }
                    pcplus4+=4;
                    output[i] = result;

                }
            }
           
           /* using (StreamWriter sw = new StreamWriter(@"C:\Users\Sahar Ghoflsaz\Desktop\miniature\MIPSinCSharp-master\assembly.mc"))
            {
                for (int i = 0; i < Instructions.Length; i++)
                {
                    sw.WriteLine(output[i]);
                }
            }*/


            using (StreamWriter sw = new StreamWriter(@"C:\Users\Sahar Ghoflsaz\Desktop\miniature\MIPSinCSharp-master\assembly1.mc"))
            {
                for (int y = 0; y < Instructions.Length; y++)
                {
                    sw.WriteLine(Instructions[y]);
                }

            }

            using (StreamWriter sw = new StreamWriter(@"C:\Users\Sahar Ghoflsaz\Desktop\miniature\MIPSinCSharp-master\symbolTable.mc"))
            {
                for (int y = 0; y < symbolTable.Length; y++)
                {
                    sw.WriteLine(symbolTable[y]);
                }

            }
            Console.WriteLine("Finish! :)");
            
            return output;
        }

        public static void Main(string[] args)
        {
            StreamReader input = new StreamReader(@"C:\Users\Sahar Ghoflsaz\Desktop\miniature\MIPSinCSharp-master\assembly.mc");
            int i = 0;
            instruction = new string[200];
            string[] output1 = new string[200];
            if (args.Any())
            {
                var path = args[0];
                if (File.Exists(path))
                {
                    input = File.OpenText(path);
                }
            }

            for (string line; (line = input.ReadLine()) != null; )
            {
                instruction[i] = line;
                i++;
            }
           
            Program P = new Program();
            //Miniature mini = new Miniature(instruction);
            output1 = P.assmble(instruction,i);
            Console.WriteLine("hello");
            Console.WriteLine(output1.Length);
            Console.WriteLine(args.Length);

            Console.WriteLine(args[0]);
            Console.WriteLine(args[1]);
            using (StreamWriter sw = new StreamWriter(args[1]))
            {
                for (int j = 0; j < output1.Length; j++)
                {
                    Console.WriteLine(output1[j]);
                    sw.WriteLine(output1[j]);
                }

            }
            P.exitFunction();
            Array.Clear(output1, 0, output1.Length);
            System.Environment.Exit(0);
        }
    }
}