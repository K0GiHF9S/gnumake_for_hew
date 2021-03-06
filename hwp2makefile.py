import sys
import os
from pathlib import Path, PureWindowsPath
import re

C_PREFIX = '.c'
CPP_PREFIX = '.cpp'
ASM_PREFIX = '.src'


def filter_parent_dir(data):
    return re.findall(
        '\[PROJECT_DETAILS\]\n"\w+" "(.*?)"', data, flags=re.MULTILINE)[0]


def filter_src_files(data, record_dir):
    project_files_area = re.findall(
        '\[PROJECT_FILES\]\n((?:.*\n)*?)\[', data, flags=re.MULTILINE)[0]
    project_files = re.findall(
        '^"(.*?)"', project_files_area, flags=re.MULTILINE)
    project_files = [str(PureWindowsPath(f).relative_to(
        record_dir)).replace('\\', '/') for f in project_files]

    c_project_files = [f for f in project_files if f.endswith(C_PREFIX)]
    cpp_project_files = [f for f in project_files if f.endswith(CPP_PREFIX)]
    asm_project_files = [f for f in project_files if f.endswith(ASM_PREFIX)]
    rule_text = 'C_SRC := ' + ' \\\n\t'.join(c_project_files) + '\n'
    rule_text += 'CXX_SRC := ' + ' \\\n\t'.join(cpp_project_files) + '\n'
    rule_text += 'ASM_SRC := ' + ' \\\n\t'.join(asm_project_files)
    return rule_text


def to_option_dict(data, config):
    option_area = re.findall(
        f'\[OPTIONS_{config}\]\n((?:.*\n)*?)\[', data, flags=re.MULTILINE)
    if len(option_area) != 1:
        print('Undefined config name.')
        sys.exit(1)
    option_area = option_area[0]
    option_datas = re.findall(
        '^.*\[S\|GBR\|.*\n', option_area, flags=re.MULTILINE)
    option_datas = [re.sub('\[S\|LISTPATH\|.*?\] ', '', d)
                    for d in option_datas]
    option_datas = [re.sub('\[S\|LANG\|.*?\] ', '', d) for d in option_datas]
    if len(set(option_datas)) != 1:
        print('Not supported option.')
        sys.exit(1)

    option_data = {k: [d.replace('^"', '').replace('$(PROJDIR)', '.').replace('\\', '/') for d in v.split('|')] for (k, v) in re.findall(
        '\[\w\|(\w+)\|([^\]]*)\]', option_datas[0])}

    link_option_data = re.findall(
        '^.*\[S\|START\|.*\n', option_area, flags=re.MULTILINE)
    link_option_data = {k: [d.replace('^"', '').replace('$(PROJDIR)', '.').replace('\\', '/') for d in v.split('|')] for (k, v) in re.findall(
        '\[\w\|(\w+)\|([^\]]*)\]', link_option_data[0])}
    for k, v in link_option_data.items():
        print(f'{k} {v}')
    return option_data, link_option_data


def filter_include_dirs(option_data):
    return 'INCLUDE := ' + ','.join(option_data.get('INCLUDE', ''))


def filter_defines(option_data):
    return 'DEFINE := ' + ','.join(option_data.get('DEFINE', ''))


def filter_sections(link_option_data):
    start = ','.join(link_option_data['START'])
    start = re.sub('\(([\dA-F]+)\)', r'/\1', start).replace('$', '$$')
    return f'START := {start}'


def hwp2rule(filename, config):
    with open(filename, 'r', encoding='cp932') as f:
        data = f.read()
    p_infile = Path(filename)
    p_outfile = p_infile.with_suffix(f'.mak.{config}').resolve()
    os.chdir(p_infile.parent)

    record_dir = filter_parent_dir(data)
    option_data, link_option_data = to_option_dict(data, config)

    d = filter_src_files(data, record_dir) + '\n'
    d += filter_include_dirs(option_data) + '\n'
    d += filter_defines(option_data) + '\n'
    d += filter_sections(link_option_data) + '\n'

    with open(p_outfile, 'w', encoding='utf8') as f:
        f.write(d)


if __name__ == '__main__':
    if len(sys.argv) < 3:
        sys.exit(1)
    hew_path = sys.argv[1]
    config = sys.argv[2]
    hwp2rule(hew_path, config)
