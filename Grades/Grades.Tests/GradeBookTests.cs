using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Grades.Tests
{
    [TestClass]
    public class GradeBookTests

    {
        [TestMethod]
        public void ComputeHightestGrade()
        {
            GradeBook book = new GradeBook();
            book.AddGrade(80);
            book.AddGrade(90);
            GradeStatistics result = book.ComputeStatistics();
            Assert.AreEqual(90, result.HighestGrade);

        }

        [TestMethod]
        public void ComputeLowestGrade()
        {
            GradeBook book = new GradeBook();
            book.AddGrade(80);
            book.AddGrade(90);
            GradeStatistics result = book.ComputeStatistics();
            Assert.AreEqual(80, result.LowestGrade);

        }

        [TestMethod]
        public void ComputeAverageGrade()
        {
            GradeBook book = new GradeBook();
            book.AddGrade(91);
            book.AddGrade(89.5f);
            book.AddGrade(75);
            GradeStatistics result = book.ComputeStatistics();

            Assert.AreEqual(85.166666, result.AverageGrade,0.01);

        }

    }
}
