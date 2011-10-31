# About ii.do

ii.do, pronounced eye-do is a simple bash to-do script which can be used to keep track of a todo list.

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

6) To view tasks from anywhere define an alias in your ~/.bash_profile

```
alias t='~/Downloads/ii.do/iido'
```

7) To use a different todo file use the -f option with full path to the file.

```
alias t='~/Downloads/ii.do/iido -f ~/Documents/todo.md'
```

8) To quickly launch the editor (vi by default, else $EDITOR) and edit the todo file

```
t -e
```

# License

Copyright &copy; 2011 Buddhika Siddhisena

Licensed under the GPL license v2

