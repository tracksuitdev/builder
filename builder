#!/usr/bin/python
import os
import shutil
import stat
import argparse

"""
Program for building and installing other python programs. 
"""


def validate(project_root, executable):
    """
    Checks if folder is valid python project
    :param executable: name of the main project file
    :param project_root: path to project dir
    :return: true if specified folder has at least  one .py file or file named as root
    """
    print("Checking if {} is valid project root".format(project_root))
    for name in os.listdir(project_root):
        full_name = os.path.join(project_root, name)
        if is_python_file(full_name, executable):
            return True
    print("Project root {} is not valid python project".format(project_root))
    return False


def remove_old_exe(exe_dir):
    """
    Removes specified dir
    :param exe_dir: dir to remove
    """
    if os.path.exists(exe_dir):
        print("Removing {}".format(exe_dir))
        shutil.rmtree(exe_dir)


def make_executable(filename):
    """
    Make file executable, something like chmod +x
    :param filename: name of the file to make executable
    """
    print("Making {} executable".format(filename))
    st = os.stat(filename)
    os.chmod(filename, st.st_mode | stat.S_IEXEC)


def is_python_file(filename, executable):
    """
    Check if the file ends with .py extension or is executable
    :param filename: name of the file to test
    :param executable: main file in project that is being built
    """
    return os.path.isfile(filename) and (filename.endswith(".py") or filename == executable)


def copy_files(project_root, exe_root, executable):
    """
    Copies file and folder structure from project root to exe root recursively, copies only files that pass
    :func:is_is_python_file test, copies every visible folder  so we need to cleanup empty folders later
    :param project_root: source root folder
    :param exe_root: executable root folder
    :param executable: name of the main project file
    """
    print("Copying files from {} to {}".format(project_root, exe_root))
    os.makedirs(exe_root, exist_ok=True)
    for name in os.listdir(project_root):
        if name[0] == "." or name == "__pycache__":  # skip hidden folders
            continue
        full_name = os.path.join(project_root, name)
        if is_python_file(full_name, executable):
            shutil.copy2(full_name, exe_root)
        elif os.path.isdir(full_name):
            copy_files(full_name, os.path.join(exe_root, name), executable)


def append_to_bashrc(project_name, exe_dir):
    """
    Appends path export to .bashrc file, allows for executable that is being built to be called from anywhere in
    terminal.
    Text appended is:
    # {project_name} exe
    export PATH=$PATH:{exe_dir}
    :param project_name: name of the project
    :param exe_dir: directory holding executable files
    """
    print("Appending to path")
    path_text = "# {} exe\nexport PATH=$PATH:{}\n".format(project_name, exe_dir)
    bashrc = os.path.join("/home", "ivan", ".bashrc")
    append = False
    with open(bashrc) as file:
        text = file.read()
        if path_text not in text:
            append = True
        else:
            print("Already appended to path")

    if append:
        with open(bashrc, "a") as file:
            file.write(path_text)


def install(project_name, project_root, exe_root, executable):
    """
    Installs project
    :param project_name: name of the project
    :param project_root: root folder of project
    :param exe_root: executable files root folder
    :param executable: main file in project
    """
    if validate(project_root, executable):
        remove_old_exe(exe_root)
        print("Installing {} from {} to {}".format(project_name, project_root, exe_root))
        copy_files(project_root, exe_root, executable)
        make_executable(executable)
        append_to_bashrc(project_name, exe_root)
        cleanup(exe_root)


def cleanup(exe_root):
    """
    Removes empty folders in exe root recursively
    :param exe_root: executable files root folder
    """
    print("Removing empty folders from {}".format(exe_root))
    for dir_name in os.listdir(exe_root):
        dir_name = os.path.join(exe_root, dir_name)
        if os.path.isdir(dir_name):
            cleanup(dir_name)
    if not os.listdir(exe_root):
        os.rmdir(exe_root)


def main():
    """
    Builds your project, keep in mind that exe_dir will be deleted recursively and then populated with required source
    files.

    Program can be called with 3 arguments, project, executable and exe_dir.

    Project arg is path to the root of project files (source files) default is current folder.
    Executable arg is path to main executable file default is file named as project folder in project folder
    (eg. project/project).
    Exe_dir is path to directory that will hold executable files default is ~/.{project_name}-exe
    """
    parser = argparse.ArgumentParser(prog="builder", description="Simple script for making python projects executable "
                                                                 "from terminal.")
    project = os.path.abspath("")
    project_name = os.path.basename(project)
    executable = os.path.join(project, project_name)
    exe_dir = os.path.expanduser("~/." + project_name + "-exe")
    parser.add_argument("project", nargs="*", default=project, help="path to the root of project files (source "
                                                                    "files), default is current folder")
    parser.add_argument("executable", nargs="*", default=executable, help="path to main executable file, default is "
                                                                          "file named as project folder in project "
                                                                          "folder (eg. project/project)")
    parser.add_argument("exe_dir", nargs="*", default=exe_dir, help="path to directory that will hold executable "
                                                                    "files, default is ~/.{project_name}-exe (before "
                                                                    "copying any files, script will first recursively "
                                                                    "delete this folder, so be careful when providing "
                                                                    "this arg)")

    args = parser.parse_args()
    install(project_name, args.project, args.exe_dir, args.executable)


if __name__ == '__main__':
    main()
