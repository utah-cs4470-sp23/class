
CS 4470: Compilers, Spring 2023
===============================

*Instructor*: Pavel Panchekha, pavpan@cs.utah.edu \
*Assistant*: Taylor Allred, taylor.c.allred@utah.edu \
*Lecture*: Mon/Wed 3:00–4:30 in WEB L122 \
*Appointments*: Pavel: https://shorturl.at/dzDJN; Taylor: https://calendar.app.google/WJaC7S5Nk29Gx8fy6 \
*Office Hours*: Thu 12:00–1:00 in MEB 3115 \
*Discord*: https://discord.gg/fHvWXgdFv2 \
*Github*: https://github.com/utah-cs4470-sp23/class

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
will you'll write a compiler for a simple language called JPL. Prepare
to spend a significant amount of time programming.

Materials
---------

This document is the syllabus.

The [JPL specification](spec.md) details JPL: its syntax, semantics,
and some simple implementation tips.

The [x86_64 Assembly Handbook](assembly.md) details the assembly code
you'll need to know to write your compiler. You don't need to read
this until we get to the relevant part of the course.

You'll find the assignments for this class linked above as they are
released.

These and any other materials developed in this class are always works
in progress. If you see typos, inaccuracies, or anything confusing,
let the instructors know (on Discord).

No textbook is required, but if you find textbooks helpful while
studying, I hear good things about *Engineering a Compiler* by Cooper
and Torczon.

Getting help
------------

If you found lecture confusing, don't understand a homework
assignment, or are stuck debugging some issue: get help. Think about
it: if you've been stuck for three hours on a problem, how likely is
the fourth hour to help? Getting help from others is an important part
of real-world programming and developing that skill now is important.

There are three ways to get help in this class.

You can always post on the class Discord channel, linked at the top of
this syllabus. There, you can get help from other students or the
instructors. This is a great place to get clarifications, coding help,
or quick sanity-checks of your solutions. Naturally, do not post
complete solutions to homework problems or copy huge chunks of code
there (see the academic misconduct policy below), but short snippets
are typically find.

You can also join office hours with TA Allred; the time and place is
given at the top of this syllabus. Office hours are a good way to
check that you're approaching the homework the right way, get a quick
code review, or have someone help you out debugging a problem. We
recommend you show up to office hours whether or not you're having
problems, and just work on the homework while there. That way, TA
Allred can answer any questions that show up, or you can help out
other students if they run into a problem you've seen. This will be
particularly helpful once we get to generating assembly code.

Finally, you can meet with Prof. Panchekha by appointment, at the time
and place given at the top of this syllabus. This meeting is a great
way to do an in-depth code review, clarify anything that's confusing
or that you didn't understand in class, or discuss any larger issues
you're having in the class. Prof. Panchekha may also reach out to you
and request you make an appointment. You're not in trouble---Prof.
Panchekha likely wants to discuss what the instructors can be doing to
help you in this class.

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
embarrassed for it. All students must uphold a positive, welcoming,
and supportive environment during discussions both in class and
online. Remember that every piece of code has to debugged before it
works---in class, you'll be participating in that debugging.

Homework
--------

You will have a weekly homework assignment. These will be cumulative,
implementing a compiler for a new language that the instructors have
created for this course. You’ll spend a lot of time testing your
implementation to make sure that is actually works as intended. The
instructors believe that writing compiler code is the most effective
way to learn about how compilers work.

Homework will be submitted and graded via Github. Assignments will be
due at midnight at the end of Fridays. However, we will automatically
grant a 48hr extension (without any grading penalty). Because the
assignments are cumulative, if you fall behind, it's very difficult to
catch up, so we will not accept submissions that are later than that.

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

| Weight | Component   |
|--------|-------------|
| 70%    | Assignments |
| 20%    | Attendance  |
| 10%    | Quizzes     |

There will be no exams, final or otherwise.

Additionally, a couple of students who prove particularly helpful to
others in class or online will get up to 5% extra credit at
instructors' discretion.

Course Schedule
---------------

| Week | Monday   | Topic                   | Off |
|------|----------|-------------------------|-----|
| 1    | 9 Jan    | Course intro and Lexing |     |
| 2    | 16 Jan   | ASTs                    | Mon |
| 3    | 23 Jan   | Parsing                 |     |
| 4    | 30 Jan   | Parsing II              |     |
| 5    | 6 Feb    | Symbol tables           |     |
| 6    | 13 Feb   | Type checking           |     |
| 7    | 20 Feb   | Assembly and linking    | Mon |
| 8    | 27 Feb   | Runtime systems         |     |
| 9    | 6 March  | Spring break            | All |
| 10   | 13 March | Code generation         |     |
| 11   | 20 March | IRs and SSA form        |     |
| 12   | 27 March | Optimization            |     |
| 13   | 3 April  | Dataflow                |     |
| 14   | 10 April | The memory hierarchy    | Mon |
| 15   | 17 April | Vectorization & layout  |     |
| 16   | 24 April | The future of compilers | Wed |

Note: This schedule is aspirational---a guide for our course, not a
promise that will be kept no matter what. It will be updated and
changed as the course continues.

Other parts of the syllabus can also be changed by the instructor with
reasonable notice.
