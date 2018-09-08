using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Grades
{
    
    class GradeStatistics
    {

        public GradeStatistics()                // This is a constructor.  Tye ctor and press tab twice.
        {
            HighestGrade    = 0;                // Initialising HighestGrade to zero.  This is needed by the GradeBook class has a method for 
                                                // determining the Highest Grade.
            LowestGrade     = float.MaxValue;   // Again, see the GradeBook class.  Required for iteration in determining the lowest grade.
        }
        
         public float AverageGrade;
         public float HighestGrade;
         public float LowestGrade;
    }
}
