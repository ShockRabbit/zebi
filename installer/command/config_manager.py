import os
import json
import shutil


class ConfigManager:
    root = f'{os.getenv("HOME")}/.config/zebi'
    synced_path = f'{root}/synced_config.json'
    installed_path = f'{root}/installed_config.json'

    def __init__(self):
        self.synced_config = None
        self.installed_config = None

        os.makedirs(ConfigManager.root, exist_ok=True)
        is_exist_synced = os.path.isfile(ConfigManager.synced_path)
        is_exist_installed = os.path.isfile(ConfigManager.installed_path)
        if not is_exist_synced:
            if is_exist_installed:
                shutil.copyfile(ConfigManager.installed_path, ConfigManager.synced_path)
            else:
                print('all configs not exist')
                self.__create_default_configs()
                self.__save_configs()
        elif not is_exist_installed:
            print('sync')
        else:                       # all exist
            self.__load_configs()


    def __create_default_configs(self):
        config = {
            "order": [
                "pyenv",
                "rbenv",
                "git_organization",
                "git_clone",
                "mas",
                "brew",
                "unity3d",
                "android_sdk",
                "android_ndk",
                "sdkman",
                "mas",
                "downloader",
                "unzip"
            ]
        }
        self.synced_config = config.copy()
        self.installed_config = config.copy()

    def __save_configs(self):
        with open(ConfigManager.synced_path, 'w') as fp:
            json.dump(self.synced_config, fp, indent=4)
        with open(ConfigManager.installed_path, 'w') as fp:
            json.dump(self.installed_config, fp, indent=4)

    def __load_configs(self):
        with open(ConfigManager.synced_path) as data_file:
            self.synced_config = json.load(data_file)
        with open(ConfigManager.installed_path) as data_file:
            self.installed_config = json.load(data_file)

    def get_synced_item(self, json_path, with_create=True):
        elements = json_path.split('/')
        target = None
        first_element = elements[0]
        rest_elements = elements[1:]
        target = self.synced_config[first_element]
        for element in rest_elements:
            target = target[element]
        return target

    def get_installed_item(self, json_path):
        elements = json_path.split('/')
        target = None
        first_element = elements[0]
        rest_elements = elements[1:]
        target = self.installed_config[first_element]
        for element in rest_elements:
            target = target[element]
        return target

    def save_synced_config(self):
        with open(ConfigManager.synced_path, 'w') as fp:
            json.dump(self.synced_config, fp, indent=4)

    def save_installed_config(self):
        with open(ConfigManager.installed_path, 'w') as fp:
            json.dump(self.installed_config, fp, indent=4)



class ConfigHelper:
    core = ConfigManager()

    @staticmethod
    def get_synced_config():
        return ConfigHelper.core.synced_config

    @staticmethod
    def get_installed_config():
        return ConfigHelper.core.installed_config

    @staticmethod
    def get_synced_item(json_path):
        return ConfigHelper.core.get_synced_item(json_path)

    @staticmethod
    def get_installed_item(json_path):
        return ConfigHelper.core.get_installed_item(json_path)

    @staticmethod
    def save_synced_config():
        ConfigHelper.core.save_synced_config()

    @staticmethod
    def save_installed_config():
        ConfigHelper.core.save_installed_config()


    # @staticmethod
    # def set_synced_config(path):
    #     shutil.copyfile(path, ConfigManager.synced_path)

    # @staticmethod
    # def set_installed_config(path):
    #     shutil.copyfile(path, ConfigManager.installed_path)

    # @staticmethod
    # def add_installed_item(json_path, item):
    #     print(f'add installed item : {json_path}/{item}')
    #     with open(ConfigManager.synced_path) as data_file:
    #         data = json.load(data_file)
    #     elements = json_path.split('/')
    #     for element in elements:
    #         target = data[element]
    #     target.append(item)
    #     with open(ConfigManager.synced_path, 'w') as fp:
    #         json.dump(data, fp)
    #     with open(ConfigManager.installed_path, 'w') as fp:
    #         json.dump(data, fp)

    # @staticmethod
    # def remove_installed_item(json_path, item):
    #     print(f'remove installed item : {json_path}/{item}')
    #     with open(ConfigManager.synced_path) as data_file:
    #         data = json.load(data_file)
    #     elements = json_path.split('/')
    #     for element in elements:
    #         target = data[element]
    #     target.remove(item)
    #     with open(ConfigManager.synced_path, 'w') as fp:
    #         json.dump(data, fp)
    #     with open(ConfigManager.installed_path, 'w') as fp:
    #         json.dump(data, fp)

    # @staticmethod
    # def diff_synced_and_installed():
    #     print(f'diff')

    # def print_config(self):
    #     print(f'synced config path : {ConfigManager.synced_path}')
