using System.Collections.Generic;
using System;

namespace Grades
{
    class GradeBook
    {
        public GradeBook()
        {
            grades = new List<float>();
        }
        public GradeStatistics ComputeStatistics() // So, ComputeStatistics is returning a type GradeStatistics.
        {
            GradeStatistics stats = new GradeStatistics();
            float sum = 0;
            // As part
            
            foreach (float grade in grades)
            {
                sum += grade; // Add each grade value to sum.

                // Highest grade.  For each iteration, check if the current grade value is greater then stats.HighestGrade
                stats.HighestGrade  = Math.Max(stats.HighestGrade, grade);
                stats.LowestGrade   = Math.Min(stats.LowestGrade, grade);

            }
               
            stats.AverageGrade      = sum / grades.Count; // Once outside of the grades iteration, set the average grade property.

            return stats;

        }
        public void AddGrade(float grade)
        {
            grades.Add(grade);
        }

        private List<float> grades; // list is not to be available outside of the class.  Without the private keyword, the list would still be private but using the private keyword makes it clear.
        public static float MinimumGrade = 0; // A statis member of a class can be invoked without the new keyword.
        public static float MaximumGrade = 100; //Interestinglyu, this is reference in the class, not the instanct of the class i.e. GradeBook.MinimumGrade not book.MinimumGrade which doesn't exist.
    }
}
