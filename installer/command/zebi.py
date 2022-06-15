import sys
from config_manager import ConfigHelper
from util import Utility, COLOR, printc


def get_brew_diff():
    synced_config = ConfigHelper.get_synced_config()
    installed_config = ConfigHelper.get_installed_config()

    if 'brew' not in synced_config.keys():
        return None, None

    if 'brew' not in installed_config.keys():
        return synced_config['brew'], None

    install_targets = {
            'taps': [

            ],
            'casks': [

            ],
            'brews': [

            ]
    }
    remove_targets = install_targets.copy()

    def get_install_targets(key):
        result = []
        for item_synced in synced_config['brew'][key]:
            if item_synced not in installed_config['brew'][key]:
                result.append(item_synced)
        return result

    def get_remove_targets(key):
        result = []
        for item_installed in installed_config['brew'][key]:
            if item_installed not in synced_config['brew'][key]:
                result.append(item_installed)
        return result

    install_targets['taps'] = get_install_targets('taps')
    install_targets['casks'] = get_install_targets('casks')
    install_targets['brews'] = get_install_targets('brews')
    remove_targets['taps'] = get_remove_targets('taps')
    remove_targets['casks'] = get_remove_targets('casks')
    remove_targets['brews'] = get_remove_targets('brews')

    return install_targets, remove_targets

def add_to_installed(path, item):
    installed = ConfigHelper.get_installed_item(path)
    installed.append(item)
    ConfigHelper.save_installed_config()

def remove_from_installed(path, item):
    installed = ConfigHelper.get_installed_item(path)
    installed.remove(item)
    ConfigHelper.save_installed_config()

def brew_tap(tap):
    cmd_str = f'brew tap {tap}'
    result = Utility.execute_cmd(cmd_str)
    return result

def brew_cask_install(package):
    cmd_str = f'brew install --cask {package}'
    result = Utility.execute_cmd(cmd_str)
    return result

def brew_install(package):
    cmd_str = f'brew install {package}'
    result = Utility.execute_cmd(cmd_str)
    return result

def brew_untap(tap):
    cmd_str = f'brew untap {tap}'
    result = Utility.execute_cmd(cmd_str)
    return result

def brew_cask_uninstall(package):
    cmd_str = f'brew uninstall --cask {package}'
    result = Utility.execute_cmd(cmd_str)
    return result

def brew_uninstall(package):
    cmd_str = f'brew uninstall {package}'
    result = Utility.execute_cmd(cmd_str)
    return result


def sync(install_targets, remove_targets):
    printc(COLOR.GREEN, '===== sync start =====')
    install_fail_list = []
    remove_fail_list = []
    printc(COLOR.GREEN, '# installs')
    if install_targets is not None:
        for target in install_targets['taps']:
            result = brew_tap(target)
            if result:
                add_to_installed('brew/taps', target)
            else:
                install_fail_list.append(f'brew/taps/{target}')
        for target in install_targets['casks']:
            result = brew_cask_install(target)
            if result:
                add_to_installed('brew/casks', target)
            else:
                install_fail_list.append(f'brew/casks/{target}')
        for target in install_targets['brews']:
            result = brew_install(target)
            if result:
                add_to_installed('brew/brews', target)
            else:
                install_fail_list.append(f'brew/brews/{target}')
    printc(COLOR.GREEN, '# uninstalls')
    if remove_targets is not None:
        for target in remove_targets['taps']:
            result = brew_untap(target)
            if result:
                remove_from_installed('brew/taps', target)
            else:
                remove_fail_list.append(f'brew/taps/{target}')
        for target in remove_targets['casks']:
            result = brew_cask_uninstall(target)
            if result:
                remove_from_installed('brew/casks', target)
            else:
                remove_fail_list.append(f'brew/casks/{target}')
        for target in remove_targets['brews']:
            result = brew_uninstall(target)
            if result:
                remove_from_installed('brew/brews', target)
            else:
                remove_fail_list.append(f'brew/brews/{target}')
    
    if len(install_fail_list) > 0:
        printc(COLOR.RED, '# install fail list')
        for target in install_fail_list:
            print(f'- {target}')
    if len(remove_fail_list) > 0:
        printc(COLOR.RED, '# uninstall fail list')
        for target in remove_fail_list:
            print(f'- {target}')
    printc(COLOR.GREEN, '===== sync end =====')

def is_empty_target(target):
    return (len(target['taps']) + len(target['casks']) + len(target['brews'])) <= 0


command = sys.argv[1]
params = sys.argv[2:]

if command == 'sync':
    printc(COLOR.GREEN, '===== check diff =====')
    install_targets, remove_targets = get_brew_diff()
    if install_targets is None:
        print('already synced')
    elif is_empty_target(install_targets) and is_empty_target(remove_targets):
        print('already synced')
    else:
        sync(install_targets, remove_targets)

else:
    printc(COLOR.YELLOW, f'not supported command : {command}')
