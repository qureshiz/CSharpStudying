using System;

namespace Grades
{
    class Program
    {

        static void Main(string[] args)  // What is this?
        {
            GradeBook book = new GradeBook(); 
            book.AddGrade(91);
            book.AddGrade(89.5f);   // f indifcates it's a float.  Otherwise it gives error 'cannot convert from double to float'.
            book.AddGrade(75);
            GradeStatistics stats = book.ComputeStatistics();
            Console.WriteLine(stats.AverageGrade);
            Console.WriteLine(stats.HighestGrade);
            Console.WriteLine(stats.LowestGrade);
        }
    }
}