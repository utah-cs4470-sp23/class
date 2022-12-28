
CS 4470: Compilers, Spring 2023
===============================

*Instructor*: Pavel Panchekha, pavpan@cs.utah.edu
*Assistant*: Taylor Allred, taylor.c.allred@utah.edu
*Lecture*: MW 3:00–4:30 in WEB L122
*Appointments*: W 11:00–12:00 2174 MEB
*Office Hours*: 
*Discord*: 
*Github*: 

About the Course
----------------

The goal of this class is to teach you how a compiler works, including
all of the major components from front to back. By the end of this
course, you will be able to:

- understand concepts in lexical analysis, and implement a lexer
- understand how a programming language is represented by a grammar
- understand LL and LR parsing, and write an LL parser
- understand concepts in type checking, and implement a type checker
- understand target-independent program optimizations, and implement
  several relatively simple optimizations
- understand code generation, and implement generation of x86-64

This is a programming-intensive course: to understand compilers, you
will you'll write a compiler for a simple language called JPL. No
textbook is required, but if you find textbooks helpful while
studying, I hear good things about *Engineering a Compiler* by Cooper
and Torczon.

Classwork
---------

Class periods will be used for lecture and discussion. Often, we'll do
some live coding as well. You will be required to attend. Class time
will not be recorded; if you must miss class, please let the
instructor know and arrange with a classmate to share notes.

It’s really hard to learn by only listening: people mostly learn by
participating. We’ll have discussions during class time and online and
students should participate in these. During class, instructors will
call on students to answer questions and to present code from their
compiler implementations to the class.

There will also be a short Canvas quiz after every lecture. The
intention of these quizzes is to help you recall the major topics and
ideas that you are learning in class.

No one participates in a discussion if they will be shamed or
embarrassed for it. All students must uphold a positive, wecoming, and
supportive environment during discussions both in class and online.
Remember that every piece of code has to debugged before it works---in
class, you'll be participating in that debugging.

Homework
--------

You will have a weekly homework assignment. These will be cumulative,
implementing a compiler for a new language that the instructors have
created for this course. You’ll spend a lot of time testing your
implementation to make sure that is actually works as intended. The
instructors believe that writing compiler code is the most effective
way to learn about how compilers work.

Homework will be submitted and graded via Github. Assignments will be
due at 5pm on Fridays. However, we will automatically grant an
extension (without any grading penalty) until the start of the class
period on Monday. Because the assignments are cumulative, if you fall
behind, it's very difficult to catch up, so we will not accept
submissions that are later than that.

CS 4470 will follow the School of Computing’s policy, please read it
carefully. Basically, it's OK to discuss the assignment with other
students at a high level, but in general it is not OK to share code or
look at another student's code, or similar code found online. It is
the policy of the School of Computing that academic dishonesty results
in a failing grade for the course. The School of Computing has a
two-strikes policy, where two instances of academic dishonestly lead
to expulsion from the major.

Grading
-------

Grades will be assigned on a [standard 90/80/70/60 scale][scales], but
the instructors reserve the option to curve raw scores before
assigning grades if they judge that (for example, because assignments
were more difficult than intended) students’ numeric performance is
not representative of the grades they deserve.

[scales]: https://en.wikipedia.org/wiki/Academic_grading_in_the_United_States#Grade_conversion

Components of course grades are:

| 70% | Assignments |
| 20% | Attendance  |
| 10% | Quizzes     |

There will be no exams, final or otherwise.

Course Schedule
---------------

| Week | Topic                                                |
| 1    | Course intro, syllabus. Parts of a compiler. Lexing. |
| 2    | ASTs and Parsing                                     |
| 3    | Parsing II                                           |
| 4    | Symbol tables                                        |
| 5    | Type systems and type checking                       |
| 6    | Runtime systems                                      |
| 7    | Assembly and linking                                 |
| 8    | Spring break                                         |
| 9    | Optimization basics                                  |
| 10   | Static analysis                                      |
| 11   | Common optimizations                                 |
| 12   | Intermediate representations                         |
| 13   | Control flow graphs                                  |
| 14   | The memory hierarchy                                 |
| 15   | Vectorization                                        |
| 16   | Conclusion                                           |

Note: This schedule is aspirational---a guide for our course, not a
promise that will be kept no matter what. It will be updated and
changed as the course continues.

Other parts of the syllabus can also be changed by the instructor with
reasonable notice.
