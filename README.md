# Linux py builder
Simple script for making python projects executable from terminal. 

Basically copies source files from project directory to "executable" directory and then makes main project file executable and appends it to PATH.

## Usage
1. Clone this repo
2. Execute `python builder` inside repo root, this makes builder script executable from anywhere inside terminal
3. Navigate to your python project root and execute `python builder`, this will only work if main file is named as project root

## How does it work ?

Script takes 3 arguments:
- `project` - path to the root of project files (source files), default is current folder
- `executable` - path to main executable file, default is file named as project folder in project folder (eg. project/project)
- `exe_dir` - path to directory that will hold executable files, default is `~/.{project_name}-exe` (before copying any files, script will first 
recursively delete this folder, so be careful when providing this arg)

When executed, script recreates directory structure from `project` inside `exe_dir` and copies all python files to their corresponding locations 
(so `{project}/my-package/util.py` will be copied to `{exe_dir}/my-package/util.py`). 

Script then makes `{executable}` executable (basically chmod +x).

Then it appends text to .bashrc file that looks like this:
```
# {project} exe
export PATH=$PATH:~/.{exe_dir}-exe
```

Finnaly, script deletes all empty directories from `exe_dir`

