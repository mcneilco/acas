# Process configs
import os 
from dotenv import load_dotenv
from pathlib import Path
import pandas as pd
import json
import argparse


dotenv_path = Path('./conf/docker/acas/environment/.env')
load_dotenv(dotenv_path=dotenv_path)

dotenv_path = Path('.env')
load_dotenv(dotenv_path=dotenv_path)

def get_text_file_lines(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()
    return lines

def write_lines_to_file(file_path, lines):
    with open(file_path, 'w') as f:
        for line in lines:
            f.write(line)

def process_property_lines(lines, example_names=None):
    out_lines = []
    name_maps = {}
    next_line_part_of = None
    for l, line in enumerate(lines):
        # Look for lines that actually have a setting defined
        if not line.strip().startswith("#") and line.strip() != "":
            # If the line has an equals sign, it's a setting so we need to process it
            line_parts = line.split("=")
            if len(line_parts) > 1 or next_line_part_of:
                # Check to see if this is part of the last property read
                if next_line_part_of is not None:
                    setting = line
                    original_setting = next_line_part_of
                    if not setting.strip().endswith("\\"):
                        next_line_part_of = None     
                        setting = setting+"'"
                    name_maps[original_setting]["setting"] = name_maps[original_setting]["setting"]+setting      
                    os.environ[name_maps[original_setting]['env_name']] = name_maps[original_setting]["setting"]     
                    out_line = ""
                else:
                    setting = line_parts[1]
                    original_name = line_parts[0].strip()
                    env_name = original_name.replace(".","_").upper()
                    if setting.strip().endswith("\\"):
                        next_line_part_of = original_name
                        setting = "'" + setting
                    else:
                        setting = setting.replace('\"', '\\"')
                    name_maps[original_name] = {
                        "env_name": env_name,
                        "setting": setting,
                        "interpolated_value": os.environ.get(env_name)
                    }
                    if example_names is not None and original_name in example_names:
                        continue
                    else:
                        out_line = f"{original_name}=${{env.{env_name}}}\n"
            else:
                out_line = ""
        else:
            if not line.strip().startswith("#") and not line == "\n" and line.strip() != "\n":
                out_line = ""
            else:
                out_line = line
        out_lines.append(out_line)
    return(out_lines, name_maps)

def process_configs(args):
    out_lines = []
    name_maps = {}
    [example_lines, example_name_maps] = process_property_lines(open("conf/config.properties.example").readlines())
    if args.properties:
        lines = args.properties.readlines()

        # lines = get_text_file_lines("conf/config.properties.example")
        [out_lines, name_maps] = process_property_lines(lines, list(example_name_maps.keys()))

    if args.cmpdreg:
        # out_lines.append("\n# CmpReg settings\n")
        cmpdreg_json = json.load(args.cmpdreg)
        df = pd.json_normalize(cmpdreg_json, sep='.').add_prefix('client.cmpdreg.')
        cmpdreg_configs = df.to_dict(orient='records')[0]
        for key in cmpdreg_configs:
            env_name = key.replace('.','_').upper()
            setting = cmpdreg_configs[key]
            if isinstance (setting, bool):
                setting = json.dumps(setting)

            name_maps[key] = {
                            "env_name": env_name,
                            "setting": str(setting)+"\n"
            }
            # out_line = f"{key}=${{env.{env_name}}}\n"
            # out_lines.append(out_line)


    env_file_lines = []
    env_file_lines.append("ACAS_TAG=release-1.13.6\n\n")
    for original_setting in name_maps:
        for replace_setting in name_maps:
            # If the setting inherits from another setting we need to replace the inherited settings with the
            # actual setting becuase .env files don't support inheritance
            name_maps[original_setting]['setting'] = os.path.expandvars(os.path.expandvars(name_maps[original_setting]['setting'].replace("env.","").replace(replace_setting, name_maps[replace_setting]['env_name'])))

        # Format the environment variable line
        example_value = None
        if original_setting in example_name_maps:
            example_value = example_name_maps[original_setting]['interpolated_value']
        original_value = name_maps[original_setting]['setting']

        compare_value = original_value.rstrip("\n")
        if compare_value != example_value:
            env_line = f"# MAPS TO: {original_setting}\n"
            env_line = env_line+f"{name_maps[original_setting]['env_name']}={name_maps[original_setting]['setting']}\n"
            env_file_lines.append(env_line)
        else:
            print(f"Skipping {original_setting} because it's value '{compare_value}' equals the default value '{example_value}'")

    env_file_name = "new-environment.env"
    write_lines_to_file(env_file_name, env_file_lines)
    print(f"Wrote environment variables to {env_file_name}")
    properties_file_name = "new-config.properties"
    write_lines_to_file(properties_file_name, out_lines)
    print(f"Wrote properties to {properties_file_name}")


argparser = argparse.ArgumentParser(description='Process configs')

# Get properties file path argument
argparser.add_argument('--properties', type=argparse.FileType('r', encoding='UTF-8'), 
                      help='Path to acas properties file typically found here: zzz-config.properties')
                      
# Get cmpreg json file path
argparser.add_argument('--cmpdreg', type=argparse.FileType('r', encoding='UTF-8'), 
                      help='Path to cmpdreg configuration.json typically found here: modules/CmpdReg/src/client/custom/configuration.json')
                      
args = argparser.parse_args()

if __name__ == "__main__":
    process_configs(args)