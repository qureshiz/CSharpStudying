using System.IO;
using System;
using System.Linq;

namespace Utilities
{
    class ReadFromFile
    {
        static void Main()
        {

            string[] lines = File.ReadAllLines(@"c:\temp\BreachedIncidents.txt");

            foreach (string s in lines)
            {
                System.Console.WriteLine(s);
            }
            
        }

    }
}
