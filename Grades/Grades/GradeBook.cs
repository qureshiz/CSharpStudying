using System.Collections.Generic;

namespace Grades
{
    class GradeBook
    {
        public GradeBook()
        {
            grades = new List<float>();
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
