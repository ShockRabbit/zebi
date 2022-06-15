import sys
import subprocess
from config_manager import ConfigHelper
from util import Utility


def init_brew_config():
    brew_config_template = {
            'taps': [

            ],
            'casks': [

            ],
            'brews': [

            ]
    }
    synced_config = ConfigHelper.get_synced_config()
    if 'brew' not in synced_config.keys():
        synced_config['brew'] = brew_config_template.copy()

    installed_config = ConfigHelper.get_installed_config()
    if 'brew' not in installed_config.keys():
        installed_config['brew'] = brew_config_template.copy()

def add_item(path, item):
    synced = ConfigHelper.get_synced_item(path)
    synced.append(item)
    installed = ConfigHelper.get_installed_item(path)
    installed.append(item)
    ConfigHelper.save_synced_config()
    ConfigHelper.save_installed_config()

def remove_item(path, item):
    synced = ConfigHelper.get_synced_item(path)
    if item in synced:
        synced.remove(item)
    installed = ConfigHelper.get_installed_item(path)
    if item in installed:
        installed.remove(item)
    ConfigHelper.save_synced_config()
    ConfigHelper.save_installed_config()

def post_install(params):
    print(f'post_install : {params}')
    if '--cask' in params:
        print('cask')
        package = params[-1]
        if package.startswith('-'):
            return
        add_item('brew/casks', package)
    else:
        print('normal')
        package = params[-1]
        if package.startswith('-'):
            return
        add_item('brew/brews', package)

def post_uninstall(params):
    print(f'post_uninstall : {params}')
    if '--cask' in params:
        print('cask')
        package = params[-1]
        if package.startswith('-'):
            return
        remove_item('brew/casks', package)
    else:
        print('normal')
        package = params[-1]
        if package.startswith('-'):
            return
        remove_item('brew/brews', package)

def post_tap(params):
    print(f'post_tap : {params}')
    tap = params[-1]
    if tap.startswith('-'):
        return
    add_item('brew/taps', tap)

def post_untap(params):
    print(f'post_uptap : {params}')
    tap = params[-1]
    if tap.startswith('-'):
        return
    remove_item('brew/taps', tap)

# def execute_cmd(cmd_str, verbose=True):
#     stdout_target = sys.stdout if verbose else subprocess.PIPE
#     proc = subprocess.Popen(cmd_str, shell=True, stdout=stdout_target, stderr=stdout_target)
#     out, err = proc.communicate()
#     if proc.returncode == 0:
#         return True
#     else:
#         return False


post_callbacks = {
    'install': post_install,
    'uninstall': post_uninstall,
    'tap': post_tap,
    'untap': post_untap
}

command = sys.argv[1]
params = sys.argv[2:]

init_brew_config()

if '--ignore-config' in params:
    print('ignore config')
    params.remove('--ignore-config')
    argv = ['brew', command]
    argv.extend(params)
    subprocess.call(argv)
elif command in post_callbacks.keys():
    argv = ['brew', command]
    argv.extend(params)
    cmd_str = ' '.join(argv)
    result = Utility.execute_cmd(cmd_str)
    if result:
        post_callbacks[command](params)
else:
    argv = ['brew', command]
    argv.extend(params)
    subprocess.call(argv)
