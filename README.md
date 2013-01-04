# About ii.do

ii.do, pronounced I-do (as in "Do you solemnly swear to complete all tasks till death do us part?" :-), is a simple bash script which can be used to keep track of a todo list.

After being inspired by the simplicity of [Markdown syntax](http://daringfireball.net/projects/markdown/syntax) and [Todo.txt](http://todotxt.com/), a commandline todo script, I decided to write my own script that combined both aspects.

The result is a simple `todo.markdown` file which you can easily create in your home directory and edit using any text editor (though I recommend one which has syntax highlighting such as VIM).

# Getting Started

1) Create an empty todo.markdown file in your UNIX home directory or use my sample file.

2) When editing the file, use the following format.

```markdown
# Top level heading

* Task 1
* Task 2
* etc.

## Sub heading

* Sub Task 1
* Sub Task 2
* etc.

```

3) Mark a task as completed by preceding it with a 'x'

```
* x Task 1 is complete
```

4) Mark a task as important by preceding it with a '!'

```
* ! Task 1 is very important
```

5) Define a priority as either a letter or number in front of task

```
* (1) Do Task 1 first
* (2) Then do Task 2
```

6) Set a due date for a task by ending with "by mm/dd/yyyy"

```
* Task 1 by 12/31/2013

```

7) To view tasks from anywhere define an alias in your ~/.bash_profile or ~/.bashrc

```
alias t='~/Downloads/ii.do/ii.do'
```

8) To use a different todo file use the -f option with full path to the file.

```
alias t='~/Downloads/ii.do/ii.do -f ~/Dropbox/todo.md'
```

9) To quickly launch the editor (vi by default, else $EDITOR) and edit the todo file

```
t -e
```
10) Get a count of pending tasks

```
t -n
```

11) Change Shell prompt to always show number of pending taks

```
t -S "$PS1" >> ~/.bash_profile
```
For a complete set of options do `t-h`

# See Also

[My blog post with an embedded talk on ii.do](http://geekaholic.github.com/blog/2011/12/31/new-year-resolution-iido/)

# License

Copyright &copy; 2013 Buddhika Siddhisena

Licensed under the [GPL license v2](http://www.gnu.org/licenses/gpl-2.0.html)

