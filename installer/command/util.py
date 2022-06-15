import sys
import subprocess


class COLOR:
    CLEAR = '\033[0m'
    BLACK = '\033[30m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'

def printc(color, contents):
    print(f"{color}{contents}{COLOR.CLEAR}")

class Utility:
    @staticmethod
    def execute_cmd(cmd_str, verbose=True):
        stdout_target = sys.stdout if verbose else subprocess.PIPE
        proc = subprocess.Popen(cmd_str, shell=True, stdout=stdout_target, stderr=stdout_target)
        out, err = proc.communicate()
        if proc.returncode == 0:
            return True
        else:
            return False

