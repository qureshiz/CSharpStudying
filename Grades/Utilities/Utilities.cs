using System.IO;

namespace Utilities
{
    class ReadFromFile
    {
        static void Main()
        {

            string text = File.ReadAllText("c:\BreachedIncidents.txt");
        }
    }
}
